# Tài liệu Yêu cầu

## Giới thiệu

Tính năng AI Chat Assistant (Trợ lý ảo AI) tích hợp vào ứng dụng Viora nhằm cung cấp một trợ lý cá nhân hóa, đóng vai "Chuyên gia huấn luyện lối sống" (Lifestyle Coach) thân thiện. Trợ lý sử dụng Gemini 1.5 Flash để phân tích ngữ cảnh thói quen của người dùng (danh sách thói quen, tiến độ, streak) và đưa ra lời khuyên, động viên, cùng câu trả lời y tế/dinh dưỡng dễ hiểu, có bước hành động cụ thể.

API Key Gemini được bảo mật hoàn toàn phía backend (Node.js/TypeScript). Flutter client chỉ giao tiếp với backend Viora — không gọi Gemini trực tiếp.

---

## Bảng thuật ngữ

- **AI_Chat_Service**: Dịch vụ backend xử lý yêu cầu chat, gọi Gemini API và trả về phản hồi.
- **Chat_Screen**: Màn hình Flutter hiển thị giao diện chat với Trợ lý AI.
- **Context_Builder**: Module backend tổng hợp ngữ cảnh người dùng (tên, thói quen, tiến độ, streak) trước khi gửi lên Gemini.
- **Gemini_Client**: Module backend gọi Google Gemini 1.5 Flash API.
- **Chat_History_Store**: Nơi lưu trữ lịch sử hội thoại (tùy chọn, tại client hoặc server).
- **System_Prompt**: Chỉ dẫn vai trò ban đầu gửi đến Gemini, định nghĩa hành vi của Trợ lý AI.
- **User_Context**: Tập dữ liệu gồm tên người dùng, danh sách thói quen, tiến độ hôm nay (%), streak hiện tại.
- **Lifestyle_Coach**: Vai trò AI đóng — chuyên gia huấn luyện lối sống thân thiện, tích cực, có kiến thức khoa học.

---

## Yêu cầu

### Yêu cầu 1: Giao diện Chat

**User Story:** Là người dùng Viora, tôi muốn có một màn hình chat riêng biệt để trò chuyện với Trợ lý AI, để tôi dễ dàng tiếp cận tư vấn về thói quen và sức khỏe.

#### Tiêu chí chấp nhận

1. THE Chat_Screen SHALL hiển thị danh sách tin nhắn theo thứ tự thời gian, phân biệt rõ tin nhắn người dùng (bên phải) và tin nhắn Trợ lý AI (bên trái).
2. THE Chat_Screen SHALL cung cấp ô nhập văn bản và nút gửi tin nhắn ở cuối màn hình.
3. WHEN người dùng chạm nút gửi hoặc nhấn phím gửi trên bàn phím, THE Chat_Screen SHALL gửi tin nhắn và hiển thị ngay tin nhắn đó trong danh sách.
4. WHILE AI_Chat_Service đang xử lý phản hồi, THE Chat_Screen SHALL hiển thị hiệu ứng loading (typing indicator — ba chấm nhấp nháy) ở vị trí tin nhắn Trợ lý AI.
5. THE Chat_Screen SHALL hiển thị tên và avatar (icon bot) của Trợ lý AI bên cạnh mỗi tin nhắn của AI.
6. IF ô nhập văn bản trống khi người dùng nhấn gửi, THEN THE Chat_Screen SHALL vô hiệu hóa nút gửi và không thực hiện thêm hành động nào.
7. THE Chat_Screen SHALL hỗ trợ cuộn tự động xuống tin nhắn mới nhất sau mỗi lần có tin nhắn mới.

---

### Yêu cầu 2: Tích hợp vào điều hướng ứng dụng

**User Story:** Là người dùng Viora, tôi muốn truy cập Trợ lý AI nhanh chóng từ thanh điều hướng dưới cùng và từ màn hình Hôm nay, để tôi không mất thời gian tìm kiếm.

#### Tiêu chí chấp nhận

