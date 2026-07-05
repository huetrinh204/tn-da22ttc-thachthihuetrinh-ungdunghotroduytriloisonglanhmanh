import pool from "../config/db";
import sgMail from "@sendgrid/mail";
import dotenv from "dotenv";
import { sendPushNotification } from "./fcm_push_service";

dotenv.config();

sgMail.setApiKey(process.env.SENDGRID_API_KEY || "");
const FROM_EMAIL = process.env.SENDGRID_FROM_EMAIL || process.env.GMAIL_USER || "";

export async function sendAutoReminders(timeOfDay: 'morning' | 'evening') {
  try {
    console.log(`[AutoReminder] Starting ${timeOfDay} reminder job...`);

    // Check if auto reminder is enabled
    const [settings]: any = await pool.query(
      "SELECT * FROM auto_reminder_settings WHERE id = 1"
    );

    if (settings.length === 0 || settings[0].is_enabled === 0) {
      console.log('[AutoReminder] Auto reminder is disabled');
      return;
    }

    const setting = settings[0];
    
    // Check if we should send for this time of day
    if (timeOfDay === 'morning' && setting.send_morning === 0) {
      console.log('[AutoReminder] Morning reminders are disabled');
      return;
    }
    if (timeOfDay === 'evening' && setting.send_evening === 0) {
      console.log('[AutoReminder] Evening reminders are disabled');
      return;
    }

    // Get active reminder messages
    const [messages]: any = await pool.query(
      "SELECT * FROM auto_reminder_messages WHERE is_active = 1"
    );

    if (messages.length === 0) {
      console.log('[AutoReminder] No active reminder messages');
      return;
    }

    // Select random message
    const randomMessage = messages[Math.floor(Math.random() * messages.length)];
    const messageText = randomMessage.message;

    console.log(`[AutoReminder] Selected message: ${messageText.substring(0, 50)}...`);

    // Get users who have NOT completed all their habits today
    // AND do NOT have personal reminders enabled (to avoid duplicate notifications)
    const today = new Date().toISOString().split('T')[0];
    
    const [users]: any = await pool.query(`
      SELECT DISTINCT u.id, u.name, u.email, u.fcm_token
      FROM users u
      INNER JOIN habits h ON h.user_id = u.id AND h.is_active = 1
      WHERE u.notif_morning_enabled = 0 AND u.notif_evening_enabled = 0
        AND u.id NOT IN (
        SELECT DISTINCT hl.user_id
        FROM habit_logs hl
        INNER JOIN habits h2 ON h2.id = hl.habit_id AND h2.is_active = 1
        WHERE DATE(hl.log_date) = ?
        GROUP BY hl.user_id
        HAVING COUNT(DISTINCT hl.habit_id) >= (
          SELECT COUNT(*) FROM habits WHERE user_id = hl.user_id AND is_active = 1
        )
      )
    `, [today]);

    console.log(`[AutoReminder] Found ${users.length} users who haven't completed habits`);

    if (users.length === 0) {
      console.log('[AutoReminder] All users have completed their habits! 🎉');
      return;
    }

    let emailsSent = 0;
    let notificationsSent = 0;
    let pushNotificationsSent = 0;

    // Send reminders to each user
    for (const user of users) {
      try {
        // Send FCM push notification if fcm_token exists
        if (user.fcm_token && user.fcm_token.trim() !== '') {
          try {
            await sendPushNotification(
              user.fcm_token,
              '⏰ Nhắc nhở từ Viora',
              messageText
            );
            pushNotificationsSent++;
            console.log(`[AutoReminder] Push sent to user ${user.id}`);
          } catch (pushError) {
            console.error(`[AutoReminder] Push notification error for user ${user.id}:`, pushError);
          }
        }

        // Send email via SendGrid
        try {
          await sgMail.send({
            from: FROM_EMAIL,
            to: user.email,
            subject: `⏰ Nhắc nhở từ Viora - ${timeOfDay === 'morning' ? 'Buổi sáng' : 'Buổi tối'}`,
            html: `
              <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <div style="background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%); padding: 30px; border-radius: 10px 10px 0 0;">
                  <h1 style="color: white; margin: 0; font-size: 24px;">🌱 Viora</h1>
                </div>
                <div style="background: white; padding: 30px; border-radius: 0 0 10px 10px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                  <h2 style="color: #4CAF50; margin-top: 0;">Xin chào ${user.name}!</h2>
                  <div style="background: #f0f9f0; padding: 20px; border-left: 4px solid #4CAF50; margin: 20px 0;">
                    <p style="margin: 0; font-size: 16px; color: #333;">${messageText}</p>
                  </div>
                  <p style="color: #666; font-size: 14px;">Hãy mở ứng dụng Viora và hoàn thành thói quen của bạn ngay hôm nay nhé! 💪</p>
                </div>
              </div>
            `
          });
          emailsSent++;
        } catch (emailError) {
          console.error(`[AutoReminder] Email error for user ${user.id}:`, emailError);
        }
      } catch (error) {
        console.error(`[AutoReminder] Error sending to user ${user.id}:`, error);
      }
    }

    console.log(`[AutoReminder] Job completed: ${notificationsSent} in-app notifications, ${pushNotificationsSent} push notifications, ${emailsSent} emails sent`);

  } catch (error) {
    console.error('[AutoReminder] Job error:', error);
  }
}
