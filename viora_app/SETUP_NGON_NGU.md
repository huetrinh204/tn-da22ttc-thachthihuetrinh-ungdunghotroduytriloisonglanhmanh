# Hướng dẫn Setup Đa Ngôn Ngữ

## ⚠️ QUAN TRỌNG - Chạy các lệnh sau:

### Cách 1: Chạy file batch (Windows)
```bash
setup_localization.bat
```

### Cách 2: Chạy từng lệnh
```bash
cd viora_app

# Bước 1: Cài đặt packages
flutter pub get

# Bước 2: Generate localization files
flutter gen-l10n

# Bước 3: Clean và rebuild
flutter clean
flutter pub get
```

## ✅ Sau khi chạy xong:

File `app_localizations.dart` sẽ được tạo tự động trong:
```
.dart_tool/flutter_gen/gen_l10n/app_localizations.dart
```

## 🚀 Chạy app:

```bash
flutter run
```

## ❌ Nếu vẫn còn lỗi:

1. Restart VS Code / Android Studio
2. Chạy lại: `flutter pub get`
3. Chạy lại: `flutter gen-l10n`

## 📝 Các file đã tạo:

- ✅ `pubspec.yaml` - Đã thêm dependencies
- ✅ `l10n.yaml` - Configuration
- ✅ `lib/l10n/app_vi.arb` - Tiếng Việt
- ✅ `lib/l10n/app_en.arb` - Tiếng Anh
- ✅ `lib/providers/locale_provider.dart` - Quản lý ngôn ngữ
- ✅ `lib/main.dart` - Đã cập nhật

## 🎯 Bước tiếp theo:

Sau khi setup xong, tôi sẽ giúp bạn:
1. Thêm UI chuyển đổi ngôn ngữ trong Profile
2. Cập nhật các màn hình để sử dụng translation
