import { Router, Request, Response } from "express";
import pool from "../config/db";
import jwt from "jsonwebtoken";
import dotenv from "dotenv";
import nodemailer from "nodemailer";

dotenv.config();

const router = Router();
const JWT_SECRET = process.env.JWT_SECRET || "secret_key";

// Auth middleware
function authMiddleware(req: any, res: Response, next: () => void) {
  const authHeader = req.headers.authorization;
  if (!authHeader) return res.status(401).json({ message: "Unauthorized" });

  const token = authHeader.split(" ")[1];
  try {
    const decoded = jwt.verify(token, JWT_SECRET) as { id: number; email?: string };
    req.user = decoded;
    next();
  } catch {
    return res.status(401).json({ message: "Invalid token" });
  }
}

// Admin middleware - check if user has admin role
const adminMiddleware = async (req: any, res: Response, next: any) => {
  try {
    const userId = req.user.id;
    const [rows]: any = await pool.query(
      "SELECT role FROM users WHERE id = ?",
      [userId]
    );
    
    if (rows.length === 0 || rows[0].role !== 'admin') {
      return res.status(403).json({ message: "Access denied. Admin only." });
    }
    
    next();
  } catch (error) {
    console.error("Admin middleware error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// ================= USER MANAGEMENT =================

// Get all users
router.get("/users", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const { search } = req.query;
    
    let query = `
      SELECT 
        id, name, email, role, gender, birth_year, height, weight, 
        avatar_url, created_at, goals,
        (SELECT COUNT(*) FROM habits WHERE user_id = users.id) as habit_count,
        (SELECT COUNT(*) FROM community_posts WHERE user_id = users.id) as post_count
      FROM users 
    `;
    
    const params: any[] = [];
    
    if (search) {
      query += ` WHERE name LIKE ? OR email LIKE ?`;
      params.push(`%${search}%`, `%${search}%`);
    }
    
    query += ` ORDER BY created_at DESC`;
    
    const [users]: any = await pool.query(query, params);

    res.json({ users });
  } catch (error) {
    console.error("Get users error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// Update user role
router.put("/users/:userId/role", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const { userId } = req.params;
    const { role } = req.body;

    if (!['user', 'admin'].includes(role)) {
      return res.status(400).json({ message: "Invalid role. Must be 'user' or 'admin'" });
    }

    await pool.query(
      "UPDATE users SET role = ? WHERE id = ?",
      [role, userId]
    );

    res.json({ message: "User role updated successfully" });
  } catch (error) {
    console.error("Update user role error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// Create new user (admin only)
router.post("/users", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const { name, email, password, role } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({ message: "Name, email, and password are required" });
    }

    // Check if email already exists
    const [existing]: any = await pool.query(
      "SELECT id FROM users WHERE email = ?",
      [email]
    );

    if (existing.length > 0) {
      return res.status(400).json({ message: "Email already exists" });
    }

    // Hash password
    const bcrypt = require('bcrypt');
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user
    const [result]: any = await pool.query(
      "INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)",
      [name, email, hashedPassword, role || 'user']
    );

    res.json({ 
      message: "User created successfully",
      userId: result.insertId
    });
  } catch (error) {
    console.error("Create user error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// Delete user
router.delete("/users/:userId", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const { userId } = req.params;

    // Don't allow deleting yourself
    if (userId === req.user.id.toString()) {
      return res.status(400).json({ message: "Cannot delete yourself" });
    }

    await pool.query("DELETE FROM users WHERE id = ?", [userId]);
    res.json({ message: "User deleted successfully" });
  } catch (error) {
    console.error("Delete user error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// Delete multiple users
router.post("/users/bulk-delete", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const { userIds } = req.body;

    if (!userIds || !Array.isArray(userIds) || userIds.length === 0) {
      return res.status(400).json({ message: "User IDs array is required" });
    }

    // Filter out current admin's ID
    const idsToDelete = userIds.filter((id: any) => id !== req.user.id);

    if (idsToDelete.length === 0) {
      return res.status(400).json({ message: "No valid users to delete" });
    }

    // Delete users
    const placeholders = idsToDelete.map(() => '?').join(',');
    await pool.query(`DELETE FROM users WHERE id IN (${placeholders})`, idsToDelete);

    res.json({ 
      message: "Users deleted successfully",
      deleted: idsToDelete.length
    });
  } catch (error) {
    console.error("Bulk delete users error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// ================= POST MANAGEMENT =================

// Get all posts with user info
router.get("/posts", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const { search, sort } = req.query;
    
    let query = `
      SELECT 
        p.id, p.content, p.image_url, p.hashtags, p.created_at, p.user_id,
        u.name as user_name, u.email as user_email, u.avatar_url as user_avatar,
        (SELECT COUNT(*) FROM community_post_likes WHERE post_id = p.id) as like_count,
        (SELECT COUNT(*) FROM community_comments WHERE post_id = p.id) as comment_count
      FROM community_posts p
      JOIN users u ON p.user_id = u.id
    `;
    
    const params: any[] = [];
    
    // Search filter
    if (search) {
      query += ` WHERE p.content LIKE ? OR u.name LIKE ?`;
      params.push(`%${search}%`, `%${search}%`);
    }
    
    // Sort order
    switch (sort) {
      case 'oldest':
        query += ` ORDER BY p.created_at ASC`;
        break;
      case 'trending':
        query += ` ORDER BY like_count DESC, comment_count DESC, p.created_at DESC`;
        break;
      case 'latest':
      default:
        query += ` ORDER BY p.created_at DESC`;
        break;
    }

    const [posts]: any = await pool.query(query, params);

    res.json({ posts });
  } catch (error) {
    console.error("Get admin posts error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// Delete post
router.delete("/posts/:postId", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const { postId } = req.params;

    await pool.query("DELETE FROM community_posts WHERE id = ?", [postId]);
    res.json({ message: "Post deleted successfully" });
  } catch (error) {
    console.error("Delete post error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// Report post violation (admin warning)
router.post("/posts/:postId/report", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const { postId } = req.params;
    const { reason } = req.body;

    if (!reason) {
      return res.status(400).json({ message: "Reason is required" });
    }

    // Get post and user info
    const [posts]: any = await pool.query(
      "SELECT p.*, u.name, u.email FROM community_posts p JOIN users u ON p.user_id = u.id WHERE p.id = ?",
      [postId]
    );

    if (posts.length === 0) {
      return res.status(404).json({ message: "Post not found" });
    }

    const post = posts[0];

    // Create in-app notification using user_notifications table
    await pool.query(
      `INSERT INTO user_notifications (user_id, type, title, body, emoji, payload, is_read, created_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, NOW())`,
      [
        post.user_id,
        'warning',
        'Cảnh báo vi phạm nội dung',
        `Bài viết của bạn vi phạm quy định cộng đồng: ${reason}`,
        '⚠️',
        JSON.stringify({ post_id: postId, reason: reason }),
        0
      ]
    );

    // Send email notification
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.GMAIL_USER,
        pass: process.env.GMAIL_APP_PASSWORD
      }
    });

    const mailOptions = {
      from: process.env.GMAIL_USER,
      to: post.email,
      subject: 'Cảnh báo vi phạm - Viora',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #ff9800;">⚠️ Cảnh báo vi phạm nội dung</h2>
          <p>Xin chào <strong>${post.name}</strong>,</p>
          <p>Bài viết của bạn đã vi phạm quy định cộng đồng Viora.</p>
          <div style="background-color: #fff3e0; padding: 15px; border-left: 4px solid #ff9800; margin: 20px 0;">
            <p style="margin: 0;"><strong>Lý do:</strong> ${reason}</p>
          </div>
          <div style="background-color: #f5f5f5; padding: 15px; margin: 20px 0;">
            <p style="margin: 0;"><strong>Nội dung bài viết:</strong></p>
            <p style="margin: 10px 0 0 0;">${post.content || '(Không có nội dung văn bản)'}</p>
          </div>
          <p>Vui lòng tuân thủ các quy định cộng đồng để tránh bị khóa tài khoản.</p>
          <hr style="margin: 30px 0; border: none; border-top: 1px solid #e0e0e0;">
          <p style="color: #666; font-size: 14px;">Trân trọng,<br>Đội ngũ Viora</p>
        </div>
      `
    };

    let emailSent = false;
    try {
      await transporter.sendMail(mailOptions);
      emailSent = true;
    } catch (emailError) {
      console.error("Email send error:", emailError);
      // Continue even if email fails
    }

    res.json({ 
      message: "Warning sent successfully",
      notification_sent: true,
      email_sent: emailSent
    });
  } catch (error) {
    console.error("Report post error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// ================= COMMENT MANAGEMENT =================

// Get all comments with user and post info
router.get("/comments", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const [comments]: any = await pool.query(`
      SELECT 
        c.id, c.content, c.created_at,
        u.name as user_name, u.email as user_email,
        p.id as post_id, p.content as post_content
      FROM community_comments c
      JOIN users u ON c.user_id = u.id
      JOIN community_posts p ON c.post_id = p.id
      ORDER BY c.created_at DESC
    `);

    res.json({ comments });
  } catch (error) {
    console.error("Get admin comments error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// Delete comment
router.delete("/comments/:commentId", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const { commentId } = req.params;

    await pool.query("DELETE FROM community_comments WHERE id = ?", [commentId]);
    res.json({ message: "Comment deleted successfully" });
  } catch (error) {
    console.error("Delete comment error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// ================= STATISTICS =================

// Get dashboard stats
router.get("/stats", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const [userStats]: any = await pool.query("SELECT COUNT(*) as total_users FROM users");
    const [postStats]: any = await pool.query("SELECT COUNT(*) as total_posts FROM community_posts");
    const [commentStats]: any = await pool.query("SELECT COUNT(*) as total_comments FROM community_comments");
    const [todayUsers]: any = await pool.query("SELECT COUNT(*) as today_users FROM users WHERE DATE(created_at) = CURDATE()");
    const [todayPosts]: any = await pool.query("SELECT COUNT(*) as today_posts FROM community_posts WHERE DATE(created_at) = CURDATE()");

    res.json({
      totalUsers: userStats[0].total_users,
      totalPosts: postStats[0].total_posts,
      totalComments: commentStats[0].total_comments,
      todayUsers: todayUsers[0].today_users,
      todayPosts: todayPosts[0].today_posts,
    });
  } catch (error) {
    console.error("Get stats error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// Get growth data for charts
router.get("/growth", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    // Get daily user counts for last 30 days
    const [userGrowth]: any = await pool.query(`
      SELECT 
        DATE(created_at) as date,
        COUNT(*) as daily_count
      FROM users
      WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
      GROUP BY DATE(created_at)
      ORDER BY DATE(created_at) ASC
    `);

    // Get daily post counts for last 30 days
    const [postGrowth]: any = await pool.query(`
      SELECT 
        DATE(created_at) as date,
        COUNT(*) as daily_count
      FROM community_posts
      WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
      GROUP BY DATE(created_at)
      ORDER BY DATE(created_at) ASC
    `);

    // If no data in last 30 days, get all-time data
    let finalUserGrowth = userGrowth;
    let finalPostGrowth = postGrowth;
    
    if (userGrowth.length === 0) {
      const [allTimeUsers]: any = await pool.query(`
        SELECT 
          DATE(created_at) as date,
          COUNT(*) as daily_count
        FROM users
        GROUP BY DATE(created_at)
        ORDER BY DATE(created_at) ASC
        LIMIT 30
      `);
      finalUserGrowth = allTimeUsers;
    }
    
    if (postGrowth.length === 0) {
      const [allTimePosts]: any = await pool.query(`
        SELECT 
          DATE(created_at) as date,
          COUNT(*) as daily_count
        FROM community_posts
        GROUP BY DATE(created_at)
        ORDER BY DATE(created_at) ASC
        LIMIT 30
      `);
      finalPostGrowth = allTimePosts;
    }

    // Helper function to fill missing dates
    const fillMissingDates = (data: any[], days: number = 30) => {
      const result: any[] = [];
      const today = new Date();
      const dataMap = new Map();
      
      // Create map of existing data
      data.forEach((row: any) => {
        const dateStr = new Date(row.date).toISOString().split('T')[0];
        dataMap.set(dateStr, row.daily_count);
      });
      
      // Fill all dates in range
      for (let i = days - 1; i >= 0; i--) {
        const date = new Date(today);
        date.setDate(date.getDate() - i);
        const dateStr = date.toISOString().split('T')[0];
        
        result.push({
          date: dateStr,
          daily_count: dataMap.get(dateStr) || 0
        });
      }
      
      return result;
    };

    // Fill missing dates for both datasets
    const filledUserGrowth = fillMissingDates(finalUserGrowth);
    const filledPostGrowth = fillMissingDates(finalPostGrowth);

    // Calculate cumulative counts in JavaScript
    let cumulativeUserCount = 0;
    const formattedUserGrowth = filledUserGrowth.map((row: any) => {
      cumulativeUserCount += row.daily_count;
      return {
        date: row.date,
        count: cumulativeUserCount,
      };
    });

    let cumulativePostCount = 0;
    const formattedPostGrowth = filledPostGrowth.map((row: any) => {
      cumulativePostCount += row.daily_count;
      return {
        date: row.date,
        count: cumulativePostCount,
      };
    });

    res.json({
      userGrowth: formattedUserGrowth,
      postGrowth: formattedPostGrowth,
    });
  } catch (error) {
    console.error("Get growth data error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// ================= PLANT MANAGEMENT =================

// Get all plants with user info
router.get("/plants", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const [plants]: any = await pool.query(`
      SELECT 
        p.id, p.user_id, p.plant_type, p.level, p.experience, p.last_watered,
        u.name as user_name, u.email as user_email, u.avatar_url as user_avatar
      FROM plants p
      JOIN users u ON p.user_id = u.id
      ORDER BY p.experience DESC, p.level DESC
    `);

    res.json({ plants });
  } catch (error) {
    console.error("Get admin plants error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// Get plant history (experience gain events)
router.get("/plants/:userId/history", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const { userId } = req.params;

    // Get plant info
    const [plants]: any = await pool.query(
      "SELECT * FROM plants WHERE user_id = ?",
      [userId]
    );

    if (plants.length === 0) {
      return res.json({ plant: null, history: [], user: null, stats: null });
    }

    const plant = plants[0];

    // Get user info
    const [users]: any = await pool.query(
      "SELECT id, name, email, avatar_url, created_at FROM users WHERE id = ?",
      [userId]
    );
    const user = users.length > 0 ? users[0] : null;

    // Get current streak
    const [streaks]: any = await pool.query(
      "SELECT current_streak, longest_streak FROM streaks WHERE user_id = ?",
      [userId]
    );
    const streak = streaks.length > 0 ? streaks[0] : { current_streak: 0, longest_streak: 0 };

    // Get total habits completed
    const [habitCount]: any = await pool.query(
      "SELECT COUNT(DISTINCT DATE(log_date)) as days_completed, COUNT(*) as total_habits FROM habit_logs WHERE user_id = ?",
      [userId]
    );
    const stats = habitCount.length > 0 ? habitCount[0] : { days_completed: 0, total_habits: 0 };

    // Get habit completion history (which gives experience)
    const [history]: any = await pool.query(`
      SELECT 
        hl.log_date,
        hl.habit_id,
        h.name as habit_name,
        h.icon as habit_icon,
        DATE(hl.log_date) as date
      FROM habit_logs hl
      JOIN habits h ON hl.habit_id = h.id
      WHERE hl.user_id = ?
      ORDER BY hl.log_date DESC
      LIMIT 100
    `, [userId]);

    // Group by date and count habits completed
    const historyMap = new Map();
    for (const row of history) {
      const dateStr = row.date.toISOString().split('T')[0];
      if (!historyMap.has(dateStr)) {
        historyMap.set(dateStr, {
          date: dateStr,
          habits_completed: 0,
          exp_gained: 0,
          habits: []
        });
      }
      const entry = historyMap.get(dateStr);
      entry.habits_completed += 1;
      entry.exp_gained += 1; // 1 exp per habit completion
      entry.habits.push({
        name: row.habit_name,
        icon: row.habit_icon
      });
    }

    const formattedHistory = Array.from(historyMap.values());

    res.json({ 
      plant,
      user,
      streak: {
        current: streak.current_streak || 0,
        longest: streak.longest_streak || 0
      },
      stats: {
        days_completed: stats.days_completed || 0,
        total_habits: stats.total_habits || 0
      },
      history: formattedHistory
    });
  } catch (error) {
    console.error("Get plant history error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// ================= AUTO REMINDER MANAGEMENT =================

// Get auto reminder settings
router.get("/auto-reminder/settings", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const [settings]: any = await pool.query(
      "SELECT * FROM auto_reminder_settings WHERE id = 1"
    );

    if (settings.length === 0) {
      // Create default settings if not exists
      await pool.query(
        "INSERT INTO auto_reminder_settings (id, is_enabled, morning_time, evening_time) VALUES (1, 0, '08:00:00', '20:00:00')"
      );
      return res.json({
        is_enabled: false,
        morning_time: '08:00:00',
        evening_time: '20:00:00',
        send_morning: true,
        send_evening: true
      });
    }

    res.json(settings[0]);
  } catch (error) {
    console.error("Get auto reminder settings error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// Update auto reminder settings
router.put("/auto-reminder/settings", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const { is_enabled, morning_time, evening_time, send_morning, send_evening } = req.body;

    await pool.query(
      `UPDATE auto_reminder_settings 
       SET is_enabled = ?, morning_time = ?, evening_time = ?, send_morning = ?, send_evening = ?
       WHERE id = 1`,
      [is_enabled ? 1 : 0, morning_time, evening_time, send_morning ? 1 : 0, send_evening ? 1 : 0]
    );

    res.json({ message: "Settings updated successfully" });
  } catch (error) {
    console.error("Update auto reminder settings error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// Get all reminder messages
router.get("/auto-reminder/messages", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const [messages]: any = await pool.query(
      "SELECT * FROM auto_reminder_messages ORDER BY created_at DESC"
    );

    res.json({ messages });
  } catch (error) {
    console.error("Get reminder messages error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// Add reminder message
router.post("/auto-reminder/messages", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const { message } = req.body;

    if (!message || message.trim().length === 0) {
      return res.status(400).json({ message: "Message is required" });
    }

    const [result]: any = await pool.query(
      "INSERT INTO auto_reminder_messages (message, is_active) VALUES (?, 1)",
      [message.trim()]
    );

    res.json({ 
      message: "Reminder message added successfully",
      id: result.insertId
    });
  } catch (error) {
    console.error("Add reminder message error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// Update reminder message
router.put("/auto-reminder/messages/:id", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const { id } = req.params;
    const { message, is_active } = req.body;

    await pool.query(
      "UPDATE auto_reminder_messages SET message = ?, is_active = ? WHERE id = ?",
      [message, is_active ? 1 : 0, id]
    );

    res.json({ message: "Reminder message updated successfully" });
  } catch (error) {
    console.error("Update reminder message error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// Delete reminder message
router.delete("/auto-reminder/messages/:id", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const { id } = req.params;

    await pool.query("DELETE FROM auto_reminder_messages WHERE id = ?", [id]);

    res.json({ message: "Reminder message deleted successfully" });
  } catch (error) {
    console.error("Delete reminder message error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// ================= APP SETTINGS =================

// Get app settings
router.get("/app-settings", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const [settings]: any = await pool.query(
      "SELECT * FROM app_settings WHERE setting_key IN ('app_name', 'app_logo_url')"
    );

    const settingsObj: any = {};
    settings.forEach((row: any) => {
      settingsObj[row.setting_key] = row.setting_value;
    });

    res.json(settingsObj);
  } catch (error) {
    console.error("Get app settings error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// Update app name
router.put("/app-settings/name", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const { appName } = req.body;

    if (!appName || appName.trim().length === 0) {
      return res.status(400).json({ message: "App name is required" });
    }

    await pool.query(
      `INSERT INTO app_settings (setting_key, setting_value) 
       VALUES ('app_name', ?) 
       ON DUPLICATE KEY UPDATE setting_value = ?`,
      [appName.trim(), appName.trim()]
    );

    res.json({ message: "App name updated successfully" });
  } catch (error) {
    console.error("Update app name error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// Update app logo
router.put("/app-settings/logo", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const { logoUrl } = req.body;

    await pool.query(
      `INSERT INTO app_settings (setting_key, setting_value) 
       VALUES ('app_logo_url', ?) 
       ON DUPLICATE KEY UPDATE setting_value = ?`,
      [logoUrl || null, logoUrl || null]
    );

    res.json({ message: "App logo updated successfully" });
  } catch (error) {
    console.error("Update app logo error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

export default router;