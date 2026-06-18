import { Router, Response } from "express";
import pool from "../config/db";
import jwt from "jsonwebtoken";
import dotenv from "dotenv";

dotenv.config();

const router = Router();
const JWT_SECRET = process.env.JWT_SECRET || "secret_key";
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

// Warn at module load if API key is not configured
if (!GEMINI_API_KEY) {
  console.warn("[AI] WARNING: GEMINI_API_KEY is not configured. The /ai/chat endpoint will return 503.");
}

// ─── Interfaces ──────────────────────────────────────────────────────────────

export interface ConversationTurn {
  role: "user" | "model";
  parts: [{ text: string }];
}

export interface UserContext {
  userName: string;
  habits: { name: string; category: string }[];
  completedToday: number;
  totalToday: number;
  currentStreak: number;
}

// ─── Auth Middleware ──────────────────────────────────────────────────────────

function authMiddleware(req: any, res: Response, next: () => void) {
  const authHeader = req.headers.authorization;
  if (!authHeader) return res.status(401).json({ message: "Unauthorized" });

  const token = authHeader.split(" ")[1];
  try {
    const decoded = jwt.verify(token, JWT_SECRET) as { id: number; email?: string };
    req.user = decoded;
    next();
  } catch {
    return res.status(401).json({ message: "Invalid token" });
  }
}

// ─── Context Builder ──────────────────────────────────────────────────────────

export async function buildUserContext(userId: number, dbPool = pool): Promise<UserContext> {
  const emptyContext: UserContext = {
    userName: "",
    habits: [],
    completedToday: 0,
    totalToday: 0,
    currentStreak: 0,
  };

  try {
    // Query user name
    const [userRows] = await dbPool.query(
      "SELECT name FROM users WHERE id = ?",
      [userId]
    ) as any;

    // Query active habits — không dùng is_archived vì cột chưa tồn tại
    const [habitRows] = await dbPool.query(
      "SELECT name, category FROM habits WHERE user_id = ?",
      [userId]
    ) as any;

    // Query current streak
    const [streakRows] = await dbPool.query(
      "SELECT current_streak FROM streaks WHERE user_id = ?",
      [userId]
    ) as any;

    // Query completed today
    const [completedRows] = await dbPool.query(
      "SELECT COUNT(*) as completed FROM habit_logs WHERE user_id = ? AND DATE(log_date) = CURDATE()",
      [userId]
    ) as any;

    // Query total habits for today
    const [totalRows] = await dbPool.query(
      "SELECT COUNT(*) as total FROM habits WHERE user_id = ?",
      [userId]
    ) as any;

    return {
      userName: userRows[0]?.name ?? "",
      habits: Array.isArray(habitRows)
        ? habitRows.map((h: any) => ({ name: h.name, category: h.category }))
        : [],
      completedToday: Number(completedRows[0]?.completed ?? 0),
      totalToday: Number(totalRows[0]?.total ?? 0),
      currentStreak: Number(streakRows[0]?.current_streak ?? 0),
    };
  } catch (err) {
    console.error("[AI] Failed to build user context:", err);
    return emptyContext;
  }
}

// ─── Context Formatter ────────────────────────────────────────────────────────

export function formatContextText(ctx: UserContext): string {
  const habitsList =
    ctx.habits.length > 0
      ? ctx.habits.map((h) => `• ${h.name} (${h.category})`).join("\n")
      : "Chưa có thói quen nào.";

  return [
    `Tên người dùng: ${ctx.userName || "Bạn"}`,
    `Streak hiện tại: ${ctx.currentStreak} ngày`,
    `Tiến độ hôm nay: ${ctx.completedToday}/${ctx.totalToday} thói quen đã hoàn thành`,
    `Danh sách thói quen:\n${habitsList}`,
  ].join("\n");
}

// ─── System Prompt Builder ────────────────────────────────────────────────────

export function buildSystemPrompt(ctx: UserContext): string {
  const staticPrompt = `Bạn là Viora Coach — một huấn luyện viên lối sống lành mạnh thân thiện, tích cực và khoa học.
Bạn hỗ trợ người dùng cải thiện sức khỏe thể chất và tinh thần thông qua thói quen hàng ngày.

NGUYÊN TẮC:
- Luôn trả lời bằng tiếng Việt, thân thiện và không phán xét
- Giữ câu trả lời ngắn gọn, tối đa 300 từ
- Khi phù hợp, đưa ra ít nhất 1 bước hành động cụ thể
- Nếu câu hỏi ngoài phạm vi sức khỏe, dinh dưỡng, thói quen lành mạnh — lịch sự từ chối và gợi ý quay lại chủ đề phù hợp`;

  const contextSection = `\nTHÔNG TIN NGƯỜI DÙNG:\n${formatContextText(ctx)}\n\nHãy cá nhân hóa lời khuyên dựa trên thông tin trên.`;

  return staticPrompt + contextSection;
}

// ─── Gemini Client ────────────────────────────────────────────────────────────

export async function callGemini(
  systemPrompt: string,
  userMessage: string,
  history: ConversationTurn[]
): Promise<string> {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    throw new Error("GEMINI_API_KEY is not configured");
  }

  const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${apiKey}`;

  const contents: ConversationTurn[] = [
    ...history,
    {
      role: "user",
      parts: [{ text: userMessage }],
    },
  ];

  const body = {
    system_instruction: {
      parts: [{ text: systemPrompt }],
    },
    contents,
    generationConfig: {
      maxOutputTokens: 1024,
      temperature: 0.7,
    },
  };

  const response = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    const errorText = await response.text().catch(() => "unknown error");
    // 429 = quota exceeded — throw riêng để caller có thể xử lý thân thiện
    if (response.status === 429) {
      throw Object.assign(
        new Error("Gemini API rate limit exceeded"),
        { statusCode: 429 }
      );
    }
    throw new Error(`Gemini API error ${response.status}: ${errorText}`);
  }

  const data = (await response.json()) as any;
  const replyText: string | undefined =
    data?.candidates?.[0]?.content?.parts?.[0]?.text;

  if (!replyText) {
    throw new Error("Gemini API returned empty response");
  }

  return replyText;
}

// ─── POST /ai/chat ────────────────────────────────────────────────────────────

router.post("/chat", authMiddleware, async (req: any, res: Response) => {
  const { message, history } = req.body as {
    message?: string;
    history?: ConversationTurn[];
  };

  // Validate message
  if (
    !message ||
    typeof message !== "string" ||
    message.trim().length === 0 ||
    message.length > 2000
  ) {
    return res.status(400).json({ message: "Tin nhắn không hợp lệ" });
  }

  // Check API key
  if (!process.env.GEMINI_API_KEY) {
    return res.status(503).json({ message: "Dịch vụ AI chưa được cấu hình" });
  }

  const userId: number = req.user.id;
  const conversationHistory: ConversationTurn[] = Array.isArray(history)
    ? history
    : [];

  try {
    const userCtx = await buildUserContext(userId);
    const systemPrompt = buildSystemPrompt(userCtx);
    const reply = await callGemini(systemPrompt, message.trim(), conversationHistory);

    return res.status(200).json({ reply });
  } catch (err: any) {
    console.error("[AI] Gemini call failed:", err);
    if (err?.statusCode === 429) {
      return res.status(503).json({
        message: "Trợ lý AI đang quá tải, vui lòng thử lại sau 1 phút.",
      });
    }
    return res
      .status(503)
      .json({ message: "Trợ lý AI đang bận, vui lòng thử lại sau ít phút." });
  }
});

export default router;
