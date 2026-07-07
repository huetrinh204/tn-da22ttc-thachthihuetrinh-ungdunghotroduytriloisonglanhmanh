import { Router, Request, Response } from "express";
import pool from "../config/db";
import jwt from "jsonwebtoken";
import dotenv from "dotenv";
import sgMail from "@sendgrid/mail";

dotenv.config();

sgMail.setApiKey(process.env.SENDGRID_API_KEY || "");
const SENDGRID_FROM = process.env.SENDGRID_FROM_EMAIL || process.env.GMAIL_USER || "";

const router = Router();
const JWT_SECRET = process.env.JWT_SECRET || "secret_key";

// Ensure language column exists (for email localization)
pool.query("ALTER TABLE users ADD COLUMN language VARCHAR(10) DEFAULT 'vi'").catch(() => {});

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
        p.id, p.content, p.image_url, p.hashtags, p.created_at, p.user_id, p.is_warned, p.edited_after_warn,
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

    const [rows]: any = await pool.query(query, params);
    const posts = rows.map((row: any) => ({
      ...row,
      is_warned: Boolean(row.is_warned),
      edited_after_warn: Boolean(row.edited_after_warn),
    }));

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

    // Clean up related warning notifications
    await pool.query(
      "DELETE FROM user_notifications WHERE JSON_EXTRACT(payload, '$.post_id') = ?",
      [postId]
    );

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
      "SELECT p.*, u.name, u.email, u.language FROM community_posts p JOIN users u ON p.user_id = u.id WHERE p.id = ?",
      [postId]
    );

    if (posts.length === 0) {
      return res.status(404).json({ message: "Post not found" });
    }

    const post = posts[0];

    // Mark post as warned
    await pool.query(
      "UPDATE community_posts SET is_warned = 1 WHERE id = ?",
      [postId]
    );

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
        JSON.stringify({ post_id: postId, reason: reason, reported_by: req.user.id }),
        0
      ]
    );

    // Send email notification via SendGrid
    const isVietnamese = (post.language || 'vi') === 'vi';

    const mailOptions = {
      to: post.email,
      subject: isVietnamese ? 'Cảnh báo vi phạm - Viora' : 'Content Warning - Viora',
      html: isVietnamese ? `
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
      ` : `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #ff9800;">⚠️ Content Violation Warning</h2>
          <p>Hello <strong>${post.name}</strong>,</p>
          <p>Your post has violated Viora's community guidelines.</p>
          <div style="background-color: #fff3e0; padding: 15px; border-left: 4px solid #ff9800; margin: 20px 0;">
            <p style="margin: 0;"><strong>Reason:</strong> ${reason}</p>
          </div>
          <div style="background-color: #f5f5f5; padding: 15px; margin: 20px 0;">
            <p style="margin: 0;"><strong>Post content:</strong></p>
            <p style="margin: 10px 0 0 0;">${post.content || '(No text content)'}</p>
          </div>
          <p>Please adhere to community guidelines to avoid account suspension.</p>
          <hr style="margin: 30px 0; border: none; border-top: 1px solid #e0e0e0;">
          <p style="color: #666; font-size: 14px;">Best regards,<br>The Viora Team</p>
        </div>
      `
    };

    let emailSent = false;
    try {
      await sgMail.send({ ...mailOptions, from: SENDGRID_FROM });
      emailSent = true;
    } catch (emailError) {
      console.error("Email send error:", emailError);
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

// ================= UNWARN POST =================
router.put("/posts/:postId/unwarn", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const { postId } = req.params;

    const [posts]: any = await pool.query(
      "SELECT user_id FROM community_posts WHERE id = ?",
      [postId]
    );
    if (!posts.length) return res.status(404).json({ message: "Post not found" });

    await pool.query("UPDATE community_posts SET is_warned = 0, edited_after_warn = 0 WHERE id = ?", [postId]);

    // Mark old warning notifications as read so they no longer count as unread
    await pool.query(
      "UPDATE user_notifications SET is_read = 1 WHERE type = 'warning' AND JSON_EXTRACT(payload, '$.post_id') = ?",
      [postId]
    );

    // Notify user that their post has been unflagged
    await pool.query(
      `INSERT INTO user_notifications (user_id, type, title, body, emoji, payload, is_read, created_at)
       VALUES (?, ?, ?, ?, ?, ?, 0, NOW())`,
      [
        posts[0].user_id,
        'warning_cleared',
        'Đã gỡ cảnh báo bài viết',
        'Bài viết của bạn đã được xem xét và gỡ cảnh báo. Bài viết đã hiển thị lại trên cộng đồng.',
        '✅',
        JSON.stringify({ post_id: postId }),
      ]
    );

    res.json({ message: "Post unwarned successfully" });
  } catch (error) {
    console.error("Unwarn post error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// ================= APPROVE POST (after user edit) =================
router.put("/posts/:postId/approve", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const { postId } = req.params;

    const [posts]: any = await pool.query(
      "SELECT user_id, edited_after_warn FROM community_posts WHERE id = ?",
      [postId]
    );
    if (!posts.length) return res.status(404).json({ message: "Post not found" });

    await pool.query(
      "UPDATE community_posts SET is_warned = 0, edited_after_warn = 0 WHERE id = ?",
      [postId]
    );

    // Mark old warning notifications as read so they no longer count as unread
    await pool.query(
      "UPDATE user_notifications SET is_read = 1 WHERE type = 'warning' AND JSON_EXTRACT(payload, '$.post_id') = ?",
      [postId]
    );

    // Notify user that their edited post has been approved
    await pool.query(
      `INSERT INTO user_notifications (user_id, type, title, body, emoji, payload, is_read, created_at)
       VALUES (?, ?, ?, ?, ?, ?, 0, NOW())`,
      [
        posts[0].user_id,
        'warning_cleared',
        'Bài viết đã được phê duyệt',
        'Bài viết sau khi chỉnh sửa của bạn đã được quản trị viên phê duyệt và hiển thị lại trên cộng đồng.',
        '✅',
        JSON.stringify({ post_id: postId }),
      ]
    );

    res.json({ message: "Post approved successfully" });
  } catch (error) {
    console.error("Approve post error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// ================= REJECT POST (delete after user edit fails review) =================
router.delete("/posts/:postId/reject", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const { postId } = req.params;
    const { reason } = req.body;

    if (!reason || String(reason).trim() === "") {
      return res.status(400).json({ message: "Reason is required" });
    }

    const [posts]: any = await pool.query(
      "SELECT p.user_id, u.name, u.email, u.language FROM community_posts p JOIN users u ON p.user_id = u.id WHERE p.id = ?",
      [postId]
    );
    if (!posts.length) return res.status(404).json({ message: "Post not found" });

    // Delete post
    await pool.query("DELETE FROM community_posts WHERE id = ?", [postId]);

    // Clean up old warning notifications
    await pool.query(
      "DELETE FROM user_notifications WHERE JSON_EXTRACT(payload, '$.post_id') = ?",
      [postId]
    );

    // Notify user that their post has been rejected and deleted
    await pool.query(
      `INSERT INTO user_notifications (user_id, type, title, body, emoji, payload, is_read, created_at)
       VALUES (?, ?, ?, ?, ?, ?, 0, NOW())`,
      [
        posts[0].user_id,
        'warning',
        'Bài viết đã bị xóa vì vi phạm',
        `Bài viết của bạn đã bị xóa vì: ${String(reason).trim()}`,
        '⚠️',
        JSON.stringify({ post_id: postId, reason: String(reason).trim() }),
      ]
    );

    res.json({ message: "Post rejected and deleted" });
  } catch (error) {
    console.error("Reject post error:", error);
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
    const [habitStats]: any = await pool.query("SELECT COUNT(*) as total_habits FROM habits WHERE is_active = 1");
    const [activeUsers]: any = await pool.query("SELECT COUNT(DISTINCT user_id) as active_users FROM habit_logs WHERE log_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)");

    res.json({
      totalUsers: userStats[0].total_users,
      totalPosts: postStats[0].total_posts,
      totalComments: commentStats[0].total_comments,
      todayUsers: todayUsers[0].today_users,
      todayPosts: todayPosts[0].today_posts,
      totalHabits: habitStats[0].total_habits,
      activeUsers: activeUsers[0].active_users,
    });
  } catch (error) {
    console.error("Get stats error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// Get growth data for charts
router.get("/growth", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const period = (req.query.period as string) || 'monthly'; // 'weekly' or 'monthly'
    const days = period === 'weekly' ? 7 : 30;
    
    // Get daily user counts
    const [userGrowth]: any = await pool.query(`
      SELECT 
        DATE(created_at) as date,
        COUNT(*) as daily_count
      FROM users
      WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL ? DAY)
      GROUP BY DATE(created_at)
      ORDER BY DATE(created_at) ASC
    `, [days]);

    // Get daily post counts
    const [postGrowth]: any = await pool.query(`
      SELECT 
        DATE(created_at) as date,
        COUNT(*) as daily_count
      FROM community_posts
      WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL ? DAY)
      GROUP BY DATE(created_at)
      ORDER BY DATE(created_at) ASC
    `, [days]);

    // If no data in period, get all-time data
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
        LIMIT ?
      `, [days]);
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
        LIMIT ?
      `, [days]);
      finalPostGrowth = allTimePosts;
    }

    // Helper function to fill missing dates
    const fillMissingDates = (data: any[], daysCount: number = days) => {
      const result: any[] = [];
      const today = new Date();
      const dataMap = new Map();
      
      // Create map of existing data
      data.forEach((row: any) => {
        const dateStr = new Date(row.date).toISOString().split('T')[0];
        dataMap.set(dateStr, row.daily_count);
      });
      
      // Fill all dates in range
      for (let i = daysCount - 1; i >= 0; i--) {
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
    const filledUserGrowth = fillMissingDates(finalUserGrowth, days);
    const filledPostGrowth = fillMissingDates(finalPostGrowth, days);

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

// ================= HABIT MANAGEMENT =================

// Get all habits with user info
router.get("/habits", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const { search, category } = req.query;
    let sql = `
      SELECT 
        h.id, h.user_id, h.name, h.category, h.icon, h.color, h.frequency,
        h.target_count, h.current_streak, h.longest_streak, h.is_active, h.created_at,
        u.name as user_name, u.email as user_email, u.avatar_url as user_avatar
      FROM habits h
      JOIN users u ON h.user_id = u.id
    `;
    const params: any[] = [];
    const conditions: string[] = [];

    if (search) {
      conditions.push("(h.name LIKE ? OR u.name LIKE ?)");
      params.push(`%${search}%`, `%${search}%`);
    }
    if (category) {
      conditions.push("h.category = ?");
      params.push(category);
    }

    if (conditions.length > 0) {
      sql += " WHERE " + conditions.join(" AND ");
    }

    sql += " ORDER BY h.created_at DESC LIMIT 200";

    const [habits]: any = await pool.query(sql, params);
    res.json({ habits });
  } catch (error) {
    console.error("Get admin habits error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// Get habit category statistics (for dashboard)
router.get("/habits/categories", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const [categories]: any = await pool.query(`
      SELECT 
        h.category,
        COUNT(*) as total_habits,
        COUNT(DISTINCT h.user_id) as total_users,
        SUM(h.current_streak) as total_streak
      FROM habits h
      WHERE h.is_active = 1
      GROUP BY h.category
      ORDER BY total_habits DESC
    `);

    const [total]: any = await pool.query(
      "SELECT COUNT(*) as total FROM habits WHERE is_active = 1"
    );

    res.json({ categories, totalHabits: total[0].total });
  } catch (error) {
    console.error("Get habit categories error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// Get habit trends (completion data over time for dashboard)
router.get("/habits/trends", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const period = (req.query.period as string) || 'weekly';
    const days = period === 'weekly' ? 7 : 30;

    // Daily completion counts
    const [dailyCompletions]: any = await pool.query(`
      SELECT 
        DATE(hl.log_date) as date,
        COUNT(*) as total_completions,
        COUNT(DISTINCT hl.user_id) as active_users
      FROM habit_logs hl
      WHERE hl.log_date >= DATE_SUB(CURDATE(), INTERVAL ? DAY)
      GROUP BY DATE(hl.log_date)
      ORDER BY DATE(hl.log_date) ASC
    `, [days]);

    // Category breakdown for the period
    const [categoryBreakdown]: any = await pool.query(`
      SELECT 
        h.category,
        COUNT(hl.id) as completions
      FROM habit_logs hl
      JOIN habits h ON hl.habit_id = h.id
      WHERE hl.log_date >= DATE_SUB(CURDATE(), INTERVAL ? DAY)
      GROUP BY h.category
      ORDER BY completions DESC
    `, [days]);

    // Top habits (most completed)
    const [topHabits]: any = await pool.query(`
      SELECT 
        h.name, h.category, h.icon, h.color,
        COUNT(hl.id) as completions,
        COUNT(DISTINCT hl.user_id) as users_count
      FROM habit_logs hl
      JOIN habits h ON hl.habit_id = h.id
      WHERE hl.log_date >= DATE_SUB(CURDATE(), INTERVAL ? DAY)
      GROUP BY hl.habit_id
      ORDER BY completions DESC
      LIMIT 10
    `, [days]);

    // Fill missing dates
    const fillDates = (data: any[], daysCount: number) => {
      const result: any[] = [];
      const today = new Date();
      const dataMap = new Map();
      data.forEach((row: any) => {
        const dateStr = new Date(row.date).toISOString().split('T')[0];
        dataMap.set(dateStr, row);
      });
      for (let i = daysCount - 1; i >= 0; i--) {
        const date = new Date(today);
        date.setDate(date.getDate() - i);
        const dateStr = date.toISOString().split('T')[0];
        const existing = dataMap.get(dateStr);
        result.push({
          date: dateStr,
          total_completions: existing ? Number(existing.total_completions) : 0,
          active_users: existing ? Number(existing.active_users) : 0,
        });
      }
      return result;
    };

    res.json({
      dailyCompletions: fillDates(dailyCompletions, days),
      categoryBreakdown,
      topHabits,
      period,
    });
  } catch (error) {
    console.error("Get habit trends error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// ================= PLANT MANAGEMENT =================

// Get all plants with user info (one plant per user)
router.get("/plants", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const [rows]: any = await pool.query(`
      SELECT 
        p.id, p.user_id, p.plant_type, p.level, p.experience, p.last_watered,
        u.name as user_name, u.email as user_email, u.avatar_url as user_avatar
      FROM plants p
      JOIN users u ON p.user_id = u.id
      WHERE p.id IN (
        SELECT MIN(p2.id) FROM plants p2
        WHERE p2.user_id = p.user_id
      )
      ORDER BY p.experience DESC, p.level DESC
    `);

    const thresholds = [0, 5, 15, 30, 50, 75, 105, 140, 180, 225, 275, 330, 390, 455, 525];
    const plants = rows.map((p: any) => {
      let calculatedLevel = 1;
      for (let i = thresholds.length - 1; i >= 0; i--) {
        if (p.experience >= thresholds[i]) { calculatedLevel = i + 1; break; }
      }
      p.level = calculatedLevel;
      return p;
    });

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

    // First get user by their primary key (id)
    const [userRows]: any = await pool.query(
      "SELECT id, name, email, avatar_url, created_at FROM users WHERE id = ?",
      [userId]
    );
    if (userRows.length === 0) {
      return res.status(404).json({ message: "User not found", plant: null, history: [] });
    }
    const user = userRows[0];

    // Then find plant by matching user.id with plant.user_id
    let [plantRows]: any = await pool.query(
      "SELECT * FROM plants WHERE user_id = ? ORDER BY id ASC LIMIT 1",
      [user.id]
    );

    // If no plant, create one based on habit_logs data
    if (plantRows.length === 0) {
      const [expRows]: any = await pool.query(
        `SELECT COUNT(*) as total_exp,
                MAX(hl.log_date) as last_date
         FROM habit_logs hl
         JOIN habits h ON hl.habit_id = h.id AND h.is_active = 1
         WHERE hl.user_id = ? AND hl.is_completed = 1`,
        [user.id]
      );
      const totalExp = Number(expRows[0]?.total_exp) || 0;
      let lastDate: string | null = null;
      if (expRows[0]?.last_date) {
        const d = expRows[0].last_date;
        lastDate = d instanceof Date ? d.toISOString().split('T')[0] : String(d).split('T')[0];
      }

      const thresholds = [0, 5, 15, 30, 50, 75, 105, 140, 180, 225, 275, 330, 390, 455, 525];
      let level = 1;
      for (let i = thresholds.length - 1; i >= 0; i--) {
        if (totalExp >= thresholds[i]) { level = i + 1; break; }
      }

      await pool.query(
        `INSERT INTO plants (user_id, plant_type, level, experience, health, last_watered, days_without_checkin)
         VALUES (?, 'bamboo', ?, ?, 100, ?, 0)`,
        [user.id, level, totalExp, lastDate]
      );

      // Re-query after insert
      [plantRows] = await pool.query(
        "SELECT * FROM plants WHERE user_id = ? ORDER BY id ASC LIMIT 1",
        [user.id]
      );
    }

    if (plantRows.length === 0) {
      console.error(`[Admin] Failed to create plant for userId=${userId}`);
      return res.status(500).json({ message: "Failed to create plant", plant: null, history: [] });
    }

    let plant = plantRows[0];
    // Override level to be calculated from experience (not stale DB value)
    const thresholds = [0, 5, 15, 30, 50, 75, 105, 140, 180, 225, 275, 330, 390, 455, 525];
    let calcLevel = 1;
    for (let i = thresholds.length - 1; i >= 0; i--) {
      if (plant.experience >= thresholds[i]) { calcLevel = i + 1; break; }
    }
    plant.level = calcLevel;

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
      const dateStr = typeof row.date === 'string' ? row.date.split('T')[0] : String(row.date).split('T')[0];
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

    const updates: string[] = [];
    const values: any[] = [];

    if (is_enabled !== undefined) {
      updates.push('is_enabled = ?');
      values.push(is_enabled ? 1 : 0);
    }
    if (morning_time !== undefined) {
      updates.push('morning_time = ?');
      values.push(morning_time);
    }
    if (evening_time !== undefined) {
      updates.push('evening_time = ?');
      values.push(evening_time);
    }
    if (send_morning !== undefined) {
      updates.push('send_morning = ?');
      values.push(send_morning ? 1 : 0);
    }
    if (send_evening !== undefined) {
      updates.push('send_evening = ?');
      values.push(send_evening ? 1 : 0);
    }

    if (updates.length > 0) {
      await pool.query(
        `UPDATE auto_reminder_settings SET ${updates.join(', ')} WHERE id = 1`,
        values
      );
    }

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

// ================= REPORT MANAGEMENT =================

// Get all pending reports (user_notifications type='post_reported')
router.get("/reports", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const [rows]: any = await pool.query(
      `SELECT n.id, n.user_id AS admin_id, n.type, n.title, n.body, n.emoji, n.payload, n.is_read, n.created_at,
              u.name AS admin_name
       FROM user_notifications n
       JOIN users u ON n.user_id = u.id
       WHERE n.type = 'post_reported'
       ORDER BY n.created_at DESC`
    );

    const reports = await Promise.all(rows.map(async (row: any) => {
      const payload = typeof row.payload === 'string' ? JSON.parse(row.payload) : row.payload;
      let postInfo = null;
      let reporterInfo = null;

      if (payload?.post_id) {
        const [posts]: any = await pool.query(
          "SELECT id, content, image_url, created_at, user_id FROM community_posts WHERE id = ?",
          [payload.post_id]
        );
        if (posts.length > 0) {
          const [authors]: any = await pool.query(
            "SELECT id, name, email, avatar_url FROM users WHERE id = ?",
            [posts[0].user_id]
          );
          postInfo = {
            id: posts[0].id,
            content: posts[0].content,
            image_url: posts[0].image_url,
            created_at: posts[0].created_at,
            author: authors.length > 0 ? { id: authors[0].id, name: authors[0].name, email: authors[0].email, avatar_url: authors[0].avatar_url } : null,
          };
        }
      }

      if (payload?.reporter_id) {
        const [reps]: any = await pool.query(
          "SELECT id, name, email, avatar_url FROM users WHERE id = ?",
          [payload.reporter_id]
        );
        if (reps.length > 0) {
          reporterInfo = { id: reps[0].id, name: reps[0].name, email: reps[0].email, avatar_url: reps[0].avatar_url };
        }
      }

      return {
        id: row.id,
        payload,
        post: postInfo,
        reporter: reporterInfo,
        created_at: row.created_at,
      };
    }));

    // Filter only pending
    const pending = reports.filter((r: any) => r.payload?.status === 'pending');

    res.json({ reports: pending });
  } catch (error) {
    console.error("Get reports error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// Handle a report (warn or dismiss)
router.put("/reports/:notifId/handle", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const { notifId } = req.params;
    const { action, warnReason } = req.body; // 'warn' or 'dismiss'

    if (!action || !['warn', 'dismiss'].includes(action)) {
      return res.status(400).json({ message: "Action must be 'warn' or 'dismiss'" });
    }

    // Get the report notification
    const [notifs]: any = await pool.query(
      "SELECT * FROM user_notifications WHERE id = ? AND type = 'post_reported'",
      [notifId]
    );
    if (notifs.length === 0) {
      return res.status(404).json({ message: "Report not found" });
    }

    const notif = notifs[0];
    const payload = typeof notif.payload === 'string' ? JSON.parse(notif.payload) : notif.payload;

    if (action === 'warn') {
      if (!warnReason) {
        return res.status(400).json({ message: "Warn reason is required" });
      }

      // Use existing warn flow: mark post as warned
      const postId = payload.post_id;
      const [posts]: any = await pool.query(
        "SELECT p.*, u.name, u.email, u.language FROM community_posts p JOIN users u ON p.user_id = u.id WHERE p.id = ?",
        [postId]
      );

      if (posts.length > 0) {
        const post = posts[0];

        await pool.query(
          "UPDATE community_posts SET is_warned = 1 WHERE id = ?",
          [postId]
        );

        // Notify post author
        await pool.query(
          `INSERT INTO user_notifications (user_id, type, title, body, emoji, payload, is_read, created_at)
           VALUES (?, ?, ?, ?, ?, ?, 0, NOW())`,
          [
            post.user_id,
            'warning',
            'Cảnh báo vi phạm nội dung',
            `Bài viết của bạn đã bị báo cáo và vi phạm quy định cộng đồng: ${warnReason}`,
            '⚠️',
            JSON.stringify({ post_id: postId, reason: warnReason, reported_by: req.user.id }),
          ]
        );
      }

      // Update report status to warned
      payload.status = 'warned';
      await pool.query(
        "UPDATE user_notifications SET payload = ? WHERE id = ?",
        [JSON.stringify(payload), notifId]
      );

      // Send email warning to post author
      if (posts.length > 0) {
        const post = posts[0];
        const isVietnamese = (post.language || 'vi') === 'vi';
        try {
          await sgMail.send({
            from: SENDGRID_FROM,
            to: post.email,
            subject: isVietnamese ? 'Cảnh báo vi phạm - Viora' : 'Content Warning - Viora',
            html: isVietnamese ? `
              <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <h2 style="color: #ff9800;">⚠️ Cảnh báo vi phạm nội dung</h2>
                <p>Xin chào <strong>${post.name}</strong>,</p>
                <p>Bài viết của bạn đã vi phạm quy định cộng đồng Viora.</p>
                <div style="background-color: #fff3e0; padding: 15px; border-left: 4px solid #ff9800; margin: 20px 0;">
                  <p style="margin: 0;"><strong>Lý do:</strong> ${warnReason}</p>
                </div>
                <div style="background-color: #f5f5f5; padding: 15px; margin: 20px 0;">
                  <p style="margin: 0;"><strong>Nội dung bài viết:</strong></p>
                  <p style="margin: 10px 0 0 0;">${post.content || '(Không có nội dung)'}</p>
                </div>
                <p>Vui lòng tuân thủ các quy định cộng đồng để tránh bị khóa tài khoản.</p>
                <p style="color: #666; font-size: 14px;">Trân trọng,<br>Đội ngũ Viora</p>
              </div>
            ` : `
              <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <h2 style="color: #ff9800;">⚠️ Content Violation Warning</h2>
                <p>Hello <strong>${post.name}</strong>,</p>
                <p>Your post has violated Viora's community guidelines.</p>
                <div style="background-color: #fff3e0; padding: 15px; border-left: 4px solid #ff9800; margin: 20px 0;">
                  <p style="margin: 0;"><strong>Reason:</strong> ${warnReason}</p>
                </div>
                <p>Please adhere to community guidelines to avoid account suspension.</p>
                <p style="color: #666; font-size: 14px;">Best regards,<br>The Viora Team</p>
              </div>
            `
          });
          console.log(`[Admin] Warning email sent to ${post.email}`);
        } catch (emailErr) {
          console.error("[Admin] Warning email failed:", emailErr);
        }
      }

      res.json({ message: "Post warned successfully" });
    } else {
      // Dismiss: just update status
      payload.status = 'dismissed';
      await pool.query(
        "UPDATE user_notifications SET payload = ? WHERE id = ?",
        [JSON.stringify(payload), notifId]
      );

      res.json({ message: "Report dismissed" });
    }
  } catch (error) {
    console.error("Handle report error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

export default router;