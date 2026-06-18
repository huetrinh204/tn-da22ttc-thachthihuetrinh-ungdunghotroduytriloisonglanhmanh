import { Router } from "express";
import pool from "../config/db";
import jwt from "jsonwebtoken";
import dotenv from "dotenv";

dotenv.config();

const router = Router();
const JWT_SECRET = process.env.JWT_SECRET || "secret_key";

// middleware xác thực token
function authMiddleware(req: any, res: any, next: any) {
  const authHeader = req.headers.authorization;
  if (!authHeader) return res.status(401).json({ message: "Unauthorized" });

  const token = authHeader.split(" ")[1];
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch {
    return res.status(401).json({ message: "Invalid token" });
  }
}

// ================= GET STREAK =================
router.get("/streak", authMiddleware, async (req: any, res) => {
  try {
    const [rows]: any = await pool.query(
      "SELECT * FROM streaks WHERE user_id = ?",
      [req.user.id]
    );
    const streak = rows[0] || { current_streak: 0, longest_streak: 0, freeze_tokens: 0 };
    res.json({ streak });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

// ================= GET ALL HABITS =================
router.get("/", authMiddleware, async (req: any, res) => {
  try {
    const [habits]: any = await pool.query(
      "SELECT * FROM habits WHERE user_id = ? AND is_active = 1 ORDER BY created_at DESC",
      [req.user.id]
    );
    res.json({ habits });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

// ================= GET HABITS WITH TODAY'S LOG =================
router.get("/today", authMiddleware, async (req: any, res) => {
  try {
    // Dùng giờ Việt Nam (UTC+7) để đồng nhất với route check-in
    const now = new Date();
    const vietnamTime = new Date(now.getTime() + (7 * 60 * 60 * 1000));
    const today = vietnamTime.toISOString().split("T")[0];

    const [habits]: any = await pool.query(
      `SELECT h.*, 
        CASE WHEN hl.is_completed = 1 THEN 1 ELSE 0 END AS is_completed,
        COALESCE(hl.metric_value, hl.value, 0) AS completed_count, hl.note
       FROM habits h
       LEFT JOIN habit_logs hl ON h.id = hl.habit_id AND hl.log_date = ?
       WHERE h.user_id = ? AND h.is_active = 1
       ORDER BY h.created_at DESC`,
      [today, req.user.id]
    );

    res.json({ habits, date: today });

  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

// ================= CREATE HABIT =================
router.post("/", authMiddleware, async (req: any, res) => {
  const { name, category, frequency, target_count, icon, color, reminder_time, reminder_enabled } = req.body;

  if (!name) return res.status(400).json({ message: "Tên thói quen không được trống" });

  try {
    const [result]: any = await pool.query(
      `INSERT INTO habits (user_id, name, category, frequency, target_count, icon, color, reminder_time)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        req.user.id,
        name,
        category || "other",
        frequency || "daily",
        target_count || 1,
        icon || "⭐",
        color || "#4CAF50",
        (reminder_enabled !== false && reminder_time) ? reminder_time : null,
      ]
    );

    const [rows]: any = await pool.query(
      "SELECT * FROM habits WHERE id = ?",
      [result.insertId]
    );

    res.json({ message: "Habit created", habit: rows[0] });

  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

// ================= UPDATE HABIT =================
router.put("/:id", authMiddleware, async (req: any, res) => {
  const { name, category, icon, color, target_count, reminder_time, reminder_enabled } = req.body;

  try {
    const finalReminderTime = (reminder_enabled !== false && reminder_time) ? reminder_time : null;
    await pool.query(
      `UPDATE habits SET name = ?, category = ?, icon = ?, color = ?, target_count = ?, reminder_time = ?
       WHERE id = ? AND user_id = ?`,
      [name, category, icon, color, target_count, finalReminderTime, req.params.id, req.user.id]
    );

    res.json({ message: "Habit updated" });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

// ================= DELETE HABIT (soft delete) =================
router.delete("/:id", authMiddleware, async (req: any, res) => {
  try {
    await pool.query(
      "UPDATE habits SET is_active = 0 WHERE id = ? AND user_id = ?",
      [req.params.id, req.user.id]
    );

    // Recalculate plant experience based on remaining habits
    await recalculatePlantExperience(req.user.id);

    res.json({ message: "Habit deleted" });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

// ================= CHECK-IN HABIT =================
router.post("/:id/checkin", authMiddleware, async (req: any, res) => {
  const { note, metric_value, metric_unit } = req.body;
  
  // Tính ngày hôm nay theo timezone Việt Nam (UTC+7)
  const now = new Date();
  // Chuyển sang giờ Việt Nam bằng cách thêm 7 giờ
  const vietnamTime = new Date(now.getTime() + (7 * 60 * 60 * 1000));
  const today = vietnamTime.toISOString().split('T')[0];
  
  console.log(`[Check-in] UTC time: ${now.toISOString()}, Vietnam time: ${vietnamTime.toISOString()}, today: ${today}`);

  try {
    // Lấy target_count của habit
    const [habitRows]: any = await pool.query("SELECT target_count FROM habits WHERE id = ?", [req.params.id]);
    const targetCount = habitRows[0]?.target_count || 1;
    const addMetric = metric_value || 1;

    // check xem đã check-in hôm nay chưa
    const [existing]: any = await pool.query(
      "SELECT * FROM habit_logs WHERE habit_id = ? AND log_date = ?",
      [req.params.id, today]
    );

    let isCompletedNow = false;

    if (existing.length > 0) {
      const currentLog = existing[0];
      if (currentLog.is_completed) {
        return res.json({ message: "Already fully completed", is_completed: true });
      }
      const newMetric = (parseFloat(currentLog.metric_value) || 0) + addMetric;
      isCompletedNow = newMetric >= targetCount;
      await pool.query(
        "UPDATE habit_logs SET metric_value = ?, is_completed = ?, note = ? WHERE id = ?",
        [newMetric, isCompletedNow ? 1 : 0, note || currentLog.note, currentLog.id]
      );
      console.log(`[Check-in] Updated progress: ${newMetric}/${targetCount}`);
    } else {
      isCompletedNow = addMetric >= targetCount;
      // check-in mới - dùng CAST để đảm bảo lưu đúng ngày
      await pool.query(
        `INSERT INTO habit_logs (habit_id, user_id, log_date, note, metric_value, metric_unit, is_completed)
         VALUES (?, ?, CAST(? AS DATE), ?, ?, ?, ?)`,
        [req.params.id, req.user.id, today, note || null, addMetric, metric_unit || null, isCompletedNow ? 1 : 0]
      );
      console.log(`[Check-in] Saved new progress: ${addMetric}/${targetCount} to database with log_date: ${today}`);
    }

    if (isCompletedNow) {
      // cập nhật streak tổng
      await updateStreak(req.user.id);

      // cập nhật streak riêng của habit này
      await updateHabitStreak(req.params.id, today);

      // cập nhật plant và lấy số điểm được cộng
      const pointsEarned = await updatePlant(req.user.id, today);

      // kiểm tra và unlock achievements
      const newAchievements = await checkAchievements(req.user.id);

      res.json({ 
        message: "Checked in completely", 
        is_completed: true, 
        points_earned: pointsEarned,
        new_achievements: newAchievements 
      });
    } else {
      res.json({
        message: "Progress updated",
        is_completed: false,
        points_earned: 0,
        new_achievements: []
      });
    }
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

// helper: cập nhật streak riêng của habit
async function updateHabitStreak(habitId: number, today: string) {
  const [habitRows]: any = await pool.query(
    "SELECT current_streak, last_completed_date FROM habits WHERE id = ?",
    [habitId]
  );

  if (habitRows.length === 0) return;

  const habit = habitRows[0];
  const lastDate = habit.last_completed_date
    ? new Date(habit.last_completed_date)
    : null;
  const todayDate = new Date(today);

  let newStreak = habit.current_streak || 0;

  if (lastDate) {
    const diffDays = Math.floor(
      (todayDate.getTime() - lastDate.getTime()) / (1000 * 60 * 60 * 24)
    );

    if (diffDays === 0) return; // Đã check-in hôm nay rồi
    if (diffDays === 1) newStreak += 1; // Liên tiếp
    else newStreak = 1; // Bị gián đoạn, reset về 1
  } else {
    newStreak = 1; // Lần đầu tiên
  }

  const longestStreak = Math.max(newStreak, habit.longest_streak || 0);

  await pool.query(
    "UPDATE habits SET current_streak = ?, longest_streak = ?, last_completed_date = ? WHERE id = ?",
    [newStreak, longestStreak, today, habitId]
  );
}

// helper: cập nhật streak (với streak freeze logic)
async function updateStreak(userId: number) {
  const now = new Date();
  const vietnamTime = new Date(now.getTime() + (7 * 60 * 60 * 1000));
  const today = vietnamTime.toISOString().split('T')[0];

  const [streakRows]: any = await pool.query(
    "SELECT * FROM streaks WHERE user_id = ?",
    [userId]
  );

  if (streakRows.length === 0) {
    await pool.query(
      "INSERT INTO streaks (user_id, current_streak, longest_streak, last_completed_date, freeze_tokens) VALUES (?, 1, 1, ?, 0)",
      [userId, today]
    );
    return;
  }

  const streak = streakRows[0];
  const lastDate = streak.last_completed_date
    ? new Date(streak.last_completed_date)
    : null;
  const todayDate = new Date(today);

  let newStreak = streak.current_streak;
  let freezeTokens = streak.freeze_tokens ?? 0;

  if (lastDate) {
    const diffDays = Math.floor(
      (todayDate.getTime() - lastDate.getTime()) / (1000 * 60 * 60 * 24)
    );

    if (diffDays === 0) return; // Đã check-in hôm nay
    if (diffDays === 1) {
      newStreak += 1; // Liên tiếp bình thường
    } else if (diffDays === 2 && freezeTokens > 0) {
      // Bỏ 1 ngày nhưng có freeze token → dùng token, giữ streak
      newStreak += 1;
      freezeTokens -= 1;
      console.log(`[Streak] User ${userId} used freeze token! Tokens left: ${freezeTokens}`);
    } else {
      newStreak = 1; // Reset streak
    }
  }

  // Tặng freeze token khi đạt bội số của 7 (7, 14, 21...) và chưa đủ 2 tokens
  const reachedMilestone = newStreak > 0 && newStreak % 7 === 0;
  if (reachedMilestone && freezeTokens < 2) {
    freezeTokens = Math.min(2, freezeTokens + 1);
    console.log(`[Streak] User ${userId} earned freeze token! Total: ${freezeTokens}`);
  }

  const longestStreak = Math.max(newStreak, streak.longest_streak);

  await pool.query(
    "UPDATE streaks SET current_streak = ?, longest_streak = ?, last_completed_date = ?, freeze_tokens = ? WHERE user_id = ?",
    [newStreak, longestStreak, today, freezeTokens, userId]
  );
}

export default router;

// ================= GET ACHIEVEMENTS =================
router.get("/achievements", authMiddleware, async (req: any, res) => {
  try {
    const [rows]: any = await pool.query(
      "SELECT * FROM achievements WHERE user_id = ? ORDER BY unlocked_at DESC",
      [req.user.id]
    );
    res.json({ achievements: rows });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

// helper: kiểm tra và unlock achievements
const ACHIEVEMENTS = [
  { key: "first_checkin",   title: "Bước đầu tiên",     icon: "🌱", desc: "Hoàn thành check-in đầu tiên" },
  { key: "streak_3",        title: "3 ngày liên tiếp",   icon: "🔥", desc: "Duy trì streak 3 ngày" },
  { key: "streak_7",        title: "Tuần kiên trì",      icon: "⚡", desc: "Duy trì streak 7 ngày" },
  { key: "streak_30",       title: "Tháng bền bỉ",       icon: "🏆", desc: "Duy trì streak 30 ngày" },
  { key: "habits_5",        title: "Đa nhiệm",           icon: "🎯", desc: "Tạo 5 thói quen" },
  { key: "checkin_50",      title: "Nửa trăm",           icon: "💪", desc: "Hoàn thành 50 check-ins" },
  { key: "checkin_100",     title: "Bách chiến",         icon: "🌟", desc: "Hoàn thành 100 check-ins" },
  { key: "plant_level_3",   title: "Cây non",            icon: "🪴", desc: "Cây đạt cấp độ 3" },
  { key: "plant_level_15",  title: "Vườn địa đàng",     icon: "🌳", desc: "Cây đạt cấp độ tối đa" },
];

async function checkAchievements(userId: number): Promise<any[]> {
  // Lấy achievements đã unlock
  const [existing]: any = await pool.query(
    "SELECT achievement_key FROM achievements WHERE user_id = ?",
    [userId]
  );
  const unlockedKeys = new Set(existing.map((r: any) => r.achievement_key));

  const newlyUnlocked: any[] = [];

  // Lấy dữ liệu cần thiết
  const [streakRows]: any = await pool.query(
    "SELECT current_streak FROM streaks WHERE user_id = ?", [userId]);
  const streak = streakRows[0]?.current_streak ?? 0;

  const [checkinRows]: any = await pool.query(
    "SELECT COUNT(*) as total FROM habit_logs WHERE user_id = ?", [userId]);
  const totalCheckins = checkinRows[0].total;

  const [habitRows]: any = await pool.query(
    "SELECT COUNT(*) as total FROM habits WHERE user_id = ? AND is_active = 1", [userId]);
  const totalHabits = habitRows[0].total;

  const [plantRows]: any = await pool.query(
    "SELECT level FROM plants WHERE user_id = ?", [userId]);
  const plantLevel = plantRows[0]?.level ?? 1;

  // Điều kiện cho từng achievement
  const conditions: Record<string, boolean> = {
    first_checkin:   totalCheckins >= 1,
    streak_3:        streak >= 3,
    streak_7:        streak >= 7,
    streak_30:       streak >= 30,
    habits_5:        totalHabits >= 5,
    checkin_50:      totalCheckins >= 50,
    checkin_100:     totalCheckins >= 100,
    plant_level_3:   plantLevel >= 3,
    plant_level_15:  plantLevel >= 15,
  };

  for (const ach of ACHIEVEMENTS) {
    if (!unlockedKeys.has(ach.key) && conditions[ach.key]) {
      await pool.query(
        `INSERT INTO achievements (user_id, achievement_key, title, description, icon)
         VALUES (?, ?, ?, ?, ?)`,
        [userId, ach.key, ach.title, ach.desc, ach.icon]
      );
      newlyUnlocked.push(ach);
    }
  }

  return newlyUnlocked;
}

// ================= SET PLANT TYPE =================
router.put("/plant/type", authMiddleware, async (req: any, res) => {
  const { plant_type } = req.body;
  if (!plant_type) return res.status(400).json({ message: "Missing plant_type" });

  try {
    const [rows]: any = await pool.query(
      "SELECT id FROM plants WHERE user_id = ?", [req.user.id]);

    if (rows.length === 0) {
      await pool.query(
        "INSERT INTO plants (user_id, plant_type, level, experience) VALUES (?, ?, 1, 0)",
        [req.user.id, plant_type]
      );
    } else {
      await pool.query(
        "UPDATE plants SET plant_type = ? WHERE user_id = ?",
        [plant_type, req.user.id]
      );
    }
    res.json({ message: "Plant type updated" });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

// ================= GET PLANT =================
router.get("/plant", authMiddleware, async (req: any, res) => {
  try {
    const [rows]: any = await pool.query(
      "SELECT * FROM plants WHERE user_id = ?",
      [req.user.id]
    );

    if (rows.length === 0) {
      return res.json({
        plant: {
          plant_type: "sprout",
          level: 1,
          experience: 0,
          is_wilted: false,
          days_without_checkin: 0,
        },
      });
    }

    const plant = rows[0];

    // Return plant data with days_without_checkin
    res.json({ 
      plant: { 
        ...plant, 
        is_wilted: plant.is_wilted === 1,
        days_without_checkin: plant.days_without_checkin || 0,
      } 
    });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

// helper: cập nhật plant experience và level
async function updatePlant(userId: number, today: string): Promise<number> {
  // Đếm tổng habits active
  const [habitRows]: any = await pool.query(
    "SELECT COUNT(*) as total FROM habits WHERE user_id = ? AND is_active = 1",
    [userId]
  );
  const totalHabits = habitRows[0].total;
  console.log(`[Plant] userId=${userId} totalHabits=${totalHabits}`);
  if (totalHabits === 0) return 0;

  // Đếm habits đã check-in hôm nay
  const [doneRows]: any = await pool.query(
    `SELECT COUNT(*) as done FROM habit_logs 
     WHERE user_id = ? AND log_date = ?`,
    [userId, today]
  );
  const doneToday = doneRows[0].done;
  console.log(`[Plant] doneToday=${doneToday} today=${today}`);

  // Tính điểm theo tỉ lệ hoàn thành
  const ratio = doneToday / totalHabits;
  let points = 0;
  if (ratio >= 1.0) points = 3;
  else if (ratio >= 0.5) points = 2;
  else if (ratio > 0) points = 1;

  console.log(`[Plant] ratio=${ratio} points=${points}`);
  if (points === 0) return 0;

  // Lấy hoặc tạo plant
  const [plantRows]: any = await pool.query(
    "SELECT * FROM plants WHERE user_id = ?",
    [userId]
  );

  if (plantRows.length === 0) {
    console.log(`[Plant] No plant found, creating new`);
    await pool.query(
      `INSERT INTO plants (user_id, plant_type, level, experience, last_watered)
       VALUES (?, 'sprout', 1, ?, ?)`,
      [userId, points, today]
    );
    return points;
  }

  const plant = plantRows[0];

  // Chỉ cộng điểm 1 lần/ngày — convert về string để so sánh đúng
  const lastWatered = plant.last_watered
    ? (plant.last_watered instanceof Date
        ? plant.last_watered.toISOString().split("T")[0]
        : String(plant.last_watered).split("T")[0])
    : null;

  console.log(`[Plant] lastWatered=${lastWatered} today=${today} exp=${plant.experience}`);

  if (lastWatered === today) {
    console.log(`[Plant] Already watered today, skip`);
    return 0;
  }

  const newExp = plant.experience + points;

  // Hệ thống 15 level mới
  // Ngưỡng: 0, 5, 15, 30, 50, 75, 105, 140, 180, 225, 275, 330, 390, 455, 525
  const thresholds = [0, 5, 15, 30, 50, 75, 105, 140, 180, 225, 275, 330, 390, 455, 525];
  let newLevel = 1;
  for (let i = thresholds.length - 1; i >= 0; i--) {
    if (newExp >= thresholds[i]) {
      newLevel = i + 1;
      break;
    }
  }

  console.log(`[Plant] newExp=${newExp} newLevel=${newLevel} oldLevel=${plant.level}`);
  
  await pool.query(
    `UPDATE plants SET experience = ?, level = ?, last_watered = ? WHERE user_id = ?`,
    [newExp, newLevel, today, userId]
  );

  console.log(`[Plant] Updated plant: exp=${plant.experience} -> ${newExp}, level=${plant.level} -> ${newLevel}`);
  
  return points;
}

// Helper: Recalculate plant experience from scratch based on all habit logs
async function recalculatePlantExperience(userId: number) {
  try {
    console.log(`[Recalculate] Starting for userId=${userId}`);

    // Check if user has any active habits
    const [activeHabits]: any = await pool.query(
      `SELECT COUNT(*) as count FROM habits WHERE user_id = ? AND is_active = 1`,
      [userId]
    );

    if (activeHabits[0].count === 0) {
      // No active habits, reset plant to initial state
      await pool.query(
        `UPDATE plants SET experience = 0, level = 1, last_watered = NULL WHERE user_id = ?`,
        [userId]
      );
      console.log(`[Recalculate] No active habits, reset plant to level 1 with 0 exp`);
      return;
    }

    // Get all unique dates where user checked in habits
    const [logDates]: any = await pool.query(
      `SELECT DISTINCT log_date FROM habit_logs WHERE user_id = ? ORDER BY log_date ASC`,
      [userId]
    );

    if (logDates.length === 0) {
      // No logs, reset plant to initial state
      await pool.query(
        `UPDATE plants SET experience = 0, level = 1, last_watered = NULL WHERE user_id = ?`,
        [userId]
      );
      console.log(`[Recalculate] No logs found, reset plant to level 1`);
      return;
    }

    let totalExp = 0;

    // For each date, calculate points based on completion ratio
    for (const row of logDates) {
      const date = row.log_date instanceof Date
        ? row.log_date.toISOString().split("T")[0]
        : String(row.log_date).split("T")[0];

      // Count total active habits that existed on that date (currently active habits only)
      const [habitRows]: any = await pool.query(
        `SELECT COUNT(*) as total FROM habits 
         WHERE user_id = ? AND is_active = 1 AND created_at <= ?`,
        [userId, date + ' 23:59:59']
      );
      const totalHabits = habitRows[0].total;

      if (totalHabits === 0) continue;

      // Count completed habits on that date (only count logs for currently active habits)
      const [doneRows]: any = await pool.query(
        `SELECT COUNT(*) as done FROM habit_logs hl
         INNER JOIN habits h ON hl.habit_id = h.id
         WHERE hl.user_id = ? AND hl.log_date = ? AND h.is_active = 1`,
        [userId, date]
      );
      const doneToday = doneRows[0].done;

      // Calculate points based on ratio
      const ratio = doneToday / totalHabits;
      let points = 0;
      if (ratio >= 1.0) points = 3;
      else if (ratio >= 0.5) points = 2;
      else if (ratio > 0) points = 1;

      totalExp += points;
      console.log(`[Recalculate] Date=${date}, done=${doneToday}/${totalHabits}, points=${points}, totalExp=${totalExp}`);
    }

    // Calculate new level
    const thresholds = [0, 5, 15, 30, 50, 75, 105, 140, 180, 225, 275, 330, 390, 455, 525];
    let newLevel = 1;
    for (let i = thresholds.length - 1; i >= 0; i--) {
      if (totalExp >= thresholds[i]) {
        newLevel = i + 1;
        break;
      }
    }

    // Get last watered date
    const lastDate = logDates[logDates.length - 1].log_date;
    const lastWatered = lastDate instanceof Date
      ? lastDate.toISOString().split("T")[0]
      : String(lastDate).split("T")[0];

    // Update plant
    await pool.query(
      `UPDATE plants SET experience = ?, level = ?, last_watered = ? WHERE user_id = ?`,
      [totalExp, newLevel, lastWatered, userId]
    );

    console.log(`[Recalculate] Complete: totalExp=${totalExp}, newLevel=${newLevel}`);
  } catch (error) {
    console.error("[Recalculate] Error:", error);
  }
}