1. THE Chat_Screen SHALL được thêm vào bottom navigation bar của HomeScreen như một tab riêng biệt với icon "bot" hoặc "message-circle" và nhãn "Trợ lý AI".
2. THE HomeScreen SHALL hiển thị một shortcut card (thẻ nhanh) trên màn hình Hôm nay để mở Chat_Screen trong cùng navigation stack.
3. WHEN người dùng chạm tab Trợ lý AI trên bottom navigation bar, THE HomeScreen SHALL chuyển ngay sang Chat_Screen mà không load lại toàn bộ ứng dụng.
4. WHEN người dùng chạm shortcut card trên màn hình Hôm nay, THE Chat_Screen SHALL mở ra và hiển thị gợi ý câu hỏi hoặc lời chào mừng từ Trợ lý AI.

---

### Yêu cầu 3: Xây dựng ngữ cảnh người dùng (Context Building)

**User Story:** Là người dùng Viora, tôi muốn Trợ lý AI hiểu được tiến độ thói quen của tôi, để lời khuyên nhận được phù hợp với tình hình thực tế của bản thân.

#### Tiêu chí chấp nhận

1. WHEN người dùng gửi tin nhắn, THE Context_Builder SHALL thu thập và đính kèm User_Context gồm: tên người dùng, danh sách thói quen hiện tại (tên + danh mục), tiến độ hoàn thành hôm nay (số đã xong / tổng số), và streak hiện tại.
2. THE Context_Builder SHALL chỉ gửi User_Context lên Gemini_Client; THE Context_Builder SHALL không lưu User_Context vào cơ sở dữ liệu như một bản ghi riêng biệt.
3. IF không lấy được dữ liệu thói quen của người dùng, THEN THE Context_Builder SHALL gửi yêu cầu lên Gemini_Client với User_Context rỗng và ghi log lỗi phía server.
4. THE Context_Builder SHALL tổng hợp User_Context dưới dạng văn bản có cấu trúc để nhúng vào System_Prompt.

---

### Yêu cầu 4: System Prompt & Vai trò AI

**User Story:** Là người dùng Viora, tôi muốn Trợ lý AI luôn đóng vai một huấn luyện viên lối sống thân thiện, tích cực, để tôi cảm thấy được hỗ trợ và không bị phán xét.

#### Tiêu chí chấp nhận

1. THE AI_Chat_Service SHALL đính kèm System_Prompt vào mỗi yêu cầu gửi đến Gemini_Client, trong đó định nghĩa vai trò Lifestyle_Coach: thân thiện, tích cực, có kiến thức khoa học, trả lời bằng tiếng Việt.
2. THE AI_Chat_Service SHALL yêu cầu Gemini_Client trả về phản hồi ngắn gọn (tối đa 300 từ), dễ hiểu, và có ít nhất một bước hành động cụ thể (actionable step) khi phù hợp.
3. WHEN người dùng hỏi về chủ đề ngoài phạm vi sức khỏe, dinh dưỡng, và thói quen lành mạnh, THE AI_Chat_Service SHALL hướng dẫn Gemini_Client từ chối lịch sự và gợi ý quay lại chủ đề phù hợp.
4. THE System_Prompt SHALL bao gồm User_Context đã được tổng hợp bởi Context_Builder để cá nhân hóa phản hồi.

---

### Yêu cầu 5: API Backend — Endpoint Chat

**User Story:** Là lập trình viên backend, tôi muốn có một endpoint rõ ràng để Flutter client gửi yêu cầu chat, để API Key Gemini không bao giờ bị lộ phía client.

#### Tiêu chí chấp nhận

1. THE AI_Chat_Service SHALL cung cấp endpoint `POST /ai/chat` yêu cầu xác thực JWT (Authorization Bearer token).
2. WHEN nhận được yêu cầu hợp lệ, THE AI_Chat_Service SHALL gọi Gemini_Client với nội dung tin nhắn + System_Prompt + User_Context và trả về phản hồi JSON `{ "reply": "<nội dung>" }` với HTTP 200.
3. IF token JWT không hợp lệ hoặc hết hạn, THEN THE AI_Chat_Service SHALL trả về HTTP 401 với `{ "message": "Unauthorized" }`.
4. IF Gemini_Client trả về lỗi (quá tải, timeout, nội dung không phù hợp), THEN THE AI_Chat_Service SHALL trả về HTTP 503 với `{ "message": "<mô tả lỗi thân thiện>" }`.
5. IF nội dung tin nhắn từ client rỗng hoặc vượt quá 2000 ký tự, THEN THE AI_Chat_Service SHALL trả về HTTP 400 với `{ "message": "Tin nhắn không hợp lệ" }`.
6. THE AI_Chat_Service SHALL đọc GEMINI_API_KEY từ biến môi trường; THE AI_Chat_Service SHALL không hard-code API key trong source code.
7. WHERE tính năng streaming được bật trong cấu hình, THE AI_Chat_Service SHALL hỗ trợ Server-Sent Events (SSE) qua endpoint `GET /ai/chat/stream` để truyền phản hồi từng phần.

