# Sơ Đồ Hoạt Động - Viora

## 1. Đăng Ký

```
Màn hình Đăng nhập
    │
    ├── Người dùng nhấn "Đăng ký"
    │
    ▼
Màn hình Đăng ký
    │
    ├── Nhập họ tên
    ├── Nhập email
    ├── Nhập mật khẩu
    ├── Nhấn "Đăng ký"
    │
    ├── [Thành công] → Màn hình Onboarding
    │
    └── [Thất bại]   → Xem thông báo lỗi
                          ├─ "Email đã được sử dụng"
                          └─ "Lỗi mạng"
```

---

## 2. Đăng Nhập (Email)

```
Màn hình Đăng nhập
    │
    ├── Nhập email
    ├── Nhập mật khẩu
    ├── Nhấn "Đăng nhập"
    │
    ├── [Thành công]
    │     ├── [Đã onboarding] → Màn hình chính (Tab Today)
    │     └── [Chưa onboard] → Màn hình Onboarding
    │
    └── [Thất bại] → Xem thông báo "Sai email hoặc mật khẩu"
```

---

## 3. Đăng Nhập (Google)

```
Màn hình Đăng nhập
    │
    ├── Nhấn "Đăng nhập với Google"
    │
    ▼
Chọn tài khoản Google
    │
    ├── [Thành công]
    │     ├── [Tài khoản mới] → Màn hình Onboarding
    │     └── [Tài khoản cũ] → Màn hình chính
    │
    └── [Thất bại] → Quay lại màn hình Đăng nhập
```

---

## 4. Thiết Lập Tài Khoản & Mục Tiêu Cá Nhân

### 4a. Thiết lập lần đầu (Onboarding - 6 bước)

```
Màn hình Onboarding (vuốt trái/phải giữa các bước)
    │
    ├── Bước 1: Chọn giới tính (Nam / Nữ / Khác)
    │     └── Nhấn "Tiếp theo" (bắt buộc)
    │
    ├── Bước 2: Nhập năm sinh
    │     └── Nhấn "Tiếp theo" (có validate: >= 1930, <= hiện tại - 10)
    │
    ├── Bước 3: Nhập chiều cao (cm) + cân nặng (kg)
    │     └── Nhấn "Tiếp theo" (không bắt buộc, có validate: 100-250cm, 15-300kg)
    │
    ├── Bước 4: Chọn mục tiêu cá nhân (có thể chọn nhiều)
    │     ├── 🥗 Ăn lành mạnh
    │     ├── 🏃 Vận động
    │     ├── 😴 Giấc ngủ
    │     ├── 🧘 Tinh thần
    │     ├── ⚖️ Cân nặng
    │     ├── 💧 Uống nước
    │     └── ✏️ Mục tiêu khác (nhập tự do)
    │     └── Nhấn "Tiếp theo" (phải chọn ít nhất 1)
    │
    ├── Bước 5: Chọn thói quen mẫu (gợi ý dựa trên mục tiêu đã chọn)
    │     ├── Tự động gợi ý 3 thói quen, có thể bỏ tick/thêm
    │     └── Nhấn "Tiếp theo" (phải chọn ít nhất 1)
    │
    ├── Bước 6: Chọn loại cây đồng hành
    │     ├── 🎋 Tre
    │     ├── 🌵 Xương rồng
    │     ├── 🌸 Hoa anh đào
    │     └── 🌻 Hoa hướng dương
    │     └── Nhấn "Bắt đầu"
    │
    ├── [Hoàn tất] → Lưu thông tin cá nhân (PUT profile)
    │     → Tạo habits mẫu đã chọn (POST habits hàng loạt)
    │     → Lưu loại cây (PUT plant/type)
    │     → Đánh dấu onboarding hoàn tất
    │     → Mở màn hình chính (Tab Today)
    │
    └── [Nhấn "Bỏ qua" ở bất kỳ bước nào]
          → Đánh dấu onboarding hoàn tất
          → Đánh dấu profile chưa hoàn chỉnh
          → Mở màn hình chính (không tạo habits, không lưu thông tin)
```

### 4b. Chỉnh sửa thông tin (Profile)

```
Màn hình Profile (Tab Me)
    │
    ├── Xem thông tin hiện tại:
    │     ├── Avatar + tên
    │     ├── Email
    │     ├── Giới tính, năm sinh
    │     ├── Chiều cao, cân nặng
    │     └── Mục tiêu cá nhân
    │
    ├── Nhấn vào avatar → Chọn ảnh từ thư viện
    │     └── Upload avatar mới
    │
    ├── Nhấn "Sửa tên" → Bottom sheet nhập tên mới → Lưu
    │
    ├── Nhấn "Sửa chiều cao, cân nặng" → Bottom sheet
    │     ├── Nhập chiều cao (cm) + cân nặng (kg) mới
    │     └── Lưu
    │
    ├── Nhấn "Sửa mục tiêu" → Bottom sheet
    │     ├── Tick/bỏ tick các mục tiêu
    │     └── Lưu
    │
    ├── Nhấn "Đổi mật khẩu" → Bottom sheet
    │     ├── Nhập mật khẩu hiện tại
    │     ├── Nhập mật khẩu mới (>= 8 ký tự)
    │     ├── Nhập lại mật khẩu mới
    │     ├── Lưu
    │     └── [Quên mật khẩu] → Chuyển đến màn hình Quên mật khẩu
    │
    └── Sau mỗi lần sửa → Xem thông báo "Cập nhật thành công"
```

