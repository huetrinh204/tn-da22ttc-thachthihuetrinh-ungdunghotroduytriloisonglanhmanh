import cron from "node-cron";
import pool from "../config/db";
import { sendMorningReminder, sendEveningReminder } from "./email_service";
import { sendPushNotification } from "./fcm_push_service";

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

  console.log("[Cron] Jobs scheduled");
}

// Kiểm tra từng user xem có đến giờ nhắc không → gửi FCM push
async function checkAndSendPersonalReminders() {
  try {
    const now = new Date(new Date().toLocaleString("en-US", { timeZone: "Asia/Ho_Chi_Minh" }));
    const currentHour = now.getHours();
    const currentMinute = now.getMinutes();
    const today = now.toISOString().split("T")[0];

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
          "SELECT COUNT(*) as done FROM habit_logs WHERE user_id = ? AND log_date = ?",
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
        "SELECT COUNT(*) as done FROM habit_logs WHERE user_id = ? AND log_date = ?",
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
