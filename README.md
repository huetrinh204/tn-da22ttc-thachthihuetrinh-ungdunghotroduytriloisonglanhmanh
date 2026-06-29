# 🌱 Viora — PHÁT TRIỂN ỨNG DỤNG DI ĐỘNG HỖ TRỢ VÀ DUY TRÌ LỐI SỐNG LÀNH MẠNH

Viora là ứng dụng **habit tracker** kết hợp **gamification** (cây ảo), **mạng xã hội** và **AI coaching**, giúp người dùng xây dựng thói quen tốt mỗi ngày một cách vui vẻ và có động lực.

---

## 🎯 Mục tiêu

- Giúp người dùng **hình thành thói quen lành mạnh** thông qua check-in hàng ngày
- Tạo động lực bằng **cây ảo** (lên cấp, EXP, wilting), **streak** và **thành tựu**
- Kết nối cộng đồng qua **feed bài viết**, **bình luận**, **follow**
- Hỗ trợ cá nhân hóa với **AI Coach** (Gemini 2.5 Flash)
- Quản trị hệ thống qua **admin panel**

---

## 🏗 Kiến trúc hệ thống

```
┌─────────────────────────────────────────────────────┐
│                    Viora App                         │
│         Flutter (Dart) — Mobile/Web/Desktop          │
│  setState + SharedPreferences + Firebase Messaging   │
└───────────────────────┬─────────────────────────────┘
                        │ HTTP/JSON (JWT Bearer)
                        ▼
┌─────────────────────────────────────────────────────┐
│                  Viora Backend                       │
│           Node.js + Express 5 + TypeScript            │
│   JWT Auth · MySQL (mysql2) · Firebase Admin · Gemini │
└──────┬──────────────────────────────────────┬────────┘
       │                                      │
       ▼                                      ▼
┌──────────────┐                   ┌──────────────────┐
│    MySQL     │                   │  External APIs   │
│  viora_app   │                   │  · Google OAuth   │
│ (18 tables)  │                   │  · Gemini AI      │
└──────────────┘                   │  · Gmail SMTP     │
                                   │  · Firebase FCM   │
                                   └──────────────────┘
```

### Frontend — `viora_app/`

| Layer | Công nghệ |
|---|---|
| Ngôn ngữ | Dart 3.11.4+ |
| Framework | Flutter (Material 3) |
| State management | `setState` + `ValueNotifier` + `ChangeNotifier` |
| HTTP Client | `http` 1.2 |
| Local storage | `shared_preferences` |
| Charts | `fl_chart` |
| Push notifications | `firebase_messaging` + `flutter_local_notifications` |
| Icons | `lucide_icons` |
| Đa ngôn ngữ | `intl` + `flutter gen-l10n` (VI/EN) |

### Backend — `viora_backend/`

| Layer | Công nghệ |
|---|---|
| Runtime | Node.js + TypeScript 6 |
| Framework | Express 5 |
| Database | MySQL 8 (mysql2/promise) |
| Auth | JWT + bcrypt + Google OAuth |
| Push | Firebase Admin SDK (FCM) |
| Email | Nodemailer (Gmail SMTP) + Resend |
| AI | Gemini 2.5 Flash API |
| Cron | node-cron (6 jobs, Asia/Ho_Chi_Minh) |

---

## 📦 Yêu cầu phần mềm

### Bắt buộc

| Phần mềm | Phiên bản tối thiểu |
|---|---|
| **Flutter** | 3.11.4 |
| **Dart** | 3.11.4 (đi kèm Flutter) |
| **Node.js** | 18.x trở lên |
| **MySQL** | 8.0 |
| **Git** | — |

### Tùy chọn (cho một số tính năng)

| Phần mềm | Dùng cho |
|---|---|
| **Android Studio / Xcode** | Build mobile app |
| **Firebase project** | FCM push notifications |
| **Google Cloud Console** | Google OAuth client ID |
| **Gemini API key** | AI Coach chat |

---

## 🚀 Cách chạy chương trình

### 1. Clone & cài đặt

```bash
git clone <url-repo>
cd viora
```

### 2. Backend

```bash
cd viora_backend

# Cài dependencies
npm install

# Tạo file .env từ mẫu (điền các giá trị tương ứng)
cp .env.example .env
```

**Nội dung file `.env`:**

