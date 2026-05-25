import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import 'flow_prefs.dart';
import 'notification_service.dart';

/// Quyết định có cần hiển thị onboarding sau đăng nhập/đăng ký hay không.
class OnboardingGate {
  static const onboardingDoneKey = 'onboarding_done';
  static const onboardingUserIdKey = 'onboarding_user_id';

  /// Gọi khi tạo tài khoản mới (đăng ký thủ công hoặc Google lần đầu).
  static Future<void> prepareNewAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardingDoneKey, false);
    await prefs.remove(onboardingUserIdKey);
    await FlowPrefs.setProfileIncomplete(true);
  }

  static Future<void> markComplete(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardingDoneKey, true);
    await prefs.setString(onboardingUserIdKey, userId);
    await FlowPrefs.setProfileIncomplete(false);
    try {
      await NotificationService.scheduleAll();
    } catch (_) {}
  }

  static bool isProfileComplete(Map<String, dynamic> user) {
    final gender = user['gender'];
    if (gender == null || gender.toString().trim().isEmpty) return false;

    final goals = user['goals'];
    if (goals == null) return false;
    if (goals is List) return goals.isNotEmpty;
    if (goals is String) {
      final s = goals.trim();
      if (s.isEmpty || s == '[]' || s == 'null') return false;
      try {
        final parsed = jsonDecode(s);
        if (parsed is List) return parsed.isNotEmpty;
      } catch (_) {
        return true;
      }
    }
    return true;
  }

  /// `true` = cần vào [OnboardingScreen].
  static Future<bool> needsOnboarding(
    String token, {
    bool isNewUser = false,
  }) async {
    if (isNewUser) {
      await prepareNewAccount();
      return true;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final profile = await ApiService.getProfile(token);
      final rawUser = profile['user'];
      if (rawUser is! Map) return true;
      final user = Map<String, dynamic>.from(rawUser);

      final userId = user['id']?.toString() ?? '';
      final savedUserId = prefs.getString(onboardingUserIdKey);
      final localDone = prefs.getBool(onboardingDoneKey) ?? false;

      if (localDone && savedUserId == userId) {
        try {
          await NotificationService.scheduleAll();
        } catch (_) {}
        return false;
      }

      if (isProfileComplete(user)) {
        await markComplete(userId);
        return false;
      }

      await prefs.setBool(onboardingDoneKey, false);
      return true;
    } catch (_) {
      // Không chắc trạng thái → ưu tiên onboarding (an toàn cho tài khoản mới).
      return true;
    }
  }
}
