import 'package:shared_preferences/shared_preferences.dart';

/// Cờ hỗ trợ user flow (onboarding, lần check-in đầu, v.v.)
class FlowPrefs {
  static const _profileIncomplete = 'profile_incomplete';
  static const _firstCheckInDone = 'first_checkin_done';
  static const _pendingFirstHabitNudge = 'pending_first_habit_nudge';
  static const _openHabitsAfterOnboarding = 'open_habits_after_onboarding';
  static const _onboardingHabitsReady = 'onboarding_habits_ready';
  static const _streakRecoveryDismissed = 'streak_recovery_dismissed_date';
  static const _postCheckinCoachStep = 'post_checkin_coach_step';

  static Future<bool> isProfileIncomplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_profileIncomplete) ?? false;
  }

  static Future<void> setProfileIncomplete(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_profileIncomplete, value);
  }

  static Future<bool> hasCompletedFirstCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstCheckInDone) ?? false;
  }

  static Future<void> markFirstCheckInDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstCheckInDone, true);
  }

  /// Sau onboarding — nhắc tạo thói quen lần đầu trên Home (một lần).
  static Future<void> markPendingFirstHabitNudge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pendingFirstHabitNudge, true);
  }

  static Future<void> markOpenHabitsAfterOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_openHabitsAfterOnboarding, true);
  }

  static Future<bool> consumeOpenHabitsAfterOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getBool(_openHabitsAfterOnboarding) ?? false;
    if (v) await prefs.setBool(_openHabitsAfterOnboarding, false);
    return v;
  }

  static Future<void> markOnboardingHabitsReady() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingHabitsReady, true);
  }

  static Future<bool> consumeOnboardingHabitsReady() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getBool(_onboardingHabitsReady) ?? false;
    if (v) await prefs.setBool(_onboardingHabitsReady, false);
    return v;
  }

  static Future<bool> consumePendingFirstHabitNudge() async {
    final prefs = await SharedPreferences.getInstance();
    final pending = prefs.getBool(_pendingFirstHabitNudge) ?? false;
    if (pending) {
      await prefs.setBool(_pendingFirstHabitNudge, false);
    }
    return pending;
  }

  static Future<bool> wasStreakRecoveryDismissedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_streakRecoveryDismissed);
    if (saved == null) return false;
    final today = DateTime.now().toIso8601String().split('T').first;
    return saved == today;
  }

  static Future<void> dismissStreakRecoveryForToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T').first;
    await prefs.setString(_streakRecoveryDismissed, today);
  }

  /// Flow hướng dẫn sau khi check-in:
  /// 0 = chưa bật / đã hoàn tất
  /// 1 = bước xem thống kê
  /// 2 = bước xem cây
  static Future<void> startPostCheckinCoachFlow() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_postCheckinCoachStep) ?? 0;
    if (current == 0) {
      await prefs.setInt(_postCheckinCoachStep, 1);
    }
  }

  static Future<int> getPostCheckinCoachStep() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_postCheckinCoachStep) ?? 0;
  }

  static Future<void> setPostCheckinCoachStep(int step) async {
    final prefs = await SharedPreferences.getInstance();
    if (step <= 0) {
      await prefs.remove(_postCheckinCoachStep);
      return;
    }
    await prefs.setInt(_postCheckinCoachStep, step);
  }

  static Future<void> completePostCheckinCoachFlow() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_postCheckinCoachStep);
  }

  /// Đóng coach tạm thời ở phiên hiện tại, không khóa vĩnh viễn.
  static Future<void> dismissPostCheckinCoachFlow() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_postCheckinCoachStep);
  }
}
