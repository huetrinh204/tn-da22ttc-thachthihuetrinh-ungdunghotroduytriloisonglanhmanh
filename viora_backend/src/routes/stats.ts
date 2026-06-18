import { Router } from "express";
import pool from "../config/db";
import jwt from "jsonwebtoken";
import dotenv from "dotenv";

dotenv.config();

const router = Router();
const JWT_SECRET = process.env.JWT_SECRET || "secret_key";

// Helper function to convert MySQL date (UTC) to Vietnam date string
function convertToVietnamDateString(mysqlDate: any): string {
  let utcDate: Date;
  
  if (mysqlDate instanceof Date) {
    utcDate = mysqlDate;
  } else if (typeof mysqlDate === 'string') {
    utcDate = new Date(mysqlDate);
  } else {
    utcDate = new Date(String(mysqlDate));
  }
  
  // MySQL trả về UTC, cộng 7 giờ để convert sang Vietnam timezone
  const vietnamDate = new Date(utcDate.getTime() + (7 * 60 * 60 * 1000));
  return vietnamDate.toISOString().split('T')[0];
}

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
    // Tính 7 ngày bằng JavaScript
    const today = new Date();
    const allDates: string[] = [];
    
    for (let i = 6; i >= 0; i--) {
      const date = new Date(today);
      date.setDate(today.getDate() - i);
      allDates.push(date.toISOString().split('T')[0]);
    }
    
    const startDate = allDates[0];
    const endDate = allDates[allDates.length - 1];
    
    console.log(`[Weekly Stats] userId=${req.user.id} startDate=${startDate} endDate=${endDate}`);
    
    // Lấy dữ liệu từ DB - không dùng DATE() để tránh timezone issue
    // Dùng < endDate + 1 day thay vì <= endDate để bao gồm cả ngày
    const nextDay = new Date(today);
    nextDay.setDate(today.getDate() + 1);
    const nextDayStr = nextDay.toISOString().split('T')[0];
    
    const [dbRows]: any = await pool.query(
      `SELECT DATE(log_date) as log_date, COUNT(*) as count
       FROM habit_logs
       WHERE user_id = ? AND log_date >= ? AND log_date < ?
       GROUP BY DATE(log_date)
       ORDER BY DATE(log_date) ASC`,
      [req.user.id, startDate, nextDayStr]
    );
    
    console.log(`[Weekly Stats] DB returned ${dbRows.length} rows:`, dbRows);
    
    // Map dữ liệu
    const dbMap = new Map();
    dbRows.forEach((row: any) => {
      const dateStr = convertToVietnamDateString(row.log_date);
      console.log(`[Weekly Stats] Mapping: ${row.log_date} -> ${dateStr}, count: ${row.count}`);
      dbMap.set(dateStr, row.count);
    });
    
    // Tạo kết quả với tất cả các ngày
    const rows = allDates.map(dateStr => ({
      log_date: dateStr,
      count: dbMap.get(dateStr) || 0
    }));
    
    console.log(`[Weekly Stats] Final result:`, rows);
    
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
    // Tính 30 ngày bằng JavaScript
    const today = new Date();
    const allDates: string[] = [];
    
    for (let i = 29; i >= 0; i--) {
      const date = new Date(today);
      date.setDate(today.getDate() - i);
      allDates.push(date.toISOString().split('T')[0]);
    }
    
    const startDate = allDates[0];
    const endDate = allDates[allDates.length - 1];
    
    // Tính ngày mai để query < nextDay (bao gồm cả hôm nay)
    const nextDay = new Date(today);
    nextDay.setDate(today.getDate() + 1);
    const nextDayStr = nextDay.toISOString().split('T')[0];
    
    // Lấy dữ liệu từ DB
    const [dbRows]: any = await pool.query(
      `SELECT DATE(log_date) as log_date, COUNT(*) as count
       FROM habit_logs
       WHERE user_id = ? AND log_date >= ? AND log_date < ?
       GROUP BY DATE(log_date)
       ORDER BY DATE(log_date) ASC`,
      [req.user.id, startDate, nextDayStr]
    );
    
    // Map dữ liệu
    const dbMap = new Map();
    dbRows.forEach((row: any) => {
      const dateStr = convertToVietnamDateString(row.log_date);
      dbMap.set(dateStr, row.count);
    });
    
    // Tạo kết quả với tất cả các ngày
    const rows = allDates.map(dateStr => ({
      log_date: dateStr,
      count: dbMap.get(dateStr) || 0
    }));
    
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

