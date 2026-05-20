# Cập nhật Translation

## Bước 1: Generate lại localization files

```bash
cd viora_app
flutter gen-l10n
```

## Bước 2: Restart app HOÀN TOÀN

**QUAN TRỌNG**: Phải restart app hoàn toàn, không phải hot reload/hot restart!

```bash
# Stop app hiện tại
# Sau đó chạy lại:
flutter run
```

## Bước 3: Test

1. Vào Profile → Giao diện → Ngôn ngữ
2. Chọn English
3. Restart app
4. Kiểm tra xem text đã chuyển sang tiếng Anh chưa

## Lưu ý:

- Hiện tại chỉ có Profile screen được translate
- Các màn hình khác vẫn hardcode tiếng Việt
- Cần cập nhật từng màn hình để sử dụng `AppLocalizations`

## Nếu vẫn không đổi:

1. Xóa app khỏi thiết bị
2. Chạy `flutter clean`
3. Chạy `flutter pub get`
4. Chạy `flutter gen-l10n`
5. Cài đặt lại app: `flutter run`
