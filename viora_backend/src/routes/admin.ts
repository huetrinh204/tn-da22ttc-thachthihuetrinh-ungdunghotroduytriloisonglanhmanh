import { Router, Request, Response } from "express";
import pool from "../config/db";
import jwt from "jsonwebtoken";
import dotenv from "dotenv";

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

export default router;