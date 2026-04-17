import { Router } from "express";
import pool from "../config/db";
const router = Router();
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";

// REGISTER
router.post("/register", async (req, res) => {
  const { name, email, password } = req.body;

  try {
    // 🔐 hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    await pool.query(
      "INSERT INTO users (name, email, password) VALUES (?, ?, ?)",
      [name, email, hashedPassword]
    );

    res.json({ message: "Register success" });
  } catch (error) {
    console.log(error);
    res.status(500).json({ error });
  }
});



// LOGIN
router.post("/login", async (req, res) => {
  const { email, password } = req.body;

  try {
    const [rows]: any = await pool.query(
      "SELECT * FROM users WHERE email = ?",
      [email]
    );

    if (rows.length === 0) {
      return res.status(400).json({ message: "User not found" });
    }

    const user = rows[0];

    // 🔐 so sánh password
    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(400).json({ message: "Wrong password" });
    }

    // 🎟️ tạo token
    const token = jwt.sign(
      { id: user.id, email: user.email },
      "SECRET_KEY",
      { expiresIn: "7d" }
    );

    res.json({
      message: "Login success",
      token,
    });
  } catch (error) {
    console.log(error);
    res.status(500).json({ error });
  }
});

export default router;
