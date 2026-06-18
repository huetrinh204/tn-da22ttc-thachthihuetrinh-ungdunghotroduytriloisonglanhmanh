# Kế hoạch triển khai: AI Chat Assistant

## Tổng quan

Triển khai tính năng AI Chat Assistant theo thứ tự: backend endpoint → Flutter model/service/store → UI screen → tích hợp navigation. Mỗi bước build trên bước trước, kết thúc bằng wiring toàn bộ vào app.

## Tasks

- [x] 1. Tạo backend route `POST /ai/chat`
  - [x] 1.1 Tạo file `viora_backend/src/routes/ai.ts`
    - Định nghĩa interface `ConversationTurn` và `UserContext`
    - Implement `buildUserContext(userId)` — query DB lấy tên, habits, streak, tiến độ hôm nay
    - Implement `formatContextText(ctx)` — trả về chuỗi văn bản có cấu trúc
    - Implement `buildSystemPrompt(ctx)` — ghép System Prompt tĩnh với User Context động
    - Implement `callGemini(systemPrompt, userMessage, history)` — gọi Gemini REST API với `GEMINI_API_KEY` từ `.env`
    - Implement `POST /ai/chat` với `authMiddleware` JWT, validate message (không rỗng, ≤ 2000 ký tự), xử lý lỗi 400/401/503
    - Log cảnh báo khi khởi động nếu `GEMINI_API_KEY` chưa được cấu hình
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 8.1, 8.2, 8.3_

  - [ ]* 1.2 Viết unit tests cho backend (`viora_backend/src/routes/ai.test.ts`)
    - Kiểm tra 401 khi không có JWT
    - Kiểm tra 400 khi message rỗng hoặc > 2000 ký tự
    - Kiểm tra 503 khi `GEMINI_API_KEY` chưa cấu hình (mock env)
    - Kiểm tra 503 khi Gemini API trả lỗi (mock fetch)
    - Kiểm tra response shape `{ reply: string }` với mock Gemini thành công
    - Kiểm tra `buildUserContext` với habits rỗng/null (edge case 3.3)
    - _Requirements: 5.3, 5.4, 5.5, 8.3_

  - [ ]* 1.3 Viết property test cho `formatContextText` và `buildSystemPrompt` (`viora_backend/src/routes/ai.test.ts`)
    - **Property 4: Context Builder output chứa đủ trường**
    - **Validates: Requirements 3.1, 3.4**
    - **Property 5: System Prompt chứa User Context**
    - **Validates: Requirements 4.4**
    - Dùng `fast-check`, tối thiểu 100 iterations
    - _Requirements: 3.1, 3.4, 4.4_

- [x] 2. Đăng ký route AI vào Express server
  - Thêm `import aiRoutes from "./routes/ai"` vào `viora_backend/src/index.ts`
  - Thêm `app.use("/ai", aiRoutes)` sau các route hiện có
  - _Requirements: 5.1_

- [x] 3. Checkpoint — backend sẵn sàng
  - Ensure all tests pass, ask the user if questions arise.

- [x] 4. Tạo Flutter model `ChatMessage`
  - [x] 4.1 Tạo file `viora_app/lib/models/chat_message.dart`
    - Định nghĩa class `ChatMessage` với các trường `role` (String), `content` (String), `timestamp` (DateTime)
    - Implement `toJson()` và factory `ChatMessage.fromJson(Map<String, dynamic> json)`
    - Xử lý edge case timestamp không hợp lệ trong `fromJson`
    - _Requirements: 7.4_

  - [ ]* 4.2 Viết property test cho `ChatMessage` serialization (`viora_app/test/models/chat_message_test.dart`)
    - **Property 6: ChatMessage serialization round-trip**
    - **Validates: Requirements 7.4**
    - Dùng `glados`, tối thiểu 100 iterations
    - _Requirements: 7.4_

- [x] 5. Tạo Flutter service `ChatHistoryStore`
  - [x] 5.1 Tạo file `viora_app/lib/services/chat_history_store.dart`
    - Implement `ChatHistoryStore.load()` — đọc từ `SharedPreferences` key `ai_chat_history`, deserialize JSON, trả về tối đa 50 tin nhắn gần nhất
    - Implement `ChatHistoryStore.save(List<ChatMessage> messages)` — serialize và lưu vào `SharedPreferences`
    - Implement `ChatHistoryStore.clear()` — xóa key `ai_chat_history`
    - _Requirements: 7.1, 7.2, 7.3, 7.4_

  - [ ]* 5.2 Viết property test cho `ChatHistoryStore` (`viora_app/test/services/chat_history_store_test.dart`)
    - **Property 7: Lưu và tải lịch sử giữ nguyên dữ liệu (giới hạn 50 tin nhắn)**
    - **Validates: Requirements 7.1, 7.2**
    - Dùng `glados`, tối thiểu 100 iterations
    - _Requirements: 7.1, 7.2_

