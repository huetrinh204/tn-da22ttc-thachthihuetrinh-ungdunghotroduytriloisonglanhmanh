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
    const streak = rows[0] || { current_streak: 0, longest_streak: 0 };
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
    const today = new Date().toISOString().split("T")[0];

    const [habits]: any = await pool.query(
      `SELECT h.*, 
        CASE WHEN hl.id IS NOT NULL THEN 1 ELSE 0 END AS is_completed,
        hl.value AS completed_count, hl.note
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
  const { name, category, frequency, target_count, icon, color } = req.body;

  if (!name) return res.status(400).json({ message: "Tên thói quen không được trống" });

  try {
    const [result]: any = await pool.query(
      `INSERT INTO habits (user_id, name, category, frequency, target_count, icon, color)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        req.user.id,
        name,
        category || "other",
        frequency || "daily",
        target_count || 1,
        icon || "⭐",
        color || "#4CAF50",
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
  const { name, category, icon, color, target_count } = req.body;

  try {
    await pool.query(
      `UPDATE habits SET name = ?, category = ?, icon = ?, color = ?, target_count = ?
       WHERE id = ? AND user_id = ?`,
      [name, category, icon, color, target_count, req.params.id, req.user.id]
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

    res.json({ message: "Habit deleted" });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

// ================= CHECK-IN HABIT =================
router.post("/:id/checkin", authMiddleware, async (req: any, res) => {
  const { note } = req.body;
  const today = new Date().toISOString().split("T")[0];

  try {
    // check xem đã check-in hôm nay chưa
    const [existing]: any = await pool.query(
      "SELECT * FROM habit_logs WHERE habit_id = ? AND log_date = ?",
      [req.params.id, today]
    );

    if (existing.length > 0) {
      // undo check-in
      await pool.query(
        "DELETE FROM habit_logs WHERE habit_id = ? AND log_date = ?",
        [req.params.id, today]
      );
      return res.json({ message: "Unchecked", is_completed: false });
    }

    // check-in mới
    await pool.query(
      `INSERT INTO habit_logs (habit_id, user_id, log_date, note)
       VALUES (?, ?, ?, ?)`,
      [req.params.id, req.user.id, today, note || null]
    );

    // cập nhật streak
    await updateStreak(req.user.id);

    // cập nhật plant
    await updatePlant(req.user.id, today);

    // kiểm tra và unlock achievements
    const newAchievements = await checkAchievements(req.user.id);

    res.json({ message: "Checked in", is_completed: true, new_achievements: newAchievements });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

// helper: cập nhật streak
async function updateStreak(userId: number) {
  const today = new Date().toISOString().split("T")[0];

  const [streakRows]: any = await pool.query(
    "SELECT * FROM streaks WHERE user_id = ?",
    [userId]
  );

  if (streakRows.length === 0) {
    await pool.query(
      "INSERT INTO streaks (user_id, current_streak, longest_streak, last_completed_date) VALUES (?, 1, 1, ?)",
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

  if (lastDate) {
    const diffDays = Math.floor(
      (todayDate.getTime() - lastDate.getTime()) / (1000 * 60 * 60 * 24)
    );

    if (diffDays === 0) return;
    if (diffDays === 1) newStreak += 1;
    else newStreak = 1;
  }

  const longestStreak = Math.max(newStreak, streak.longest_streak);

  await pool.query(
    "UPDATE streaks SET current_streak = ?, longest_streak = ?, last_completed_date = ? WHERE user_id = ?",
    [newStreak, longestStreak, today, userId]
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
  { key: "first_checkin",  title: "Bước đầu tiên",     icon: "🌱", desc: "Hoàn thành check-in đầu tiên" },
  { key: "streak_3",       title: "3 ngày liên tiếp",   icon: "🔥", desc: "Duy trì streak 3 ngày" },
  { key: "streak_7",       title: "Tuần kiên trì",      icon: "⚡", desc: "Duy trì streak 7 ngày" },
  { key: "streak_30",      title: "Tháng bền bỉ",       icon: "🏆", desc: "Duy trì streak 30 ngày" },
  { key: "habits_5",       title: "Đa nhiệm",           icon: "🎯", desc: "Tạo 5 thói quen" },
  { key: "checkin_50",     title: "Nửa trăm",           icon: "💪", desc: "Hoàn thành 50 check-ins" },
  { key: "checkin_100",    title: "Bách chiến",         icon: "🌟", desc: "Hoàn thành 100 check-ins" },
  { key: "plant_level_3",  title: "Cây non",            icon: "🪴", desc: "Cây đạt cấp độ 3" },
  { key: "plant_level_5",  title: "Vườn địa đàng",     icon: "🌳", desc: "Cây đạt cấp độ tối đa" },
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
    first_checkin:  totalCheckins >= 1,
    streak_3:       streak >= 3,
    streak_7:       streak >= 7,
    streak_30:      streak >= 30,
    habits_5:       totalHabits >= 5,
    checkin_50:     totalCheckins >= 50,
    checkin_100:    totalCheckins >= 100,
    plant_level_3:  plantLevel >= 3,
    plant_level_5:  plantLevel >= 5,
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
        },
      });
    }

    const plant = rows[0];

    // check héo: không check-in 3 ngày liên tiếp
    const [lastLog]: any = await pool.query(
      `SELECT MAX(log_date) as last_date FROM habit_logs WHERE user_id = ?`,
      [req.user.id]
    );

    const lastDate = lastLog[0]?.last_date;
    let isWilted = false;
    if (lastDate) {
      const diffDays = Math.floor(
        (new Date().getTime() - new Date(lastDate).getTime()) / (1000 * 60 * 60 * 24)
      );
      isWilted = diffDays >= 3;
    }

    res.json({ plant: { ...plant, is_wilted: isWilted } });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

// helper: cập nhật plant experience và level
async function updatePlant(userId: number, today: string) {
  // Đếm tổng habits active
  const [habitRows]: any = await pool.query(
    "SELECT COUNT(*) as total FROM habits WHERE user_id = ? AND is_active = 1",
    [userId]
  );
  const totalHabits = habitRows[0].total;
  console.log(`[Plant] userId=${userId} totalHabits=${totalHabits}`);
  if (totalHabits === 0) return;

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
  if (points === 0) return;

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
    return;
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
    return;
  }

  const newExp = plant.experience + points;

  // Ngưỡng level: 1→2: 10, 2→3: 30, 3→4: 100, 4→5: 300
  const thresholds = [0, 10, 30, 100, 300];
  let newLevel = plant.level;
  for (let i = thresholds.length - 1; i >= 0; i--) {
    if (newExp >= thresholds[i]) {
      newLevel = Math.min(i + 1, 5);
      break;
    }
  }

  await pool.query(
    `UPDATE plants SET experience = ?, level = ?, last_watered = ? WHERE user_id = ?`,
    [newExp, newLevel, today, userId]
  );
}
