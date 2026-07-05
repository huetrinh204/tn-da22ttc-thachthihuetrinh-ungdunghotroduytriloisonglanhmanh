import mysql from "mysql2/promise";
import dotenv from "dotenv";

dotenv.config();

const pool = mysql.createPool({
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASSWORD || "",
  database: process.env.DB_NAME || "viora_app",
  port: parseInt(process.env.DB_PORT || "3306"),
  timezone: "+00:00", // Store as UTC, Flutter will convert to local time
  dateStrings: true,   // Return all date/time types as strings, not Date objects
  ssl: process.env.DB_SSL === "true" ? { rejectUnauthorized: false } : undefined,
});

export default pool;
