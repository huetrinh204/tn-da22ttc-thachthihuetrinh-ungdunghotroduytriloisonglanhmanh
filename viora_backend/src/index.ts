console.log("------------------------- START SERVER... ------------------------");
import express from "express";
import cors from "cors";
import pool from "./config/db";
import authRoutes from "./routes/auth";
import habitRoutes from "./routes/habits";
import statsRoutes from "./routes/stats";
import { startCronJobs } from "./services/cron_service";

const app = express();
app.use(cors());
app.use(express.json());
app.use("/auth", authRoutes);
app.use("/habits", habitRoutes);
app.use("/stats", statsRoutes);
app.listen(3000, () => {
  console.log("===============🚀 Server running at http://localhost:3000 ===============");
  startCronJobs();
});

app.get("/", async (req, res) => {
  const [rows] = await pool.query("SELECT 1");
  res.json({ message: "API OK", db: rows });
});