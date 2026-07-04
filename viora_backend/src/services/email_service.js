"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendMorningReminder = sendMorningReminder;
exports.sendEveningReminder = sendEveningReminder;
exports.sendOtpEmail = sendOtpEmail;
const nodemailer_1 = __importDefault(require("nodemailer"));
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
const transporter = nodemailer_1.default.createTransport({
    service: "gmail",
    auth: {
        user: process.env.GMAIL_USER,
        pass: process.env.GMAIL_APP_PASSWORD,
    },
});
const FROM = `Viora App <${process.env.GMAIL_USER}>`;
const baseStyle = `
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: 'Inter', Arial, sans-serif; background: #f0f4f0; }
    .wrapper { max-width: 560px; margin: 32px auto; }
    .card { background: white; border-radius: 20px; overflow: hidden; box-shadow: 0 8px 32px rgba(0,0,0,0.08); }
    .header { padding: 40px 32px 32px; text-align: center; }
    .logo { font-size: 32px; margin-bottom: 8px; }
    .brand { font-size: 22px; font-weight: 700; letter-spacing: 3px; color: white; }
    .tagline { font-size: 13px; color: rgba(255,255,255,0.8); margin-top: 4px; }
    .body { padding: 32px; }
    .greeting { font-size: 20px; font-weight: 700; color: #1a1a1a; margin-bottom: 12px; }
    .text { font-size: 15px; color: #555; line-height: 1.7; margin-bottom: 20px; }
    .quote-box { background: #f1f8f1; border-left: 4px solid #4CAF50; border-radius: 0 12px 12px 0; padding: 16px 20px; margin: 24px 0; }
    .quote-text { font-size: 14px; color: #2E7D32; font-style: italic; line-height: 1.6; }
    .stats-row { display: flex; gap: 12px; margin: 24px 0; }
    .stat-box { flex: 1; background: #f8faf8; border-radius: 12px; padding: 16px; text-align: center; border: 1px solid #e8f5e9; }
    .stat-num { font-size: 28px; font-weight: 700; color: #2E7D32; }
    .stat-label { font-size: 12px; color: #888; margin-top: 4px; }
    .progress-section { margin: 20px 0; }
    .progress-label { display: flex; justify-content: space-between; margin-bottom: 8px; }
    .progress-label span { font-size: 13px; color: #666; }
    .progress-label strong { font-size: 13px; color: #2E7D32; font-weight: 600; }
    .progress-bar { background: #e8f5e9; border-radius: 8px; height: 10px; overflow: hidden; }
    .progress-fill { height: 100%; border-radius: 8px; background: linear-gradient(90deg, #4CAF50, #81C784); }
    .cta-btn { display: block; background: linear-gradient(135deg, #2E7D32, #4CAF50); color: white; text-decoration: none; text-align: center; padding: 16px 32px; border-radius: 14px; font-size: 16px; font-weight: 600; margin: 28px 0 8px; letter-spacing: 0.3px; }
    .divider { height: 1px; background: #f0f0f0; margin: 24px 0; }
    .tip-box { background: #fffbf0; border: 1px solid #ffe082; border-radius: 12px; padding: 16px; display: flex; gap: 12px; align-items: flex-start; }
    .tip-icon { font-size: 20px; flex-shrink: 0; }
    .tip-text { font-size: 13px; color: #795548; line-height: 1.6; }
    .footer { background: #f8faf8; padding: 24px 32px; text-align: center; border-top: 1px solid #f0f0f0; }
    .footer-logo { font-size: 16px; font-weight: 700; color: #2E7D32; letter-spacing: 2px; margin-bottom: 8px; }
    .footer-text { font-size: 12px; color: #aaa; line-height: 1.6; }
    .footer-links { margin-top: 12px; }
    .footer-links a { font-size: 12px; color: #4CAF50; text-decoration: none; margin: 0 8px; }
  </style>
`;
// ===== MORNING TEMPLATE =====
function morningTemplate(name) {
    const hour = new Date().getHours();
    const greeting = hour < 12 ? "Chào buổi sáng" : hour < 18 ? "Chào buổi chiều" : "Chào buổi tối";
    return `<!DOCTYPE html>
<html lang="vi">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width">
<title>Viora - Nhắc nhở thói quen</title>
${baseStyle}
</head>
<body>
<div class="wrapper">
  <div class="card">
    <div class="header" style="background: linear-gradient(135deg, #1B5E20 0%, #2E7D32 50%, #43A047 100%);">
      <div class="logo">🌱</div>
      <div class="brand">VIORA</div>
      <div class="tagline">Sống khoẻ · Sống xanh · Sống an lành</div>
    </div>
    <div class="body">
      <div class="greeting">${greeting}, ${name}! 👋</div>
      <p class="text">Một ngày mới đã bắt đầu — đây là cơ hội tuyệt vời để bạn tiếp tục hành trình sống lành mạnh của mình.</p>

      <div class="quote-box">
        <div class="quote-text">"Sự thay đổi không đến từ điều lớn lao, mà từ những thói quen nhỏ được lặp lại mỗi ngày."</div>
      </div>

      <p class="text">Cây ảo của bạn đang chờ được tưới nước hôm nay 🌿 Hãy hoàn thành thói quen để cây phát triển và đạt cấp độ mới!</p>

      <div class="tip-box">
        <div class="tip-icon">💡</div>
        <div class="tip-text"><strong>Mẹo nhỏ:</strong> Bắt đầu với thói quen dễ nhất trước — điều đó sẽ tạo đà để bạn hoàn thành những thói quen còn lại trong ngày.</div>
      </div>
    </div>
    <div class="footer">
      <div class="footer-logo">🌱 VIORA</div>
      <div class="footer-text">© 2026 Viora App. Bạn nhận được email này vì đã đăng ký tài khoản Viora.<br>Để tắt thông báo, vào Hồ sơ → Nhắc nhở trong app.</div>
    </div>
  </div>
</div>
</body></html>`;
}
// ===== EVENING TEMPLATE =====
function eveningTemplate(name, completed, total) {
    const allDone = completed === total && total > 0;
    const pct = total > 0 ? Math.round((completed / total) * 100) : 0;
    const remaining = total - completed;
    const headerGradient = allDone
        ? "background: linear-gradient(135deg, #1B5E20 0%, #388E3C 100%);"
        : "background: linear-gradient(135deg, #1a237e 0%, #283593 50%, #3949AB 100%);";
    const headerEmoji = allDone ? "🎉" : "🌙";
    const headerTitle = allDone ? "Xuất sắc!" : "Nhắc nhở buổi tối";
    const headerSub = allDone
        ? "Bạn đã hoàn thành tất cả thói quen hôm nay!"
        : "Đừng quên hoàn thành thói quen trước khi ngủ";
    return `<!DOCTYPE html>
<html lang="vi">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width">
<title>Viora - Tổng kết ngày</title>
${baseStyle}
</head>
<body>
<div class="wrapper">
  <div class="card">
    <div class="header" style="${headerGradient}">
      <div class="logo">${headerEmoji}</div>
      <div class="brand">VIORA</div>
      <div class="tagline">${headerSub}</div>
    </div>
    <div class="body">
      <div class="greeting">Xin chào, ${name}!</div>
      <p class="text">Đây là tổng kết thói quen của bạn hôm nay:</p>

      <div class="stats-row">
        <div class="stat-box">
          <div class="stat-num" style="color: #4CAF50;">${completed}</div>
          <div class="stat-label">Đã hoàn thành</div>
        </div>
        <div class="stat-box">
          <div class="stat-num" style="color: ${remaining > 0 ? '#FF7043' : '#4CAF50'};">${remaining}</div>
          <div class="stat-label">Còn lại</div>
        </div>
        <div class="stat-box">
          <div class="stat-num" style="color: #2196F3;">${pct}%</div>
          <div class="stat-label">Tỉ lệ</div>
        </div>
      </div>

      <div class="progress-section">
        <div class="progress-label">
          <span>Tiến độ hôm nay</span>
          <strong>${completed}/${total} thói quen</strong>
        </div>
        <div class="progress-bar">
          <div class="progress-fill" style="width: ${pct}%;"></div>
        </div>
      </div>

      <div class="divider"></div>

      ${allDone ? `
      <div class="tip-box" style="background: #f1f8f1; border-color: #a5d6a7;">
        <div class="tip-icon">🏆</div>
        <div class="tip-text" style="color: #2E7D32;"><strong>Tuyệt vời!</strong> Cây của bạn đã được tưới hôm nay. Hãy tiếp tục duy trì streak để cây phát triển lên cấp độ mới!</div>
      </div>
      ` : `
      <div class="tip-box">
        <div class="tip-icon">⏰</div>
        <div class="tip-text"><strong>Bạn vẫn còn thời gian!</strong> Hãy mở app Viora và hoàn thành ${remaining} thói quen còn lại trước khi ngủ. Cây của bạn đang chờ được tưới! 🌿</div>
      </div>
      `}
    </div>
    <div class="footer">
      <div class="footer-logo">🌱 VIORA</div>
      <div class="footer-text">© 2026 Viora App. Bạn nhận được email này vì đã đăng ký tài khoản Viora.<br>Để tắt thông báo, vào Hồ sơ → Nhắc nhở trong app.</div>
    </div>
  </div>
</div>
</body></html>`;
}
// ===== OTP TEMPLATE =====
function otpTemplate(name, code) {
    return `<!DOCTYPE html>
<html lang="vi">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width">
<title>Viora - Đặt lại mật khẩu</title>
${baseStyle}
</head>
<body>
<div class="wrapper">
  <div class="card">
    <div class="header" style="background: linear-gradient(135deg, #1B5E20 0%, #2E7D32 50%, #43A047 100%);">
      <div class="logo">🔐</div>
      <div class="brand">VIORA</div>
      <div class="tagline">Xác thực bảo mật</div>
    </div>
    <div class="body">
      <div class="greeting">Xin chào, ${name}!</div>
      <p class="text">Bạn đã yêu cầu đặt lại mật khẩu cho tài khoản Viora. Sử dụng mã OTP bên dưới để tiếp tục:</p>

      <div style="background: linear-gradient(135deg, #f1f8f1, #e8f5e9); border: 2px dashed #4CAF50; border-radius: 16px; padding: 28px; text-align: center; margin: 24px 0;">
        <div style="font-size: 11px; color: #888; letter-spacing: 2px; text-transform: uppercase; margin-bottom: 12px;">Mã xác thực của bạn</div>
        <div style="font-size: 44px; font-weight: 800; letter-spacing: 14px; color: #1B5E20; font-family: monospace;">${code}</div>
        <div style="margin-top: 12px; display: inline-block; background: #fff3e0; border-radius: 20px; padding: 6px 16px;">
          <span style="font-size: 12px; color: #E65100;">⏱ Hết hạn sau <strong>10 phút</strong></span>
        </div>
      </div>

      <div class="divider"></div>

      <div class="tip-box" style="background: #fff8f8; border-color: #ffcdd2;">
        <div class="tip-icon">⚠️</div>
        <div class="tip-text" style="color: #c62828;"><strong>Lưu ý bảo mật:</strong> Không chia sẻ mã này với bất kỳ ai. Viora sẽ không bao giờ yêu cầu mã OTP của bạn qua điện thoại hay email khác.</div>
      </div>

      <p class="text" style="margin-top: 20px; font-size: 13px; color: #999;">Nếu bạn không yêu cầu đặt lại mật khẩu, hãy bỏ qua email này. Tài khoản của bạn vẫn an toàn.</p>
    </div>
    <div class="footer">
      <div class="footer-logo">🌱 VIORA</div>
      <div class="footer-text">© 2026 Viora App · Bảo mật tài khoản của bạn</div>
    </div>
  </div>
</div>
</body></html>`;
}
// ===== SEND FUNCTIONS =====
async function sendMorningReminder(email, name) {
    try {
        await transporter.sendMail({
            from: FROM,
            to: email,
            subject: `🌱 ${name}, hôm nay bạn đã sẵn sàng chưa?`,
            html: morningTemplate(name),
        });
        console.log(`[Email] Morning sent to ${email}`);
    }
    catch (err) {
        console.error(`[Email] Failed morning to ${email}:`, err);
    }
}
async function sendEveningReminder(email, name, completed, total) {
    const allDone = completed === total && total > 0;
    try {
        await transporter.sendMail({
            from: FROM,
            to: email,
            subject: allDone
                ? `🎉 ${name}, bạn đã hoàn thành tất cả thói quen hôm nay!`
                : `🌙 ${name}, còn ${total - completed} thói quen chưa hoàn thành`,
            html: eveningTemplate(name, completed, total),
        });
        console.log(`[Email] Evening sent to ${email}`);
    }
    catch (err) {
        console.error(`[Email] Failed evening to ${email}:`, err);
    }
}
async function sendOtpEmail(email, name, code) {
    try {
        await transporter.sendMail({
            from: FROM,
            to: email,
            subject: "🔐 Mã xác thực đặt lại mật khẩu Viora",
            html: otpTemplate(name, code),
        });
        console.log(`[Email] OTP sent to ${email}`);
    }
    catch (err) {
        console.error(`[Email] Failed OTP to ${email}:`, err);
    }
}
