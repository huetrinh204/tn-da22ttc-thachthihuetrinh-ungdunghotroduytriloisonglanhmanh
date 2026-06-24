# Kiến trúc Hệ thống Viora

## Tổng quan

**Viora** là ứng dụng theo dõi thói quen (habit tracker) kết hợp gamification (cây ảo), mạng xã hội và AI coaching. Hệ thống gồm 2 phần chính:

| Thành phần | Công nghệ | Vai trò |
|---|---|---|
| **viora_app** | Flutter (Dart) ^3.11.4 | Mobile app (Android/iOS/Web/Desktop) |
| **viora_backend** | Node.js + Express 5 + TypeScript | REST API + cron jobs + push notifications |

---

## 1. Kiến trúc Backend (`viora_backend/`)

### 1.1. Cấu trúc thư mục

```
viora_backend/
├── src/
│   ├── index.ts            # Entry point, Express setup, route mounting
│   ├── config/
│   │   └── db.ts           # MySQL connection pool (mysql2/promise, UTC+7)
│   ├── routes/
│   │   ├── auth.ts         # /auth - Đăng ký, đăng nhập, profile, OAuth, OTP
│   │   ├── habits.ts       # /habits - CRUD thói quen, check-in, plant, achievements
│   │   ├── stats.ts        # /stats - Thống kê weekly/monthly/category
│   │   ├── community.ts    # /community - Posts, comments, likes, follows, notifications
│   │   ├── admin.ts        # /admin - Quản trị users, posts, habits, plants, settings
│   │   └── ai.ts           # /ai - Chat với Gemini AI coach
│   └── services/
│       ├── cron_service.ts       # 6 cron jobs (node-cron, Asia/Ho_Chi_Minh)
│       ├── email_service.ts      # Gmail SMTP (nodemailer) - reminders, OTP
│       ├── fcm_push_service.ts   # Firebase Cloud Messaging push notifications
│       └── autoReminderService.ts # Auto-reminder delivery (FCM + email)
├── uploads/                # Thư mục lưu file upload (avatar, post images)
├── .env                    # Biến môi trường
├── package.json
└── tsconfig.json
```

### 1.2. Luồng xử lý request

```
Client (Flutter)  
  ──HTTP/JSON──>  Express 5
                    │
                    ├─ cors()
                    ├─ express.json()
                    ├─ Logger middleware
                    ├─ static('/uploads')
                    │
                    ├─ [JWT authMiddleware] ──> Routes
                    │   ├─ /habits, /stats, /community
                    │   └─ [+ adminMiddleware] ──> /admin
                    │
                    └─ MySQL (mysql2 pool, UTC+7)
```

### 1.3. Authentication & Authorization

| Phương thức | Mô tả |
|---|---|
| **Email/Password** | bcrypt (10 rounds), JWT 7 ngày |
| **Google OAuth** | `google-auth-library`, verify ID token với 2 client IDs |
| **JWT** | Payload: `{ id, email }`, secret từ `.env` |
| **Role-based** | `user` / `admin` — kiểm tra trong database |

### 1.4. Database Schema (MySQL)

**Core tables:**
| Table | Mục đích |
|---|---|
| `users` | Thông tin user, notif settings, OTP, language |
| `habits` | Thói quen, category, frequency, streak mỗi habit |
| `habit_logs` | Check-in logs (UNIQUE: habit_id + log_date) |
| `streaks` | Streak tổng thể, freeze tokens |
| `plants` | Cây ảo (type, level, EXP, wilting) |
| `achievements` | Thành tựu đã mở khóa |

**Community tables:**
| Table | Mục đích |
|---|---|
| `community_posts` | Bài viết (content, image, hashtags, post_type) |
| `community_comments` | Bình luận |
| `community_comment_replies` | Trả lời bình luận |
| `community_post_likes` | Like bài viết (composite PK) |
| `community_comment_likes` | Like bình luận (composite PK) |
| `user_follows` | Follow (composite PK) |
| `user_notifications` | Thông báo in-app |
| `user_hidden_notifications` | Ẩn thông báo |

**Admin tables:**
| Table | Mục đích |
|---|---|
| `auto_reminder_settings` | Cấu hình auto-reminder |
| `auto_reminder_messages` | Nội dung tin nhắn reminder |
| `app_settings` | Cấu hình app (name, logo) |

### 1.5. API Endpoints

