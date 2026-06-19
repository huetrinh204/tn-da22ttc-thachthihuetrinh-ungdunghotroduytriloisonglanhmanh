import cron from "node-cron";
import pool from "../config/db";
import { sendMorningReminder, sendEveningReminder } from "./email_service";
import { sendPushNotification } from "./fcm_push_service";
import { sendAutoReminders } from "./autoReminderService";

export function startCronJobs() {
  // Chạy mỗi phút — check user nào đến giờ nhắc
  cron.schedule("* * * * *", async () => {
    await checkAndSendPersonalReminders();
  }, { timezone: "Asia/Ho_Chi_Minh" });

  // Cron email cố định 8:00 sáng
  cron.schedule("0 8 * * *", async () => {
    console.log("[Cron] Running morning email...");
    await sendMorningEmails();
  }, { timezone: "Asia/Ho_Chi_Minh" });

  // Cron email cố định 21:00 tối
  cron.schedule("0 21 * * *", async () => {
    console.log("[Cron] Running evening email...");
    await sendEveningEmails();
  }, { timezone: "Asia/Ho_Chi_Minh" });

  // Auto reminder - check every minute for dynamic scheduling
  cron.schedule("* * * * *", async () => {
    await checkAndSendAutoReminders();
  }, { timezone: "Asia/Ho_Chi_Minh" });

  // Habit-specific reminders — check every minute
  cron.schedule("* * * * *", async () => {
    await checkAndSendHabitReminders();
  }, { timezone: "Asia/Ho_Chi_Minh" });

  // Progressive wilting check - runs at midnight every day
  cron.schedule("0 0 * * *", async () => {
    console.log("[Cron] Running progressive wilting check...");
    await checkProgressiveWilting();
  }, { timezone: "Asia/Ho_Chi_Minh" });

  console.log("[Cron] Jobs scheduled");
}

// Check if it's time to send auto reminders based on admin settings
async function checkAndSendAutoReminders() {
  try {
    // Get settings
    const [settings]: any = await pool.query(
      "SELECT * FROM auto_reminder_settings WHERE id = 1"
    );

    if (settings.length === 0 || settings[0].is_enabled === 0) {
      return; // Auto reminder disabled
    }

    const setting = settings[0];
    const now = new Date();
    const vietnamTime = new Date(now.getTime() + 7 * 60 * 60 * 1000);
    const currentHour = vietnamTime.getUTCHours();
    const currentMinute = vietnamTime.getUTCMinutes();

    // Parse morning time
    if (setting.send_morning === 1 && setting.morning_time) {
      const [mHour, mMinute] = setting.morning_time.split(':').map((n: string) => parseInt(n));
      if (currentHour === mHour && currentMinute === mMinute) {
        console.log('[Cron] Triggering morning auto reminder');
        await sendAutoReminders('morning');
      }
    }

    // Parse evening time
    if (setting.send_evening === 1 && setting.evening_time) {
      const [eHour, eMinute] = setting.evening_time.split(':').map((n: string) => parseInt(n));
      if (currentHour === eHour && currentMinute === eMinute) {
        console.log('[Cron] Triggering evening auto reminder');
        await sendAutoReminders('evening');
      }
    }
  } catch (error) {
    console.error('[Cron] Auto reminder check error:', error);
  }
}

// Kiểm tra từng user xem có đến giờ nhắc không → gửi FCM push
async function checkAndSendPersonalReminders() {
  try {
    const now = new Date();
    const vietnamTime = new Date(now.getTime() + 7 * 60 * 60 * 1000);
    const currentHour = vietnamTime.getUTCHours();
    const currentMinute = vietnamTime.getUTCMinutes();
    const today = vietnamTime.toISOString().split("T")[0];

    // Lấy users có FCM token và giờ nhắc khớp với giờ hiện tại
    const [users]: any = await pool.query(
      `SELECT id, name, fcm_token, 
        notif_morning_enabled, notif_morning_hour, notif_morning_minute,
        notif_evening_enabled, notif_evening_hour, notif_evening_minute
       FROM users 
       WHERE fcm_token IS NOT NULL AND (
         (notif_morning_enabled = 1 AND notif_morning_hour = ? AND notif_morning_minute = ?) OR
         (notif_evening_enabled = 1 AND notif_evening_hour = ? AND notif_evening_minute = ?)
       )`,
      [currentHour, currentMinute, currentHour, currentMinute]
    );

    for (const user of users) {
      const isMorning = user.notif_morning_enabled &&
        user.notif_morning_hour === currentHour &&
        user.notif_morning_minute === currentMinute;

      if (isMorning) {
        await sendPushNotification(
          user.fcm_token,
          "🌱 Chào buổi sáng!",
          `Xin chào ${user.name}! Hôm nay bạn đã sẵn sàng cho thói quen chưa?`
        );
      } else {
        // Evening — chỉ gửi nếu chưa hoàn thành hết
        const [habitRows]: any = await pool.query(
          "SELECT COUNT(*) as total FROM habits WHERE user_id = ? AND is_active = 1",
          [user.id]
        );
        const total = habitRows[0].total;
        if (total === 0) continue;

        const [doneRows]: any = await pool.query(
          `SELECT COUNT(*) as done FROM habit_logs hl
           INNER JOIN habits h ON hl.habit_id = h.id AND h.is_active = 1
           WHERE hl.user_id = ? AND hl.log_date = ?`,
          [user.id, today]
        );
        const done = doneRows[0].done;

        if (done < total) {
          await sendPushNotification(
            user.fcm_token,
            "🌙 Nhắc nhở buổi tối",
            `Bạn còn ${total - done}/${total} thói quen chưa hoàn thành hôm nay!`
          );
        }
      }
    }
  } catch (error) {
    console.error("[Cron] Personal reminder error:", error);
  }
}