```env
PORT=3000
PUBLIC_BASE_URL=http://localhost:3000

DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=viora_app

JWT_SECRET=your_jwt_secret

GOOGLE_CLIENT_ID=your_google_client_id
GEMINI_API_KEY=your_gemini_api_key

FIREBASE_PROJECT_ID=your_project_id
FIREBASE_CLIENT_EMAIL=your_client_email
FIREBASE_PRIVATE_KEY="your_private_key"

GMAIL_USER=your_email@gmail.com
GMAIL_APP_PASSWORD=your_app_password
```

**Khởi tạo database:**

```bash
# Import file SQL mới nhất vào MySQL
mysql -u root -p viora_app < database/21062026.sql
```

**Chạy backend:**

```bash
npm run dev
```

Server chạy tại `http://localhost:3000`.

### 3. Frontend

```bash
cd viora_app

# Kiểm tra Flutter
flutter doctor

# Cài dependencies
flutter pub get

# Generate localization (l10n)
flutter gen-l10n

# Chạy app
flutter run
```

> **Lưu ý:** Trong file `lib/services/api_service.dart`, cập nhật `baseUrl` cho phù hợp:
> - Emulator Android: `http://10.0.2.2:3000`
> - iOS Simulator / Web: `http://localhost:3000`
> - Thiết bị thật: dùng IP máy trong mạng LAN

---

## 📁 Cấu trúc thư mục

```
viora/
├── viora_app/                   # Flutter mobile app
│   └── lib/
│       ├── main.dart            # Entry point
│       ├── constants/           # Hằng số (icons...)
│       ├── data/                # Dữ liệu mẫu
│       ├── l10n/                # Đa ngôn ngữ (VI/EN)
│       ├── models/              # Model classes
│       ├── navigation/          # Điều hướng + deep links
│       ├── providers/           # ChangeNotifier (locale)
│       ├── screens/             # 30+ màn hình
│       ├── services/            # API, FCM, notification...
│       ├── theme/               # Material 3 theme
│       ├── utils/               # Utility functions
│       └── widgets/             # 20+ widget tái sử dụng
│
├── viora_backend/               # Node.js REST API
│   └── src/
│       ├── index.ts             # Entry point + Express setup
│       ├── config/db.ts         # MySQL connection pool
│       ├── routes/              # 6 route files
│       │   ├── auth.ts          # Đăng ký, đăng nhập, OAuth, OTP
│       │   ├── habits.ts        # CRUD thói quen, check-in, plant
│       │   ├── stats.ts         # Thống kê
│       │   ├── community.ts     # Bài viết, comment, follow
│       │   ├── admin.ts         # Quản trị
│       │   └── ai.ts            # AI Coach chat
│       └── services/            # Cron, email, FCM push
│           ├── cron_service.ts
│           ├── email_service.ts
│           ├── fcm_push_service.ts
│           └── autoReminderService.ts
│
├── database/                    # MySQL dump files
│   └── 21062026.sql             # Full database (mới nhất)
│
├── ARCHITECTURE.md              # Kiến trúc chi tiết
├── ACTIVITY_DIAGRAMS.md         # Sơ đồ hoạt động
└── README.md                    # File này
```

---

## 🔑 Tính năng chính

| Tính năng | Mô tả |
|---|---|
| **Check-in habits** | Theo dõi thói quen hàng ngày với mục tiêu số đo |
| **Cây ảo** | 15 cấp độ, 4 loại cây, EXP, wilting |
| **Streak** | Chuỗi ngày liên tiếp, freeze token |
| **Thành tựu** | 9 thành tựu (first check-in, streak milestones...) |
| **Cộng đồng** | Feed bài viết, like, comment, reply, follow |
| **AI Coach** | Chat với Gemini AI (tư vấn thói quen) |
| **Thống kê** | Biểu đồ tuần/tháng/danh mục |
| **Đa ngôn ngữ** | Tiếng Việt & English |
| **Admin panel** | Quản lý user, post, habit, cài đặt app |
| **Push notification** | FCM + email (sáng/tối/nhắc nhở) |

---

## 🧪 Cron Jobs (Backend)

| Cron | Tác vụ |
|---|---|
| `* * * * *` | Gửi reminder cá nhân (FCM) |
| `0 8 * * *` | Email + push buổi sáng |
| `0 21 * * *` | Email + push buổi tối |
| `* * * * *` | Auto reminder theo cấu hình admin |
| `* * * * *` | Nhắc habit theo `reminder_time` |
| `0 0 * * *` | Wilting penalty (trừ EXP cây) |

---

## 📄 License

Dự án này được phát triển cho mục đích học tập.