---

## 5. Quên Mật Khẩu

```
Màn hình Đăng nhập
    │
    ├── Nhấn "Quên mật khẩu"
    │
    ▼
Màn hình nhập email
    │
    ├── Nhập email
    ├── Nhấn "Gửi mã OTP"
    │
    ▼
Kiểm tra email (hộp thư đến)
    │
    ├── [Nhận được OTP]
    │     │
    │     ▼
    │   Màn hình nhập OTP
    │     ├── Nhập 6 số OTP
    │     ├── Nhập mật khẩu mới
    │     ├── Nhập lại mật khẩu mới
    │     ├── Nhấn "Đặt lại mật khẩu"
    │     │
    │     ├── [Thành công] → Màn hình Đăng nhập (thông báo "Đặt lại thành công")
    │     │
    │     └── [Thất bại] → Xem lỗi: "OTP không đúng" / "OTP hết hạn"
    │
    └── [Không nhận được OTP] → Nhấn "Gửi lại"
```

---

## 6. Tạo Thói Quen

```
Màn hình Today / Habits
    │
    ├── Nhấn nút "+" (góc dưới phải)
    │
    ▼
Màn hình Thêm thói quen
    │
    ├── Nhập tên thói quen (vd: "Tập thể dục")
    ├── Chọn biểu tượng (emoji)
    ├── Chọn danh mục (Sức khỏe, Học tập, Công việc...)
    ├── Chọn tần suất (Hàng ngày / Hàng tuần)
    ├── Đặt mục tiêu (vd: 1 lần/ngày)
    ├── Đặt giờ nhắc (tuỳ chọn)
    ├── Nhấn "Lưu"
    │
    ├── [Thành công] → Quay lại danh sách (thấy habit mới)
    │
    └── [Thất bại] → Xem lỗi
```

---

## 7. Sửa / Xoá Thói Quen

```
Màn hình Today / Habits
    │
    ├── Nhấn vào thói quen
    │
    ▼
Màn hình Chi tiết thói quen
    │
    ├── [Sửa]
    │     ├── Nhấn "Sửa"
    │     ├── Chỉnh sửa thông tin
    │     ├── Nhấn "Lưu"
    │     └── Quay lại chi tiết (thấy thông tin mới)
    │
    └── [Xoá]
          ├── Nhấn "Xoá"
          ├── Xác nhận "Bạn chắc chắn muốn xoá?"
          ├── Nhấn "Xoá" (xác nhận)
          └── Quay lại danh sách (habit biến mất)
```

---

## 8. Check-in Hàng Ngày

```
Màn hình Today (danh sách habits hôm nay)
    │
    ├── Nhấn nút check-in (hình tròn) bên cạnh thói quen
    │
    ▼
Xem hiệu ứng:
    ├── "+1 EXP" bay lên từ cây
    ├── [Cây lên level] → Màn hình Level Up (cây lớn hơn)
    ├── [Mở thành tựu] → Popup "Thành tựu mới!"
    ├── Cập nhật: streak tăng, cây lớn hơn
    │
    └── Check-in xong, nút chuyển màu xanh / có dấu tick
```

---

## 9. Xem Cây & Streak

```
Tab "Grow" (Bottom nav thứ 3)
    │
    ├── Xem cây ảo (có animation)
    ├── Xem cấp độ (Level X / 15)
    ├── Xem thanh EXP
    ├── Xem streak hiện tại (vd: "🔥 7 ngày")
    ├── Xem kỷ lục streak dài nhất
    ├── Xem số lượng Freeze Token
    │
    ├── Nhấn vào cây → Màn hình chi tiết cây
    │     ├── Chọn loại cây khác (4 loại)
    │     └── Xem lịch sử cây
    │
    └── Nhấn "Thành tựu" → Danh sách thành tựu (đã mở/chưa mở)
```

---

## 10. Xem Feed Cộng Đồng

```
Tab "Community" (Bottom nav thứ 2)
    │
    ├── Chọn tab: "Thịnh hành" / "Đang follow" / "Thành tựu"
    │
    ▼
Danh sách bài viết
    │
    ├── Vuốt lên/xuống để xem thêm
    ├── Mỗi bài viết gồm:
    │     ├── Avatar + tên người đăng
    │     ├── Nội dung + hình ảnh
    │     ├── Hashtags
    │     ├── Nút Like (tim) + số lượt thích
    │     ├── Nút Bình luận + số bình luận
    │     └── Nút Menu (báo cáo / chia sẻ)
    │
    └── Nhấn vào bài viết → Màn hình chi tiết
```

---

## 11. Tạo Bài Viết