// Export để test thủ công
export { sendMorningEmails, sendEveningEmails };

async function sendMorningEmails() {
  try {
    const [users]: any = await pool.query(
      "SELECT id, name, email, fcm_token FROM users WHERE email IS NOT NULL AND email != ''"
    );

    for (const user of users) {
      // Gửi email
      await sendMorningReminder(user.email, user.name);
      // Gửi FCM push nếu có token
      if (user.fcm_token) {
        await sendPushNotification(
          user.fcm_token,
          "🌱 Chào buổi sáng!",
          `Xin chào ${user.name}! Hôm nay bạn đã sẵn sàng cho thói quen chưa?`
        );
      }
    }
    console.log(`[Cron] Morning sent to ${users.length} users`);
  } catch (error) {
    console.error("[Cron] Morning error:", error);
  }
}

async function sendEveningEmails() {
  try {
    const today = new Date().toISOString().split("T")[0];
    const [users]: any = await pool.query(
      "SELECT id, name, email, fcm_token FROM users WHERE email IS NOT NULL AND email != ''"
    );

    let sentCount = 0;
    for (const user of users) {
      const [habitRows]: any = await pool.query(
        "SELECT COUNT(*) as total FROM habits WHERE user_id = ? AND is_active = 1",
        [user.id]
      );
      const total = habitRows[0].total;
      if (total === 0) continue;

      const [doneRows]: any = await pool.query(
        `SELECT COUNT(*) as done FROM habit_logs hl
         INNER JOIN habits h ON hl.habit_id = h.id AND h.is_active = 1
         WHERE hl.user_id = ? AND hl.log_date = ?`,
        [user.id, today]
      );
      const done = doneRows[0].done;

      if (done < total) {
        // Gửi email
        await sendEveningReminder(user.email, user.name, done, total);
        // Gửi FCM push nếu có token
        if (user.fcm_token) {
          await sendPushNotification(
            user.fcm_token,
            "🌙 Nhắc nhở buổi tối",
            `Bạn còn ${total - done}/${total} thói quen chưa hoàn thành hôm nay!`
          );
        }
        sentCount++;
      }
    }
    console.log(`[Cron] Evening sent to ${sentCount}/${users.length} users`);
  } catch (error) {
    console.error("[Cron] Evening error:", error);
  }
}


/**
 * Habit-specific reminders (per user, per habit)
 * - Each habit has its own reminder_time set by the user
 * - Repeats every 20 minutes for up to 1 hour (4 notifications max)
 * - Stops when habit is completed for the day
 */
async function checkAndSendHabitReminders() {
  try {
    const now = new Date();
    const vietnamTime = new Date(now.getTime() + 7 * 60 * 60 * 1000);
    const currentHour = vietnamTime.getUTCHours();
    const currentMinute = vietnamTime.getUTCMinutes();
    const today = vietnamTime.toISOString().split("T")[0];

    // Lấy tất cả habits có reminder_time, chưa hoàn thành hôm nay, và user có fcm_token
    const [habits]: any = await pool.query(
      `SELECT h.id as habit_id, h.name as habit_name, h.reminder_time,
              u.id as user_id, u.fcm_token
       FROM habits h
       INNER JOIN users u ON h.user_id = u.id
       WHERE h.reminder_time IS NOT NULL
         AND h.is_active = 1
         AND u.fcm_token IS NOT NULL
         AND h.id NOT IN (
           SELECT habit_id FROM habit_logs
           WHERE log_date = ? AND is_completed = 1
         )`,
      [today]
    );

    for (const habit of habits) {
      const reminderTime = habit.reminder_time as string; // format "HH:MM" or "HH:MM:SS"
      const parts = reminderTime.split(':');
      const rHour = parseInt(parts[0]);
      const rMinute = parseInt(parts[1]);

      // Tính số phút đã trôi qua kể từ reminder_time
      const reminderTotalMin = rHour * 60 + rMinute;
      const currentTotalMin = currentHour * 60 + currentMinute;
      const diffMin = currentTotalMin - reminderTotalMin;

      // Chỉ gửi trong khoảng 0 → 60 phút sau reminder_time
      if (diffMin < 0 || diffMin > 60) continue;

      // Gửi tại phút 0, 20, 40, 60
      if (diffMin % 20 !== 0) continue;

      await sendPushNotification(
        habit.fcm_token,
        '⏰ Đến giờ rồi!',
        `Đã đến lúc thực hiện thói quen "${habit.habit_name}" 💪`
      );

      console.log(`[HabitReminder] Sent to user=${habit.user_id} habit="${habit.habit_name}" at +${diffMin}min`);
    }
  } catch (error) {
    console.error('[Cron] Habit reminder error:', error);
  }
}

