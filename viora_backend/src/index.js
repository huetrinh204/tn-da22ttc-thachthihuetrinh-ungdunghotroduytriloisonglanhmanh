"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
console.log("------------------------- START SERVER... ------------------------");
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const path_1 = __importDefault(require("path"));
const db_1 = __importDefault(require("./config/db"));
const auth_1 = __importDefault(require("./routes/auth"));
const habits_1 = __importDefault(require("./routes/habits"));
const stats_1 = __importDefault(require("./routes/stats"));
const community_1 = __importDefault(require("./routes/community"));
const admin_1 = __importDefault(require("./routes/admin"));
const ai_1 = __importDefault(require("./routes/ai"));
const cron_service_1 = require("./services/cron_service");
const app = (0, express_1.default)();
app.use((0, cors_1.default)());
app.use(express_1.default.json());
// Request logger middleware
app.use((req, res, next) => {
    const start = Date.now();
    res.on("finish", () => {
        console.log(`[HTTP] ${req.method} ${req.originalUrl || req.url} - ${res.statusCode} (${Date.now() - start}ms)`);
    });
    next();
});
app.use("/uploads", express_1.default.static(path_1.default.join(__dirname, "../uploads")));
app.use("/auth", auth_1.default);
app.use("/habits", habits_1.default);
app.use("/stats", stats_1.default);
app.use("/community", community_1.default);
app.use("/admin", admin_1.default);
app.use("/ai", ai_1.default);
app.listen(3000, () => {
    console.log("===============🚀 Server running at http://localhost:3000 ===============");
    (0, cron_service_1.startCronJobs)();
});
app.get("/", async (req, res) => {
    const [rows] = await db_1.default.query("SELECT 1");
    res.json({ message: "API OK", db: rows });
});
// Test endpoints — gửi email ngay không cần chờ cron
app.get("/test/morning-email", async (req, res) => {
    await (0, cron_service_1.sendMorningEmails)();
    res.json({ message: "Morning emails sent" });
});
app.get("/test/evening-email", async (req, res) => {
    await (0, cron_service_1.sendEveningEmails)();
    res.json({ message: "Evening emails sent (incomplete habits only)" });
});
