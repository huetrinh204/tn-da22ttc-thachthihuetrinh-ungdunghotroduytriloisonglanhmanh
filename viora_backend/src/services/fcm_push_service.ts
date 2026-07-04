import * as admin from "firebase-admin";
import dotenv from "dotenv";

dotenv.config();

// Init Firebase Admin một lần
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, "\n"),
    }),
    storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
  });
}

export async function sendPushNotification(
  fcmToken: string,
  title: string,
  body: string,
  userId?: number | string
) {
  try {
    const message: any = {
      token: fcmToken,
      notification: { title, body },
      android: {
        priority: "high",
        notification: {
          sound: "default",
          channelId: "viora_fcm",
        },
      },
    };
    if (userId != null) {
      message.data = { userId: String(userId) };
    }
    await admin.messaging().send(message);
    console.log(`[FCM] Push sent to token: ${fcmToken.substring(0, 20)}...`);
  } catch (err) {
    console.error(`[FCM] Failed:`, err);
  }
}