- [ ] 6. Tạo Flutter service `AiChatService`
  - [x] 6.1 Tạo file `viora_app/lib/services/ai_chat_service.dart`
    - Implement static method `AiChatService.sendMessage({required String token, required String message, required List<ChatMessage> history})`
    - Gọi `POST /ai/chat` với Authorization Bearer, body gồm `message` và `history` (map `role: "ai"` → `"model"` khi serialize history cho backend nếu cần)
    - Ném exception có message rõ ràng khi HTTP 400, 503, hoặc network error
    - _Requirements: 5.1, 5.2, 6.1, 6.2, 6.3_

- [x] 7. Tạo `AiChatScreen`
  - [x] 7.1 Tạo file `viora_app/lib/screens/ai_chat_screen.dart`
    - Tạo `StatefulWidget` với `ScrollController` và `TextEditingController`
    - State: `List<ChatMessage> _messages`, `bool _isLoading`, `String? _inputError`
    - Trong `initState`: load lịch sử từ `ChatHistoryStore` và scroll xuống cuối
    - Build UI: danh sách tin nhắn (user bên phải, AI bên trái với icon bot), typing indicator (3 chấm nhấp nháy) khi `_isLoading`
    - Nút gửi bị disabled khi input rỗng/whitespace hoặc `_isLoading`; khi hợp lệ gọi `AiChatService.sendMessage`
    - Auto-scroll xuống sau mỗi tin nhắn mới
    - Xử lý lỗi: HTTP 503 → bubble lỗi ở vị trí AI message; HTTP 400 → `_inputError` dưới ô input; network error → SnackBar
    - Restore nội dung input khi xảy ra lỗi
    - Nút "Xóa lịch sử" với confirm dialog gọi `ChatHistoryStore.clear()`
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 6.1, 6.2, 6.3, 6.4, 6.5, 7.2, 7.3_

  - [ ]* 7.2 Viết property tests cho `AiChatScreen` (`viora_app/test/widgets/ai_chat_screen_test.dart`)
    - **Property 1: Alignment tin nhắn theo role**
    - **Validates: Requirements 1.1**
    - **Property 2: Tin nhắn hợp lệ xuất hiện trong danh sách sau khi gửi**
    - **Validates: Requirements 1.3**
    - **Property 3: Nút gửi disabled/enabled theo trạng thái input**
    - **Validates: Requirements 1.6**
    - **Property 8: Input được restore khi request lỗi**
    - **Validates: Requirements 6.5**
    - Dùng `glados`, tối thiểu 100 iterations
    - _Requirements: 1.1, 1.3, 1.6, 6.5_

  - [ ]* 7.3 Viết unit tests cho UI behaviors (`viora_app/test/screens/ai_chat_screen_test.dart`)
    - Typing indicator hiển thị khi loading và ẩn sau khi nhận phản hồi
    - Error bubble hiển thị khi 503
    - Error message dưới input khi 400
    - SnackBar khi mất mạng
    - Nút xóa lịch sử hoạt động đúng
    - _Requirements: 1.4, 6.1, 6.2, 6.3, 7.3_

- [x] 8. Checkpoint — Flutter core sẵn sàng
  - Ensure all tests pass, ask the user if questions arise.

- [x] 9. Tích hợp navigation — thêm tab AI vào app
  - [x] 9.1 Cập nhật `viora_app/lib/constants/app_icons.dart`
    - Thêm `static const aiChat = LucideIcons.bot;`
    - _Requirements: 2.1_

  - [x] 9.2 Cập nhật `viora_app/lib/navigation/app_tabs.dart`
    - Thêm `static const int aiChat = 5;`
    - Cập nhật `normalize()` để xử lý index 5
    - _Requirements: 2.1_

  - [x] 9.3 Cập nhật `viora_app/lib/navigation/app_navigation.dart`
    - Thêm `static void openAiChat() => switchToTab(AppTabs.aiChat);`
    - _Requirements: 2.1, 2.2, 2.3_

  - [x] 9.4 Cập nhật `viora_app/lib/screens/home_screen.dart`
    - Import `ai_chat_screen.dart`
    - Thêm `import 'ai_chat_screen.dart'` và case `AppTabs.aiChat` trong `_buildScreen`
    - Thêm `_NavItem(icon: AppIcons.aiChat, label: "Trợ lý AI")` vào `navItems` list
    - Thêm shortcut card "Trợ lý AI" trong `_DashboardTab._buildTodayCard` hoặc cuối danh sách cards — khi tap gọi `AppNavigation.openAiChat()`
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

- [x] 10. Final checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks đánh dấu `*` là optional, có thể bỏ qua để ra MVP nhanh hơn
- Property tests dùng `glados` (Flutter) và `fast-check` (TypeScript/Node.js)
- `GEMINI_API_KEY` phải được thêm vào file `.env` của backend trước khi chạy
- Lịch sử hội thoại lưu cục bộ bằng `SharedPreferences` — không cần migration DB
