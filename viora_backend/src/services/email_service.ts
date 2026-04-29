import nodemailer from "nodemailer";
import dotenv from "dotenv";

dotenv.config();

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.GMAIL_USER,
    pass: process.env.GMAIL_APP_PASSWORD,
  },
});

const FROM = `Viora App <${process.env.GMAIL_USER}>`;

// ===== EMAIL TEMPLATES =====

function morningTemplate(name: string): string {
  return `
<!DOCTYPE html>
<html>
<head><meta charset="utf-8">
<style>
  body{font-family:Arial,sans-serif;background:#f5f5f5;margin:0;padding:0}
  .container{max-width:480px;margin:32px auto;background:white;border-radius:16px;overflow:hidden;box-shadow:0 4px 16px rgba(0,0,0,0.08)}
  .header{background:linear-gradient(135deg,#2E7D32,#4CAF50);padding:32px 24px;text-align:center}
  .header h1{color:white;margin:0;font-size:24px}
  .header p{color:rgba(255,255,255,0.85);margin:8px 0 0;font-size:14px}
  .body{padding:28px 24px}
  .body p{color:#444;line-height:1.6;font-size:15px}
  .quote{background:#F1F8E9;border-left:4px solid #4CAF50;padding:14px 16px;border-radius:0 8px 8px 0;margin:20px 0;font-style:italic;color:#2E7D32;font-size:14px}
  .footer{text-align:center;padding:16px;color:#aaa;font-size:12px}
</style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>🌱 Chào buổi sáng, ${name}!</h1>
      <p>Một ngày mới, một cơ hội mới</p>
    </div>
    <div class="body">
      <p>Hôm nay là một ngày tuyệt vời để duy trì thói quen lành mạnh. Cây ảo của bạn đang chờ được tưới nước! 🌿</p>
      <div class="quote">"Sự thay đổi không đến từ điều lớn lao, mà từ những thói quen nhỏ được lặp lại mỗi ngày."</div>
      <p>Hãy mở app <strong>Viora</strong> và hoàn thành thói quen của bạn ngay hôm nay nhé!</p>
    </div>
    <div class="footer"><p>© 2026 Viora App · Sống khoẻ · Sống xanh · Sống an lành</p></div>
  </div>
</body>
</html>`;
}

function eveningTemplate(name: string, completed: number, total: number): string {
  const allDone = completed === total && total > 0;
  const pct = total > 0 ? Math.round((completed / total) * 100) : 0;

  return `
<!DOCTYPE html>
<html>
<head><meta charset="utf-8">
<style>
  body{font-family:Arial,sans-serif;background:#f5f5f5;margin:0;padding:0}
  .container{max-width:480px;margin:32px auto;background:white;border-radius:16px;overflow:hidden;box-shadow:0 4px 16px rgba(0,0,0,0.08)}
  .header{background:linear-gradient(135deg,#1B5E20,#2E7D32);padding:32px 24px;text-align:center}
  .header h1{color:white;margin:0;font-size:24px}
  .header p{color:rgba(255,255,255,0.85);margin:8px 0 0;font-size:14px}
  .body{padding:28px 24px}
  .body p{color:#444;line-height:1.6;font-size:15px}
  .stats{display:flex;justify-content:space-around;margin:20px 0;text-align:center}
  .stat-value{font-size:28px;font-weight:bold;color:#2E7D32}
  .stat-label{font-size:12px;color:#888}
  .bar-bg{background:#E8F5E9;border-radius:8px;height:12px;margin:16px 0;overflow:hidden}
  .bar-fill{background:#4CAF50;height:100%;border-radius:8px;width:${pct}%}
  .footer{text-align:center;padding:16px;color:#aaa;font-size:12px}
</style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>${allDone ? "🎉 Xuất sắc!" : "🌙 Nhắc nhở tối"}</h1>
      <p>${allDone ? "Bạn đã hoàn thành tất cả hôm nay!" : "Đừng quên thói quen trước khi ngủ nhé"}</p>
    </div>
    <div class="body">
      <p>Xin chào <strong>${name}</strong>, đây là tổng kết thói quen hôm nay:</p>
      <div class="stats">
        <div><div class="stat-value">${completed}</div><div class="stat-label">Đã hoàn thành</div></div>
        <div><div class="stat-value">${total - completed}</div><div class="stat-label">Còn lại</div></div>
        <div><div class="stat-value">${pct}%</div><div class="stat-label">Tỉ lệ</div></div>
      </div>
      <div class="bar-bg"><div class="bar-fill"></div></div>
      <p>${allDone
        ? "Tuyệt vời! Cây của bạn đã được tưới hôm nay. Hãy tiếp tục duy trì nhé! 🌱"
        : "Bạn vẫn còn thời gian để hoàn thành thói quen còn lại. Cây của bạn đang chờ! 🌿"
      }</p>
    </div>
    <div class="footer"><p>© 2026 Viora App · Sống khoẻ · Sống xanh · Sống an lành</p></div>
  </div>
</body>
</html>`;
}