```
Màn hình Community
    │
    ├── Nhấn nút "+" (góc dưới phải)
    │
    ▼
Màn hình Tạo bài viết
    │
    ├── Nhập nội dung
    ├── Chọn ảnh từ thư viện / chụp ảnh (tuỳ chọn)
    ├── Thêm hashtag (vd: #suckhoe #thoi quen)
    ├── Nhấn "Đăng"
    │
    ├── [Thành công] → Quay lại Feed (thấy bài viết mới)
    │
    └── [Thất bại] → Xem lỗi
```

---

## 12. Like & Bình Luận

```
Màn hình chi tiết bài viết
    │
    ├── [Like]
    │     ├── Nhấn tim → tim đỏ, số like tăng 1
    │     ├── Nhấn lại → tim trắng, số like giảm 1
    │     │
    │     └── [Bài viết của người khác] → Họ nhận thông báo
    │
    └── [Bình luận]
          ├── Nhập nội dung bình luận
          ├── Nhấn "Gửi"
          ├── Bình luận hiện ra dưới bài viết
          │
          ├── [Trả lời bình luận]
          │     ├── Nhấn vào bình luận → Nhập reply
          │     └── Reply hiện ra dưới bình luận
          │
          └── [Like bình luận]
                └── Nhấn tim bên cạnh bình luận
```

---

## 13. Follow / Xem Profile

```
Màn hình chi tiết bài viết
    │
    ├── Nhấn vào tên / avatar người đăng
    │
    ▼
Màn hình Profile người dùng
    │
    ├── Xem: avatar, tên, tiểu sử, số follow/follower
    ├── Xem: streak, cấp cây, thành tựu
    ├── Xem: danh sách bài viết của họ
    │
    ├── Nhấn "Theo dõi" (nút chuyển xanh)
    └── Nhấn "Đang follow" (nút chuyển xám) → Huỷ follow
```

---

## 14. Chat với AI Coach

```
Màn hình chính (Tab Today)
    │
    ├── Nhấn vào biểu tượng chat (bubble nổi, góc dưới phải)
    │
    ▼
Màn hình Chat AI
    │
    ├── Xem lịch sử chat cũ
    ├── Nhập câu hỏi (vd: "Làm sao để dậy sớm hơn?")
    ├── Nhấn "Gửi"
    │
    ▼
Xem AI trả lời (markdown - có thể có bullet, in đậm...)
    │
    ├── Tiếp tục hỏi / hỏi câu khác
    │
    └── Nhấn nút Back → Quay lại màn hình chính
```

---

## 15. Xem Thống Kê

```
Màn hình Profile / Stats
    │
    ├── Chọn tab: "Tuần này" / "Tháng này" / "Danh mục"
    │
    ├── [Tuần này] → Biểu đồ cột 7 ngày (cột cao = check-in nhiều)
    ├── [Tháng này] → Biểu đồ cột 30 ngày
    ├── [Danh mục] → Biểu đồ tròn (tỉ lệ các danh mục)
    │
    └── Nhấn vào thói quen cụ thể → Xem biểu đồ riêng
          ├── Streak hiện tại
          ├── Tổng số lần check-in
          ├── Tỉ lệ hoàn thành
          └── Biểu đồ đường theo thời gian
```

---

## 16. Xem Thông Báo

```
Mọi màn hình
    │
    ├── Có badge đỏ trên icon chuông (nếu có thông báo mới)
    │
    ├── Nhấn vào icon chuông (góc trên phải)
    │
    ▼
Màn hình Thông báo
    │
    ├── Danh sách thông báo (mới nhất ở trên)
    │     ├─ "A đã thích bài viết của bạn"
    │     ├─ "B đã bình luận: 'Cố gắng nhé!'"
    │     ├─ "C đã theo dõi bạn"
    │     ├─ "Cây của bạn đã lên cấp 5!"
    │     └─ "Bạn đã đạt thành tựu 7 ngày streak!"
    │
    ├── Nhấn vào thông báo → Chuyển đến bài viết / profile
    ├── Nhấn "Đọc tất cả" → Tất cả chuyển màu xám
    └── Vuốt trái → Ẩn thông báo
```

---

## 17. Cài Đặt Thông Báo

```
Màn hình Profile → Cài đặt → Thông báo
    │
    ├── Bật/tắt thông báo buổi sáng (08:00)
    ├── Bật/tắt thông báo buổi tối (21:00)
    ├── Đặt giờ nhắc nhở cá nhân
    └── Bật/tắt thông báo qua email
```

---

## 18. Admin - Dashboard

```
Màn hình Profile → Admin Panel
    │
    ├── Nhấn "Dashboard"
    │
    ▼
Xem tổng quan:
    ├── Tổng số người dùng
    ├── Tổng số bài viết
    ├── Tổng số check-in hôm nay
    ├── Biểu đồ tăng trưởng (số người dùng mới theo ngày)
    └── Biểu đồ habits phổ biến
```

---

## 19. Admin - Quản Lý Người Dùng

```
Admin Panel → Người dùng
    │
    ├── Danh sách user (có ô tìm kiếm)
    ├── Nhấn vào user → Xem chi tiết
    │     ├── Sửa role (user ↔ admin)
    │     └── Xoá user (có xác nhận)
    │
    ├── Nhấn "Thêm user" → Nhập thông tin → Tạo
    └── Chọn nhiều user → "Xoá hàng loạt" → Xác nhận
```

