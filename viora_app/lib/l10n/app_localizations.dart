import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appName.
  ///
  /// In vi, this message translates to:
  /// **'Viora'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get home;

  /// No description provided for @habits.
  ///
  /// In vi, this message translates to:
  /// **'Thói quen'**
  String get habits;

  /// No description provided for @plant.
  ///
  /// In vi, this message translates to:
  /// **'Cây'**
  String get plant;

  /// No description provided for @stats.
  ///
  /// In vi, this message translates to:
  /// **'Thống kê'**
  String get stats;

  /// No description provided for @profile.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ'**
  String get profile;

  /// No description provided for @goodMorning.
  ///
  /// In vi, this message translates to:
  /// **'Chào buổi sáng'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In vi, this message translates to:
  /// **'Chào buổi chiều'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In vi, this message translates to:
  /// **'Chào buổi tối'**
  String get goodEvening;

  /// No description provided for @daysStreak.
  ///
  /// In vi, this message translates to:
  /// **'{count} ngày liên tiếp'**
  String daysStreak(int count);

  /// No description provided for @keepItUp.
  ///
  /// In vi, this message translates to:
  /// **'Giữ vững phong độ nhé! 💪'**
  String get keepItUp;

  /// No description provided for @best.
  ///
  /// In vi, this message translates to:
  /// **'Best'**
  String get best;

  /// No description provided for @yourPlant.
  ///
  /// In vi, this message translates to:
  /// **'Cây của bạn'**
  String get yourPlant;

  /// No description provided for @plantWilted.
  ///
  /// In vi, this message translates to:
  /// **'Hãy check-in để cây hồi phục! 💧'**
  String get plantWilted;

  /// No description provided for @plantNotWatered.
  ///
  /// In vi, this message translates to:
  /// **'Cây chưa được tưới 3 ngày rồi...'**
  String get plantNotWatered;

  /// No description provided for @completeHabitsToGrow.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành thói quen để cây lớn lên!'**
  String get completeHabitsToGrow;

  /// No description provided for @today.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get today;

  /// No description provided for @completed.
  ///
  /// In vi, this message translates to:
  /// **'{done}/{total}'**
  String completed(int done, int total);

  /// No description provided for @noHabitsYet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có thói quen nào. Thêm ngay nhé! ✨'**
  String get noHabitsYet;

  /// No description provided for @allDoneToday.
  ///
  /// In vi, this message translates to:
  /// **'Tuyệt vời! Bạn đã hoàn thành tất cả hôm nay 🎉'**
  String get allDoneToday;

  /// No description provided for @habitsRemaining.
  ///
  /// In vi, this message translates to:
  /// **'Còn {count} thói quen chưa hoàn thành'**
  String habitsRemaining(int count);

  /// No description provided for @quote1.
  ///
  /// In vi, this message translates to:
  /// **'Mỗi ngày một bước nhỏ, tạo nên thay đổi lớn. 💪'**
  String get quote1;

  /// No description provided for @quote2.
  ///
  /// In vi, this message translates to:
  /// **'Thói quen tốt là nền tảng của cuộc sống lành mạnh. 🌿'**
  String get quote2;

  /// No description provided for @quote3.
  ///
  /// In vi, this message translates to:
  /// **'Kiên trì là chìa khóa của thành công. 🗝️'**
  String get quote3;

  /// No description provided for @quote4.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay tốt hơn hôm qua là đủ rồi. ✨'**
  String get quote4;

  /// No description provided for @quote5.
  ///
  /// In vi, this message translates to:
  /// **'Sức khỏe là tài sản quý giá nhất. 🏃'**
  String get quote5;

  /// No description provided for @myPlant.
  ///
  /// In vi, this message translates to:
  /// **'Cây của tôi'**
  String get myPlant;

  /// No description provided for @level.
  ///
  /// In vi, this message translates to:
  /// **'Cấp {level}'**
  String level(int level);

  /// No description provided for @levelRange.
  ///
  /// In vi, this message translates to:
  /// **'Cấp {current} → {next}'**
  String levelRange(int current, int next);

  /// No description provided for @points.
  ///
  /// In vi, this message translates to:
  /// **'{count} điểm'**
  String points(int count);

  /// No description provided for @totalPoints.
  ///
  /// In vi, this message translates to:
  /// **'Tổng điểm'**
  String get totalPoints;

  /// No description provided for @levelProgress.
  ///
  /// In vi, this message translates to:
  /// **'Cấp độ'**
  String get levelProgress;

  /// No description provided for @maxLevel.
  ///
  /// In vi, this message translates to:
  /// **'🏆 Cây đã đạt cấp độ tối đa!'**
  String get maxLevel;

  /// No description provided for @developmentProgress.
  ///
  /// In vi, this message translates to:
  /// **'Tiến trình phát triển'**
  String get developmentProgress;

  /// No description provided for @developmentRoadmap.
  ///
  /// In vi, this message translates to:
  /// **'Lộ trình phát triển'**
  String get developmentRoadmap;

  /// No description provided for @howToEarnPoints.
  ///
  /// In vi, this message translates to:
  /// **'Cách kiếm điểm'**
  String get howToEarnPoints;

  /// No description provided for @earnTip1.
  ///
  /// In vi, this message translates to:
  /// **'✅ Hoàn thành ≥ 1 habit trong ngày'**
  String get earnTip1;

  /// No description provided for @earnReward1.
  ///
  /// In vi, this message translates to:
  /// **'+1 điểm'**
  String get earnReward1;

  /// No description provided for @earnTip2.
  ///
  /// In vi, this message translates to:
  /// **'✅ Hoàn thành ≥ 50% habits trong ngày'**
  String get earnTip2;

  /// No description provided for @earnReward2.
  ///
  /// In vi, this message translates to:
  /// **'+2 điểm'**
  String get earnReward2;

  /// No description provided for @earnTip3.
  ///
  /// In vi, this message translates to:
  /// **'🏆 Hoàn thành 100% habits trong ngày'**
  String get earnTip3;

  /// No description provided for @earnReward3.
  ///
  /// In vi, this message translates to:
  /// **'+3 điểm'**
  String get earnReward3;

  /// No description provided for @earnTip4.
  ///
  /// In vi, this message translates to:
  /// **'⚠️ Không check-in 3 ngày liên tiếp'**
  String get earnTip4;

  /// No description provided for @earnReward4.
  ///
  /// In vi, this message translates to:
  /// **'Cây héo'**
  String get earnReward4;

  /// No description provided for @congratulations.
  ///
  /// In vi, this message translates to:
  /// **'🎉 CHÚC MỪNG! 🎉'**
  String get congratulations;

  /// No description provided for @plantLeveledUp.
  ///
  /// In vi, this message translates to:
  /// **'Cây của bạn đã lên cấp!'**
  String get plantLeveledUp;

  /// No description provided for @keepGrowing.
  ///
  /// In vi, this message translates to:
  /// **'✨ Tiếp tục phát triển nhé! ✨'**
  String get keepGrowing;

  /// No description provided for @treasureUnlocked.
  ///
  /// In vi, this message translates to:
  /// **'🏆 Nước thần'**
  String get treasureUnlocked;

  /// No description provided for @treasureLocked.
  ///
  /// In vi, this message translates to:
  /// **'🔒 Khóa'**
  String get treasureLocked;

  /// No description provided for @plantLevel1.
  ///
  /// In vi, this message translates to:
  /// **'Hạt giống'**
  String get plantLevel1;

  /// No description provided for @plantLevel2.
  ///
  /// In vi, this message translates to:
  /// **'Hạt nảy mầm'**
  String get plantLevel2;

  /// No description provided for @plantLevel3.
  ///
  /// In vi, this message translates to:
  /// **'Mầm non'**
  String get plantLevel3;

  /// No description provided for @plantLevel4.
  ///
  /// In vi, this message translates to:
  /// **'Cây non'**
  String get plantLevel4;

  /// No description provided for @plantLevel5.
  ///
  /// In vi, this message translates to:
  /// **'Cây con'**
  String get plantLevel5;

  /// No description provided for @plantLevel6.
  ///
  /// In vi, this message translates to:
  /// **'Cây nhỏ'**
  String get plantLevel6;

  /// No description provided for @plantLevel7.
  ///
  /// In vi, this message translates to:
  /// **'Cây đang lớn'**
  String get plantLevel7;

  /// No description provided for @plantLevel8.
  ///
  /// In vi, this message translates to:
  /// **'Cây trưởng thành'**
  String get plantLevel8;

  /// No description provided for @plantLevel9.
  ///
  /// In vi, this message translates to:
  /// **'Cây phát triển tốt'**
  String get plantLevel9;

  /// No description provided for @plantLevel10.
  ///
  /// In vi, this message translates to:
  /// **'Cây ra hoa'**
  String get plantLevel10;

  /// No description provided for @plantLevel11.
  ///
  /// In vi, this message translates to:
  /// **'Cây kết trái non'**
  String get plantLevel11;

  /// No description provided for @plantLevel12.
  ///
  /// In vi, this message translates to:
  /// **'Cây trái lớn dần'**
  String get plantLevel12;

  /// No description provided for @plantLevel13.
  ///
  /// In vi, this message translates to:
  /// **'Cây kết trái chín'**
  String get plantLevel13;

  /// No description provided for @plantLevel14.
  ///
  /// In vi, this message translates to:
  /// **'Cây sai quả'**
  String get plantLevel14;

  /// No description provided for @plantLevel15.
  ///
  /// In vi, this message translates to:
  /// **'Cây trưởng thành hoàn hảo'**
  String get plantLevel15;

  /// No description provided for @plantWiltedWarning.
  ///
  /// In vi, this message translates to:
  /// **'Cây đang héo! Hãy check-in ngay 💧'**
  String get plantWiltedWarning;

  /// No description provided for @plantWiltingStatus.
  ///
  /// In vi, this message translates to:
  /// **'Cây đang héo...'**
  String get plantWiltingStatus;

  /// No description provided for @monday.
  ///
  /// In vi, this message translates to:
  /// **'Thứ 2'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In vi, this message translates to:
  /// **'Thứ 3'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In vi, this message translates to:
  /// **'Thứ 4'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In vi, this message translates to:
  /// **'Thứ 5'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In vi, this message translates to:
  /// **'Thứ 6'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In vi, this message translates to:
  /// **'Thứ 7'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In vi, this message translates to:
  /// **'Chủ nhật'**
  String get sunday;

  /// No description provided for @achievementsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thành tích'**
  String get achievementsTitle;

  /// No description provided for @achievementsCount.
  ///
  /// In vi, this message translates to:
  /// **'{unlocked} / {total} thành tích'**
  String achievementsCount(int unlocked, int total);

  /// No description provided for @allAchievementsUnlocked.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã mở khóa tất cả! 🎉'**
  String get allAchievementsUnlocked;

  /// No description provided for @achievementsRemaining.
  ///
  /// In vi, this message translates to:
  /// **'Còn {count} thành tích chưa mở'**
  String achievementsRemaining(int count);

  /// No description provided for @achievementFirstStep.
  ///
  /// In vi, this message translates to:
  /// **'Bước đầu tiên'**
  String get achievementFirstStep;

  /// No description provided for @achievementFirstStepDesc.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành check-in đầu tiên'**
  String get achievementFirstStepDesc;

  /// No description provided for @achievementStreak3.
  ///
  /// In vi, this message translates to:
  /// **'3 ngày liên tiếp'**
  String get achievementStreak3;

  /// No description provided for @achievementStreak3Desc.
  ///
  /// In vi, this message translates to:
  /// **'Duy trì streak 3 ngày liên tiếp'**
  String get achievementStreak3Desc;

  /// No description provided for @achievementStreak7.
  ///
  /// In vi, this message translates to:
  /// **'Tuần kiên trì'**
  String get achievementStreak7;

  /// No description provided for @achievementStreak7Desc.
  ///
  /// In vi, this message translates to:
  /// **'Duy trì streak 7 ngày liên tiếp'**
  String get achievementStreak7Desc;

  /// No description provided for @achievementStreak30.
  ///
  /// In vi, this message translates to:
  /// **'Tháng bền bỉ'**
  String get achievementStreak30;

  /// No description provided for @achievementStreak30Desc.
  ///
  /// In vi, this message translates to:
  /// **'Duy trì streak 30 ngày liên tiếp'**
  String get achievementStreak30Desc;

  /// No description provided for @achievementHabits5.
  ///
  /// In vi, this message translates to:
  /// **'Đa nhiệm'**
  String get achievementHabits5;

  /// No description provided for @achievementHabits5Desc.
  ///
  /// In vi, this message translates to:
  /// **'Tạo 5 thói quen'**
  String get achievementHabits5Desc;

  /// No description provided for @achievementCheckin50.
  ///
  /// In vi, this message translates to:
  /// **'Nửa trăm'**
  String get achievementCheckin50;

  /// No description provided for @achievementCheckin50Desc.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành 50 check-ins'**
  String get achievementCheckin50Desc;

  /// No description provided for @achievementCheckin100.
  ///
  /// In vi, this message translates to:
  /// **'Bách chiến'**
  String get achievementCheckin100;

  /// No description provided for @achievementCheckin100Desc.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành 100 check-ins'**
  String get achievementCheckin100Desc;

  /// No description provided for @achievementPlantLevel3.
  ///
  /// In vi, this message translates to:
  /// **'Cây non'**
  String get achievementPlantLevel3;

  /// No description provided for @achievementPlantLevel3Desc.
  ///
  /// In vi, this message translates to:
  /// **'Cây ảo đạt cấp độ 3'**
  String get achievementPlantLevel3Desc;

  /// No description provided for @achievementPlantLevel5.
  ///
  /// In vi, this message translates to:
  /// **'Vườn địa đàng'**
  String get achievementPlantLevel5;

  /// No description provided for @achievementPlantLevel5Desc.
  ///
  /// In vi, this message translates to:
  /// **'Cây ảo đạt cấp độ tối đa'**
  String get achievementPlantLevel5Desc;

  /// No description provided for @notificationSettingsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo nhắc nhở'**
  String get notificationSettingsTitle;

  /// No description provided for @notificationInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo sẽ nhắc bạn check-in thói quen mỗi ngày để cây phát triển.'**
  String get notificationInfo;

  /// No description provided for @morningReminder.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc buổi sáng'**
  String get morningReminder;

  /// No description provided for @morningReminderDesc.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu ngày mới với thói quen lành mạnh'**
  String get morningReminderDesc;

  /// No description provided for @eveningReminder.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc buổi tối'**
  String get eveningReminder;

  /// No description provided for @eveningReminderDesc.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành thói quen trước khi ngủ'**
  String get eveningReminderDesc;

  /// No description provided for @reminderTime.
  ///
  /// In vi, this message translates to:
  /// **'Giờ nhắc'**
  String get reminderTime;

  /// No description provided for @settings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get language;

  /// No description provided for @vietnamese.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnamese;

  /// No description provided for @english.
  ///
  /// In vi, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @darkMode.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ tối'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ sáng'**
  String get lightMode;

  /// No description provided for @usingDarkMode.
  ///
  /// In vi, this message translates to:
  /// **'Đang dùng chế độ tối'**
  String get usingDarkMode;

  /// No description provided for @usingLightMode.
  ///
  /// In vi, this message translates to:
  /// **'Đang dùng chế độ sáng'**
  String get usingLightMode;

  /// No description provided for @notifications.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo'**
  String get notifications;

  /// No description provided for @savedSettings.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu và áp dụng cài đặt'**
  String get savedSettings;

  /// No description provided for @logout.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get logout;

  /// No description provided for @personalInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin cá nhân'**
  String get personalInfo;

  /// No description provided for @fullName.
  ///
  /// In vi, this message translates to:
  /// **'Họ và tên'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @gender.
  ///
  /// In vi, this message translates to:
  /// **'Giới tính'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In vi, this message translates to:
  /// **'Nam'**
  String get male;

  /// No description provided for @female.
  ///
  /// In vi, this message translates to:
  /// **'Nữ'**
  String get female;

  /// No description provided for @other.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get other;

  /// No description provided for @notUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Chưa cập nhật'**
  String get notUpdated;

  /// No description provided for @birthYear.
  ///
  /// In vi, this message translates to:
  /// **'Năm sinh'**
  String get birthYear;

  /// No description provided for @bodyStats.
  ///
  /// In vi, this message translates to:
  /// **'Thông số cơ thể'**
  String get bodyStats;

  /// No description provided for @height.
  ///
  /// In vi, this message translates to:
  /// **'Chiều cao'**
  String get height;

  /// No description provided for @weight.
  ///
  /// In vi, this message translates to:
  /// **'Cân nặng'**
  String get weight;

  /// No description provided for @bmi.
  ///
  /// In vi, this message translates to:
  /// **'BMI'**
  String get bmi;

  /// No description provided for @underweight.
  ///
  /// In vi, this message translates to:
  /// **'Thiếu cân'**
  String get underweight;

  /// No description provided for @normal.
  ///
  /// In vi, this message translates to:
  /// **'Bình thường'**
  String get normal;

  /// No description provided for @overweight.
  ///
  /// In vi, this message translates to:
  /// **'Thừa cân'**
  String get overweight;

  /// No description provided for @obese.
  ///
  /// In vi, this message translates to:
  /// **'Béo phì'**
  String get obese;

  /// No description provided for @personalGoals.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu cá nhân'**
  String get personalGoals;

  /// No description provided for @goals.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu'**
  String get goals;

  /// No description provided for @noGoalsSelected.
  ///
  /// In vi, this message translates to:
  /// **'Chưa chọn mục tiêu'**
  String get noGoalsSelected;

  /// No description provided for @security.
  ///
  /// In vi, this message translates to:
  /// **'Bảo mật'**
  String get security;

  /// No description provided for @changePassword.
  ///
  /// In vi, this message translates to:
  /// **'Đổi mật khẩu'**
  String get changePassword;

  /// No description provided for @updatePassword.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật mật khẩu'**
  String get updatePassword;

  /// No description provided for @currentPassword.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu hiện tại'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu mới'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận mật khẩu mới'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In vi, this message translates to:
  /// **'Quên mật khẩu hiện tại? Đặt lại qua email →'**
  String get forgotPassword;

  /// No description provided for @passwordMismatch.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu xác nhận không khớp'**
  String get passwordMismatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu tối thiểu 8 ký tự'**
  String get passwordTooShort;

  /// No description provided for @passwordUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Đổi mật khẩu thành công'**
  String get passwordUpdated;

  /// No description provided for @failed.
  ///
  /// In vi, this message translates to:
  /// **'Thất bại'**
  String get failed;

  /// No description provided for @achievements.
  ///
  /// In vi, this message translates to:
  /// **'Thành tích'**
  String get achievements;

  /// No description provided for @myAchievements.
  ///
  /// In vi, this message translates to:
  /// **'Thành tích của tôi'**
  String get myAchievements;

  /// No description provided for @viewUnlockedAchievements.
  ///
  /// In vi, this message translates to:
  /// **'Xem các thành tích đã mở khóa'**
  String get viewUnlockedAchievements;

  /// No description provided for @habitReminders.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc nhở thói quen'**
  String get habitReminders;

  /// No description provided for @setDailyReminders.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt giờ nhắc hàng ngày'**
  String get setDailyReminders;

  /// No description provided for @appearance.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get appearance;

  /// No description provided for @selectLanguage.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngôn ngữ'**
  String get selectLanguage;

  /// No description provided for @languageChanged.
  ///
  /// In vi, this message translates to:
  /// **'Đã chuyển sang Tiếng Việt. Khởi động lại app để áp dụng.'**
  String get languageChanged;

  /// No description provided for @languageChangedEn.
  ///
  /// In vi, this message translates to:
  /// **'Switched to English. Restart app to apply.'**
  String get languageChangedEn;

  /// No description provided for @editName.
  ///
  /// In vi, this message translates to:
  /// **'Đổi tên'**
  String get editName;

  /// No description provided for @save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get save;

  /// No description provided for @nameUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Đã cập nhật tên'**
  String get nameUpdated;

  /// No description provided for @bodyStatsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thông số cơ thể'**
  String get bodyStatsTitle;

  /// No description provided for @heightRange.
  ///
  /// In vi, this message translates to:
  /// **'Chiều cao từ 100–250 cm'**
  String get heightRange;

  /// No description provided for @weightRange.
  ///
  /// In vi, this message translates to:
  /// **'Cân nặng từ 15–300 kg'**
  String get weightRange;

  /// No description provided for @statsUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Đã cập nhật thông số'**
  String get statsUpdated;

  /// No description provided for @goalsUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Đã cập nhật mục tiêu'**
  String get goalsUpdated;

  /// No description provided for @login.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get login;

  /// No description provided for @register.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký'**
  String get register;

  /// No description provided for @loginTitle.
  ///
  /// In vi, this message translates to:
  /// **'ĐĂNG NHẬP'**
  String get loginTitle;

  /// No description provided for @registerTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tạo tài khoản'**
  String get registerTitle;

  /// No description provided for @password.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get password;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận mật khẩu'**
  String get confirmPasswordLabel;

  /// No description provided for @enterEmail.
  ///
  /// In vi, this message translates to:
  /// **'Nhập email của bạn'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mật khẩu của bạn'**
  String get enterPassword;

  /// No description provided for @enterFullName.
  ///
  /// In vi, this message translates to:
  /// **'Nhập họ và tên'**
  String get enterFullName;

  /// No description provided for @enterPasswordAgain.
  ///
  /// In vi, this message translates to:
  /// **'Nhập lại mật khẩu'**
  String get enterPasswordAgain;

  /// No description provided for @minEightChars.
  ///
  /// In vi, this message translates to:
  /// **'Tối thiểu 8 ký tự'**
  String get minEightChars;

  /// No description provided for @forgotPasswordQuestion.
  ///
  /// In vi, this message translates to:
  /// **'Quên mật khẩu?'**
  String get forgotPasswordQuestion;

  /// No description provided for @or.
  ///
  /// In vi, this message translates to:
  /// **'hoặc'**
  String get or;

  /// No description provided for @loginWithGoogle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập bằng Google'**
  String get loginWithGoogle;

  /// No description provided for @noAccount.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tài khoản? '**
  String get noAccount;

  /// No description provided for @registerNow.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký ngay'**
  String get registerNow;

  /// No description provided for @haveAccount.
  ///
  /// In vi, this message translates to:
  /// **'Đã có tài khoản? '**
  String get haveAccount;

  /// No description provided for @loginNow.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get loginNow;

  /// No description provided for @quote.
  ///
  /// In vi, this message translates to:
  /// **'\"Sự thay đổi không đến từ điều lớn lao,\\nmà từ những thói quen nhỏ được lặp lại mỗi ngày.\"'**
  String get quote;

  /// No description provided for @pleaseEnterAllInfo.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập đầy đủ thông tin'**
  String get pleaseEnterAllInfo;

  /// No description provided for @loginFailed.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập thất bại'**
  String get loginFailed;

  /// No description provided for @loginFailedRetry.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập thất bại, thử lại'**
  String get loginFailedRetry;

  /// No description provided for @googleLoginFailed.
  ///
  /// In vi, this message translates to:
  /// **'Google login thất bại'**
  String get googleLoginFailed;

  /// No description provided for @googleLoginError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi Google login: {error}'**
  String googleLoginError(String error);

  /// No description provided for @registerFailed.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký thất bại'**
  String get registerFailed;

  /// No description provided for @pleaseEnterName.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập tên'**
  String get pleaseEnterName;

  /// No description provided for @nameTooShort.
  ///
  /// In vi, this message translates to:
  /// **'Tên phải có ít nhất 2 ký tự'**
  String get nameTooShort;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập email'**
  String get pleaseEnterEmail;

  /// No description provided for @invalidEmailFormat.
  ///
  /// In vi, this message translates to:
  /// **'Email không đúng định dạng'**
  String get invalidEmailFormat;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập mật khẩu'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordMinEightChars.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu tối thiểu 8 ký tự'**
  String get passwordMinEightChars;

  /// No description provided for @passwordNeedsUppercase.
  ///
  /// In vi, this message translates to:
  /// **'Phải có ít nhất 1 chữ hoa'**
  String get passwordNeedsUppercase;

  /// No description provided for @passwordNeedsNumber.
  ///
  /// In vi, this message translates to:
  /// **'Phải có ít nhất 1 chữ số'**
  String get passwordNeedsNumber;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng xác nhận mật khẩu'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu không khớp'**
  String get passwordsDoNotMatch;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quên mật khẩu'**
  String get forgotPasswordTitle;

  /// No description provided for @enterYourEmail.
  ///
  /// In vi, this message translates to:
  /// **'Nhập email của bạn'**
  String get enterYourEmail;

  /// No description provided for @weWillSendOtp.
  ///
  /// In vi, this message translates to:
  /// **'Chúng tôi sẽ gửi mã OTP 6 chữ số đến email của bạn'**
  String get weWillSendOtp;

  /// No description provided for @sendOtp.
  ///
  /// In vi, this message translates to:
  /// **'Gửi mã OTP'**
  String get sendOtp;

  /// No description provided for @resetPassword.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại mật khẩu'**
  String get resetPassword;

  /// No description provided for @enterOtpSentTo.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mã OTP đã gửi đến {email}'**
  String enterOtpSentTo(String email);

  /// No description provided for @newPasswordMinEight.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu mới (tối thiểu 8 ký tự)'**
  String get newPasswordMinEight;

  /// No description provided for @confirmNewPassword.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận mật khẩu mới'**
  String get confirmNewPassword;

  /// No description provided for @resendOtp.
  ///
  /// In vi, this message translates to:
  /// **'Gửi lại mã OTP'**
  String get resendOtp;

  /// No description provided for @otpSent.
  ///
  /// In vi, this message translates to:
  /// **'Mã OTP đã được gửi đến email của bạn'**
  String get otpSent;

  /// No description provided for @otpMustBeSixDigits.
  ///
  /// In vi, this message translates to:
  /// **'Mã OTP gồm 6 chữ số'**
  String get otpMustBeSixDigits;

  /// No description provided for @confirmPasswordMismatch.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu xác nhận không khớp'**
  String get confirmPasswordMismatch;

  /// No description provided for @resetPasswordSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại mật khẩu thành công!'**
  String get resetPasswordSuccess;

  /// No description provided for @stepEmail.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get stepEmail;

  /// No description provided for @stepConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get stepConfirm;

  /// No description provided for @habitsToday.
  ///
  /// In vi, this message translates to:
  /// **'Thói quen hôm nay'**
  String get habitsToday;

  /// No description provided for @confirmCompletion.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận hoàn thành'**
  String get confirmCompletion;

  /// No description provided for @confirmHabitMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn đã hoàn thành thói quen này hôm nay không?\\n\\nSau khi xác nhận, bạn sẽ không thể bỏ tick trong ngày.'**
  String get confirmHabitMessage;

  /// No description provided for @notSure.
  ///
  /// In vi, this message translates to:
  /// **'Chưa chắc'**
  String get notSure;

  /// No description provided for @completedExclaim.
  ///
  /// In vi, this message translates to:
  /// **'Đã hoàn thành!'**
  String get completedExclaim;

  /// No description provided for @deleteHabit.
  ///
  /// In vi, this message translates to:
  /// **'Xóa thói quen?'**
  String get deleteHabit;

  /// No description provided for @confirmDeleteHabit.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn xóa \\\"{name}\\\" không?'**
  String confirmDeleteHabit(String name);

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get close;

  /// No description provided for @unlockedOn.
  ///
  /// In vi, this message translates to:
  /// **'Mở khóa ngày {date}'**
  String unlockedOn(String date);

  /// No description provided for @addNewHabit.
  ///
  /// In vi, this message translates to:
  /// **'Thêm thói quen mới'**
  String get addNewHabit;

  /// No description provided for @selectIcon.
  ///
  /// In vi, this message translates to:
  /// **'Chọn icon'**
  String get selectIcon;

  /// No description provided for @habitName.
  ///
  /// In vi, this message translates to:
  /// **'Tên thói quen'**
  String get habitName;

  /// No description provided for @habitNameExample.
  ///
  /// In vi, this message translates to:
  /// **'VD: Uống 2L nước mỗi ngày'**
  String get habitNameExample;

  /// No description provided for @category.
  ///
  /// In vi, this message translates to:
  /// **'Danh mục'**
  String get category;

  /// No description provided for @addHabit.
  ///
  /// In vi, this message translates to:
  /// **'Thêm thói quen'**
  String get addHabit;

  /// No description provided for @noHabits.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có thói quen nào'**
  String get noHabits;

  /// No description provided for @addFirstHabit.
  ///
  /// In vi, this message translates to:
  /// **'Thêm thói quen đầu tiên để bắt đầu\\nhành trình sống lành mạnh'**
  String get addFirstHabit;

  /// No description provided for @amazingAllDone.
  ///
  /// In vi, this message translates to:
  /// **'Tuyệt vời! Hoàn thành hết rồi 🎉'**
  String get amazingAllDone;

  /// No description provided for @yourToday.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay của bạn'**
  String get yourToday;

  /// No description provided for @habitsLabel.
  ///
  /// In vi, this message translates to:
  /// **'thói quen'**
  String get habitsLabel;

  /// No description provided for @consecutiveDays.
  ///
  /// In vi, this message translates to:
  /// **'{count} ngày liên tiếp'**
  String consecutiveDays(int count);

  /// No description provided for @categoryEat.
  ///
  /// In vi, this message translates to:
  /// **'Ăn uống'**
  String get categoryEat;

  /// No description provided for @categoryExercise.
  ///
  /// In vi, this message translates to:
  /// **'Vận động'**
  String get categoryExercise;

  /// No description provided for @categorySleep.
  ///
  /// In vi, this message translates to:
  /// **'Giấc ngủ'**
  String get categorySleep;

  /// No description provided for @categoryMental.
  ///
  /// In vi, this message translates to:
  /// **'Tinh thần'**
  String get categoryMental;

  /// No description provided for @categoryHydration.
  ///
  /// In vi, this message translates to:
  /// **'Uống nước'**
  String get categoryHydration;

  /// No description provided for @categoryOther.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get categoryOther;

  /// No description provided for @metricWater.
  ///
  /// In vi, this message translates to:
  /// **'Số ml nước'**
  String get metricWater;

  /// No description provided for @metricDistance.
  ///
  /// In vi, this message translates to:
  /// **'Khoảng cách (m)'**
  String get metricDistance;

  /// No description provided for @metricSleepHours.
  ///
  /// In vi, this message translates to:
  /// **'Số giờ ngủ'**
  String get metricSleepHours;

  /// No description provided for @metricCalories.
  ///
  /// In vi, this message translates to:
  /// **'Calories'**
  String get metricCalories;

  /// No description provided for @enterNumberOptional.
  ///
  /// In vi, this message translates to:
  /// **'Nhập số (tùy chọn)'**
  String get enterNumberOptional;

  /// No description provided for @unitMl.
  ///
  /// In vi, this message translates to:
  /// **'ml'**
  String get unitMl;

  /// No description provided for @unitM.
  ///
  /// In vi, this message translates to:
  /// **'m'**
  String get unitM;

  /// No description provided for @unitHours.
  ///
  /// In vi, this message translates to:
  /// **'giờ'**
  String get unitHours;

  /// No description provided for @unitCal.
  ///
  /// In vi, this message translates to:
  /// **'cal'**
  String get unitCal;

  /// No description provided for @onboardingWhoAreYou.
  ///
  /// In vi, this message translates to:
  /// **'Bạn là?'**
  String get onboardingWhoAreYou;

  /// No description provided for @onboardingPersonalize.
  ///
  /// In vi, this message translates to:
  /// **'Giúp chúng tôi cá nhân hóa cho bạn'**
  String get onboardingPersonalize;

  /// No description provided for @onboardingBirthYear.
  ///
  /// In vi, this message translates to:
  /// **'Năm sinh?'**
  String get onboardingBirthYear;

  /// No description provided for @onboardingAgeRecommendation.
  ///
  /// In vi, this message translates to:
  /// **'Để gợi ý phù hợp với độ tuổi của bạn'**
  String get onboardingAgeRecommendation;

  /// No description provided for @onboardingBodyStats.
  ///
  /// In vi, this message translates to:
  /// **'Thông số cơ thể'**
  String get onboardingBodyStats;

  /// No description provided for @onboardingOptionalLater.
  ///
  /// In vi, this message translates to:
  /// **'Không bắt buộc — có thể cập nhật sau'**
  String get onboardingOptionalLater;

  /// No description provided for @onboardingYourGoals.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu của bạn?'**
  String get onboardingYourGoals;

  /// No description provided for @onboardingSelectGoals.
  ///
  /// In vi, this message translates to:
  /// **'Chọn một hoặc nhiều mục tiêu'**
  String get onboardingSelectGoals;

  /// No description provided for @onboardingChoosePlant.
  ///
  /// In vi, this message translates to:
  /// **'Chọn cây của bạn'**
  String get onboardingChoosePlant;

  /// No description provided for @onboardingPlantCompanion.
  ///
  /// In vi, this message translates to:
  /// **'Người bạn đồng hành trong hành trình'**
  String get onboardingPlantCompanion;

  /// No description provided for @skip.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ qua'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp theo →'**
  String get next;

  /// No description provided for @startJourney.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu hành trình 🌱'**
  String get startJourney;

  /// No description provided for @enterBirthYear.
  ///
  /// In vi, this message translates to:
  /// **'Nhập năm sinh (VD: 1995)'**
  String get enterBirthYear;

  /// No description provided for @quickSelect.
  ///
  /// In vi, this message translates to:
  /// **'Chọn nhanh:'**
  String get quickSelect;

  /// No description provided for @invalidBirthYear.
  ///
  /// In vi, this message translates to:
  /// **'Năm sinh không hợp lệ'**
  String get invalidBirthYear;

  /// No description provided for @birthYearBefore1930.
  ///
  /// In vi, this message translates to:
  /// **'Năm sinh không thể trước 1930'**
  String get birthYearBefore1930;

  /// No description provided for @mustBeAtLeast10.
  ///
  /// In vi, this message translates to:
  /// **'Bạn phải ít nhất 10 tuổi'**
  String get mustBeAtLeast10;

  /// No description provided for @heightLabel.
  ///
  /// In vi, this message translates to:
  /// **'Chiều cao'**
  String get heightLabel;

  /// No description provided for @weightLabel.
  ///
  /// In vi, this message translates to:
  /// **'Cân nặng'**
  String get weightLabel;

  /// No description provided for @heightExample.
  ///
  /// In vi, this message translates to:
  /// **'Ví dụ: 165'**
  String get heightExample;

  /// No description provided for @weightExample.
  ///
  /// In vi, this message translates to:
  /// **'Ví dụ: 55'**
  String get weightExample;

  /// No description provided for @unitCm.
  ///
  /// In vi, this message translates to:
  /// **'cm'**
  String get unitCm;

  /// No description provided for @unitKg.
  ///
  /// In vi, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// No description provided for @bmiInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin này giúp tính BMI và gợi ý thói quen phù hợp hơn.'**
  String get bmiInfo;

  /// No description provided for @invalidHeight.
  ///
  /// In vi, this message translates to:
  /// **'Chiều cao không hợp lệ'**
  String get invalidHeight;

  /// No description provided for @heightMin.
  ///
  /// In vi, this message translates to:
  /// **'Chiều cao tối thiểu 100 cm'**
  String get heightMin;

  /// No description provided for @heightMax.
  ///
  /// In vi, this message translates to:
  /// **'Chiều cao tối đa 250 cm'**
  String get heightMax;

  /// No description provided for @invalidWeight.
  ///
  /// In vi, this message translates to:
  /// **'Cân nặng không hợp lệ'**
  String get invalidWeight;

  /// No description provided for @weightMin.
  ///
  /// In vi, this message translates to:
  /// **'Cân nặng tối thiểu 15 kg'**
  String get weightMin;

  /// No description provided for @weightMax.
  ///
  /// In vi, this message translates to:
  /// **'Cân nặng tối đa 300 kg'**
  String get weightMax;

  /// No description provided for @goalEatHealthy.
  ///
  /// In vi, this message translates to:
  /// **'Ăn lành mạnh'**
  String get goalEatHealthy;

  /// No description provided for @goalExercise.
  ///
  /// In vi, this message translates to:
  /// **'Vận động'**
  String get goalExercise;

  /// No description provided for @goalSleep.
  ///
  /// In vi, this message translates to:
  /// **'Giấc ngủ'**
  String get goalSleep;

  /// No description provided for @goalMental.
  ///
  /// In vi, this message translates to:
  /// **'Tinh thần'**
  String get goalMental;

  /// No description provided for @goalWeight.
  ///
  /// In vi, this message translates to:
  /// **'Cân nặng'**
  String get goalWeight;

  /// No description provided for @goalHydration.
  ///
  /// In vi, this message translates to:
  /// **'Uống nước'**
  String get goalHydration;

  /// No description provided for @goalOther.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get goalOther;

  /// No description provided for @whatIsYourGoal.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu của bạn là gì?'**
  String get whatIsYourGoal;

  /// No description provided for @plantSprout.
  ///
  /// In vi, this message translates to:
  /// **'Mầm xanh'**
  String get plantSprout;

  /// No description provided for @plantCactus.
  ///
  /// In vi, this message translates to:
  /// **'Xương rồng'**
  String get plantCactus;

  /// No description provided for @plantBonsai.
  ///
  /// In vi, this message translates to:
  /// **'Bonsai'**
  String get plantBonsai;

  /// No description provided for @plantFlower.
  ///
  /// In vi, this message translates to:
  /// **'Hoa anh đào'**
  String get plantFlower;

  /// No description provided for @plantBamboo.
  ///
  /// In vi, this message translates to:
  /// **'Tre xanh'**
  String get plantBamboo;

  /// No description provided for @plantSunflower.
  ///
  /// In vi, this message translates to:
  /// **'Hướng dương'**
  String get plantSunflower;

  /// No description provided for @plantDescSprout.
  ///
  /// In vi, this message translates to:
  /// **'Nhỏ bé nhưng đầy tiềm năng'**
  String get plantDescSprout;

  /// No description provided for @plantDescCactus.
  ///
  /// In vi, this message translates to:
  /// **'Kiên cường, không bỏ cuộc'**
  String get plantDescCactus;

  /// No description provided for @plantDescBonsai.
  ///
  /// In vi, this message translates to:
  /// **'Kiên nhẫn, từng bước vững chắc'**
  String get plantDescBonsai;

  /// No description provided for @plantDescFlower.
  ///
  /// In vi, this message translates to:
  /// **'Tươi sáng và tràn đầy năng lượng'**
  String get plantDescFlower;

  /// No description provided for @plantDescBamboo.
  ///
  /// In vi, this message translates to:
  /// **'Dẻo dai, bền bỉ mỗi ngày'**
  String get plantDescBamboo;

  /// No description provided for @plantDescSunflower.
  ///
  /// In vi, this message translates to:
  /// **'Luôn hướng về phía ánh sáng'**
  String get plantDescSunflower;

  /// No description provided for @onboardingPlantGrowWithHabits.
  ///
  /// In vi, this message translates to:
  /// **'Cây sẽ lớn lên cùng thói quen của bạn'**
  String get onboardingPlantGrowWithHabits;

  /// No description provided for @onboardingPlantTip.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành thói quen mỗi ngày để cây phát triển và mở khóa thành tích mới!'**
  String get onboardingPlantTip;

  /// No description provided for @notifMorningTitle.
  ///
  /// In vi, this message translates to:
  /// **'🌱 Chào buổi sáng!'**
  String get notifMorningTitle;

  /// No description provided for @notifMorningBody.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay bạn đã sẵn sàng cho thói quen của mình chưa?'**
  String get notifMorningBody;

  /// No description provided for @notifEveningTitle.
  ///
  /// In vi, this message translates to:
  /// **'🌙 Nhắc nhở buổi tối'**
  String get notifEveningTitle;

  /// No description provided for @notifEveningBody.
  ///
  /// In vi, this message translates to:
  /// **'Đừng quên hoàn thành thói quen hôm nay nhé! Cây của bạn đang chờ 🌿'**
  String get notifEveningBody;

  /// No description provided for @notifChannelMorning.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc sáng'**
  String get notifChannelMorning;

  /// No description provided for @notifChannelEvening.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc tối'**
  String get notifChannelEvening;

  /// No description provided for @notifChannelMorningDesc.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc nhở thói quen buổi sáng'**
  String get notifChannelMorningDesc;

  /// No description provided for @notifChannelEveningDesc.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc nhở thói quen buổi tối'**
  String get notifChannelEveningDesc;

  /// No description provided for @notifDailyReminder.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc nhở thói quen hàng ngày'**
  String get notifDailyReminder;

  /// No description provided for @statsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thống kê'**
  String get statsTitle;

  /// No description provided for @thisWeek.
  ///
  /// In vi, this message translates to:
  /// **'Tuần này'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In vi, this message translates to:
  /// **'Tháng này'**
  String get thisMonth;

  /// No description provided for @details.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết'**
  String get details;

  /// No description provided for @totalCheckins.
  ///
  /// In vi, this message translates to:
  /// **'Tổng check-in'**
  String get totalCheckins;

  /// No description provided for @activeDaysLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ngày hoạt động'**
  String get activeDaysLabel;

  /// No description provided for @longestStreakLabel.
  ///
  /// In vi, this message translates to:
  /// **'Streak dài nhất'**
  String get longestStreakLabel;

  /// No description provided for @habitsCount.
  ///
  /// In vi, this message translates to:
  /// **'Thói quen'**
  String get habitsCount;

  /// No description provided for @days.
  ///
  /// In vi, this message translates to:
  /// **'ngày'**
  String get days;

  /// No description provided for @habitsCompletedDaily.
  ///
  /// In vi, this message translates to:
  /// **'Thói quen hoàn thành mỗi ngày'**
  String get habitsCompletedDaily;

  /// No description provided for @habitsCompleted30Days.
  ///
  /// In vi, this message translates to:
  /// **'Thói quen hoàn thành 30 ngày'**
  String get habitsCompleted30Days;

  /// No description provided for @noDataYet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu'**
  String get noDataYet;

  /// No description provided for @completeHabitsToSeeStats.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành thói quen để xem thống kê'**
  String get completeHabitsToSeeStats;

  /// No description provided for @noHabitsYetStats.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có thói quen nào'**
  String get noHabitsYetStats;

  /// No description provided for @createHabitsToSeeStats.
  ///
  /// In vi, this message translates to:
  /// **'Tạo thói quen để xem thống kê chi tiết'**
  String get createHabitsToSeeStats;

  /// No description provided for @timesCheckin.
  ///
  /// In vi, this message translates to:
  /// **'lần check-in'**
  String get timesCheckin;

  /// No description provided for @totalLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tổng'**
  String get totalLabel;

  /// No description provided for @byCategory.
  ///
  /// In vi, this message translates to:
  /// **'Theo danh mục'**
  String get byCategory;

  /// No description provided for @completionPercentageDaily.
  ///
  /// In vi, this message translates to:
  /// **'Phần trăm thói quen hoàn thành mỗi ngày'**
  String get completionPercentageDaily;

  /// No description provided for @good.
  ///
  /// In vi, this message translates to:
  /// **'Tốt'**
  String get good;

  /// No description provided for @fair.
  ///
  /// In vi, this message translates to:
  /// **'Khá'**
  String get fair;

  /// No description provided for @needsImprovement.
  ///
  /// In vi, this message translates to:
  /// **'Cần cố gắng'**
  String get needsImprovement;

  /// No description provided for @goodPercent.
  ///
  /// In vi, this message translates to:
  /// **'Tốt (≥80%)'**
  String get goodPercent;

  /// No description provided for @fairPercent.
  ///
  /// In vi, this message translates to:
  /// **'Khá (≥50%)'**
  String get fairPercent;

  /// No description provided for @needsImprovementPercent.
  ///
  /// In vi, this message translates to:
  /// **'Cần cố gắng'**
  String get needsImprovementPercent;

  /// No description provided for @currentStreak.
  ///
  /// In vi, this message translates to:
  /// **'Streak hiện tại'**
  String get currentStreak;

  /// No description provided for @consecutiveDaysLabel.
  ///
  /// In vi, this message translates to:
  /// **'ngày liên tiếp'**
  String get consecutiveDaysLabel;

  /// No description provided for @greatKeepGoing.
  ///
  /// In vi, this message translates to:
  /// **'Tuyệt vời! Tiếp tục phát huy! 💪'**
  String get greatKeepGoing;

  /// No description provided for @maintainDaily.
  ///
  /// In vi, this message translates to:
  /// **'Hãy duy trì mỗi ngày nhé! 🌟'**
  String get maintainDaily;

  /// No description provided for @activityCalendar30Days.
  ///
  /// In vi, this message translates to:
  /// **'Lịch hoạt động 30 ngày'**
  String get activityCalendar30Days;

  /// No description provided for @darkerMoreHabits.
  ///
  /// In vi, this message translates to:
  /// **'Màu đậm = hoàn thành nhiều thói quen'**
  String get darkerMoreHabits;

  /// No description provided for @less.
  ///
  /// In vi, this message translates to:
  /// **'Ít'**
  String get less;

  /// No description provided for @more.
  ///
  /// In vi, this message translates to:
  /// **'Nhiều'**
  String get more;

  /// No description provided for @quantityLabel.
  ///
  /// In vi, this message translates to:
  /// **'Số lượng thói quen hoàn thành mỗi ngày'**
  String get quantityLabel;

  /// No description provided for @trendOver7Days.
  ///
  /// In vi, this message translates to:
  /// **'Xu hướng theo thời gian'**
  String get trendOver7Days;

  /// No description provided for @trendSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Giá trị ghi nhận mỗi ngày (P*)'**
  String get trendSubtitle;

  /// No description provided for @logoutConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn đăng xuất?'**
  String get logoutConfirm;

  /// No description provided for @yes.
  ///
  /// In vi, this message translates to:
  /// **'Có'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In vi, this message translates to:
  /// **'Không'**
  String get no;

  /// No description provided for @sevenDays.
  ///
  /// In vi, this message translates to:
  /// **'7 ngày'**
  String get sevenDays;

  /// No description provided for @thirtyDays.
  ///
  /// In vi, this message translates to:
  /// **'30 ngày'**
  String get thirtyDays;

  /// No description provided for @ninetyDays.
  ///
  /// In vi, this message translates to:
  /// **'90 ngày'**
  String get ninetyDays;

  /// No description provided for @currentStreakLabel.
  ///
  /// In vi, this message translates to:
  /// **'🔥 Streak hiện tại'**
  String get currentStreakLabel;

  /// No description provided for @longestStreakDetail.
  ///
  /// In vi, this message translates to:
  /// **'🏆 Streak dài nhất'**
  String get longestStreakDetail;

  /// No description provided for @totalCheckinsLabel.
  ///
  /// In vi, this message translates to:
  /// **'✅ Tổng check-in'**
  String get totalCheckinsLabel;

  /// No description provided for @times.
  ///
  /// In vi, this message translates to:
  /// **'lần'**
  String get times;

  /// No description provided for @trendOverTime.
  ///
  /// In vi, this message translates to:
  /// **'Xu hướng theo thời gian'**
  String get trendOverTime;

  /// No description provided for @dailyRecordedValues.
  ///
  /// In vi, this message translates to:
  /// **'Giá trị ghi nhận mỗi ngày'**
  String get dailyRecordedValues;

  /// No description provided for @dailyRecordedValuesWithUnit.
  ///
  /// In vi, this message translates to:
  /// **'Giá trị ghi nhận mỗi ngày ({unit})'**
  String dailyRecordedValuesWithUnit(String unit);

  /// No description provided for @average.
  ///
  /// In vi, this message translates to:
  /// **'📊 Trung bình'**
  String get average;

  /// No description provided for @totalSum.
  ///
  /// In vi, this message translates to:
  /// **'📈 Tổng cộng'**
  String get totalSum;

  /// No description provided for @noDataForPeriod.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có dữ liệu trong khoảng thời gian này'**
  String get noDataForPeriod;

  /// No description provided for @startTrackingHabit.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu theo dõi thói quen để xem biểu đồ'**
  String get startTrackingHabit;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