function otpTemplate(name: string, code: string): string {
  return `
<!DOCTYPE html>
<html>
<head><meta charset="utf-8">
<style>
  body{font-family:Arial,sans-serif;background:#f5f5f5;margin:0;padding:0}
  .container{max-width:480px;margin:32px auto;background:white;border-radius:16px;overflow:hidden;box-shadow:0 4px 16px rgba(0,0,0,0.08)}
  .header{background:linear-gradient(135deg,#2E7D32,#4CAF50);padding:32px 24px;text-align:center}
  .header h1{color:white;margin:0;font-size:24px}
  .header p{color:rgba(255,255,255,0.85);margin:8px 0 0;font-size:14px}
  .body{padding:28px 24px}
  .body p{color:#444;line-height:1.6;font-size:15px}
  .otp-box{background:#F1F8E9;border:2px dashed #4CAF50;border-radius:12px;padding:20px;text-align:center;margin:20px 0}
  .otp-code{font-size:40px;font-weight:bold;letter-spacing:12px;color:#1B5E20}
  .footer{text-align:center;padding:16px;color:#aaa;font-size:12px}
</style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>🔐 Đặt lại mật khẩu</h1>
      <p>Xin chào ${name}!</p>
    </div>
    <div class="body">
      <p>Bạn đã yêu cầu đặt lại mật khẩu. Dùng mã OTP bên dưới:</p>
      <div class="otp-box">
        <div class="otp-code">${code}</div>
        <p style="color:#888;font-size:13px;margin:8px 0 0">Mã có hiệu lực trong <strong>10 phút</strong></p>
      </div>
      <p style="color:#888;font-size:13px">Nếu bạn không yêu cầu, hãy bỏ qua email này.</p>
    </div>
    <div class="footer"><p>© 2026 Viora App</p></div>
  </div>
</body>
</html>`;
}

// ===== SEND FUNCTIONS =====

export async function sendMorningReminder(email: string, name: string) {
  try {
    await transporter.sendMail({
      from: FROM,
      to: email,
      subject: "🌱 Bắt đầu ngày mới với Viora!",
      html: morningTemplate(name),
    });
    console.log(`[Email] Morning sent to ${email}`);
  } catch (err) {
    console.error(`[Email] Failed morning to ${email}:`, err);
  }
}

export async function sendEveningReminder(
  email: string, name: string,
  completed: number, total: number
) {
  try {
    await transporter.sendMail({
      from: FROM,
      to: email,
      subject: completed === total && total > 0
        ? "🎉 Bạn đã hoàn thành tất cả thói quen hôm nay!"
        : "🌙 Nhắc nhở: Hoàn thành thói quen trước khi ngủ",
      html: eveningTemplate(name, completed, total),
    });
    console.log(`[Email] Evening sent to ${email}`);
  } catch (err) {
    console.error(`[Email] Failed evening to ${email}:`, err);
  }
}

export async function sendOtpEmail(email: string, name: string, code: string) {
  try {
    await transporter.sendMail({
      from: FROM,
      to: email,
      subject: "🔐 Mã xác thực đặt lại mật khẩu Viora",
      html: otpTemplate(name, code),
    });
    console.log(`[Email] OTP sent to ${email}`);
  } catch (err) {
    console.error(`[Email] Failed OTP to ${email}:`, err);
  }
}
