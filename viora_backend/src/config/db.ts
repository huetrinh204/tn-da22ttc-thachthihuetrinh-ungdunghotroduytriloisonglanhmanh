import mysql from "mysql2/promise";

const pool = mysql.createPool({
  host: "localhost",
  user: "root",
  password: "111111",
  database: "viora_app",
});

export default pool;