#### Auth (`/auth`)
| Method | Endpoint | Mô tả |
|---|---|---|
| POST | `/register` | Đăng ký |
| POST | `/login` | Đăng nhập |
| POST | `/google` | Google OAuth |
| GET | `/profile` | Lấy profile |
| PUT | `/profile` | Cập nhật profile |
| POST | `/avatar` | Upload avatar |
| PUT | `/password` | Đổi mật khẩu |
| PUT | `/notification-settings` | Cấu hình thông báo |
| POST | `/fcm-token` | Lưu FCM token |
| PUT | `/user/language` | Đổi ngôn ngữ |
| POST | `/forgot-password` | Gửi OTP |
| POST | `/reset-password` | Đặt lại mật khẩu |

#### Habits (`/habits`) — Yêu cầu JWT
| Method | Endpoint | Mô tả |
|---|---|---|
| GET | `/streak` | Streak + freeze tokens |
| GET | `/` | Danh sách habits |
| GET | `/today` | Habits hôm nay + check-in status |
| POST | `/` | Tạo habit mới |
| PUT | `/:id` | Cập nhật habit |
| DELETE | `/:id` | Xóa mềm habit |
| POST | `/:id/checkin` | Check-in habit |
| GET | `/achievements` | Thành tựu đã mở |
| PUT | `/plant/type` | Đổi loại cây |
| GET | `/plant` | Thông tin cây |

#### Stats (`/stats`) — Yêu cầu JWT
| Method | Endpoint | Mô tả |
|---|---|---|
| GET | `/weekly` | 7 ngày gần nhất |
| GET | `/monthly` | 30 ngày gần nhất |
| GET | `/categories` | Theo category |
| GET | `/summary` | Tổng quan |
| GET | `/habits/:habitId/metrics` | Chi tiết 1 habit |
| GET | `/habits/overview` | Tổng quan habits |

#### Community (`/community`) — Yêu cầu JWT
| Method | Endpoint | Mô tả |
|---|---|---|
| GET | `/posts` | Feed (trending/following/achievements) |
| POST | `/posts` | Tạo bài viết |
| GET | `/posts/:postId` | Chi tiết bài viết |
| PUT | `/posts/:postId` | Sửa bài viết |
| DELETE | `/posts/:postId` | Xóa bài viết |
| POST | `/posts/:postId/like` | Like |
| DELETE | `/posts/:postId/like` | Unlike |
| GET | `/posts/:postId/comments` | Comments |
| POST | `/posts/:postId/comments` | Tạo comment |
| POST | `/comments/:commentId/like` | Like comment |
| DELETE | `/comments/:commentId/like` | Unlike comment |
| GET | `/comments/:commentId/replies` | Replies |
| POST | `/comments/:commentId/replies` | Tạo reply |
| POST | `/users/:userId/follow` | Follow |
| DELETE | `/users/:userId/follow` | Unfollow |
| GET | `/users/:userId/profile` | Profile người dùng |
| GET | `/search` | Tìm kiếm |
| GET | `/notifications` | Thông báo |
| PUT | `/notifications/:id/read` | Đánh dấu đã đọc |
| PUT | `/notifications/read-all` | Đọc tất cả |

#### Admin (`/admin`) — Yêu cầu JWT + admin role
| Method | Endpoint | Mô tả |
|---|---|---|
| GET | `/users` | Danh sách users |
| PUT | `/users/:userId/role` | Đổi role |
| POST | `/users` | Tạo user |
| DELETE | `/users/:userId` | Xóa user |
| POST | `/users/bulk-delete` | Xóa hàng loạt |
| GET | `/posts` | Danh sách posts |
| DELETE | `/posts/:postId` | Xóa post |
| POST | `/posts/:postId/report` | Cảnh cáo post |
| PUT | `/posts/:postId/unwarn` | Gỡ cảnh cáo |
| PUT | `/posts/:postId/approve` | Phê duyệt |
| DELETE | `/posts/:postId/reject` | Từ chối |
| GET | `/stats` | Dashboard stats |
| GET | `/growth` | Dữ liệu tăng trưởng |
| GET | `/habits` | Habits management |
| GET | `/habits/categories` | Category stats |
| GET | `/habits/trends` | Trends |
| GET | `/plants` | Plants management |
| GET | `/plants/:userId/history` | Lịch sử cây |
| GET/PUT | `/auto-reminder/settings` | Cấu hình reminder |
| GET/POST | `/auto-reminder/messages` | Messages |
| PUT/DELETE | `/auto-reminder/messages/:id` | Message CRUD |
| GET | `/app-settings` | App settings |
| PUT | `/app-settings/name` | Tên app |
| PUT | `/app-settings/logo` | Logo app |

#### AI (`/ai`)
| Method | Endpoint | Mô tả |
|---|---|---|
| POST | `/chat` | Chat với Gemini 2.5 Flash |

### 1.6. Gamification System

