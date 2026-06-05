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
    const [users]: any = await pool.query(`
      SELECT 
        id, name, email, role, gender, birth_year, height, weight, 
        avatar_url, created_at, updated_at,
        (SELECT COUNT(*) FROM habits WHERE user_id = users.id) as habit_count,
        (SELECT COUNT(*) FROM community_posts WHERE user_id = users.id) as post_count
      FROM users 
      ORDER BY created_at DESC
    `);

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

// ================= POST MANAGEMENT =================

// Get all posts with user info
router.get("/posts", authMiddleware, adminMiddleware, async (req: any, res: Response) => {
  try {
    const [posts]: any = await pool.query(`
      SELECT 
        p.id, p.content, p.image_url, p.hashtags, p.created_at,
        u.name as user_name, u.email as user_email,
        (SELECT COUNT(*) FROM community_post_likes WHERE post_id = p.id) as like_count,
        (SELECT COUNT(*) FROM community_comments WHERE post_id = p.id) as comment_count
      FROM community_posts p
      JOIN users u ON p.user_id = u.id
      ORDER BY p.created_at DESC
    `);

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
    // Get user growth data (last 30 days)
    const [userGrowth]: any = await pool.query(`
      SELECT 
        DATE(created_at) as date,
        COUNT(*) as count
      FROM users 
      WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
      GROUP BY DATE(created_at)
      ORDER BY date ASC
    `);

    // Get post growth data (last 30 days)
    const [postGrowth]: any = await pool.query(`
      SELECT 
        DATE(created_at) as date,
        COUNT(*) as count
      FROM community_posts 
      WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
      GROUP BY DATE(created_at)
      ORDER BY date ASC
    `);

    res.json({
      userGrowth,
      postGrowth,
    });
  } catch (error) {
    console.error("Get growth data error:", error);
    res.status(500).json({ message: "Server error" });
  }
});

export default router;