---

## 20. Admin - Kiểm Duyệt Bài Viết

```
Admin Panel → Bài viết
    │
    ├── Lọc: "Tất cả" / "Đã cảnh cáo" / "Chờ duyệt"
    │
    ├── Bài viết có vấn đề → Nhấn "Cảnh cáo"
    │     ├── Bài viết bị ẩn khỏi feed
    │     └── Người đăng nhận email + thông báo
    │
    ├── Người dùng sửa bài sau cảnh cáo
    │     ├── Nhấn "Phê duyệt" → Bài hiện lại
    │     └── Nhấn "Từ chối" → Xoá bài + gửi lý do
    │
    └── Nhấn vào bài viết → Xem chi tiết
```

---

## 21. Admin - Cài Đặt Chung

```
Admin Panel → Cài đặt
    │
    ├── Đổi tên ứng dụng
    ├── Đổi logo ứng dụng
    │
    ├── Cấu hình Auto Reminder
    │     ├── Bật/tắt
    │     ├── Chọn thời gian gửi
    │     └── Quản lý nội dung tin nhắn
    │
    └── AI Assistant (chat với AI để quản trị)
```

---

## 22. Mở Ứng Dụng (Luồng Khởi Động)

```
Người dùng mở app
    │
    ├── [Chưa đăng nhập] → Màn hình Đăng nhập
    │
    └── [Đã đăng nhập trước đó]
          ├── [Token còn hạn]
          │     ├── [Đã onboarding] → Màn hình chính (Tab Today)
          │     └── [Chưa onboard] → Onboarding
          │
          └── [Token hết hạn] → Màn hình Đăng nhập
```

---

## 23. Navigation Tổng Thể

```
Màn hình chính (Bottom Navigation, 4 tab)

┌──────────┬──────────────┬──────────┬──────────┐
│  Today   │  Community   │   Grow   │    Me    │
│ (Tab 0)  │  (Tab 1)     │ (Tab 2)  │ (Tab 3)  │
├──────────┼──────────────┼──────────┼──────────┤
│ Danh     │ Feed bài     │ Cây ảo   │ Profile  │
│ sách     │ viết         │ + Streak │ + Cài    │
│ habits   │              │ + Thành  │ đặt      │
│ hôm nay  │              │ tựu      │          │
└──────────┴──────────────┴──────────┴──────────┘
     │           │              │           │
     │           │              │           └── Admin Panel
     │           │              │               ├ Dashboard
     │           │              │               ├ Users
     │           │              │               ├ Bài viết
     │           │              │               ├ Habits
     │           │              │               ├ Plants
     │           │              │               └ Cài đặt
     │           │              │
     │           │              └── Chi tiết cây
     │           │                  └── Đổi loại cây
     │           │
     │           ├── Tạo bài viết
     │           ├── Chi tiết bài viết
     │           │     ├── Like
     │           │     ├── Bình luận
     │           │     └── Trả lời
     │           └── Profile người dùng
     │                 └── Follow/Unfollow
     │
      ├── Thêm/Sửa/Xoá habit
      ├── Chi tiết habit (biểu đồ)
      └── Chat AI (bubble nổi)
```

---

## 24. Quản Lý Hồ Sơ Cá Nhân

