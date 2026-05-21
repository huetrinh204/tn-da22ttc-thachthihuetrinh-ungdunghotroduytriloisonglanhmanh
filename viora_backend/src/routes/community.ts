import { Router, Request, Response } from "express";
import pool from "../config/db";
import jwt from "jsonwebtoken";
import dotenv from "dotenv";
import multer from "multer";
import path from "path";
import fs from "fs";

dotenv.config();

const router = Router();
const JWT_SECRET = process.env.JWT_SECRET || "secret_key";
const PUBLIC_BASE_URL = process.env.PUBLIC_BASE_URL || "http://localhost:3000";

const uploadsDir = path.join(__dirname, "../../uploads");
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, uploadsDir),
  filename: (_req, file, cb) => {
    const ext = path.extname(file.originalname) || ".jpg";
    cb(null, `${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    if (!file.mimetype.startsWith("image/")) {
      cb(new Error("Only image files allowed"));
      return;
    }
    cb(null, true);
  },
});

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

function resolveImageUrl(imageUrl: string | null | undefined): string | null {
  if (!imageUrl) return null;
  if (imageUrl.startsWith("http://") || imageUrl.startsWith("https://")) {
    return imageUrl;
  }
  const base = PUBLIC_BASE_URL.replace(/\/$/, "");
  return imageUrl.startsWith("/") ? `${base}${imageUrl}` : `${base}/${imageUrl}`;
}

function parseHashtags(raw: unknown): string[] {
  if (!raw) return [];
  if (Array.isArray(raw)) return raw.map(String);
  if (typeof raw === "string") {
    try {
      const parsed = JSON.parse(raw);
      return Array.isArray(parsed) ? parsed.map(String) : [];
    } catch {
      return [];
    }
  }
  return [];
}

function mapPostRow(row: any, currentUserId: number) {
  return {
    id: String(row.id),
    user_id: String(row.user_id),
    user_name: row.user_name,
    user_avatar: row.user_avatar ?? null,
    content: row.content,
    image_url: resolveImageUrl(row.image_url),
    hashtags: parseHashtags(row.hashtags),
    like_count: Number(row.like_count) || 0,
    comment_count: Number(row.comment_count) || 0,
    is_liked: Boolean(row.is_liked),
    created_at: row.created_at,
    challenge_name: row.challenge_name ?? null,
    days_streak: row.days_streak != null ? Number(row.days_streak) : null,
  };
}

function mapCommentRow(row: any) {
  return {
    id: String(row.id),
    post_id: String(row.post_id),
    user_id: String(row.user_id),
    user_name: row.user_name,
    user_avatar: row.user_avatar ?? null,
    content: row.content,
    like_count: Number(row.like_count) || 0,
    is_liked: Boolean(row.is_liked),
    created_at: row.created_at,
  };
}

const POST_SELECT = `
  SELECT
    p.id,
    p.user_id,
    u.name AS user_name,
    p.content,
    p.image_url,
    p.hashtags,
    p.challenge_name,
    p.days_streak,
    p.created_at,
    (SELECT COUNT(*) FROM community_post_likes pl WHERE pl.post_id = p.id) AS like_count,
    (SELECT COUNT(*) FROM community_comments cc WHERE cc.post_id = p.id) AS comment_count,
    EXISTS(
      SELECT 1 FROM community_post_likes pl2
      WHERE pl2.post_id = p.id AND pl2.user_id = ?
    ) AS is_liked
  FROM community_posts p
  JOIN users u ON u.id = p.user_id
`;

async function fetchPostById(postId: number, userId: number) {
  const [rows]: any = await pool.query(`${POST_SELECT} WHERE p.id = ?`, [userId, postId]);
  if (!rows.length) return null;
  return mapPostRow(rows[0], userId);
}

// ================= GET POSTS =================
router.get("/posts", authMiddleware, async (req: any, res: Response) => {
  const type = (req.query.type as string) || "trending";
  const page = Math.max(1, parseInt(String(req.query.page || "1"), 10) || 1);
  const limit = Math.min(50, Math.max(1, parseInt(String(req.query.limit || "20"), 10) || 20));
  const offset = (page - 1) * limit;
  const userId = req.user.id;

  try {
    let sql = `${POST_SELECT}`;
    const params: any[] = [userId];

    if (type === "following") {
      sql += `
        WHERE p.user_id IN (
          SELECT following_id FROM user_follows WHERE follower_id = ?
        )
      `;
      params.push(userId);
    } else if (type === "achievements") {
      sql += ` WHERE (p.days_streak IS NOT NULL OR p.challenge_name IS NOT NULL)`;
    }

    if (type === "trending") {
      sql += ` ORDER BY like_count DESC, p.created_at DESC`;
    } else {
      sql += ` ORDER BY p.created_at DESC`;
    }

    sql += ` LIMIT ? OFFSET ?`;
    params.push(limit, offset);

    const [rows]: any = await pool.query(sql, params);
    const posts = rows.map((row: any) => mapPostRow(row, userId));

    res.json({ posts, page, limit, type });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error", posts: [] });
  }
});

// ================= CREATE POST =================
router.post("/posts", authMiddleware, async (req: any, res: Response) => {
  const { content, image_url, hashtags, challenge_name, days_streak } = req.body;
  const userId = req.user.id;

  if (!content || String(content).trim() === "") {
    return res.status(400).json({ message: "Content is required" });
  }

  try {
    const hashtagsJson = hashtags && Array.isArray(hashtags) ? JSON.stringify(hashtags) : null;

    let streakValue = days_streak != null ? parseInt(String(days_streak), 10) : null;
    if (streakValue == null) {
      const [streakRows]: any = await pool.query(
        "SELECT current_streak FROM streaks WHERE user_id = ?",
        [userId]
      );
      const current = streakRows[0]?.current_streak;
      if (current && current > 0) {
        streakValue = current;
      }
    }

    const [result]: any = await pool.query(
      `INSERT INTO community_posts (user_id, content, image_url, hashtags, challenge_name, days_streak)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [
        userId,
        String(content).trim(),
        image_url || null,
        hashtagsJson,
        challenge_name || null,
        streakValue,
      ]
    );

    const post = await fetchPostById(result.insertId, userId);
    res.json({ post });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

// ================= DELETE POST =================
router.delete("/posts/:postId", authMiddleware, async (req: any, res: Response) => {
  const postId = parseInt(req.params.postId, 10);
  const userId = req.user.id;

  if (isNaN(postId)) {
    return res.status(400).json({ message: "Invalid post id" });
  }

  try {
    const [rows]: any = await pool.query(
      "SELECT user_id, image_url FROM community_posts WHERE id = ?",
      [postId]
    );
    if (!rows.length) return res.status(404).json({ message: "Post not found" });
    if (rows[0].user_id !== userId) {
      return res.status(403).json({ message: "Not allowed" });
    }

    await pool.query("DELETE FROM community_posts WHERE id = ?", [postId]);

    const imageUrl = rows[0].image_url as string | null;
    if (imageUrl && imageUrl.startsWith("/uploads/")) {
      const filename = path.basename(imageUrl);
      const filePath = path.join(uploadsDir, filename);
      if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
    }

    res.json({ message: "Deleted" });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

// ================= LIKE / UNLIKE POST =================
router.post("/posts/:postId/like", authMiddleware, async (req: any, res: Response) => {
  const postId = parseInt(req.params.postId, 10);
  const userId = req.user.id;

  if (isNaN(postId)) return res.status(400).json({ message: "Invalid post id" });

  try {
    const [posts]: any = await pool.query("SELECT id FROM community_posts WHERE id = ?", [postId]);
    if (!posts.length) return res.status(404).json({ message: "Post not found" });

    await pool.query(
      "INSERT IGNORE INTO community_post_likes (user_id, post_id) VALUES (?, ?)",
      [userId, postId]
    );

    const [countRows]: any = await pool.query(
      "SELECT COUNT(*) AS cnt FROM community_post_likes WHERE post_id = ?",
      [postId]
    );

    res.json({
      like_count: countRows[0].cnt,
      is_liked: true,
    });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

router.delete("/posts/:postId/like", authMiddleware, async (req: any, res: Response) => {
  const postId = parseInt(req.params.postId, 10);
  const userId = req.user.id;

  if (isNaN(postId)) return res.status(400).json({ message: "Invalid post id" });

  try {
    await pool.query(
      "DELETE FROM community_post_likes WHERE user_id = ? AND post_id = ?",
      [userId, postId]
    );

    const [countRows]: any = await pool.query(
      "SELECT COUNT(*) AS cnt FROM community_post_likes WHERE post_id = ?",
      [postId]
    );

    res.json({
      like_count: countRows[0].cnt,
      is_liked: false,
    });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

// ================= GET / CREATE COMMENTS =================
router.get("/posts/:postId/comments", authMiddleware, async (req: any, res: Response) => {
  const postId = parseInt(req.params.postId, 10);
  const userId = req.user.id;
  const page = Math.max(1, parseInt(String(req.query.page || "1"), 10) || 1);
  const limit = Math.min(100, Math.max(1, parseInt(String(req.query.limit || "50"), 10) || 50));
  const offset = (page - 1) * limit;

  if (isNaN(postId)) return res.status(400).json({ message: "Invalid post id", comments: [] });

  try {
    const [rows]: any = await pool.query(
      `SELECT
        c.id,
        c.post_id,
        c.user_id,
        u.name AS user_name,
        c.content,
        c.created_at,
        (SELECT COUNT(*) FROM community_comment_likes cl WHERE cl.comment_id = c.id) AS like_count,
        EXISTS(
          SELECT 1 FROM community_comment_likes cl2
          WHERE cl2.comment_id = c.id AND cl2.user_id = ?
        ) AS is_liked
      FROM community_comments c
      JOIN users u ON u.id = c.user_id
      WHERE c.post_id = ?
      ORDER BY c.created_at ASC
      LIMIT ? OFFSET ?`,
      [userId, postId, limit, offset]
    );

    res.json({ comments: rows.map(mapCommentRow), page, limit });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error", comments: [] });
  }
});

router.post("/posts/:postId/comments", authMiddleware, async (req: any, res: Response) => {
  const postId = parseInt(req.params.postId, 10);
  const userId = req.user.id;
  const { content } = req.body;

  if (isNaN(postId)) return res.status(400).json({ message: "Invalid post id" });
  if (!content || String(content).trim() === "") {
    return res.status(400).json({ message: "Content is required" });
  }

  try {
    const [posts]: any = await pool.query("SELECT id FROM community_posts WHERE id = ?", [postId]);
    if (!posts.length) return res.status(404).json({ message: "Post not found" });

    const [result]: any = await pool.query(
      "INSERT INTO community_comments (post_id, user_id, content) VALUES (?, ?, ?)",
      [postId, userId, String(content).trim()]
    );

    const [rows]: any = await pool.query(
      `SELECT
        c.id,
        c.post_id,
        c.user_id,
        u.name AS user_name,
        c.content,
        c.created_at,
        0 AS like_count,
        0 AS is_liked
      FROM community_comments c
      JOIN users u ON u.id = c.user_id
      WHERE c.id = ?`,
      [result.insertId]
    );

    res.json({ comment: mapCommentRow(rows[0]) });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

// ================= LIKE / UNLIKE COMMENT =================
router.post("/comments/:commentId/like", authMiddleware, async (req: any, res: Response) => {
  const commentId = parseInt(req.params.commentId, 10);
  const userId = req.user.id;

  if (isNaN(commentId)) return res.status(400).json({ message: "Invalid comment id" });

  try {
    await pool.query(
      "INSERT IGNORE INTO community_comment_likes (user_id, comment_id) VALUES (?, ?)",
      [userId, commentId]
    );

    const [countRows]: any = await pool.query(
      "SELECT COUNT(*) AS cnt FROM community_comment_likes WHERE comment_id = ?",
      [commentId]
    );

    res.json({ like_count: countRows[0].cnt, is_liked: true });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

router.delete("/comments/:commentId/like", authMiddleware, async (req: any, res: Response) => {
  const commentId = parseInt(req.params.commentId, 10);
  const userId = req.user.id;

  if (isNaN(commentId)) return res.status(400).json({ message: "Invalid comment id" });

  try {
    await pool.query(
      "DELETE FROM community_comment_likes WHERE user_id = ? AND comment_id = ?",
      [userId, commentId]
    );

    const [countRows]: any = await pool.query(
      "SELECT COUNT(*) AS cnt FROM community_comment_likes WHERE comment_id = ?",
      [commentId]
    );

    res.json({ like_count: countRows[0].cnt, is_liked: false });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

// ================= UPLOAD IMAGE =================
router.post("/upload", authMiddleware, (req: any, res: Response) => {
  upload.single("image")(req, res, (err: any) => {
    if (err) {
      return res.status(400).json({ message: err.message || "Upload failed" });
    }
    if (!req.file) {
      return res.status(400).json({ message: "No image file" });
    }

    const relativePath = `/uploads/${req.file.filename}`;
    const url = resolveImageUrl(relativePath);
    res.json({ url, path: relativePath });
  });
});

// ================= FOLLOW (bonus — tab Đang theo dõi) =================
router.post("/users/:userId/follow", authMiddleware, async (req: any, res: Response) => {
  const followingId = parseInt(req.params.userId, 10);
  const followerId = req.user.id;

  if (isNaN(followingId)) return res.status(400).json({ message: "Invalid user id" });
  if (followingId === followerId) {
    return res.status(400).json({ message: "Cannot follow yourself" });
  }

  try {
    await pool.query(
      "INSERT IGNORE INTO user_follows (follower_id, following_id) VALUES (?, ?)",
      [followerId, followingId]
    );
    res.json({ message: "Followed" });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

router.delete("/users/:userId/follow", authMiddleware, async (req: any, res: Response) => {
  const followingId = parseInt(req.params.userId, 10);
  const followerId = req.user.id;

  if (isNaN(followingId)) return res.status(400).json({ message: "Invalid user id" });

  try {
    await pool.query(
      "DELETE FROM user_follows WHERE follower_id = ? AND following_id = ?",
      [followerId, followingId]
    );
    res.json({ message: "Unfollowed" });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

async function ensureCommunitySchema() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS community_posts (
      id INT AUTO_INCREMENT PRIMARY KEY,
      user_id INT NOT NULL,
      content TEXT NOT NULL,
      image_url VARCHAR(500),
      hashtags JSON,
      challenge_name VARCHAR(100),
      days_streak INT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    )
  `);
  await pool.query(`
    CREATE TABLE IF NOT EXISTS community_comments (
      id INT AUTO_INCREMENT PRIMARY KEY,
      post_id INT NOT NULL,
      user_id INT NOT NULL,
      content TEXT NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (post_id) REFERENCES community_posts(id) ON DELETE CASCADE,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    )
  `);
  await pool.query(`
    CREATE TABLE IF NOT EXISTS community_post_likes (
      user_id INT NOT NULL,
      post_id INT NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (user_id, post_id),
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
      FOREIGN KEY (post_id) REFERENCES community_posts(id) ON DELETE CASCADE
    )
  `);
  await pool.query(`
    CREATE TABLE IF NOT EXISTS community_comment_likes (
      user_id INT NOT NULL,
      comment_id INT NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (user_id, comment_id),
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
      FOREIGN KEY (comment_id) REFERENCES community_comments(id) ON DELETE CASCADE
    )
  `);
  await pool.query(`
    CREATE TABLE IF NOT EXISTS user_follows (
      follower_id INT NOT NULL,
      following_id INT NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (follower_id, following_id),
      FOREIGN KEY (follower_id) REFERENCES users(id) ON DELETE CASCADE,
      FOREIGN KEY (following_id) REFERENCES users(id) ON DELETE CASCADE
    )
  `);
}

ensureCommunitySchema().catch((err) =>
  console.error("Community schema init failed:", err)
);

export default router;
