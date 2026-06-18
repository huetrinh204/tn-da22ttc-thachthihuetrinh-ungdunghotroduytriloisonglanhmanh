console.log("------------------------- START SERVER... ------------------------");
import express from "express";
import cors from "cors";
import path from "path";
import pool from "./config/db";
import authRoutes from "./routes/auth";
import habitRoutes from "./routes/habits";
import statsRoutes from "./routes/stats";
import communityRoutes from "./routes/community";
import adminRoutes from "./routes/admin";
import aiRoutes from "./routes/ai";
import { startCronJobs, sendMorningEmails, sendEveningEmails } from "./services/cron_service";

const app = express();
app.use(cors());
app.use(express.json());

// Request logger middleware
app.use((req, res, next) => {
  const start = Date.now();
  res.on("finish", () => {
    console.log(`[HTTP] ${req.method} ${req.originalUrl || req.url} - ${res.statusCode} (${Date.now() - start}ms)`);
  });
  next();
});

app.use("/uploads", express.static(path.join(__dirname, "../uploads")));
app.use("/auth", authRoutes);
app.use("/habits", habitRoutes);
app.use("/stats", statsRoutes);
app.use("/community", communityRoutes);
app.use("/admin", adminRoutes);
app.use("/ai", aiRoutes);
app.listen(3000, () => {
  console.log("===============🚀 Server running at http://localhost:3000 ===============");
  startCronJobs();
});

app.get("/", async (req, res) => {
  const [rows] = await pool.query("SELECT 1");
  res.json({ message: "API OK", db: rows });
});

// Test endpoints — gửi email ngay không cần chờ cron
app.get("/test/morning-email", async (req, res) => {
  await sendMorningEmails();
  res.json({ message: "Morning emails sent" });
});

app.get("/test/evening-email", async (req, res) => {
  await sendEveningEmails();
  res.json({ message: "Evening emails sent (incomplete habits only)" });
});