---

### Yêu cầu 6: Xử lý lỗi phía Client

**User Story:** Là người dùng Viora, tôi muốn nhận thông báo rõ ràng khi có lỗi xảy ra (mất mạng, server quá tải), để tôi biết chuyện gì đang xảy ra và có thể thử lại.

#### Tiêu chí chấp nhận

1. IF kết nối mạng bị gián đoạn khi gửi tin nhắn, THEN THE Chat_Screen SHALL hiển thị thông báo lỗi "Không có kết nối mạng. Vui lòng thử lại." và cho phép người dùng gửi lại tin nhắn.
2. IF AI_Chat_Service trả về HTTP 503, THEN THE Chat_Screen SHALL hiển thị thông báo "Trợ lý AI đang bận, vui lòng thử lại sau ít phút." trong bubble tin nhắn của AI.
3. IF AI_Chat_Service trả về HTTP 400, THEN THE Chat_Screen SHALL hiển thị thông báo "Tin nhắn không hợp lệ. Vui lòng kiểm tra lại nội dung." ngay bên dưới ô nhập văn bản.
4. WHILE AI_Chat_Service đang xử lý, THE Chat_Screen SHALL vô hiệu hóa nút gửi để ngăn người dùng gửi nhiều yêu cầu đồng thời.
5. WHEN xảy ra lỗi bất kỳ, THE Chat_Screen SHALL khôi phục lại nội dung tin nhắn trong ô nhập để người dùng không phải nhập lại.

---

### Yêu cầu 7: Lưu lịch sử hội thoại (tùy chọn)

**User Story:** Là người dùng Viora, tôi muốn xem lại lịch sử hội thoại khi mở lại ứng dụng, để tôi có thể ôn lại lời khuyên đã nhận.

#### Tiêu chí chấp nhận

1. WHERE tính năng lưu lịch sử được bật, THE Chat_History_Store SHALL lưu mỗi cặp tin nhắn (người dùng + AI) vào bộ nhớ cục bộ (SharedPreferences hoặc SQLite) trên thiết bị.
2. WHERE tính năng lưu lịch sử được bật, WHEN người dùng mở Chat_Screen, THE Chat_Screen SHALL tải và hiển thị tối đa 50 tin nhắn gần nhất từ Chat_History_Store.
3. WHERE tính năng lưu lịch sử được bật, THE Chat_Screen SHALL cung cấp nút "Xóa lịch sử" để xóa toàn bộ hội thoại đã lưu sau khi người dùng xác nhận.
4. THE Chat_History_Store SHALL lưu mỗi tin nhắn với các trường: vai trò (user/ai), nội dung văn bản, và dấu thời gian.

---

### Yêu cầu 8: Bảo mật API Key

**User Story:** Là lập trình viên, tôi muốn API Key Gemini không bao giờ xuất hiện trong mã Flutter hoặc APK, để tránh rủi ro lộ key và lạm dụng quota.

#### Tiêu chí chấp nhận

1. THE AI_Chat_Service SHALL là điểm duy nhất giữ và sử dụng GEMINI_API_KEY; Flutter client SHALL không nhận, lưu, hoặc truyền đi API key này.
2. THE AI_Chat_Service SHALL đọc GEMINI_API_KEY từ file `.env` (biến môi trường) tại thời điểm khởi động server; biến này SHALL không được commit vào source control.
3. IF GEMINI_API_KEY không được cấu hình trong môi trường, THEN THE AI_Chat_Service SHALL log cảnh báo khi khởi động và trả về HTTP 503 cho mọi yêu cầu `/ai/chat`.