#### Plant System
- **15 levels** với EXP thresholds: `[0, 5, 15, 30, 50, 75, 105, 140, 180, 225, 275, 330, 390, 455, 525]`
- **+1 EXP** mỗi check-in
- **Wilting:** 3+ ngày không check-in → mất 3 EXP/ngày
- **Freeze tokens:** Nhận mỗi 7-day streak (max 2), bảo vệ streak 1 ngày

#### Achievement System
| Key | Điều kiện |
|---|---|
| `first_checkin` | 1 check-in |
| `streak_3` | Streak >= 3 |
| `streak_7` | Streak >= 7 |
| `streak_30` | Streak >= 30 |
| `habits_5` | >= 5 habits active |
| `checkin_50` | 50 check-ins |
| `checkin_100` | 100 check-ins |
| `plant_level_3` | Plant level >= 3 |
| `plant_level_15` | Plant level >= 15 |

### 1.7. Cron Jobs (node-cron, Asia/Ho_Chi_Minh)

| Cron | Job | Mô tả |
|---|---|---|
| `* * * * *` | Personal reminders | Gửi FCM push theo giờ cá nhân của user |
| `0 8 * * *` | Morning emails | Email + push buổi sáng |
| `0 21 * * *` | Evening emails | Email + push buổi tối (chỉ nếu chưa hoàn thành) |
| `* * * * *` | Auto reminders | Gửi reminder theo cấu hình admin |
| `* * * * *` | Habit reminders | Nhắc habit theo reminder_time |
| `0 0 * * *` | Wilting penalty | Trừ điểm cây nếu không check-in |

### 1.8. External Services

| Service | Package | Mục đích |
|---|---|---|
| **Firebase** | `firebase-admin` | FCM push notifications |
| **Gemini AI** | REST API (fetch) | AI coaching chat (model: gemini-2.5-flash) |
| **Google OAuth** | `google-auth-library` | Sign in với Google |
| **Gmail SMTP** | `nodemailer` | Gửi email (reminders, OTP) |
| **MySQL** | `mysql2` | Database chính |

---

## 2. Kiến trúc Frontend (`viora_app/`)

### 2.1. Cấu trúc thư mục