```
Màn hình Profile (Tab Me)
    │
    ├── Xem thông tin cá nhân hiện tại:
    │     ├── Ảnh đại diện + tên hiển thị
    │     ├── Email (chỉ xem, không sửa)
    │     ├── Giới tính, năm sinh
    │     ├── Chiều cao, cân nặng
    │     └── Mục tiêu cá nhân
    │
    ├── [Chỉnh sửa ảnh đại diện]
    │     ├── Nhấn vào ảnh đại diện
    │     ├── Chọn nguồn: "Chụp ảnh" / "Chọn từ thư viện"
    │     ├── Cắt / điều chỉnh ảnh
    │     ├── Hệ thống kiểm tra định dạng & kích thước
    │     │     ├── [Ảnh hợp lệ] → Upload lên server → Cập nhật DB
    │     │     └── [Ảnh không hợp lệ] → Thông báo lỗi: "Ảnh tối đa 5MB, định dạng JPEG/PNG"
    │     └── Xem ảnh đại diện mới
    │
    ├── [Chỉnh sửa tên hiển thị]
    │     ├── Nhấn vào tên
    │     ├── Bottom sheet nhập tên mới
    │     ├── Hệ thống kiểm tra:
    │     │     ├── [Tên trống] → Lỗi "Tên không được để trống"
    │     │     ├── [Tên quá ngắn/dài] → Lỗi "Tên phải từ 2-50 ký tự"
    │     │     └── [Hợp lệ] → Cập nhật DB
    │     └── Xem tên mới trên profile
    │
    ├── [Chỉnh sửa giới tính]
    │     ├── Nhấn vào giới tính
    │     ├── Chọn: Nam / Nữ / Khác
    │     └── Cập nhật DB
    │
    ├── [Chỉnh sửa năm sinh]
    │     ├── Nhấn vào năm sinh
    │     ├── Chọn năm từ bộ chọn ngày tháng
    │     ├── Hệ thống kiểm tra:
    │     │     ├── [< 1930 hoặc > hiện tại - 10] → Lỗi "Năm sinh không hợp lệ"
    │     │     └── [Hợp lệ] → Cập nhật DB
    │     └── Xem năm sinh mới
    │
    ├── [Chỉnh sửa chiều cao, cân nặng]
    │     ├── Nhấn vào mục chiều cao / cân nặng
    │     ├── Bottom sheet nhập:
    │     │     ├── Chiều cao (cm) — kiểm tra 100-250cm
    │     │     └── Cân nặng (kg) — kiểm tra 15-300kg
    │     ├── Hệ thống kiểm tra:
    │     │     ├── [Không hợp lệ] → Lỗi "Giá trị nằm ngoài phạm vi cho phép"
    │     │     └── [Hợp lệ] → Cập nhật DB
    │     └── Xem thông số mới
    │
    ├── [Chỉnh sửa mục tiêu cá nhân]
    │     ├── Nhấn vào mục tiêu
    │     ├── Bottom sheet hiện danh sách mục tiêu:
    │     │     ├── 🥗 Ăn lành mạnh
    │     │     ├── 🏃 Vận động
    │     │     ├── 😴 Giấc ngủ
    │     │     ├── 🧘 Tinh thần
    │     │     ├── ⚖️ Cân nặng
    │     │     ├── 💧 Uống nước
    │     │     └── ✏️ Mục tiêu khác
    │     ├── Tick/bỏ tick các mục tiêu
    │     ├── Hệ thống kiểm tra:
    │     │     └── [Chưa chọn mục tiêu nào] → Lỗi "Vui lòng chọn ít nhất 1 mục tiêu"
    │     └── Cập nhật DB
    │
    └── Nhấn "Lưu" (nếu có thay đổi)
          ├── Hệ thống gửi request PUT /auth/profile
          ├── [Thành công] → Thông báo "Cập nhật thành công"
          │     └── Làm mới thông tin trên màn hình
          └── [Thất bại] → Thông báo "Có lỗi xảy ra, vui lòng thử lại"
```

---

## 25. Xem Danh Sách Thói Quen

```
Người dùng mở ứng dụng (đã đăng nhập)
    │
    ▼
Màn hình chính (Tab Today — Tab 0)
    │
    ├── Gọi API GET /habits/today
    │     ├── [Thành công] → Nhận danh sách habits hôm nay + trạng thái check-in
    │     └── [Thất bại] → Hiển thị thông báo lỗi + nút "Thử lại"
    │
    ├── Hiển thị danh sách thói quen:
    │     ├── Mỗi thói quen gồm:
    │     │     ├── Biểu tượng (emoji) theo danh mục
    │     │     ├── Tên thói quen
    │     │     ├── Mục tiêu hôm nay (vd: "1/1 lần")
    │     │     ├── Giờ nhắc nhở (nếu có)
    │     │     └── Nút check-in (hình tròn)
    │     │           ├── [Chưa check-in] → Nút trống, màu xám
    │     │           └── [Đã check-in] → Nút có tick xanh, disabled
    │     │
    │     ├── [Có habits] → Danh sách cuộn được
    │     │     ├── Nhấn vào habit → Chuyển đến habit_detail_screen
    │     │     └── Nhấn check-in → Thực hiện check-in
    │     │
    │     └── [Không có habits] → Hiển thị trạng thái rỗng:
    │           ├── Hình minh hoạ (cây nhỏ / icon)
    │           ├── "Bạn chưa có thói quen nào"
    │           └── Nút "Thêm thói quen đầu tiên"
    │
    ├── Các thao tác khác trên danh sách:
    │     ├── Kéo xuống (pull-to-refresh) → Gọi lại API GET /habits/today
    │     ├── Nút "+" (góc dưới phải) → Chuyển đến màn hình Thêm thói quen
    │     └── Nút chat AI (bubble nổi) → Chuyển đến AI Chat screen
    │
    └── Xem toàn bộ habits (nếu cần)
          ├── Nhấn "Xem tất cả" / chuyển tab Habits
          ├── Gọi API GET /habits (danh sách đầy đủ)
          ├── Hiển thị tất cả habits (bao gồm cả đã xoá mềm? — chỉ active)
          │     ├── Chia nhóm theo danh mục (Sức khoẻ, Học tập, Công việc...)
          │     └── Mỗi habit hiển thị:
          │           ├── Tên + icon
          │           ├── Tần suất (Hàng ngày / Hàng tuần)
          │           ├── Streak hiện tại của habit
          │           └── Trạng thái (Active / Đã tạm dừng)
          ├── Nhấn vào habit → Chi tiết thói quen
          └── [Lỗi tải] → Retry hoặc thông báo
```

---

## 26. Nhập Mức Độ Hoàn Thành

