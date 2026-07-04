"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const promise_1 = __importDefault(require("mysql2/promise"));
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
const pool = promise_1.default.createPool({
    host: process.env.DB_HOST || "localhost",
    user: process.env.DB_USER || "root",
    password: process.env.DB_PASSWORD || "",
    database: process.env.DB_NAME || "viora_app",
    port: parseInt(process.env.DB_PORT || "3306"),
    timezone: "+07:00", // Set timezone to Vietnam (UTC+7)
    dateStrings: true, // Return all date/time types as strings, not Date objects
    ssl: process.env.DB_SSL === "true" ? { rejectUnauthorized: false } : undefined,
});

exports.default = pool;
