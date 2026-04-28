import { Router } from "express";
import pool from "../config/db";
import jwt from "jsonwebtoken";
import dotenv from "dotenv";

dotenv.config();

const router = Router();
const JWT_SECRET = process.env.JWT_SECRET || "secret_key";

function authMiddleware(req: any, res: any, next: any) {
  const authHeader = req.headers.authorization;
  if (!authHeader) return res.status(401).json({ message: "Unauthorized" });
  const token = authHeader.split(" ")[1];
  try {
    req.user = jwt.verify(token, JWT_SECRET);
    next();
  } catch {
    return res.status(401).json({ message: "Invalid token" });
  }
}

// ================= WEEKLY STATS =================
// Trả về số habit hoàn thành theo từng ngày trong 7 ngày gần nhất
router.get("/weekly", authMiddleware, async (req: any, res) => {
  try {
    const [rows]: any = await pool.query(
      `SELECT log_date, COUNT(*) as count
       FROM habit_logs
       WHERE user_id = ?
         AND log_date >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)
       GROUP BY log_date
       ORDER BY log_date ASC`,
      [req.user.id]
    );
    res.json({ data: rows });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

// ================= MONTHLY STATS =================
// Trả về số habit hoàn thành theo từng ngày trong 30 ngày gần nhất
router.get("/monthly", authMiddleware, async (req: any, res) => {
  try {
    const [rows]: any = await pool.query(
      `SELECT log_date, COUNT(*) as count
       FROM habit_logs
       WHERE user_id = ?
         AND log_date >= DATE_SUB(CURDATE(), INTERVAL 29 DAY)
       GROUP BY log_date
       ORDER BY log_date ASC`,
      [req.user.id]
    );
    res.json({ data: rows });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

// ================= CATEGORY STATS =================
// Tỉ lệ hoàn thành theo từng danh mục
router.get("/categories", authMiddleware, async (req: any, res) => {
  try {
    const [rows]: any = await pool.query(
      `SELECT h.category, COUNT(hl.id) as completed
       FROM habits h
       LEFT JOIN habit_logs hl ON h.id = hl.habit_id
       WHERE h.user_id = ? AND h.is_active = 1
       GROUP BY h.category`,
      [req.user.id]
    );
    res.json({ data: rows });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

// ================= SUMMARY =================
// Tổng quan: tổng check-in, streak dài nhất, ngày hoạt động
router.get("/summary", authMiddleware, async (req: any, res) => {
  try {
    const [totalRows]: any = await pool.query(
      `SELECT COUNT(*) as total_checkins,
              COUNT(DISTINCT log_date) as active_days
       FROM habit_logs WHERE user_id = ?`,
      [req.user.id]
    );

    const [streakRows]: any = await pool.query(
      `SELECT longest_streak FROM streaks WHERE user_id = ?`,
      [req.user.id]
    );

    const [habitRows]: any = await pool.query(
      `SELECT COUNT(*) as total_habits FROM habits WHERE user_id = ? AND is_active = 1`,
      [req.user.id]
    );

    res.json({
      summary: {
        total_checkins: totalRows[0].total_checkins,
        active_days: totalRows[0].active_days,
        longest_streak: streakRows[0]?.longest_streak ?? 0,
        total_habits: habitRows[0].total_habits,
      },
    });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

export default router;