```
Người dùng ở màn hình Today / Habits
    │
    ├── Thói quen có mục tiêu đo lường được (vd: "Uống 8 ly nước", "Chạy 5km")
    │
    ├── Nhấn vào nút check-in (hình tròn) của thói quen
    │
    ▼
Màn hình / Bottom sheet Nhập mức độ hoàn thành
    │
    ├── Hiển thị thông tin thói quen:
    │     ├── Tên + icon thói quen
    │     ├── Mục tiêu hôm nay (vd: 8 ly / 5 km / 30 phút)
    │     └── Đã hoàn thành (nếu đã nhập một phần trước đó)
    │
    ├── [Lần đầu check-in trong ngày]
    │     ├── Nhập giá trị hoàn thành:
    │     │     ├── [Dạng số] → Nhập số lượng (vd: 5 ly nước)
    │     │     │     └── Kiểm tra: giá trị >= 0
    │     │     ├── [Dạng thời gian] → Nhập số phút (vd: 20 phút)
    │     │     │     └── Kiểm tra: giá trị >= 0
    │     │     └── [Dạng boolean] → Xác nhận hoàn thành (Có/Không)
    │     │
    │     ├── Nhấn "Xác nhận"
    │     │     ├── Hệ thống kiểm tra:
    │     │     │     ├── [Giá trị hợp lệ] → Gọi API POST /habits/:id/checkin
    │     │     │     │     └── Payload: { value: <số lượng>, unit: <đơn vị> }
    │     │     │     └── [Giá trị không hợp lệ] → Lỗi "Vui lòng nhập giá trị hợp lệ"
    │     │     │
    │     │     ├── API xử lý:
    │     │     │     ├── INSERT / UPDATE habit_logs (log_date, value)
    │     │     │     ├── Tính toán tỉ lệ hoàn thành = value / target
    │     │     │     ├── [value >= target] → Đánh dấu hoàn thành 100%
    │     │     │     │     ├── Cập nhật streak
    │     │     │     │     ├── +1 EXP cây
    │     │     │     │     ├── Kiểm tra achievements
    │     │     │     │     └── Response: { completed: true, exp_gained: 1, ... }
    │     │     │     └── [value < target] → Đánh dấu hoàn thành một phần
    │     │     │           └── Response: { completed: false, progress: value/target }
    │     │     │
    │     │     ├── [Thành công] → Quay lại danh sách
    │     │     │     ├── Hiển thị tiến độ mới (vd: "5/8 ly")
    │     │     │     ├── Nếu hoàn thành 100% → Tick xanh + animation EXP
    │     │     │     └── Nếu chưa đạt → Thanh tiến độ cập nhật
    │     │     │
    │     │     └── [Thất bại] → Thông báo lỗi
    │     │
    │     └── [Huỷ] → Đóng bottom sheet, không thay đổi
    │
    ├── [Đã check-in một phần trước đó]
    │     ├── Hiển thị giá trị đã nhập (vd: "3/8 ly")
    │     ├── Nhập bổ sung giá trị:
    │     │     └── Giá trị mới = giá trị cũ + giá trị nhập thêm
    │     ├── Nhấn "Cập nhật"
    │     │     └── Gọi API PUT /habits/:id/checkin
    │     │           ├── [value mới >= target] → Hoàn thành 100% (như trên)
    │     │           └── [value mới < target] → Cập nhật tiến độ
    │     └── [Huỷ] → Giữ nguyên giá trị cũ
    │
    └── [Thói quen đã hoàn thành 100% hôm nay]
          └── Nút check-in disabled (tick xanh) → Không thể nhập thêm
```

---

## 27. Theo Dõi Chuỗi Ngày (Streak)

