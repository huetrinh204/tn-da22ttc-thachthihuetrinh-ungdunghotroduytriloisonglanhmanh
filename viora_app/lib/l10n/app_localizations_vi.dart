// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Tên ứng dụng';

  @override
  String get home => 'Trang chủ';

  @override
  String get habits => 'Thói quen';

  @override
  String get plant => 'Cây';

  @override
  String get stats => 'Thống kê';

  @override
  String get profile => 'Hồ sơ';

  @override
  String get grow => 'Phát triển';

  @override
  String get navMe => 'Tôi';

  @override
  String get insights => 'Thông tin chi tiết';

  @override
  String get viewInsights => 'Biểu đồ và tiến độ theo thời gian';

  @override
  String get goodMorning => 'Chào buổi sáng';

  @override
  String get goodAfternoon => 'Chào buổi chiều';

  @override
  String get goodEvening => 'Chào buổi tối';

  @override
  String daysStreak(int count) {
    return '$count ngày liên tiếp';
  }

  @override
  String get keepItUp => 'Giữ vững phong độ nhé! 💪';

  @override
  String get best => 'Best';

  @override
  String get yourPlant => 'Cây của bạn';

  @override
  String get plantWilted => 'Hãy check-in để cây hồi phục! 💧';

  @override
  String get plantNotWatered => 'Cây chưa được tưới 3 ngày rồi...';

  @override
  String get completeHabitsToGrow => 'Hoàn thành thói quen để cây lớn lên!';

  @override
  String get today => 'Hôm nay';

  @override
  String completed(int done, int total) {
    return '$done/$total';
  }

  @override
  String get noHabitsYet => 'Chưa có thói quen nào. Thêm ngay nhé! ✨';

  @override
  String get allDoneToday => 'Tuyệt vời! Bạn đã hoàn thành tất cả hôm nay 🎉';

  @override
  String habitsRemaining(int count) {
    return 'Còn $count thói quen chưa hoàn thành';
  }

  @override
  String get quote1 => 'Mỗi ngày một bước nhỏ, tạo nên thay đổi lớn. 💪';

  @override
  String get quote2 => 'Thói quen tốt là nền tảng của cuộc sống lành mạnh. 🌿';

  @override
  String get quote3 => 'Kiên trì là chìa khóa của thành công. 🗝️';

  @override
  String get quote4 => 'Hôm nay tốt hơn hôm qua là đủ rồi. ✨';

  @override
  String get quote5 => 'Sức khỏe là tài sản quý giá nhất. 🏃';

  @override
  String get myPlant => 'Cây của tôi';

  @override
  String level(int level) {
    return 'Cấp $level';
  }

  @override
  String levelRange(int current, int next) {
    return 'Cấp $current → $next';
  }

  @override
  String points(int count) {
    return '$count điểm';
  }

  @override
  String get totalPoints => 'Tổng điểm';

  @override
  String get levelProgress => 'Cấp độ';

  @override
  String get maxLevel => '🏆 Cây đã đạt cấp độ tối đa!';

  @override
  String get developmentProgress => 'Tiến trình phát triển';

  @override
  String get developmentRoadmap => 'Lộ trình phát triển';

  @override
  String get howToEarnPoints => 'Cách kiếm điểm';

  @override
  String get earnTip1 => 'Mỗi habit hoàn thành trong ngày';

  @override
  String get earnReward1 => '+1 EXP';

  @override
  String get earnTip2 => 'EXP tích lũy để nâng cấp cây';

  @override
  String get earnReward2 => '15 cấp độ';

  @override
  String get earnTip3 => 'Duy trì check-in mỗi ngày';

  @override
  String get earnReward3 => 'Cây luôn tươi tốt';

  @override
  String get earnTip4 => 'Bỏ check-in 3 ngày liên tiếp';

  @override
  String get earnReward4 => '-3 EXP & cây héo';

  @override
  String get congratulations => '🎉 CHÚC MỪNG! 🎉';

  @override
  String get plantLeveledUp => 'Cây của bạn đã lên cấp!';

  @override
  String get keepGrowing => '✨ Tiếp tục phát triển nhé! ✨';

  @override
  String get treasureUnlocked => '🏆 Nước thần';

  @override
  String get treasureLocked => '🔒 Khóa';

  @override
  String get plantLevel1 => 'Hạt giống';

  @override
  String get plantLevel2 => 'Hạt nảy mầm';

  @override
  String get plantLevel3 => 'Mầm non';

  @override
  String get plantLevel4 => 'Cây non';

  @override
  String get plantLevel5 => 'Cây con';

  @override
  String get plantLevel6 => 'Cây nhỏ';

  @override
  String get plantLevel7 => 'Cây đang lớn';

  @override
  String get plantLevel8 => 'Cây trưởng thành';

  @override
  String get plantLevel9 => 'Cây phát triển tốt';

  @override
  String get plantLevel10 => 'Cây ra hoa';

  @override
  String get plantLevel11 => 'Cây kết trái non';

  @override
  String get plantLevel12 => 'Cây trái lớn dần';

  @override
  String get plantLevel13 => 'Cây kết trái chín';

  @override
  String get plantLevel14 => 'Cây sai quả';

  @override
  String get plantLevel15 => 'Cây trưởng thành hoàn hảo';

  @override
  String get plantWiltedWarning => 'Cây đang héo! Hãy check-in ngay 💧';

  @override
  String get plantWiltingStatus => 'Cây đang héo...';

  @override
  String get plantWarningDay1 => '⚠️ Chưa check-in hôm qua. Hãy quay lại nhé!';

  @override
  String get plantWarningDay2 =>
      '⚠️ Cây cần được chăm sóc! Sẽ bị héo và mất 3 điểm nếu không check-in trong 24h!';

  @override
  String get plantWarningDay3 =>
      '🍂 Cây đã bị héo và mất 3 điểm! Hãy check-in để cây hồi phục!';

  @override
  String get plantWarningDay3Plus =>
      '🍂 Cây đang héo nặng! Check-in ngay để cứu cây!';

  @override
  String get monday => 'Thứ 2';

  @override
  String get tuesday => 'Thứ 3';

  @override
  String get wednesday => 'Thứ 4';

  @override
  String get thursday => 'Thứ 5';

  @override
  String get friday => 'Thứ 6';

  @override
  String get saturday => 'Thứ 7';

  @override
  String get sunday => 'Chủ nhật';

  @override
  String get achievementsTitle => 'Thành tích';

  @override
  String achievementsCount(int unlocked, int total) {
    return '$unlocked / $total thành tích';
  }

  @override
  String get allAchievementsUnlocked => 'Bạn đã mở khóa tất cả! 🎉';

  @override
  String achievementsRemaining(int count) {
    return 'Còn $count thành tích chưa mở';
  }

  @override
  String get achievementFirstStep => 'Bước đầu tiên';

  @override
  String get achievementFirstStepDesc => 'Hoàn thành check-in đầu tiên';

  @override
  String get achievementStreak3 => '3 ngày liên tiếp';

  @override
  String get achievementStreak3Desc => 'Duy trì streak 3 ngày liên tiếp';

  @override
  String get achievementStreak7 => 'Tuần kiên trì';

  @override
  String get achievementStreak7Desc => 'Duy trì streak 7 ngày liên tiếp';

  @override
  String get achievementStreak30 => 'Tháng bền bỉ';

  @override
  String get achievementStreak30Desc => 'Duy trì streak 30 ngày liên tiếp';

  @override
  String get achievementHabits5 => 'Đa nhiệm';

  @override
  String get achievementHabits5Desc => 'Tạo 5 thói quen';

  @override
  String get achievementCheckin50 => 'Nửa trăm';

  @override
  String get achievementCheckin50Desc => 'Hoàn thành 50 check-ins';

  @override
  String get achievementCheckin100 => 'Bách chiến';

  @override
  String get achievementCheckin100Desc => 'Hoàn thành 100 check-ins';

  @override
  String get achievementPlantLevel3 => 'Cây non';

  @override
  String get achievementPlantLevel3Desc => 'Cây ảo đạt cấp độ 3';

  @override
  String get achievementPlantLevel5 => 'Vườn địa đàng';

  @override
  String get achievementPlantLevel5Desc => 'Cây ảo đạt cấp độ tối đa';

  @override
  String get notificationSettingsTitle => 'Thông báo nhắc nhở';

  @override
  String get notificationInfo =>
      'Thông báo sẽ nhắc bạn check-in thói quen mỗi ngày để cây phát triển.';

  @override
  String get morningReminder => 'Nhắc buổi sáng';

  @override
  String get morningReminderDesc => 'Bắt đầu ngày mới với thói quen lành mạnh';

  @override
  String get eveningReminder => 'Nhắc buổi tối';

  @override
  String get eveningReminderDesc => 'Hoàn thành thói quen trước khi ngủ';

  @override
  String get reminderTime => 'Giờ nhắc';

  @override
  String get settings => 'Cài đặt';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get darkMode => 'Chế độ tối';

  @override
  String get lightMode => 'Chế độ sáng';

  @override
  String get usingDarkMode => 'Đang dùng chế độ tối';

  @override
  String get usingLightMode => 'Đang dùng chế độ sáng';

  @override
  String get notifications => 'Thông báo';

  @override
  String get savedSettings => 'Đã lưu và áp dụng cài đặt';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get personalInfo => 'Thông tin cá nhân';

  @override
  String get fullName => 'Họ và tên';

  @override
  String get email => 'Email';

  @override
  String get gender => 'Giới tính';

  @override
  String get male => 'Nam';

  @override
  String get female => 'Nữ';

  @override
  String get other => 'Khác';

  @override
  String get notUpdated => 'Chưa cập nhật';

  @override
  String get birthYear => 'Năm sinh';

  @override
  String get bodyStats => 'Thông số cơ thể';

  @override
  String get height => 'Chiều cao';

  @override
  String get weight => 'Cân nặng';

  @override
  String get bmi => 'BMI';

  @override
  String get underweight => 'Thiếu cân';

  @override
  String get normal => 'Bình thường';

  @override
  String get overweight => 'Thừa cân';

  @override
  String get obese => 'Béo phì';

  @override
  String get personalGoals => 'Mục tiêu cá nhân';

  @override
  String get goals => 'Mục tiêu';

  @override
  String get noGoalsSelected => 'Chưa chọn mục tiêu';

  @override
  String get security => 'Bảo mật';

  @override
  String get changePassword => 'Đổi mật khẩu';

  @override
  String get updatePassword => 'Cập nhật mật khẩu';

  @override
  String get currentPassword => 'Mật khẩu hiện tại';

  @override
  String get newPassword => 'Mật khẩu mới';

  @override
  String get confirmPassword => 'Xác nhận mật khẩu mới';

  @override
  String get forgotPassword => 'Quên mật khẩu hiện tại? Đặt lại qua email →';

  @override
  String get passwordMismatch => 'Mật khẩu xác nhận không khớp';

  @override
  String get passwordTooShort => 'Mật khẩu tối thiểu 8 ký tự';

  @override
  String get passwordUpdated => 'Đổi mật khẩu thành công';

  @override
  String get failed => 'Thất bại';

  @override
  String get achievements => 'Thành tích';

  @override
  String get myAchievements => 'Thành tích của tôi';

  @override
  String get viewUnlockedAchievements => 'Xem các thành tích đã mở khóa';

  @override
  String get habitReminders => 'Nhắc nhở thói quen';

  @override
  String get setDailyReminders => 'Cài đặt giờ nhắc hàng ngày';

  @override
  String get appearance => 'Giao diện';

  @override
  String get selectLanguage => 'Chọn ngôn ngữ';

  @override
  String get languageChanged => 'Đã chuyển sang Tiếng Việt';

  @override
  String get languageChangedEn => 'Đã chuyển sang Tiếng Anh';

  @override
  String get editName => 'Đổi tên';

  @override
  String get save => 'Lưu';

  @override
  String get nameUpdated => 'Đã cập nhật tên';

  @override
  String get bodyStatsTitle => 'Thông số cơ thể';

  @override
  String get heightRange => 'Chiều cao từ 100–250 cm';

  @override
  String get weightRange => 'Cân nặng từ 15–300 kg';

  @override
  String get statsUpdated => 'Đã cập nhật thông số';

  @override
  String get goalsUpdated => 'Đã cập nhật mục tiêu';

  @override
  String get login => 'Đăng nhập';

  @override
  String get register => 'Đăng ký';

  @override
  String get loginTitle => 'ĐĂNG NHẬP';

  @override
  String get registerTitle => 'Tạo tài khoản';

  @override
  String get password => 'Mật khẩu';

  @override
  String get confirmPasswordLabel => 'Xác nhận mật khẩu';

  @override
  String get enterEmail => 'Nhập email của bạn';

  @override
  String get enterPassword => 'Nhập mật khẩu của bạn';

  @override
  String get enterFullName => 'Nhập họ và tên';

  @override
  String get enterPasswordAgain => 'Nhập lại mật khẩu';

  @override
  String get minEightChars => 'Tối thiểu 8 ký tự';

  @override
  String get forgotPasswordQuestion => 'Quên mật khẩu?';

  @override
  String get or => 'hoặc';

  @override
  String get loginWithGoogle => 'Đăng nhập bằng Google';

  @override
  String get noAccount => 'Chưa có tài khoản? ';

  @override
  String get registerNow => 'Đăng ký ngay';

  @override
  String get haveAccount => 'Đã có tài khoản? ';

  @override
  String get loginNow => 'Đăng nhập';

  @override
  String get quote =>
      '\"Sự thay đổi không đến từ điều lớn lao,\\nmà từ những thói quen nhỏ được lặp lại mỗi ngày.\"';

  @override
  String get pleaseEnterAllInfo => 'Vui lòng nhập đầy đủ thông tin';

  @override
  String get loginFailed => 'Đăng nhập thất bại';

  @override
  String get loginFailedRetry => 'Đăng nhập thất bại, thử lại';

  @override
  String get googleLoginFailed => 'Google login thất bại';

  @override
  String googleLoginError(String error) {
    return 'Lỗi Google login: $error';
  }

  @override
  String get registerFailed => 'Đăng ký thất bại';

  @override
  String get pleaseEnterName => 'Vui lòng nhập tên';

  @override
  String get nameTooShort => 'Tên phải có ít nhất 2 ký tự';

  @override
  String get pleaseEnterEmail => 'Vui lòng nhập email';

  @override
  String get invalidEmailFormat => 'Email không đúng định dạng';

  @override
  String get pleaseEnterPassword => 'Vui lòng nhập mật khẩu';

  @override
  String get passwordMinEightChars => 'Mật khẩu tối thiểu 8 ký tự';

  @override
  String get passwordNeedsUppercase => 'Phải có ít nhất 1 chữ hoa';

  @override
  String get passwordNeedsNumber => 'Phải có ít nhất 1 chữ số';

  @override
  String get pleaseConfirmPassword => 'Vui lòng xác nhận mật khẩu';

  @override
  String get passwordsDoNotMatch => 'Mật khẩu không khớp';

  @override
  String get forgotPasswordTitle => 'Quên mật khẩu';

  @override
  String get enterYourEmail => 'Nhập email của bạn';

  @override
  String get weWillSendOtp =>
      'Chúng tôi sẽ gửi mã OTP 6 chữ số đến email của bạn';

  @override
  String get sendOtp => 'Gửi mã OTP';

  @override
  String get resetPassword => 'Đặt lại mật khẩu';

  @override
  String enterOtpSentTo(String email) {
    return 'Nhập mã OTP đã gửi đến $email';
  }

  @override
  String get newPasswordMinEight => 'Mật khẩu mới (tối thiểu 8 ký tự)';

  @override
  String get confirmNewPassword => 'Xác nhận mật khẩu mới';

  @override
  String get resendOtp => 'Gửi lại mã OTP';

  @override
  String get otpSent => 'Mã OTP đã được gửi đến email của bạn';

  @override
  String get otpMustBeSixDigits => 'Mã OTP gồm 6 chữ số';

  @override
  String get confirmPasswordMismatch => 'Mật khẩu xác nhận không khớp';

  @override
  String get resetPasswordSuccess => 'Đặt lại mật khẩu thành công!';

  @override
  String get stepEmail => 'Email';

  @override
  String get stepConfirm => 'Xác nhận';

  @override
  String get agreePrivacyPolicy =>
      'Tôi đồng ý với Chính sách Bảo mật và Điều khoản Sử dụng';

  @override
  String get pleaseAgreePrivacy =>
      'Vui lòng đồng ý với Chính sách Bảo mật và Điều khoản Sử dụng';

  @override
  String get policiesTitle => 'Chính sách Bảo mật & Điều khoản';

  @override
  String get privacyPolicyTitle => 'Chính sách Bảo mật';

  @override
  String get termsOfServiceTitle => 'Điều khoản Sử dụng';

  @override
  String get ppInfoCollected => '1. Thông tin chúng tôi thu thập';

  @override
  String get ppInfoCollectedContent =>
      'Khi bạn sử dụng ứng dụng Viora, chúng tôi có thể thu thập các thông tin sau:\n- Thông tin tài khoản: họ tên, địa chỉ email, ảnh đại diện\n- Dữ liệu thói quen: danh sách thói quen, nhật ký check-in hằng ngày, số đo, tiến trình\n- Dữ liệu tương tác: bài viết, bình luận, lượt thích, theo dõi trong cộng đồng\n- Dữ liệu cây ảo: cấp độ, kinh nghiệm (EXP), loại cây\n- Dữ liệu thiết bị: mã thiết bị cho push notification';

  @override
  String get ppPurpose => '2. Mục đích sử dụng thông tin';

  @override
  String get ppPurposeContent =>
      'Chúng tôi sử dụng thông tin của bạn cho các mục đích sau:\n- Cung cấp và vận hành các tính năng của ứng dụng (theo dõi thói quen, cây ảo, cộng đồng)\n- Cá nhân hóa trải nghiệm người dùng và đề xuất thói quen phù hợp\n- Gửi thông báo nhắc nhở thói quen qua push notification và email\n- Cung cấp tính năng AI Coach để tư vấn và hỗ trợ xây dựng thói quen\n- Phân tích, thống kê để cải thiện chất lượng dịch vụ\n- Hỗ trợ kỹ thuật và xử lý sự cố';

  @override
  String get ppStorageSecurity => '3. Lưu trữ và bảo mật';

  @override
  String get ppStorageSecurityContent =>
      'Chúng tôi áp dụng các biện pháp bảo mật sau:\n- Dữ liệu được lưu trữ trên máy chủ an toàn với mã hóa SSL/TLS\n- Mật khẩu được mã hóa bằng thuật toán băm (bcrypt)\n- Dữ liệu chỉ được giữ lại trong thời gian cần thiết để cung cấp dịch vụ\n- Chúng tôi định kỳ đánh giá và cập nhật các biện pháp bảo mật';

  @override
  String get ppDataSharing => '4. Chia sẻ dữ liệu';

  @override
  String get ppDataSharingContent =>
      'Chúng tôi cam kết không bán, trao đổi hoặc chuyển nhượng thông tin cá nhân của bạn cho bên thứ ba, ngoại trừ:\n- Khi có yêu cầu từ cơ quan pháp luật có thẩm quyền\n- Khi cần thiết để bảo vệ quyền lợi và an toàn của người dùng hoặc ứng dụng\n- Với các đối tác cung cấp dịch vụ (như Firebase cho push notification) dưới sự ràng buộc bảo mật';

  @override
  String get ppUserRights => '5. Quyền của người dùng';

  @override
  String get ppUserRightsContent =>
      'Bạn có quyền:\n- Truy cập và xem thông tin cá nhân của mình\n- Chỉnh sửa, cập nhật thông tin cá nhân\n- Yêu cầu xóa tài khoản và dữ liệu liên quan\n- Từ chối nhận thông báo push hoặc email quảng cáo\n- Xuất dữ liệu của mình theo yêu cầu';

  @override
  String get ppPolicyChanges => '6. Thay đổi chính sách';

  @override
  String get ppPolicyChangesContent =>
      'Chúng tôi có thể cập nhật Chính sách Bảo mật này theo thời gian. Khi có thay đổi quan trọng, chúng tôi sẽ thông báo cho bạn qua email hoặc thông báo trong ứng dụng. Việc bạn tiếp tục sử dụng ứng dụng sau khi thay đổi có hiệu lực đồng nghĩa với việc bạn chấp nhận các thay đổi đó.';

  @override
  String get ppContact => '7. Liên hệ';

  @override
  String get ppContactContent =>
      'Nếu bạn có bất kỳ câu hỏi hoặc thắc mắc nào về Chính sách Bảo mật này, vui lòng liên hệ với chúng tôi qua email: support@viora.app';

  @override
  String get tosAcceptance => '1. Chấp nhận Điều khoản';

  @override
  String get tosAcceptanceContent =>
      'Bằng việc đăng ký và sử dụng ứng dụng Viora, bạn xác nhận đã đọc, hiểu và đồng ý bị ràng buộc bởi các Điều khoản Sử dụng này. Nếu bạn không đồng ý với bất kỳ điều khoản nào, vui lòng không sử dụng ứng dụng.';

  @override
  String get tosAccount => '2. Trách nhiệm tài khoản';

  @override
  String get tosAccountContent =>
      'Bạn có trách nhiệm:\n- Cung cấp thông tin chính xác, đầy đủ và cập nhật khi đăng ký\n- Bảo mật mật khẩu và tài khoản của mình\n- Thông báo ngay cho chúng tôi nếu phát hiện truy cập trái phép\n- Chịu trách nhiệm về mọi hoạt động diễn ra trên tài khoản của mình';

  @override
  String get tosProhibited => '3. Hành vi bị nghiêm cấm';

  @override
  String get tosProhibitedContent =>
      'Khi sử dụng ứng dụng, bạn không được:\n- Đăng tải nội dung vi phạm pháp luật, khiêu dâm, bạo lực hoặc xúc phạm\n- Quấy rối, đe dọa hoặc xâm phạm quyền riêng tư của người dùng khác\n- Giả mạo danh tính hoặc tạo nhiều tài khoản với mục đích xấu\n- Phát tán spam, virus hoặc mã độc\n- Khai thác lỗ hổng hoặc can thiệp vào hệ thống của ứng dụng\n- Sử dụng ứng dụng cho mục đích thương mại khi chưa được cho phép';

  @override
  String get tosUserContent => '4. Nội dung người dùng';

  @override
  String get tosUserContentContent =>
      'Bạn giữ quyền sở hữu trí tuệ đối với nội dung bạn đăng tải (bài viết, bình luận, hình ảnh). Bằng việc đăng tải, bạn cấp cho chúng tôi giấy phép không độc quyền, miễn phí bản quyền để sử dụng, hiển thị và phân phối nội dung đó trong phạm vi ứng dụng.';

  @override
  String get tosAppRights => '5. Quyền của ứng dụng';

  @override
  String get tosAppRightsContent =>
      'Chúng tôi có quyền:\n- Xóa nội dung vi phạm Điều khoản Sử dụng mà không cần thông báo trước\n- Tạm khóa hoặc vô hiệu hóa tài khoản vi phạm\n- Điều chỉnh, tạm ngưng hoặc ngừng cung cấp dịch vụ bất kỳ lúc nào\n- Thay đổi giới hạn sử dụng hoặc tính năng của ứng dụng';

  @override
  String get tosDisclaimer => '6. Tuyên bố miễn trừ trách nhiệm';

  @override
  String get tosDisclaimerContent =>
      'Ứng dụng được cung cấp trên cơ sở \'nguyên trạng\' (as is). Chúng tôi không bảo đảm rằng ứng dụng sẽ đáp ứng mọi nhu cầu của bạn hoặc không có lỗi. Thông tin và tư vấn từ AI Coach chỉ mang tính tham khảo, không thay thế cho tư vấn chuyên môn từ bác sĩ hoặc chuyên gia sức khỏe.';

  @override
  String get tosChanges => '7. Thay đổi Điều khoản';

  @override
  String get tosChangesContent =>
      'Chúng tôi có thể sửa đổi Điều khoản Sử dụng này bất kỳ lúc nào. Khi có thay đổi, chúng tôi sẽ thông báo cho bạn qua email hoặc thông báo trong ứng dụng. Việc bạn tiếp tục sử dụng ứng dụng sau khi thay đổi có hiệu lực đồng nghĩa với việc bạn chấp nhận các điều khoản mới.';

  @override
  String get tosContact => '8. Liên hệ';

  @override
  String get tosContactContent =>
      'Nếu bạn có bất kỳ câu hỏi nào về Điều khoản Sử dụng, vui lòng liên hệ qua email: support@viora.app';

  @override
  String get habitsToday => 'Thói quen hôm nay';

  @override
  String get confirmCompletion => 'Xác nhận hoàn thành';

  @override
  String get confirmHabitMessage =>
      'Bạn có chắc chắn đã hoàn thành thói quen này hôm nay không?';

  @override
  String get notSure => 'Chưa chắc';

  @override
  String get completedExclaim => 'Đã hoàn thành!';

  @override
  String get deleteHabit => 'Xóa thói quen?';

  @override
  String confirmDeleteHabit(String name) {
    return 'Bạn có chắc chắn muốn xóa thói quen “$name” không?';
  }

  @override
  String get cancel => 'Hủy';

  @override
  String get delete => 'Xóa';

  @override
  String get close => 'Đóng';

  @override
  String unlockedOn(String date) {
    return 'Mở khóa ngày $date';
  }

  @override
  String get addNewHabit => 'Thêm thói quen mới';

  @override
  String get selectIcon => 'Chọn icon';

  @override
  String get habitName => 'Tên thói quen';

  @override
  String get habitNameExample => 'VD: Uống 2L nước mỗi ngày';

  @override
  String get category => 'Danh mục';

  @override
  String get addHabit => 'Thêm thói quen';

  @override
  String get viewAllHabits => 'Xem tất cả thói quen';

  @override
  String get noHabits => 'Chưa có thói quen nào';

  @override
  String get addFirstHabit =>
      'Thêm thói quen đầu tiên để bắt đầu\\nhành trình sống lành mạnh';

  @override
  String get amazingAllDone => 'Tuyệt vời! Hoàn thành hết rồi 🎉';

  @override
  String get yourToday => 'Hôm nay của bạn';

  @override
  String get habitsLabel => 'Thói quen';

  @override
  String consecutiveDays(int count) {
    return '$count ngày liên tiếp';
  }

  @override
  String get categoryEat => 'Ăn uống';

  @override
  String get categoryExercise => 'Vận động';

  @override
  String get categorySleep => 'Giấc ngủ';

  @override
  String get categoryMental => 'Tinh thần';

  @override
  String get categoryHydration => 'Uống nước';

  @override
  String get categoryOther => 'Khác';

  @override
  String get metricExercise => 'Thời gian (Phút)';

  @override
  String get metricWater => 'Số ml nước';

  @override
  String get metricDistance => 'Khoảng cách (m)';

  @override
  String get metricSleepHours => 'Số giờ ngủ';

  @override
  String get metricSleepMinutes => 'Số phút ngủ';

  @override
  String get metricCalories => 'Calories';

  @override
  String get enterNumberOptional => 'Nhập số (tùy chọn)';

  @override
  String get unitMl => 'ml';

  @override
  String get unitM => 'm';

  @override
  String get unitHours => 'giờ';

  @override
  String get unitMinutes => 'phút';

  @override
  String get unitCal => 'cal';

  @override
  String get onboardingWhoAreYou => 'Bạn là?';

  @override
  String get onboardingPersonalize => 'Giúp chúng tôi cá nhân hóa cho bạn';

  @override
  String get onboardingBirthYear => 'Năm sinh?';

  @override
  String get onboardingAgeRecommendation =>
      'Để gợi ý phù hợp với độ tuổi của bạn';

  @override
  String get onboardingBodyStats => 'Thông số cơ thể';

  @override
  String get onboardingOptionalLater => 'Không bắt buộc — có thể cập nhật sau';

  @override
  String get onboardingYourGoals => 'Mục tiêu của bạn?';

  @override
  String get onboardingSelectGoals => 'Chọn một hoặc nhiều mục tiêu';

  @override
  String get onboardingChoosePlant => 'Chọn cây của bạn';

  @override
  String get onboardingPlantCompanion => 'Người bạn đồng hành trong hành trình';

  @override
  String get skip => 'Bỏ qua';

  @override
  String get next => 'Tiếp theo →';

  @override
  String get startJourney => 'Bắt đầu hành trình 🌱';

  @override
  String get enterBirthYear => 'Nhập năm sinh (VD: 1995)';

  @override
  String get quickSelect => 'Chọn nhanh:';

  @override
  String get invalidBirthYear => 'Năm sinh không hợp lệ';

  @override
  String get birthYearBefore1930 => 'Năm sinh không thể trước 1930';

  @override
  String get mustBeAtLeast10 => 'Bạn phải ít nhất 10 tuổi';

  @override
  String get heightLabel => 'Chiều cao';

  @override
  String get weightLabel => 'Cân nặng';

  @override
  String get heightExample => 'Ví dụ: 165';

  @override
  String get weightExample => 'Ví dụ: 55';

  @override
  String get unitCm => 'cm';

  @override
  String get unitKg => 'kg';

  @override
  String get bmiInfo =>
      'Thông tin này giúp tính BMI và gợi ý thói quen phù hợp hơn.';

  @override
  String get invalidHeight => 'Chiều cao không hợp lệ';

  @override
  String get heightMin => 'Chiều cao tối thiểu 100 cm';

  @override
  String get heightMax => 'Chiều cao tối đa 250 cm';

  @override
  String get invalidWeight => 'Cân nặng không hợp lệ';

  @override
  String get weightMin => 'Cân nặng tối thiểu 15 kg';

  @override
  String get weightMax => 'Cân nặng tối đa 300 kg';

  @override
  String get goalEatHealthy => 'Ăn uống lành mạnh';

  @override
  String get goalExercise => 'Tập thể dục';

  @override
  String get goalSleep => 'Ngủ đủ giấc';

  @override
  String get goalMental => 'Sức khỏe tinh thần';

  @override
  String get goalWeight => 'Quản lý cân nặng';

  @override
  String get goalHydration => 'Uống đủ nước';

  @override
  String get goalOther => 'Khác';

  @override
  String get whatIsYourGoal => 'Mục tiêu của bạn là gì?';

  @override
  String get plantSprout => 'Mầm xanh';

  @override
  String get plantCactus => 'Xương rồng';

  @override
  String get plantBonsai => 'Bonsai';

  @override
  String get plantFlower => 'Hoa anh đào';

  @override
  String get plantBamboo => 'Tre xanh';

  @override
  String get plantSunflower => 'Hướng dương';

  @override
  String get plantDescSprout => 'Nhỏ bé nhưng đầy tiềm năng';

  @override
  String get plantDescCactus => 'Kiên cường, không bỏ cuộc';

  @override
  String get plantDescBonsai => 'Kiên nhẫn, từng bước vững chắc';

  @override
  String get plantDescFlower => 'Tươi sáng và tràn đầy năng lượng';

  @override
  String get plantDescBamboo => 'Dẻo dai, bền bỉ mỗi ngày';

  @override
  String get plantDescSunflower => 'Luôn hướng về phía ánh sáng';

  @override
  String get onboardingPlantGrowWithHabits =>
      'Cây sẽ lớn lên cùng thói quen của bạn';

  @override
  String get onboardingPlantTip =>
      'Hoàn thành thói quen mỗi ngày để cây phát triển và mở khóa thành tích mới!';

  @override
  String get notifMorningTitle => '🌱 Chào buổi sáng!';

  @override
  String get notifMorningBody =>
      'Hôm nay bạn đã sẵn sàng cho thói quen của mình chưa?';

  @override
  String get notifEveningTitle => '🌙 Nhắc nhở buổi tối';

  @override
  String get notifEveningBody =>
      'Đừng quên hoàn thành thói quen hôm nay nhé! Cây của bạn đang chờ 🌿';

  @override
  String get notifChannelMorning => 'Nhắc sáng';

  @override
  String get notifChannelEvening => 'Nhắc tối';

  @override
  String get notifChannelMorningDesc => 'Nhắc nhở thói quen buổi sáng';

  @override
  String get notifChannelEveningDesc => 'Nhắc nhở thói quen buổi tối';

  @override
  String get notifDailyReminder => 'Nhắc nhở thói quen hàng ngày';

  @override
  String get statsTitle => 'Thống kê';

  @override
  String get thisWeek => 'Tuần này';

  @override
  String get thisMonth => 'Tháng này';

  @override
  String get details => 'Chi tiết';

  @override
  String get totalCheckins => 'Tổng check-in';

  @override
  String get activeDaysLabel => 'Ngày hoạt động';

  @override
  String get longestStreakLabel => 'Kỷ lục';

  @override
  String get habitsCount => 'Thói quen';

  @override
  String get days => 'ngày';

  @override
  String get habitsCompletedDaily => 'Thói quen hoàn thành mỗi ngày';

  @override
  String get habitsCompleted30Days => 'Thói quen hoàn thành 30 ngày';

  @override
  String get noDataYet => 'Chưa có dữ liệu';

  @override
  String get completeHabitsToSeeStats => 'Hoàn thành thói quen để xem thống kê';

  @override
  String get noHabitsYetStats => 'Chưa có thói quen nào';

  @override
  String get createHabitsToSeeStats => 'Tạo thói quen để xem thống kê chi tiết';

  @override
  String get timesCheckin => 'lần check-in';

  @override
  String get totalLabel => 'Tổng';

  @override
  String get byCategory => 'Theo danh mục';

  @override
  String get completionPercentageDaily =>
      'Phần trăm thói quen hoàn thành mỗi ngày';

  @override
  String get good => 'Tốt';

  @override
  String get fair => 'Khá';

  @override
  String get needsImprovement => 'Cần cố gắng';

  @override
  String get goodPercent => 'Tốt (≥80%)';

  @override
  String get fairPercent => 'Khá (≥50%)';

  @override
  String get needsImprovementPercent => 'Cần cố gắng';

  @override
  String get currentStreak => 'Streak hiện tại';

  @override
  String get consecutiveDaysLabel => 'ngày liên tiếp';

  @override
  String get greatKeepGoing => 'Tuyệt vời! Tiếp tục phát huy! 💪';

  @override
  String get maintainDaily => 'Hãy duy trì mỗi ngày nhé! 🌟';

  @override
  String get activityCalendar30Days => 'Lịch hoạt động 30 ngày';

  @override
  String get darkerMoreHabits => 'Màu đậm = hoàn thành nhiều thói quen';

  @override
  String get less => 'Ít';

  @override
  String get more => 'Nhiều';

  @override
  String get quantityLabel => 'Số lượng thói quen hoàn thành mỗi ngày';

  @override
  String get trendOver7Days => 'Xu hướng theo thời gian';

  @override
  String get trendSubtitle => 'Giá trị ghi nhận mỗi ngày (P*)';

  @override
  String get logoutConfirm => 'Bạn có chắc muốn đăng xuất?';

  @override
  String get yes => 'Có';

  @override
  String get no => 'Không';

  @override
  String get sevenDays => '7 ngày';

  @override
  String get thirtyDays => '30 ngày';

  @override
  String get ninetyDays => '90 ngày';

  @override
  String get currentStreakLabel => 'Streak hiện tại';

  @override
  String get longestStreakDetail => 'Streak dài nhất';

  @override
  String get totalCheckinsLabel => 'Tổng check-in';

  @override
  String get times => 'lần';

  @override
  String get trendOverTime => 'Xu hướng theo thời gian';

  @override
  String get dailyRecordedValues => 'Giá trị ghi nhận mỗi ngày';

  @override
  String dailyRecordedValuesWithUnit(String unit) {
    return 'Giá trị ghi nhận mỗi ngày ($unit)';
  }

  @override
  String get average => 'Trung bình';

  @override
  String get totalSum => 'Tổng cộng';

  @override
  String get noDataForPeriod => 'Chưa có dữ liệu trong khoảng thời gian này';

  @override
  String get startTrackingHabit => 'Bắt đầu theo dõi thói quen để xem biểu đồ';

  @override
  String get community => 'Cộng đồng';

  @override
  String get noCommunityActivity => 'Chưa có hoạt động nào từ cộng đồng';

  @override
  String get viewInCommunity => 'Xem thêm trong Cộng đồng';

  @override
  String get shareYourProgress => 'Bạn muốn chia sẻ gì với mọi người nào?';

  @override
  String get photo => 'Ảnh';

  @override
  String get achievement => 'Thành tích';

  @override
  String get trending => 'Xu hướng';

  @override
  String get following => 'Đang theo dõi';

  @override
  String get followUser => 'Theo dõi';

  @override
  String get followingUser => 'Đang theo dõi';

  @override
  String get friends => 'Bạn bè';

  @override
  String get retry => 'Thử lại';

  @override
  String get loadFeedError => 'Không tải được bài viết';

  @override
  String get followingTabEmpty => 'Theo dõi người khác để xem bài viết của họ';

  @override
  String get noSearchResults => 'Không tìm thấy bài viết';

  @override
  String get searchCommunity => 'Tìm kiếm bài viết hoặc người dùng...';

  @override
  String get noPosts => 'Chưa có bài viết nào';

  @override
  String get createFirstPost => 'Hãy là người đầu tiên chia sẻ!';

  @override
  String get createPost => 'Tạo bài viết';

  @override
  String get postContent => 'Nội dung bài viết';

  @override
  String get shareYourThoughts => 'Chia sẻ suy nghĩ của bạn...';

  @override
  String get addPhoto => 'Thêm ảnh';

  @override
  String get publish => 'Đăng bài';

  @override
  String likes(int count) {
    return '$count thích';
  }

  @override
  String comments(int count) {
    return '$count bình luận';
  }

  @override
  String get share => 'Chia sẻ';

  @override
  String get writeComment => 'Viết bình luận...';

  @override
  String get writeReply => 'Viết trả lời...';

  @override
  String get reply => 'Trả lời';

  @override
  String get replies => 'Trả lời';

  @override
  String viewReplies(int count) {
    return 'Xem $count trả lời';
  }

  @override
  String get hideReplies => 'Ẩn trả lời';

  @override
  String get send => 'Gửi';

  @override
  String get deletePost => 'Xóa bài viết';

  @override
  String get confirmDeletePost => 'Bạn có chắc muốn xóa bài viết này không?';

  @override
  String get postDeleted => 'Đã xóa bài viết';

  @override
  String get postCreated => 'Đã đăng bài thành công!';

  @override
  String get justNow => 'Vừa xong';

  @override
  String minutesAgo(int count) {
    return '$count phút trước';
  }

  @override
  String hoursAgo(int count) {
    return '$count giờ trước';
  }

  @override
  String get completeProfileBanner => 'Hoàn thiện hồ sơ để Viora gợi ý tốt hơn';

  @override
  String get completeProfileBannerAction => 'Chạm để tiếp tục thiết lập';

  @override
  String get tapToAddFirstHabit => 'Chạm để thêm thói quen đầu tiên →';

  @override
  String get streakBrokenTitle => 'Streak đã reset';

  @override
  String get streakBrokenBody =>
      'Không sao — mỗi ngày mới là cơ hội bắt đầu lại. Hoàn thành một thói quen hôm nay để nuôi cây nhé!';

  @override
  String get startFreshStreak => 'Bắt đầu lại';

  @override
  String get firstCheckInTitle => 'Tuyệt vời! 🎉';

  @override
  String get firstCheckInBody =>
      'Bạn vừa hoàn thành check-in đầu tiên. Xem cây của bạn lớn lên nhé!';

  @override
  String get firstCheckInStatsHint =>
      'Mẹo: chạm biểu tượng thống kê trên tab Thói quen để xem tiến độ và chuỗi ngày của bạn.';

  @override
  String get viewHabitStats => 'Xem thống kê';

  @override
  String get gotIt => 'Đã hiểu';

  @override
  String get habitCreatedSuccess => 'Đã thêm thói quen!';

  @override
  String get afterFirstHabitTitle => 'Bước tiếp theo là gì? 🌱';

  @override
  String get afterFirstHabitBody =>
      'Chạm vào thói quen vừa tạo bên dưới để đánh dấu hoàn thành hôm nay — cây của bạn sẽ lớn thêm!';

  @override
  String get completeHabitToday => 'Hoàn thành hôm nay';

  @override
  String get goToTodayTab => 'Về trang Hôm nay';

  @override
  String get addAnotherHabit => 'Thêm thói quen khác';

  @override
  String get afterOnboardingNoHabitsTitle => 'Tạo thói quen đầu tiên';

  @override
  String get afterOnboardingNoHabitsBody =>
      'Bạn đã thiết lập hồ sơ xong. Hãy thêm 1–2 thói quen để bắt đầu thói quen hằng ngày.';

  @override
  String get createFirstHabit => 'Tạo thói quen đầu tiên';

  @override
  String get tapHabitToCompleteHint => 'Chạm thói quen để hoàn thành hôm nay';

  @override
  String get onboardingStarterHabitsTitle => 'Chọn thói quen cho hôm nay';

  @override
  String get onboardingStarterHabitsSubtitle =>
      'Gợi ý từ mục tiêu của bạn — có thể sửa bất cứ lúc nào';

  @override
  String get onboardingStarterHabitsHint =>
      'Chọn ít nhất 1 thói quen để bắt đầu';

  @override
  String get starterHabitHydration2L => 'Uống đủ 2 lít nước';

  @override
  String get starterHabitWalk20 => 'Đi bộ 20 phút';

  @override
  String get starterHabitExercise30 => 'Vận động 30 phút';

  @override
  String get starterHabitSleep23 => 'Ngủ trước 23h';

  @override
  String get starterHabitMeditation10 => 'Thiền 10 phút';

  @override
  String get starterHabitHealthyBreakfast => 'Ăn sáng lành mạnh';

  @override
  String get starterHabitEatVeggies => 'Ăn đủ rau & trái cây';

  @override
  String get starterHabitRead30 => 'Đọc sách 30 phút';

  @override
  String get starterHabitStudy60 => 'Học tập 1 giờ';

  @override
  String get starterHabitReviewNotes => 'Ôn bài / ghi chép 15 phút';

  @override
  String get onboardingReadyCheckHabits =>
      'Thói quen đã sẵn sàng — chạm một thói quen để hoàn thành hôm nay!';

  @override
  String get viewYourPlant => 'Xem cây';

  @override
  String get editHabit => 'Sửa thói quen';

  @override
  String get habitUpdated => 'Đã cập nhật thói quen';

  @override
  String get notificationsTitle => 'Thông báo';

  @override
  String get noNotifications => 'Chưa có thông báo';

  @override
  String get noNotificationsHint => 'Thành tích và nhắc nhở sẽ hiện ở đây';

  @override
  String daysAgo(int count) {
    return '$count ngày trước';
  }

  @override
  String get followers => 'Người theo dõi';

  @override
  String get posts => 'Bài viết';

  @override
  String get viewProfile => 'Xem hồ sơ';

  @override
  String get viewProfileInCommunity => 'Xem hồ sơ của bạn trong cộng đồng';

  @override
  String notifLike(String name) {
    return '$name đã thích bài viết của bạn';
  }

  @override
  String notifComment(String name) {
    return '$name đã bình luận về bài viết của bạn';
  }

  @override
  String notifFollow(String name) {
    return '$name đã bắt đầu theo dõi bạn';
  }

  @override
  String notifNewPost(String name) {
    return '$name vừa đăng bài viết mới';
  }

  @override
  String get notifWarning => 'Cảnh báo từ quản trị viên';

  @override
  String get notifPostEdited => 'Người dùng đã chỉnh sửa bài viết';

  @override
  String get notifWarningCleared => 'Đã gỡ cảnh báo bài viết';

  @override
  String notifDefaultActivity(String name) {
    return 'Hoạt động mới từ $name';
  }

  @override
  String get tapToChangeAvatar => 'Chạm để thay ảnh đại diện';

  @override
  String get avatarUpdated => 'Đã cập nhật ảnh đại diện';

  @override
  String get avatarUpdateFailed => 'Không thể cập nhật ảnh đại diện';

  @override
  String get searchResultsUsers => 'Người dùng';

  @override
  String get searchResultsPosts => 'Bài viết';

  @override
  String get shareAchievement => 'Chia sẻ thành tích';

  @override
  String get achievementShared => 'Đã chia sẻ thành tích lên cộng đồng!';

  @override
  String get noSearchResultsUsers => 'Không tìm thấy người dùng';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get adminUsers => 'Quản lý người dùng';

  @override
  String get adminPosts => 'Quản lý bài viết';

  @override
  String get adminPlants => 'Quản lý cây';

  @override
  String get adminSettings => 'Cài đặt';

  @override
  String get admin => 'Admin';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get users => 'Người dùng';

  @override
  String get postsLabel => 'Bài viết';

  @override
  String get plants => 'Cây';

  @override
  String get overview => 'Tổng quan';

  @override
  String get commentsLabel => 'Bình luận';

  @override
  String get todayLabel => 'hôm nay';

  @override
  String get growthCharts => 'Biểu đồ tăng trưởng';

  @override
  String get dataDistribution => 'Phân bổ dữ liệu';

  @override
  String get userGrowth30Days => 'Tăng trưởng người dùng (30 ngày qua)';

  @override
  String get postGrowth30Days => 'Tăng trưởng bài viết (30 ngày qua)';

  @override
  String get userGrowth7Days => 'Tăng trưởng người dùng (7 ngày qua)';

  @override
  String get postGrowth7Days => 'Tăng trưởng bài viết (7 ngày qua)';

  @override
  String get weekly => 'Tuần';

  @override
  String get monthly => 'Tháng';

  @override
  String get noGrowthData => 'Chưa có dữ liệu tăng trưởng';

  @override
  String get searchByNameEmail => 'Tìm kiếm theo tên hoặc email...';

  @override
  String get noUsersFound => 'Không tìm thấy người dùng';

  @override
  String get noUsersYet => 'Chưa có người dùng';

  @override
  String get active => 'Đang hoạt động';

  @override
  String get inactive => 'Không hoạt động';

  @override
  String get demoteToUser => 'Hạ xuống User';

  @override
  String get promoteToAdmin => 'Lên Admin';

  @override
  String get blockUser => 'Chặn người dùng';

  @override
  String get confirmBlock => 'Xác nhận chặn';

  @override
  String confirmBlockMessage(String name) {
    return 'Bạn có chắc muốn chặn user \"$name\"?';
  }

  @override
  String get block => 'Chặn';

  @override
  String get confirmDelete => 'Xác nhận xóa';

  @override
  String confirmDeleteUserMessage(String name) {
    return 'Bạn có chắc muốn xóa user \"$name\"?';
  }

  @override
  String get userDeleted => 'Đã xóa user';

  @override
  String get selected => 'đã chọn';

  @override
  String get deleteAll => 'Xóa tất cả';

  @override
  String confirmBulkDeleteMessage(int count) {
    return 'Bạn có chắc muốn xóa $count người dùng đã chọn?';
  }

  @override
  String usersDeleted(int count) {
    return 'Đã xóa $count người dùng';
  }

  @override
  String get addUser => 'Thêm user';

  @override
  String get addNewUser => 'Thêm người dùng mới';

  @override
  String get name => 'Tên';

  @override
  String get role => 'Vai trò';

  @override
  String get user => 'User';

  @override
  String get create => 'Tạo';

  @override
  String get pleaseEnterAllFields => 'Vui lòng điền đầy đủ thông tin';

  @override
  String get userCreated => 'Đã tạo người dùng mới';

  @override
  String get roleUpdated => 'Đã cập nhật role';

  @override
  String get blockFeatureInDev => 'Tính năng chặn user đang phát triển';

  @override
  String get searchPostsOrAuthors => 'Tìm kiếm bài viết hoặc tác giả...';

  @override
  String get noPostsFound => 'Không tìm thấy bài viết';

  @override
  String get noPostsYet => 'Chưa có bài viết nào';

  @override
  String get latest => 'Mới nhất';

  @override
  String get oldest => 'Cũ nhất';

  @override
  String get trendingLabel => 'Xu hướng';

  @override
  String get reportViolation => 'Cảnh báo vi phạm';

  @override
  String get viewDetails => 'Xem chi tiết';

  @override
  String confirmDeletePostMessage(String content) {
    return 'Bạn có chắc muốn xóa bài viết này?\n\n\"$content\"';
  }

  @override
  String get warningViolation => 'Cảnh báo vi phạm';

  @override
  String get content => 'Nội dung';

  @override
  String get selectViolationReason => 'Chọn lý do vi phạm:';

  @override
  String get violentContent => 'Nội dung bạo lực hoặc gây shock';

  @override
  String get spamContent => 'Nội dung spam hoặc lừa đảo';

  @override
  String get hateSpeech => 'Ngôn từ thù địch hoặc phân biệt đối xử';

  @override
  String get misinformation => 'Thông tin sai sự thật';

  @override
  String get adultContent => 'Nội dung khiêu dâm';

  @override
  String get copyrightViolation => 'Vi phạm quyền sở hữu trí tuệ';

  @override
  String get otherReason => 'Lý do khác';

  @override
  String get enterReason => 'Nhập lý do';

  @override
  String get sendWarning => 'Gửi cảnh báo';

  @override
  String get warningSent => 'Đã gửi cảnh báo';

  @override
  String get userDetails => 'Chi tiết người dùng';

  @override
  String get noGoalsSet => 'Chưa thiết lập mục tiêu';

  @override
  String get habitCount => 'Số thói quen';

  @override
  String get postCount => 'Số bài viết';

  @override
  String get joinedDate => 'Tham gia';

  @override
  String get noDate => 'Chưa có';

  @override
  String get noPlantsYet => 'Chưa có cây nào';

  @override
  String get exp => 'EXP';

  @override
  String plantOwnerOf(String name) {
    return 'Cây của $name';
  }

  @override
  String get userHasNoPlant => 'Người dùng chưa có cây';

  @override
  String get owner => 'Chủ sở hữu';

  @override
  String get plantType => 'Loại cây';

  @override
  String levelWithExp(int level, int exp) {
    return 'Cấp độ $level • $exp EXP';
  }

  @override
  String get planted => 'Gieo';

  @override
  String get watered => 'Tưới';

  @override
  String get statistics => 'Thống kê';

  @override
  String get streakDays => 'Chuỗi ngày';

  @override
  String get daysCompleted => 'Ngày hoàn thành';

  @override
  String get expHistory => 'Lịch sử nhận điểm';

  @override
  String get expPerHabit => 'Mỗi thói quen hoàn thành = +1 EXP';

  @override
  String get noExpHistory => 'Chưa có lịch sử nhận điểm';

  @override
  String habitsCompletedCount(int count) {
    return '$count thói quen hoàn thành:';
  }

  @override
  String get yesterday => 'Hôm qua';

  @override
  String daysAgoCount(int count) {
    return '$count ngày trước';
  }

  @override
  String get plantTypeBamboo => 'Tre xanh';

  @override
  String get plantTypeCactus => 'Xương rồng';

  @override
  String get plantTypeSunflower => 'Hướng dương';

  @override
  String get plantTypeFlower => 'Hoa';

  @override
  String get changePlantType => 'Đổi cây';

  @override
  String get appInfo => 'Thông tin ứng dụng';

  @override
  String get appLogo => 'Logo ứng dụng';

  @override
  String get tapToChangeLogo => 'Chạm để thay đổi logo';

  @override
  String get changeAppName => 'Đổi tên ứng dụng';

  @override
  String get enterNewAppName => 'Nhập tên mới cho ứng dụng';

  @override
  String get appNameUpdated => 'Đã cập nhật tên ứng dụng';

  @override
  String get logoUpdated => 'Đã cập nhật logo ứng dụng';

  @override
  String get updateFailed => 'Cập nhật thất bại';

  @override
  String get bambooLevel1 => 'Măng tre non';

  @override
  String get bambooLevel2 => 'Măng vươn lên';

  @override
  String get bambooLevel3 => 'Cây tre nhỏ';

  @override
  String get bambooLevel4 => 'Cây tre thẳng';

  @override
  String get bambooLevel5 => 'Cây tre xanh tốt';

  @override
  String get bambooLevel6 => 'Cây tre vững chãi';

  @override
  String get bambooLevel7 => 'Cây tre cao';

  @override
  String get bambooLevel8 => 'Cây tre đơm lá';

  @override
  String get bambooLevel9 => 'Cây tre xanh mướt';

  @override
  String get bambooLevel10 => 'Cây tre sum suê';

  @override
  String get bambooLevel11 => 'Cây tre trưởng thành';

  @override
  String get bambooLevel12 => 'Cây tre tươi tốt';

  @override
  String get bambooLevel13 => 'Cây tre rậm rạp';

  @override
  String get bambooLevel14 => 'Cây tre xanh tốt tuyệt vời';

  @override
  String get bambooLevel15 => 'Cây tre hoàn hảo';

  @override
  String get cactusLevel1 => 'Hạt xương rồng';

  @override
  String get cactusLevel2 => 'Mầm xương rồng';

  @override
  String get cactusLevel3 => 'Xương rồng nhỏ';

  @override
  String get cactusLevel4 => 'Xương rồng non';

  @override
  String get cactusLevel5 => 'Xương rồng lớn dần';

  @override
  String get cactusLevel6 => 'Xương rồng vững';

  @override
  String get cactusLevel7 => 'Xương rồng mập';

  @override
  String get cactusLevel8 => 'Xương rồng cao';

  @override
  String get cactusLevel9 => 'Xương rồng đâm gai';

  @override
  String get cactusLevel10 => 'Xương rồng nở hoa';

  @override
  String get cactusLevel11 => 'Xương rồng hoa đẹp';

  @override
  String get cactusLevel12 => 'Xương rồng kiên cường';

  @override
  String get cactusLevel13 => 'Xương rồng hoàn hảo';

  @override
  String get cactusLevel14 => 'Xương rồng thần thánh';

  @override
  String get cactusLevel15 => 'Xương rồng huyền thoại';

  @override
  String get sakuraLevel1 => 'Hạt anh đào';

  @override
  String get sakuraLevel2 => 'Mầm anh đào';

  @override
  String get sakuraLevel3 => 'Cây anh đào nhỏ';

  @override
  String get sakuraLevel4 => 'Cây anh đào non';

  @override
  String get sakuraLevel5 => 'Cây anh đào lớn';

  @override
  String get sakuraLevel6 => 'Cây anh đào nảy lộc';

  @override
  String get sakuraLevel7 => 'Cây anh đào xanh tốt';

  @override
  String get sakuraLevel8 => 'Cây anh đào nở nụ';

  @override
  String get sakuraLevel9 => 'Cây anh đào nở hoa';

  @override
  String get sakuraLevel10 => 'Cây anh đào hoa rộ';

  @override
  String get sakuraLevel11 => 'Cây anh đào hoa tuyệt đẹp';

  @override
  String get sakuraLevel12 => 'Cây anh đào hoa rực rỡ';

  @override
  String get sakuraLevel13 => 'Cây anh đào hoa đầy cành';

  @override
  String get sakuraLevel14 => 'Cây anh đào hoàn hảo';

  @override
  String get sakuraLevel15 => 'Cây anh đào huyền thoại';

  @override
  String get sunflowerLevel1 => 'Hạt hướng dương';

  @override
  String get sunflowerLevel2 => 'Hạt nảy mầm';

  @override
  String get sunflowerLevel3 => 'Mầm hướng dương';

  @override
  String get sunflowerLevel4 => 'Cây hướng dương nhỏ';

  @override
  String get sunflowerLevel5 => 'Cây hướng dương lớn';

  @override
  String get sunflowerLevel6 => 'Cây hướng dương xanh';

  @override
  String get sunflowerLevel7 => 'Cây hướng dương cao';

  @override
  String get sunflowerLevel8 => 'Cây hướng dương nở nụ';

  @override
  String get sunflowerLevel9 => 'Cây hướng dương nở hoa';

  @override
  String get sunflowerLevel10 => 'Cây hướng dương hoa vàng';

  @override
  String get sunflowerLevel11 => 'Cây hướng dương hoa to';

  @override
  String get sunflowerLevel12 => 'Cây hướng dương rực rỡ';

  @override
  String get sunflowerLevel13 => 'Cây hướng dương hoa đẹp';

  @override
  String get sunflowerLevel14 => 'Cây hướng dương chín hạt';

  @override
  String get sunflowerLevel15 => 'Cây hướng dương vàng óng';

  @override
  String get sunflowerLevel16 => 'Cây hướng dương hoàn hảo';

  @override
  String get habitsInProgress => 'Đang thực hiện';

  @override
  String get habitsCompleted => 'Đã hoàn thành';

  @override
  String get noHabitsCompletedToday =>
      'Chưa có thói quen nào hoàn thành hôm nay 🌱';

  @override
  String get addHabitToStart => 'Hãy thêm thói quen mới để bắt đầu nhé! 🌱';

  @override
  String get addHabitButton => 'Thêm thói quen';

  @override
  String get habitDeletedSuccess => 'Đã xóa thói quen';

  @override
  String get addHabitDailyGoal => 'MỤC TIÊU MỖI NGÀY';

  @override
  String get addHabitCategory => 'DANH MỤC';

  @override
  String get addHabitIcon => 'BIỂU TƯỢNG';

  @override
  String get addHabitReminder => 'NHẮC NHỞ';

  @override
  String get addHabitReminderLabel => 'Thông báo\ncho tôi vào\nlúc';

  @override
  String get addHabitUnitTimes => 'lần';

  @override
  String get addHabitUnitMinutes => 'phút';

  @override
  String get addHabitUnitCalories => 'calo';

  @override
  String get addHabitEnterName => 'Vui lòng nhập tên thói quen';

  @override
  String get addHabitQuote =>
      '\"Kỷ luật là cầu nối giữa mục tiêu và thành tựu.\"';

  @override
  String get addHabitQuoteAuthor => '— Jim Rohn';

  @override
  String get habitProgress => 'Tiến độ';

  @override
  String get allCompletedTitle => 'Xuất sắc! 🎉';

  @override
  String get allCompletedBody => 'Bạn đã hoàn thành tất cả thói quen hôm nay.';

  @override
  String get allCompletedSubtitle => 'Hãy duy trì để cây luôn xanh tốt nhé! 🌱';

  @override
  String get allCompletedContinue => 'Tuyệt vời!';

  @override
  String get habitTrends => 'Xu hướng thói quen';

  @override
  String get popularHabitCategories => 'Phân loại thói quen phổ biến';

  @override
  String get topCompletedHabits => 'Top thói quen được hoàn thành nhiều nhất';

  @override
  String get adminSearchHint => 'Tìm thói quen hoặc người dùng...';

  @override
  String get adminManageHabits => 'Quản lý thói quen người dùng';

  @override
  String get lastWatered => 'Tưới lần cuối';

  @override
  String get noPlants => 'Không có cây nào';

  @override
  String get all => 'Tất cả';

  @override
  String get adminHabits => 'Quản lý thói quen';

  @override
  String get warned => 'Đã cảnh báo';

  @override
  String get pending => 'Chờ duyệt';

  @override
  String get pendingApproval => 'Chờ phê duyệt';

  @override
  String get hasBeenWarned => 'Đã bị cảnh báo';

  @override
  String get approve => 'Duyệt';

  @override
  String get reject => 'Từ chối';

  @override
  String get removeWarning => 'Gỡ cảnh báo';

  @override
  String warnedPostsCount(int count) {
    return '$count bài viết bị cảnh báo';
  }

  @override
  String pendingPostsCount(int count) {
    return '$count bài chờ duyệt';
  }

  @override
  String adminPostsStatus(String posts, int warnedCount, int pendingCount) {
    return '$posts · $warnedCount bị cảnh báo · $pendingCount chờ duyệt';
  }

  @override
  String get dismissWarningHint => 'Nhấn \"Gỡ cảnh báo\" để xét duyệt';

  @override
  String get approveRejectHint =>
      'Phê duyệt hoặc từ chối bài viết đã chỉnh sửa';

  @override
  String get noPendingPosts => 'Không có bài viết chờ duyệt';

  @override
  String get noWarnedPosts => 'Không có bài viết bị cảnh báo';

  @override
  String get rejectPost => 'Từ chối bài viết';

  @override
  String get rejectPostMessage =>
      'Bài viết này sẽ bị xóa và người dùng sẽ nhận được thông báo kèm lý do.';

  @override
  String get rejectReason => 'Lý do từ chối';

  @override
  String get rejectReasonHint => 'Nhập lý do...';

  @override
  String get removeWarningConfirm =>
      'Bài viết này sẽ được hiển thị lại trên cộng đồng. Xác nhận gỡ cảnh báo?';

  @override
  String get postApproved => 'Đã phê duyệt bài viết';

  @override
  String get postRejectedDeleted => 'Đã từ chối và xóa bài viết';

  @override
  String get postWarningRemoved => 'Đã gỡ cảnh báo bài viết';

  @override
  String get levelDesc1 => 'Hành trình bắt đầu từ đây';

  @override
  String get levelDesc2 => 'Hạt đang nảy mầm';

  @override
  String get levelDesc3 => 'Cây đang nảy mầm, tiếp tục nhé!';

  @override
  String get levelDesc4 => 'Cây đang lớn dần mỗi ngày';

  @override
  String get levelDesc5 => 'Cây đang phát triển tốt';

  @override
  String get levelDesc6 => 'Cây đang vững chắc hơn';

  @override
  String get levelDesc7 => 'Cây đang lớn mạnh';

  @override
  String get levelDesc8 => 'Cây đã vững chắc';

  @override
  String get levelDesc9 => 'Cây đang phát triển rất tốt';

  @override
  String get levelDesc10 => 'Cây bắt đầu ra hoa';

  @override
  String get levelDesc11 => 'Cây đang kết trái';

  @override
  String get levelDesc12 => 'Trái đang lớn dần';

  @override
  String get levelDesc13 => 'Trái đã chín';

  @override
  String get levelDesc14 => 'Cây đầy trái chín';

  @override
  String get levelDesc15 => 'Tuyệt vời! Cây đã đạt đỉnh cao 🏆';
}