/**
 * Progressive Wilting System
 * - Day 1: No penalty, warning only
 * - Day 2: Light warning, plant starts to look sad
 * - Day 3: Plant wilts, -3 EXP penalty
 * - Day 4+: Continue -3 EXP per day until user checks in
 */
async function checkProgressiveWilting() {
  try {
    const today = new Date().toISOString().split("T")[0];
    const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString().split("T")[0];

    // Get all users with their plants
    const [users]: any = await pool.query(`
      SELECT u.id as user_id, u.name, u.email, u.fcm_token,
             p.id as plant_id, p.experience, p.days_without_checkin, 
             p.is_wilted, p.last_penalty_date,
             COALESCE(s.freeze_tokens, 0) as freeze_tokens
      FROM users u
      LEFT JOIN plants p ON u.id = p.user_id
      LEFT JOIN streaks s ON s.user_id = u.id
      WHERE p.id IS NOT NULL
    `);

    for (const user of users) {
      // Check if user completed any active habit yesterday
      const [logs]: any = await pool.query(
        `SELECT COUNT(*) as count 
         FROM habit_logs hl
         INNER JOIN habits h ON hl.habit_id = h.id AND h.is_active = 1
         WHERE hl.user_id = ? AND hl.log_date = ?`,
        [user.user_id, yesterday]
      );

      const completedYesterday = logs[0].count > 0;

      if (completedYesterday) {
        // User was active yesterday - reset counter
        if (user.days_without_checkin > 0) {
          await pool.query(
            `UPDATE plants 
             SET days_without_checkin = 0, 
                 is_wilted = 0,
                 last_penalty_date = NULL
             WHERE id = ?`,
            [user.plant_id]
          );
          console.log(`[Wilting] User ${user.name} (${user.user_id}) recovered - reset to 0 days`);
        }
      } else {
        // User didn't complete any habit yesterday - increment counter
        const newDays = user.days_without_checkin + 1;
        
        // Update days without check-in
        await pool.query(
          `UPDATE plants SET days_without_checkin = ? WHERE id = ?`,
          [newDays, user.plant_id]
        );

        console.log(`[Wilting] User ${user.name} (${user.user_id}) - ${newDays} days without check-in`);

        // Apply penalties based on days
        if (newDays >= 3) {
          // Kiểm tra còn freeze token không
          if (user.freeze_tokens > 0) {
            const newTokens = user.freeze_tokens - 1;
            await pool.query(
              "UPDATE streaks SET freeze_tokens = ? WHERE user_id = ?",
              [newTokens, user.user_id]
            );
            await pool.query(
              "UPDATE plants SET days_without_checkin = 0, is_wilted = 0 WHERE id = ?",
              [user.plant_id]
            );
            console.log(`[Wilting] User ${user.name} - Freeze token used! Tokens left: ${newTokens}`);
            if (user.fcm_token) {
              await sendPushNotification(
                user.fcm_token,
                "🧊 Streak Freeze đã được dùng!",
                `Bạn đã bỏ lỡ hôm qua nhưng streak được bảo vệ. Còn ${newTokens} freeze token. Hãy check-in hôm nay! 💪`
              );
            }
          } else {
            // Không có freeze token → phạt bình thường
            const shouldApplyPenalty = !user.last_penalty_date || user.last_penalty_date !== today;
            
            if (shouldApplyPenalty) {
              const penalty = 3;
              const newExp = Math.max(0, user.experience - penalty);
              
              await pool.query(
                `UPDATE plants 
                 SET is_wilted = 1, 
                     experience = ?,
                     last_penalty_date = ?
                 WHERE id = ?`,
                [newExp, today, user.plant_id]
              );

              console.log(`[Wilting] User ${user.name} - Plant wilted! Applied -${penalty} EXP penalty`);

              if (user.fcm_token) {
                await sendPushNotification(
                  user.fcm_token,
                  "🍂 Cây của bạn đang héo!",
                  `Cây đã bị mất ${penalty} điểm vì không check-in ${newDays} ngày. Hãy quay lại ngay! 💧`
                );
              }
            }
          }
        } else if (newDays === 2) {
          // Warning only - no penalty yet
          if (user.fcm_token) {
            await sendPushNotification(
              user.fcm_token,
              "⚠️ Cây cần được chăm sóc!",
              "Cây sẽ bị héo và mất điểm nếu bạn không check-in trong 24 giờ tới!"
            );
          }
        }
      }
    }

    console.log(`[Wilting] Processed ${users.length} users`);
  } catch (error) {
    console.error("[Cron] Progressive wilting error:", error);
  }
}