```
Người dùng vào màn hình Grow (Tab 2)
    │
    ├── Gọi API GET /streaks
    │     └── Response: { current_streak, longest_streak, freeze_tokens, streak_history }
    │
    ├── [Thành công] → Hiển thị thông tin streak:
    │     │
    │     ├── 1. Streak hiện tại
    │     │     ├── Hiển thị số ngày lớn (vd: "🔥 7")
    │     │     ├── Label: "ngày liên tiếp"
    │     │     └── Trạng thái:
    │     │           ├── [Hôm nay đã check-in] → Màu xanh lá, biểu tượng lửa
    │     │           ├── [Hôm nay chưa check-in] → Màu cam cảnh báo
    │     │           └── [Đã lỡ 1 ngày] → Biểu tượng tan vỡ, thông báo "Hãy cố gắng!"
    │     │
    │     ├── 2. Streak dài nhất
    │     │     ├── "🏆 Kỷ lục: X ngày"
    │     │     └── So sánh với streak hiện tại
    │     │
    │     ├── 3. Freeze Token
    │     │     ├── Hiển thị số lượng: "❄️ X token"
    │     │     ├── Mô tả: "Bảo vệ 1 ngày không check-in"
    │     │     ├── [Streak sắp mất & còn token] → Tự động kích hoạt
    │     │     └── [Hết token] → Nút "Xem cách nhận thêm"
    │     │
    │     ├── 4. Biểu đồ lịch sử streak (7 ngày / 30 ngày)
    │     │     ├── Mỗi ô đại diện 1 ngày
    │     │     ├── [Đã check-in] → Ô màu xanh lá
    │     │     ├── [Chưa check-in] → Ô màu xám
    │     │     ├── [Hôm nay] → Ô có viền đậm
    │     │     ├── [Dùng freeze token] → Ô màu xanh dương, icon ❄️
    │     │     └── Nhấn vào ô → Xem chi tiết ngày đó (habits đã hoàn thành)
    │     │
    │     └── 5. Streak theo từng thói quen (nếu có)
    │           ├── Gọi API GET /habits (mỗi habit có streak riêng)
    │           └── Hiển thị streak của từng habit bên dưới
    │
    ├── [Không có streak] → Trạng thái ban đầu:
    │     ├── "🔥 Bắt đầu ngay hôm nay!"
    │     ├── Hướng dẫn: "Hoàn thành thói quen mỗi ngày để xây dựng chuỗi"
    │     └── Nút "Đi đến habits hôm nay" → Chuyển Tab Today
    │
    └── [Thất bại] → Thông báo lỗi + nút "Thử lại"

─────

Cron job hàng ngày (00:00 UTC+7)
    │
    ├── Kiểm tra tất cả users:
    │     ├── [Hôm qua không check-in & hôm qua streak > 0]
    │     │     ├── [Còn freeze token] → Tự động tiêu 1 token, giữ nguyên streak
    │     │     │     └── Ghi nhận: ngày X được bảo vệ bởi freeze token
    │     │     ├── [Hết freeze token] → Reset streak về 0
    │     │     │     └── Gửi thông báo "Streak của bạn đã bị reset"
    │     │     └── Cập nhật longest_streak nếu cần
    │     │
    │     └── [Đã check-in] → Tiếp tục streak, không làm gì

─────

Mỗi 7 ngày streak đạt mốc
    │
    └── Nhận 1 Freeze Token (tối đa 2)
          └── Thông báo "🎉 Bạn đã nhận được 1 Freeze Token!"
```

---

## 28. Xem Thống Kê

```
Người dùng vào màn hình Stats (Tab Me → Thống kê)
    │
    ├── Gọi đồng thời các API:
    │     ├── GET /stats/summary      — Tổng quan
    │     ├── GET /stats/weekly       — 7 ngày gần nhất
    │     ├── GET /stats/monthly      — 30 ngày gần nhất
    │     └── GET /stats/categories   — Theo danh mục
    │
    ├── [Thành công] → Hiển thị giao diện thống kê
    │     │
    │     ├── 1. Tổng quan (Summary)
    │     │     ├── Tổng số check-in hôm nay
    │     │     ├── Tổng số check-in tuần này
    │     │     ├── Tỉ lệ hoàn thành hôm nay (vd: 75%)
    │     │     ├── Streak hiện tại
    │     │     ├── Cấp cây hiện tại
    │     │     └── Số thành tựu đã đạt
    │     │
    │     ├── 2. Biểu đồ tuần (Weekly)
    │     │     ├── Dạng biểu đồ cột, 7 cột (T2 → CN)
    │     │     ├── Trục Y: số check-in hoặc %
    │     │     ├── [Có check-in] → Cột màu xanh lá, cao tương ứng
    │     │     ├── [Không check-in] → Cột màu xám, thấp
    │     │     ├── [Hôm nay] → Cột có viền đậm
    │     │     └── Nhấn vào cột → Xem danh sách habits đã hoàn thành ngày đó
    │     │
    │     ├── 3. Biểu đồ tháng (Monthly)
    │     │     ├── Dạng biểu đồ cột / heatmap, 30 ngày
    │     │     ├── Màu sắc theo mức độ hoàn thành:
    │     │     │     ├── [100%] → Xanh lá đậm
    │     │     │     ├── [50-99%] → Xanh lá nhạt
    │     │     │     ├── [1-49%] → Cam
    │     │     │     └── [0%] → Xám
    │     │     └── Vuốt để xem tháng trước / sau
    │     │
    │     ├── 4. Biểu đồ danh mục (Categories)
    │     │     ├── Dạng biểu đồ tròn / donut
    │     │     ├── Mỗi danh mục có màu riêng:
    │     │     │     ├── 🥗 Sức khoẻ — Xanh lá
    │     │     │     ├── 📚 Học tập — Xanh dương
    │     │     │     ├── 💼 Công việc — Cam
    │     │     │     ├── 🧘 Tinh thần — Tím
    │     │     │     └── ✏️ Khác — Xám
    │     │     ├── Tỉ lệ check-in theo danh mục
    │     │     └── Nhấn vào phần → Lọc habits theo danh mục đó
    │     │
    │     └── 5. Chi tiết từng thói quen (tuỳ chọn)
    │           ├── Chọn 1 habit từ dropdown / danh sách
    │           ├── Gọi API GET /stats/habits/:habitId/metrics
    │           ├── Hiển thị:
    │           │     ├── Streak hiện tại của habit
    │           │     ├── Tổng số lần check-in
    │           │     ├── Tỉ lệ hoàn thành trung bình
    │           │     ├── Biểu đồ đường theo thời gian
    │           │     └── Số ngày bỏ lỡ
    │           └── [Lỗi] → Thông báo
    │
    ├── [Đang tải] → Hiển thị skeleton loading
    │
    ├── [Chưa có dữ liệu] → Trạng thái rỗng:
    │     ├── "Chưa có dữ liệu thống kê"
    │     ├── "Hãy bắt đầu check-in để xem thống kê!"
    │     └── Nút "Đi đến habits hôm nay"
    │
    └── [Thất bại] → Thông báo lỗi + nút "Thử lại"

─────

Tương tác bổ sung:
    │
    ├── Chuyển đổi giữa các tab: Tuần / Tháng / Danh mục
    ├── Nhấn biểu tượng tải xuống → Xuất báo cáo (ảnh / PDF)
    └── Kéo xuống (pull-to-refresh) → Làm mới tất cả biểu đồ
```

