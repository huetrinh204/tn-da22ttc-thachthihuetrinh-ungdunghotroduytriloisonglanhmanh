import cron from "node-cron";
import pool from "../config/db";
import { sendMorningReminder, sendEveningReminder } from "./email_service";

export function startCronJobs() {
  cron.schedule("0 8 * * *", async () => {
    console.log("[Cron] Running morning reminder...");
    await sendMorningEmails();
  }, { timezone: "Asia/Ho_Chi_Minh" });

  cron.schedule("0 21 * * *", async () => {
    console.log("[Cron] Running evening reminder...");
    await sendEveningEmails();
  }, { timezone: "Asia/Ho_Chi_Minh" });

  console.log("[Cron] Jobs scheduled: 8:00 AM & 9:00 PM (Asia/Ho_Chi_Minh)");
}

// Export để test thủ công
export { sendMorningEmails, sendEveningEmails };

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

      // Chỉ gửi nếu chưa hoàn thành hết
      if (done < total) {
        await sendEveningReminder(user.email, user.name, done, total);
        sentCount++;
      }
    }
    console.log(`[Cron] Evening emails sent to ${sentCount}/${users.length} users (incomplete habits only)`);
  } catch (error) {
    console.error("[Cron] Evening email error:", error);
  }
}
