console.log("------------------------- START SERVER... ------------------------");
import express from "express";
import cors from "cors";
import pool from "./config/db";
import authRoutes from "./routes/auth";

const app = express();
app.use(cors());
app.use(express.json());
app.use("/auth", authRoutes);
app.listen(3000, () => {
  console.log("===============🚀 Server running at http://localhost:3000 ===============");
});

app.get("/", async (req, res) => {
  const [rows] = await pool.query("SELECT 1");
  res.json({ message: "API OK", db: rows });
});