---

## 29. Trồng Cây Ảo

```
Màn hình Grow (Tab 2) / Onboarding (Bước 6)
    │
    ├── [Lần đầu — Onboarding Bước 6]
    │     ├── Hiển thị 4 loại cây để chọn:
    │     │     ├── 🎋 Tre (Bamboo) — Mặc định
    │     │     ├── 🌵 Xương rồng (Cactus)
    │     │     ├── 🌸 Hoa anh đào (Sakura)
    │     │     └── 🌻 Hoa hướng dương (Sunflower)
    │     ├── Mỗi loại hiển thị:
    │     │     ├── Hình minh hoạ cây (theo level)
    │     │     ├── Tên loại cây
    │     │     └── Mô tả ngắn
    │     ├── Nhấn chọn 1 loại
    │     └── Nhấn "Bắt đầu"
    │           ├── Gọi API PUT /habits/plant/type { plant_type: "bamboo" }
    │           ├── Tạo bản ghi plants (level = 1, exp = 0)
    │           └── Chuyển đến màn hình chính (Tab Today)
    │
    └── [Đã có cây — Tab Grow]
          │
          ├── Gọi API GET /habits/plant
          │     └── Response: { type, level, exp, exp_to_next, wilting_days, ... }
          │
          ├── [Thành công] → Hiển thị cây ảo
          │     │
          │     ├── 1. Hình ảnh cây
          │     │     ├── Hiển thị cây theo level (1 → 15)
          │     │     │     ├── [Level 1-3] → Cây con, nhỏ
          │     │     │     ├── [Level 4-7] → Cây trung bình, có lá
          │     │     │     ├── [Level 8-11] → Cây lớn, nhiều lá
          │     │     │     └── [Level 12-15] → Cây trưởng thành, hoa/quả
          │     │     ├── Animation: đung đưa / lá rơi / phát sáng
          │     │     └── [Wilting > 0] → Cây héo dần (màu vàng, rũ lá)
          │     │
          │     ├── 2. Thông tin cấp độ
          │     │     ├── "Level X / 15"
          │     │     ├── Thanh EXP: [████████░░] 80/100
          │     │     └── "Cần X EXP để lên cấp tiếp theo"
          │     │
          │     ├── 3. Trạng thái cây
          │     │     ├── [Wilting = 0] → "🌱 Khoẻ mạnh"
          │     │     ├── [Wilting = 1] → "⚠️ Hơi héo — Chưa check-in 3 ngày"
          │     │     ├── [Wilting = 2] → "⚠️ Đang héo — Mất 3 EXP/ngày"
          │     │     └── [Wilting ≥ 3] → "🚨 Cây sắp chết!"
          │     │
          │     └── 4. Hành động
          │           ├── Nhấn vào cây → Màn hình Plant Detail
          │           │     ├── Đổi loại cây (giữ nguyên level & EXP)
          │           │     ├── Xem lịch sử cây (biểu đồ level theo thời gian)
          │           │     └── Xem danh sách cây đã từng trồng (nếu có)
          │           └── Vuốt xuống (pull-to-refresh) → Làm mới
          │
          ├── [Chưa có cây] → Chuyển đến màn hình chọn cây lần đầu
          │
          └── [Thất bại] → Thông báo lỗi + nút "Thử lại"

─────

Hệ thống EXP & Level:
    │
    ├── Mỗi lần check-in hoàn thành 100% → +1 EXP
    ├── Mốc EXP để lên level:
    │     [0, 5, 15, 30, 50, 75, 105, 140, 180, 225, 275, 330, 390, 455, 525]
    │
    ├── [EXP >= threshold level hiện tại] → Level Up!
    │     ├── Cập nhật level cây
    │     ├── Animation level up (cây lớn lên, phát sáng)
    │     ├── Thông báo "🌳 Cây đã lên cấp X!"
    │     └── Kiểm tra achievement plant_level_3 / plant_level_15
    │
    └── [Không check-in 3+ ngày liên tiếp] → Wilting
          ├── Mỗi ngày mất 3 EXP (tối thiểu 0)
          ├── [EXP = 0] → Không thể giảm thêm, cây ở trạng thái héo
          └── [Check-in trở lại] → Hết wilting, cây hồi phục
```
