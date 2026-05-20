# Hướng dẫn setup Localization

## Bước 1: Cài đặt dependencies

Chạy lệnh sau trong thư mục `viora_app`:

```bash
flutter pub get
```

## Bước 2: Generate localization files

```bash
flutter gen-l10n
```

Lệnh này sẽ tạo file `app_localizations.dart` trong thư mục `.dart_tool/flutter_gen/gen_l10n/`

## Bước 3: Restart app

```bash
flutter run
```

## Cách sử dụng trong code

### Import

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
```

### Sử dụng

```dart
// Trong build method
final l10n = AppLocalizations.of(context)!;

Text(l10n.home)  // "Trang chủ" hoặc "Home"
Text(l10n.goodMorning)  // "Chào buổi sáng" hoặc "Good morning"
Text(l10n.daysStreak(5))  // "5 ngày liên tiếp" hoặc "5 day streak"
```

## Thay đổi ngôn ngữ

Trong Profile screen, thêm dropdown hoặc button để chuyển đổi:

```dart
import '../providers/locale_provider.dart';

// Trong widget
final localeProvider = context.findAncestorStateOfType<_MyAppState>()!.localeProvider;

// Chuyển sang tiếng Anh
localeProvider.setLocale(const Locale('en'));

// Chuyển sang tiếng Việt
localeProvider.setLocale(const Locale('vi'));
```

## Thêm translation mới

1. Mở file `lib/l10n/app_vi.arb`
2. Thêm key-value mới:
```json
"newKey": "Giá trị tiếng Việt"
```

3. Mở file `lib/l10n/app_en.arb`
4. Thêm key-value tương ứng:
```json
"newKey": "English value"
```

5. Chạy lại `flutter gen-l10n`
6. Sử dụng: `l10n.newKey`
