import cron from "node-cron";
import pool from "../config/db";
import { sendMorningReminder, sendEveningReminder } from "./email_service";

export function startCronJobs() {
  // Sáng 8:00 — nhắc bắt đầu ngày
  cron.schedule("0 8 * * *", async () => {
    console.log("[Cron] Running morning reminder...");
    await sendMorningEmails();
  }, { timezone: "Asia/Ho_Chi_Minh" });

  // Tối 21:00 — nhắc hoàn thành + tổng kết
  cron.schedule("0 21 * * *", async () => {
    console.log("[Cron] Running evening reminder...");
    await sendEveningEmails();
  }, { timezone: "Asia/Ho_Chi_Minh" });

  console.log("[Cron] Jobs scheduled: 8:00 AM & 9:00 PM (Asia/Ho_Chi_Minh)");
}

async function sendMorningEmails() {
  try {
    const [users]: any = await pool.query(
      "SELECT id, name, email FROM users WHERE email IS NOT NULL AND email != ''"
    );

    for (const user of users) {
      await sendMorningReminder(user.email, user.name);
    }
    console.log(`[Cron] Morning emails sent to ${users.length} users`);
  } catch (error) {
    console.error("[Cron] Morning email error:", error);
  }
}

async function sendEveningEmails() {
  try {
    const today = new Date().toISOString().split("T")[0];

    const [users]: any = await pool.query(
      "SELECT id, name, email FROM users WHERE email IS NOT NULL AND email != ''"
    );

    for (const user of users) {
      // Đếm tổng habits active
      const [habitRows]: any = await pool.query(
        "SELECT COUNT(*) as total FROM habits WHERE user_id = ? AND is_active = 1",
        [user.id]
      );
      const total = habitRows[0].total;
      if (total === 0) continue;

      // Đếm habits đã check-in hôm nay
      const [doneRows]: any = await pool.query(
        "SELECT COUNT(*) as done FROM habit_logs WHERE user_id = ? AND log_date = ?",
        [user.id, today]
      );
      const done = doneRows[0].done;

      await sendEveningReminder(user.email, user.name, done, total);
    }
    console.log(`[Cron] Evening emails sent to ${users.length} users`);
  } catch (error) {
    console.error("[Cron] Evening email error:", error);
  }
}
