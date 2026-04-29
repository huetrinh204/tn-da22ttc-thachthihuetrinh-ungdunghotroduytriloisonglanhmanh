import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const String _morningEnabledKey = 'notif_morning_enabled';
  static const String _eveningEnabledKey = 'notif_evening_enabled';
  static const String _morningHourKey = 'notif_morning_hour';
  static const String _morningMinuteKey = 'notif_morning_minute';
  static const String _eveningHourKey = 'notif_evening_hour';
  static const String _eveningMinuteKey = 'notif_evening_minute';

  static Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  static Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    return true;
  }

  // ===== SCHEDULE =====

  static Future<void> scheduleAll() async {
    final prefs = await SharedPreferences.getInstance();

    final morningEnabled = prefs.getBool(_morningEnabledKey) ?? true;
    final eveningEnabled = prefs.getBool(_eveningEnabledKey) ?? true;
    final morningHour = prefs.getInt(_morningHourKey) ?? 8;
    final morningMinute = prefs.getInt(_morningMinuteKey) ?? 0;
    final eveningHour = prefs.getInt(_eveningHourKey) ?? 21;
    final eveningMinute = prefs.getInt(_eveningMinuteKey) ?? 0;

    await _plugin.cancelAll();

    if (morningEnabled) {
      await _scheduleDailyNotification(
        id: 1,
        title: "🌱 Chào buổi sáng!",
        body: "Hôm nay bạn đã sẵn sàng cho thói quen của mình chưa?",
        hour: morningHour,
        minute: morningMinute,
      );
    }

    if (eveningEnabled) {
      await _scheduleDailyNotification(
        id: 2,
        title: "🌙 Nhắc nhở buổi tối",
        body: "Đừng quên hoàn thành thói quen hôm nay nhé! Cây của bạn đang chờ 🌿",
        hour: eveningHour,
        minute: eveningMinute,
      );
    }
  }

  static Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Nếu giờ đã qua hôm nay thì lên lịch cho ngày mai
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'viora_daily_$id',
          id == 1 ? 'Nhắc sáng' : 'Nhắc tối',
          channelDescription: 'Nhắc nhở thói quen hàng ngày',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ===== SETTINGS =====

  static Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'morning_enabled': prefs.getBool(_morningEnabledKey) ?? true,
      'evening_enabled': prefs.getBool(_eveningEnabledKey) ?? true,
      'morning_hour': prefs.getInt(_morningHourKey) ?? 8,
      'morning_minute': prefs.getInt(_morningMinuteKey) ?? 0,
      'evening_hour': prefs.getInt(_eveningHourKey) ?? 21,
      'evening_minute': prefs.getInt(_eveningMinuteKey) ?? 0,
    };
  }

  static Future<void> saveSettings({
    bool? morningEnabled,
    bool? eveningEnabled,
    int? morningHour,
    int? morningMinute,
    int? eveningHour,
    int? eveningMinute,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (morningEnabled != null) await prefs.setBool(_morningEnabledKey, morningEnabled);
    if (eveningEnabled != null) await prefs.setBool(_eveningEnabledKey, eveningEnabled);
    if (morningHour != null) await prefs.setInt(_morningHourKey, morningHour);
    if (morningMinute != null) await prefs.setInt(_morningMinuteKey, morningMinute);
    if (eveningHour != null) await prefs.setInt(_eveningHourKey, eveningHour);
    if (eveningMinute != null) await prefs.setInt(_eveningMinuteKey, eveningMinute);
    await scheduleAll();
  }
}