```
viora_app/
└── lib/
    ├── main.dart                    # Entry point, MaterialApp setup
    ├── constants/
    │   └── app_icons.dart           # Lucide icon constants (70+ icons)
    ├── data/
    │   └── starter_habit_templates.dart  # Mẫu habits cho onboarding
    ├── l10n/
    │   ├── app_localizations.dart        # Base class (500+ strings)
    │   ├── app_localizations_en.dart     # English
    │   └── app_localizations_vi.dart     # Tiếng Việt
    ├── models/
    │   ├── post.dart                # Post model
    │   ├── comment.dart             # Comment model
    │   ├── reply.dart               # Reply model
    │   ├── plant_type.dart          # Plant type (bamboo, cactus, sakura, sunflower)
    │   ├── chat_message.dart        # AI chat message
    │   └── notification.dart        # Community notification
    ├── navigation/
    │   ├── app_tabs.dart            # Tab index constants
    │   └── app_navigation.dart      # Navigator (GlobalKey) + deep links
    ├── providers/
    │   └── locale_provider.dart     # Locale ChangeNotifier singleton
    ├── screens/
    │   ├── login_screen.dart        # Đăng nhập
    │   ├── register_screen.dart     # Đăng ký
    │   ├── forgot_password_screen.dart  # Quên mật khẩu (OTP)
    │   ├── onboarding_screen.dart   # 6-step onboarding
    │   ├── home_screen.dart         # Bottom nav shell
    │   ├── habits_screen.dart       # Today's habits
    │   ├── add_habit_screen.dart    # Create/edit habit
    │   ├── habit_detail_screen.dart # Habit detail + charts
    │   ├── stats_screen.dart        # Statistics
    │   ├── grow_screen.dart         # Plant + streak
    │   ├── plant_screen.dart        # Plant detail
    │   ├── achievements_screen.dart # Achievements
    │   ├── community_screen.dart    # Social feed
    │   ├── create_post_screen.dart  # Create post
    │   ├── post_detail_screen.dart  # Post + comments
    │   ├── user_profile_screen.dart # User profile
    │   ├── profile_screen.dart      # Own profile + settings
    │   ├── followers_list_screen.dart
    │   ├── ai_chat_screen.dart      # AI coach chat
    │   ├── notifications_inbox_screen.dart
    │   ├── notification_settings_screen.dart
    │   ├── admin_screen.dart        # Admin entry
    │   ├── admin_home_screen.dart   # Admin tabs shell
    │   ├── admin_dashboard_tab.dart # Dashboard stats
    │   ├── admin_users_tab.dart     # User management
    │   ├── admin_user_detail_screen.dart
    │   ├── admin_posts_tab.dart     # Post management
    │   ├── admin_habits_tab.dart    # Habit management
    │   ├── admin_plants_tab.dart    # Plant management
    │   ├── admin_plant_detail_screen.dart
    │   ├── admin_ai_assistant_tab.dart
    │   └── admin_settings_tab.dart
    ├── services/
    │   ├── api_service.dart         # HTTP client (1668 dòng) - tất cả API calls
    │   ├── ai_chat_service.dart     # AI chat HTTP
    │   ├── chat_history_store.dart  # Persist chat (SharedPreferences)
    │   ├── fcm_service.dart         # Firebase Messaging + local notif
    │   ├── flow_prefs.dart          # User flow flags
    │   ├── notification_service.dart    # Local notification scheduling
    │   ├── notification_inbox_store.dart # In-app notification store
    │   └── onboarding_gate.dart     # Onboarding flow logic
    ├── theme/
    │   ├── app_colors.dart         # Color palette (primary: #006B4E)
    │   ├── app_theme.dart          # ThemeData (light + dark, Material 3)
    │   ├── app_typography.dart     # Typography
    │   ├── app_spacing.dart        # Spacing constants
    │   ├── app_radius.dart         # Border radius constants
    │   └── theme_extensions.dart   # BuildContext extensions
    ├── utils/
    │   ├── habit_icon_mapper.dart  # Emoji ↔ Lucide icon mapping
    │   └── locale_helper.dart      # Locale persistence
    └── widgets/
        ├── viora_app_bar.dart      # Custom app bar (green gradient)
        ├── primary_button.dart     # Primary action button
        ├── secondary_button.dart   # Outline button
        ├── app_text_field.dart     # Themed input
        ├── app_card.dart           # Themed card
        ├── app_snackbar.dart       # Custom snackbar
        ├── app_confirm_dialog.dart # Confirmation dialog
        ├── habit_icon.dart         # Emoji habit icon
        ├── plant_widget.dart       # Animated plant display
        ├── post_card.dart          # Community post card
        ├── floating_leaves.dart    # Decorative animation
        ├── level_up_animation.dart # Level up animation
        ├── points_fly_animation.dart   # +1 EXP animation
        ├── treasure_reward_animation.dart # Reward chest animation
        ├── achievement_popup.dart       # Achievement unlocked
        ├── all_habits_completed_dialog.dart
        ├── language_flag_toggle.dart    # VI/EN toggle
        ├── category_icon_dot_painter.dart
        └── image_dot_painter.dart
```

### 2.2. State Management

| Pattern | Sử dụng cho |
|---|---|
| **setState** | Hầu hết các screen |
| **ValueNotifier** | Theme (dark/light mode) |
| **ChangeNotifier** (singleton) | Locale (`LocaleProvider.global`) |
| **SharedPreferences** | Auth token, FCM token, settings, onboarding flags, chat history, notification inbox |

> **Lưu ý:** App **không** dùng Provider, Riverpod, Bloc hay GetX. State management tối giản với setState + SharedPreferences.

### 2.3. Navigation Flow

```
App Launch
  └── checkLogin() (SharedPreferences)
        ├── Token null ──> LoginScreen
        └── Token exists ──> OnboardingScreen (new) / HomeScreen

HomeScreen
  └── BottomNavigationBar (4 tabs)
        ├── [0] Today (habits + dashboard)
        ├── [1] Community (feed)
        ├── [2] Grow (plant + streak)
        └── [3] Me (profile + settings)

Push routes: HabitsScreen, AiChatScreen, PostDetailScreen, UserProfileScreen
```

### 2.4. Dependencies (pubspec.yaml)

| Package | Mục đích |
|---|---|
| `http` 1.2 | REST API calls |
| `shared_preferences` | Local persistence |
| `google_sign_in` | Google OAuth |
| `fl_chart` | Charts (bar, line, pie) |
| `flutter_local_notifications` | Local push scheduling |
| `timezone` | Timezone support |
| `firebase_core` + `firebase_messaging` | FCM push |
| `image_picker` | Camera/gallery picker |
| `lucide_icons` | Icon set |
| `intl` | Internationalization |

### 2.5. Theming

- **Material 3**, primary color `#006B4E` (dark green)
- **2 modes:** Light (`background: #F7F9F8`) và Dark (`darkBackground: #0F1A16`)
- **Typography:** Roboto, 6 size levels
- **Icons:** Lucide Icons (70+ constants)

