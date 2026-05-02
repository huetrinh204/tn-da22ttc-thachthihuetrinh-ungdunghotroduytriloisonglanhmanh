import { Router } from "express";
import pool from "../config/db";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { OAuth2Client } from "google-auth-library";
import { sendOtpEmail } from "../services/email_service";
import dotenv from "dotenv";

dotenv.config();

const router = Router();
const JWT_SECRET = process.env.JWT_SECRET || "secret_key";

// 👉 Google client
const GOOGLE_CLIENT_ID =
  process.env.GOOGLE_CLIENT_ID || "971894407814-sdhs1msoj8v96c13cc7jle7coq95dfcd.apps.googleusercontent.com";

const client = new OAuth2Client(GOOGLE_CLIENT_ID);


// ================= REGISTER =================
router.post("/register", async (req, res) => {
  const { name, email, password } = req.body;

  if (!name || !email || !password) {
    return res.status(400).json({ message: "Missing fields" });
  }

  try {
    const [existing]: any = await pool.query(
      "SELECT * FROM users WHERE email = ?",
      [email]
    );

    if (existing.length > 0) {
      return res.status(400).json({ message: "Email already exists" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const [result]: any = await pool.query(
      "INSERT INTO users (name, email, password) VALUES (?, ?, ?)",
      [name, email, hashedPassword]
    );

    const userId = result.insertId;

    // trả về token luôn để vào onboarding
    const token = jwt.sign(
      { id: userId, email },
      JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.json({ message: "Register success", token });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});


// ================= GET PROFILE =================
router.get("/profile", async (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) return res.status(401).json({ message: "Unauthorized" });

  const token = authHeader.split(" ")[1];

  try {
    const decoded: any = jwt.verify(token, JWT_SECRET);
    const [rows]: any = await pool.query(
      "SELECT id, name, email, gender, birth_year, height, weight, goals, created_at FROM users WHERE id = ?",
      [decoded.id]
    );

    if (rows.length === 0) return res.status(404).json({ message: "User not found" });

    res.json({ user: rows[0] });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});


// ================= UPDATE PROFILE =================
router.put("/profile", async (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) return res.status(401).json({ message: "Unauthorized" });

  const token = authHeader.split(" ")[1];

  try {
    const decoded: any = jwt.verify(token, JWT_SECRET);
    const { name, gender, birth_year, height, weight, goals } = req.body;

    // Build dynamic update query — chỉ update field nào được gửi lên
    const fields: string[] = [];
    const values: any[] = [];

    if (name !== undefined) { fields.push("name = ?"); values.push(name.trim()); }
    if (gender !== undefined) { fields.push("gender = ?"); values.push(gender); }
    if (birth_year !== undefined) { fields.push("birth_year = ?"); values.push(birth_year); }
    if (height !== undefined) { fields.push("height = ?"); values.push(height); }
    if (weight !== undefined) { fields.push("weight = ?"); values.push(weight); }
    if (goals !== undefined) { fields.push("goals = ?"); values.push(JSON.stringify(goals)); }

    if (fields.length === 0) {
      return res.status(400).json({ message: "No fields to update" });
    }

    values.push(decoded.id);
    await pool.query(
      `UPDATE users SET ${fields.join(", ")} WHERE id = ?`,
      values
    );

    res.json({ message: "Profile updated" });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});


// ================= LOGIN =================
router.post("/login", async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: "Missing fields" });
  }

  try {
    const [rows]: any = await pool.query(
      "SELECT * FROM users WHERE email = ?",
      [email]
    );

    if (rows.length === 0) {
      return res.status(400).json({ message: "User not found" });
    }

    const user = rows[0];

    // ❗ nếu là account Google thì không login bằng password
    if (!user.password) {
      return res.status(400).json({
        message: "Please login with Google",
      });
    }

    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(400).json({ message: "Wrong password" });
    }

    const token = jwt.sign(
      { id: user.id, email: user.email },
      JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.json({
      message: "Login success",
      token,
    });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});


// ================= GOOGLE LOGIN =================
router.post("/google", async (req, res) => {
  const { token } = req.body;

  if (!token) {
    return res.status(400).json({ message: "Token is required" });
  }

  try {
    const ticket = await client.verifyIdToken({
      idToken: token,
      audience: [
        "971894407814-sdhs1msoj8v96c13cc7jle7coq95dfcd.apps.googleusercontent.com",
        "971894407814-7stj4uu1l0klka0rldq9a7ulsudei802.apps.googleusercontent.com",
      ],
    });

    const payload = ticket.getPayload();

    const email = payload?.email;
    const name = payload?.name;

    if (!email) {
      return res.status(400).json({ message: "Invalid token" });
    }

    // 🔍 check user tồn tại chưa
    const [rows]: any = await pool.query(
      "SELECT * FROM users WHERE email = ?",
      [email]
    );

    let userId;

    if (rows.length === 0) {
      // 👉 tạo user mới (Google)
      const [result]: any = await pool.query(
        "INSERT INTO users (name, email, password) VALUES (?, ?, ?)",
        [name || "Google User", email, ""]
      );

      userId = result.insertId;
    } else {
      userId = rows[0].id;
    }

    // 🎟️ tạo JWT
    const jwtToken = jwt.sign(
      { id: userId, email },
      JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.json({
      message: "Login success",
      token: jwtToken,
    });

  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Google login failed" });
  }
});

// ================= UPDATE PASSWORD =================
router.put("/password", async (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) return res.status(401).json({ message: "Unauthorized" });
  const token = authHeader.split(" ")[1];

  try {
    const decoded: any = jwt.verify(token, JWT_SECRET);
    const { current_password, new_password } = req.body;

    if (!current_password || !new_password) {
      return res.status(400).json({ message: "Missing fields" });
    }

    const [rows]: any = await pool.query(
      "SELECT * FROM users WHERE id = ?", [decoded.id]
    );
    if (rows.length === 0) return res.status(404).json({ message: "User not found" });

    const user = rows[0];
    if (!user.password) {
      return res.status(400).json({ message: "Tài khoản Google không thể đổi mật khẩu" });
    }

    const isMatch = await bcrypt.compare(current_password, user.password);
    if (!isMatch) return res.status(400).json({ message: "Mật khẩu hiện tại không đúng" });

    const hashed = await bcrypt.hash(new_password, 10);
    await pool.query("UPDATE users SET password = ? WHERE id = ?", [hashed, decoded.id]);

    res.json({ message: "Password updated" });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

// ================= SAVE NOTIFICATION SETTINGS =================
router.put("/notification-settings", async (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) return res.status(401).json({ message: "Unauthorized" });
  const token = authHeader.split(" ")[1];
  try {
    const decoded: any = jwt.verify(token, JWT_SECRET);
    const {
      morning_enabled, morning_hour, morning_minute,
      evening_enabled, evening_hour, evening_minute
    } = req.body;
    await pool.query(
      `UPDATE users SET 
        notif_morning_enabled = ?, notif_morning_hour = ?, notif_morning_minute = ?,
        notif_evening_enabled = ?, notif_evening_hour = ?, notif_evening_minute = ?
       WHERE id = ?`,
      [morning_enabled, morning_hour, morning_minute,
       evening_enabled, evening_hour, evening_minute, decoded.id]
    );
    res.json({ message: "Settings saved" });
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
});

// ================= SAVE FCM TOKEN =================
router.post("/fcm-token", async (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) return res.status(401).json({ message: "Unauthorized" });
  const token = authHeader.split(" ")[1];
  try {
    const decoded: any = jwt.verify(token, JWT_SECRET);
    const { fcm_token } = req.body;
    await pool.query("UPDATE users SET fcm_token = ? WHERE id = ?",
      [fcm_token, decoded.id]);
    res.json({ message: "FCM token saved" });
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
});

// ================= SEND OTP (quên mật khẩu) =================
router.post("/forgot-password", async (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ message: "Vui lòng nhập email" });

  try {
    const [rows]: any = await pool.query(
      "SELECT id, name FROM users WHERE email = ?", [email]);
    if (rows.length === 0) {
      return res.json({ message: "Nếu email tồn tại, mã OTP đã được gửi" });
    }

    const user = rows[0];
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 phút

    // Lưu OTP thẳng vào bảng users — tự ghi đè OTP cũ
    await pool.query(
      "UPDATE users SET otp_code = ?, otp_expires_at = ? WHERE email = ?",
      [code, expiresAt, email]);

    // Gửi email qua Gmail
    await sendOtpEmail(email, user.name, code);

    res.json({ message: "Nếu email tồn tại, mã OTP đã được gửi" });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

// ================= VERIFY OTP & RESET PASSWORD =================
router.post("/reset-password", async (req, res) => {
  const { email, code, new_password } = req.body;
  if (!email || !code || !new_password) {
    return res.status(400).json({ message: "Thiếu thông tin" });
  }

  try {
    const [rows]: any = await pool.query(
      `SELECT id FROM users 
       WHERE email = ? AND otp_code = ? AND otp_expires_at > NOW()`,
      [email, code]);

    if (rows.length === 0) {
      return res.status(400).json({ message: "Mã OTP không hợp lệ hoặc đã hết hạn" });
    }

    if (new_password.length < 8) {
      return res.status(400).json({ message: "Mật khẩu tối thiểu 8 ký tự" });
    }

    const hashed = await bcrypt.hash(new_password, 10);

    // Đổi mật khẩu và xóa OTP luôn
    await pool.query(
      "UPDATE users SET password = ?, otp_code = NULL, otp_expires_at = NULL WHERE email = ?",
      [hashed, email]);

    res.json({ message: "Đặt lại mật khẩu thành công" });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: "Server error" });
  }
});

export default router;