// ================= HABIT METRICS =================
// Lấy metrics chi tiết của một habit cụ thể
router.get("/habits/:habitId/metrics", authMiddleware, async (req: any, res) => {
  try {
    const { habitId } = req.params;
    const { days = 30 } = req.query; // Mặc định 30 ngày

    // Lấy thông tin habit
    const [habitRows]: any = await pool.query(
      `SELECT h.*, 
              (SELECT COUNT(*) FROM habit_logs WHERE habit_id = h.id) as total_logs
       FROM habits h
       WHERE h.id = ? AND h.user_id = ?`,
      [habitId, req.user.id]
    );

    if (habitRows.length === 0) {
      return res.status(404).json({ message: "Habit not found" });
    }

    const habit = habitRows[0];

    // Lấy metrics theo ngày - bao gồm cả ngày hôm nay
    // Tính ngày bắt đầu và kết thúc bằng JavaScript
    const today = new Date();
    const startDate = new Date(today);
    startDate.setDate(today.getDate() - (parseInt(days as string) - 1));
    
    const startDateStr = startDate.toISOString().split('T')[0];
    const endDateStr = today.toISOString().split('T')[0];
    
    // Tính ngày mai để query < nextDay
    const nextDay = new Date(today);
    nextDay.setDate(today.getDate() + 1);
    const nextDayStr = nextDay.toISOString().split('T')[0];
    
    console.log(`[Metrics] habitId=${habitId} days=${days} startDate=${startDateStr} endDate=${endDateStr} nextDay=${nextDayStr}`);
    
    // Tạo danh sách tất cả các ngày từ startDate đến today
    const allDates: string[] = [];
    const currentDate = new Date(startDate);
    while (currentDate <= today) {
      allDates.push(currentDate.toISOString().split('T')[0]);
      currentDate.setDate(currentDate.getDate() + 1);
    }
    
    // Lấy dữ liệu từ database - dùng < nextDay để bao gồm cả hôm nay
    const [dbRows]: any = await pool.query(
      `SELECT log_date, metric_value, metric_unit, note
       FROM habit_logs
       WHERE habit_id = ? AND user_id = ? 
         AND log_date >= ? AND log_date < ?
       ORDER BY log_date ASC`,
      [habitId, req.user.id, startDateStr, nextDayStr]
    );
    
    // Map dữ liệu từ DB vào allDates
    const dbMap = new Map();
    dbRows.forEach((row: any) => {
      const dateStr = convertToVietnamDateString(row.log_date);
      dbMap.set(dateStr, row);
    });
    
    // Tạo metricsRows với tất cả các ngày
    const metricsRows = allDates.map(dateStr => {
      if (dbMap.has(dateStr)) {
        return dbMap.get(dateStr);
      }
      return {
        log_date: dateStr,
        metric_value: null,
        metric_unit: null,
        note: null
      };
    });
    
    console.log(`[Metrics] Total dates: ${metricsRows.length}, First: ${metricsRows[0]?.log_date}, Last: ${metricsRows[metricsRows.length - 1]?.log_date}`);

    // Tính tổng và trung bình (chỉ tính với các log có metric_value)
    const logsWithMetrics = metricsRows.filter((row: any) => row.metric_value !== null);
    const totalValue = logsWithMetrics.reduce((sum: number, row: any) => 
      sum + (parseFloat(row.metric_value) || 0), 0);
    const avgValue = logsWithMetrics.length > 0 ? totalValue / logsWithMetrics.length : 0;

    res.json({
      habit: {
        id: habit.id,
        name: habit.name,
        category: habit.category,
        icon: habit.icon,
        current_streak: habit.current_streak,
        longest_streak: habit.longest_streak,
        total_logs: habit.total_logs,
        target_count: habit.target_count,
        target_value: habit.target_value,
        unit: habit.unit,
      },
      metrics: metricsRows,
      summary: {
        total_value: totalValue,
        average_value: avgValue,
        total_days: logsWithMetrics.length,
        unit: logsWithMetrics[0]?.metric_unit || habit.unit || null,
      },
    });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

// ================= ALL HABITS WITH METRICS =================
// Lấy danh sách tất cả habits với tổng metrics
router.get("/habits/overview", authMiddleware, async (req: any, res) => {
  try {
    const [rows]: any = await pool.query(
      `SELECT h.id, h.name, h.category, h.icon, h.current_streak, h.longest_streak,
              COUNT(hl.id) as total_logs,
              SUM(hl.metric_value) as total_metric,
              AVG(hl.metric_value) as avg_metric,
              MAX(hl.metric_unit) as metric_unit
       FROM habits h
       LEFT JOIN habit_logs hl ON h.id = hl.habit_id
       WHERE h.user_id = ? AND h.is_active = 1
       GROUP BY h.id
       ORDER BY h.created_at DESC`,
      [req.user.id]
    );

    res.json({ habits: rows });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

export default router;