### 2.6. Localization

- **2 ngôn ngữ:** Tiếng Việt + English
- **500+ strings** generated via `flutter gen-l10n`
- **LocaleProvider** singleton quản lý locale, sync lên backend

---

## 3. Kiến trúc Tổng thể & Luồng Dữ liệu

### 3.1. Authentication Flow

```
┌──────────────┐    ┌───────────────┐    ┌──────────────┐
│  Flutter App  │    │  Express API  │    │    MySQL     │
├──────────────┤    ├───────────────┤    ├──────────────┤
│ Login/Google │───>│ /auth/login   │───>│ SELECT user  │
│              │<───│ JWT token     │<───│ verify hash  │
│ Store token  │    │               │    │              │
│ in SharedPref│    │               │    │              │
└──────────────┘    └───────────────┘    └──────────────┘
       │                                       │
       │  Bearer Token                         │
       ▼                                       ▼
┌──────────────┐    ┌───────────────┐    ┌──────────────┐
│ API calls    │───>│ authMiddleware│───>│ Verify JWT   │
│ (all routes) │    │ jwt.verify()  │    │ req.user.id  │
└──────────────┘    └───────────────┘    └──────────────┘
```

### 3.2. Check-in Flow (Core Feature)

```
User check-in
  │
  ▼
Flutter App ──POST /habits/:id/checkin──> Express
  │                                            │
  │                                            ├─ INSERT/UPDATE habit_logs
  │                                            ├─ UPDATE habits (streak)
  │                                            ├─ UPDATE streaks tổng thể
  │                                            ├─ UPDATE plants (EXP +1)
  │                                            ├─ Kiểm tra achievements
  │                                            └─ Response (streak, plant, achievements)
  │
  ▼
Flutter App hiển thị animation (EXP +1, level-up, achievement popup)
```

### 3.3. Notification System (3 Channels)

```
Cron Jobs (node-cron)
  │
  ├─ Personal reminders (FCM) ────────────────> Firebase ──> Mobile App
  ├─ Morning/Evening emails (nodemailer) ─────> Gmail SMTP ──> Email
  ├─ Auto reminders (FCM + email) ────────────> Firebase + Email
  ├─ Habit reminders (FCM) ───────────────────> Firebase
  └─ Community notifications (in-app) ────────> user_notifications table
                                                        │
                                                        ▼
                                              Flutter fetch /community/notifications
```

### 3.4. Admin Moderation Flow

```
Post bị report
  │
  ▼
Admin ──POST /admin/posts/:id/report──> is_warned = 1
  │                                        │
  │                                        ├─ Ẩn post khỏi feed
  │                                        ├─ Gửi email + notif cho user
  │
  ▼
User sửa post ──PUT /community/posts/:id──> edited_after_warn = 1
  │
  ▼
Admin review
  ├── Approve ──> is_warned = 0, post hiện lại
  └── Reject  ──> Xóa post, gửi lý do
```

---

## 4. Database Relationships

```
users (1) ───── (N) habits
users (1) ───── (1) streaks
users (1) ───── (1) plants
users (1) ───── (N) achievements
users (1) ───── (N) community_posts
users (1) ───── (N) community_comments
users (1) ───── (N) community_comment_replies
users (1) ───── (N) user_notifications
users (N) ───── (N) user_follows (self-referencing)
users (N) ───── (N) community_post_likes
users (N) ───── (N) community_comment_likes

habits (1) ──── (N) habit_logs
```

---

## 5. Security

- **JWT** 7-day expiry, Bearer token
- **Password** bcrypt (10 salt rounds)
- **File upload** validation: chỉ image, max 5MB
- **Admin routes** double middleware (JWT + role check)
- **Google OAuth** verify ID token server-side
- **OTP** 6-digit, 10 phút expiry
- **Environment variables** cho tất cả secrets

---

## 6. Deployment & Environment

| Variable | Mô tả |
|---|---|
| `PORT` | Server port (mặc định 3000) |
| `DB_HOST/DB_USER/DB_PASSWORD/DB_NAME` | MySQL config |
| `JWT_SECRET` | JWT signing key |
| `GOOGLE_CLIENT_ID` | Google OAuth client ID |
| `GEMINI_API_KEY` | Gemini AI API key |
| `FIREBASE_PROJECT_ID/CLIENT_EMAIL/PRIVATE_KEY` | Firebase Admin |
| `GMAIL_USER/GMAIL_APP_PASSWORD` | Email SMTP |
| `PUBLIC_BASE_URL` | Base URL cho file uploads |

Backend dev: `npm run dev` (nodemon + ts-node)
