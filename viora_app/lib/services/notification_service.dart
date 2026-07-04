import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../navigation/app_navigation.dart';

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
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.startsWith('tab:')) {
          final tab = int.tryParse(payload.split(':').last);
          if (tab != null) AppNavigation.switchToTab(tab);
        }
      },
    );

    // Get locale for channel names
    final prefs = await SharedPreferences.getInstance();
    final locale = prefs.getString('locale') ?? 'vi';
    final isVietnamese = locale == 'vi';

    // Tạo notification channels cho Android
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        AndroidNotificationChannel(
          'viora_daily_1',
          isVietnamese ? 'Nhắc sáng' : 'Morning Reminder',
          description: isVietnamese ? 'Nhắc nhở thói quen buổi sáng' : 'Morning habit reminders',
          importance: Importance.high,
        ),
      );
      await androidPlugin.createNotificationChannel(
        AndroidNotificationChannel(
          'viora_daily_2',
          isVietnamese ? 'Nhắc tối' : 'Evening Reminder',
          description: isVietnamese ? 'Nhắc nhở thói quen buổi tối' : 'Evening habit reminders',
          importance: Importance.high,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'viora_habit_reminder',
          'Nhắc nhở thói quen',
          description: 'Thông báo nhắc nhở từng thói quen theo giờ thiết lập',
          importance: Importance.high,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'viora_test',
          'Test',
          description: 'Test notification',
          importance: Importance.max,
        ),
      );
    }

    _initialized = true;
  }


  static Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final notifGranted = await android.requestNotificationsPermission() ?? false;
      try {
        final exactGranted = await android.requestExactAlarmsPermission() ?? false;
        print('[Notification] requestPermission: notif=$notifGranted, exact=$exactGranted');
      } catch (e) {
        print('[Notification] requestExactAlarmsPermission error: $e');
      }
      return notifGranted;
    }
    return true;
  }

  static Future<bool> canScheduleExact() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      try {
        return await android.canScheduleExactNotifications() ?? false;
      } catch (e) {
        print('[Notification] canScheduleExactNotifications error: $e');
      }
    }
    return false;
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
    
    // Get locale from SharedPreferences
    final locale = prefs.getString('locale') ?? 'vi';
    final isVietnamese = locale == 'vi';

    await _plugin.cancel(1);
    await _plugin.cancel(2);

    if (morningEnabled) {
      await _scheduleDailyNotification(
        id: 1,
        title: isVietnamese ? "🌱 Chào buổi sáng!" : "🌱 Good morning!",
        body: isVietnamese 
            ? "Hôm nay bạn đã sẵn sàng cho thói quen của mình chưa?" 
            : "Are you ready for your habits today?",
        hour: morningHour,
        minute: morningMinute,
        channelName: isVietnamese ? "Nhắc sáng" : "Morning Reminder",
      );
    }

    if (eveningEnabled) {
      await _scheduleDailyNotification(
        id: 2,
        title: isVietnamese ? "🌙 Nhắc nhở buổi tối" : "🌙 Evening Reminder",
        body: isVietnamese 
            ? "Đừng quên hoàn thành thói quen hôm nay nhé! Cây của bạn đang chờ 🌿" 
            : "Don't forget to complete your habits today! Your plant is waiting 🌿",
        hour: eveningHour,
        minute: eveningMinute,
        channelName: isVietnamese ? "Nhắc tối" : "Evening Reminder",
      );
    }
  }

  static Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String channelName,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      final prefs = await SharedPreferences.getInstance();
      final locale = prefs.getString('locale') ?? 'vi';
      final isVietnamese = locale == 'vi';
      final channelDesc = isVietnamese ? 'Nhắc nhở thói quen hàng ngày' : 'Daily habit reminders';

      final canExact = await canScheduleExact();
      final scheduleMode = canExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexact;

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'viora_daily_$id',
            channelName,
            channelDescription: channelDesc,
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
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'tab:0',
      );
      print('[Notification] Scheduled id=$id at $hour:$minute (local TZ) using $scheduleMode');
    } catch (e) {
      print('[Notification] Schedule error id=$id: $e');
    }
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // Gửi thông báo test ngay lập tức và hẹn giờ 10 giây
  static Future<void> sendTestNotification() async {
    try {
      await init();
      final hasPerm = await requestPermission();
      final canExact = await canScheduleExact();
      print('[Notification] Permission status: $hasPerm, canExact: $canExact');

      // Gửi thông báo ngay lập tức để kiểm tra quyền và channel
      await _plugin.show(
        98,
        "🌱 Thông báo test ngay lập tức",
        "Quyền: $hasPerm, ExactAlarm: $canExact. Nếu thấy thông báo này, hệ thống hoạt động tốt!",
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'viora_test',
            'Test',
            channelDescription: 'Test notification',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            presentBadge: true,
          ),
        ),
      );
      print('[Notification] Instant test notification sent');

      // Đồng thời hẹn giờ 10 giây dùng tz.local
      final now10s = tz.TZDateTime.now(tz.local);
      final scheduledTZ = now10s.add(const Duration(seconds: 10));
      final scheduleMode = canExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexact;

      await _plugin.zonedSchedule(
        99,
        "🌱 Thông báo test (sau 10 giây)",
        "Hẹn giờ hoạt động tốt với chế độ: ${scheduleMode.toString().split('.').last}!",
        scheduledTZ,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'viora_test',
            'Test',
            channelDescription: 'Test notification',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            presentBadge: true,
          ),
        ),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('[Notification] 10s test scheduled using local TZ: $scheduledTZ, mode: $scheduleMode');
    } catch (e) {
      print('[Notification] Test error: $e');
    }
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

    // Sync lên server để backend gửi FCM đúng giờ
    final token = prefs.getString("token") ?? "";
    if (token.isNotEmpty) {
      final settings = await getSettings();
      await ApiService.saveNotificationSettings(
        token: token,
        morningEnabled: settings['morning_enabled'],
        morningHour: settings['morning_hour'],
        morningMinute: settings['morning_minute'],
        eveningEnabled: settings['evening_enabled'],
        eveningHour: settings['evening_hour'],
        eveningMinute: settings['evening_minute'],
      );
    }

    await scheduleAll();
  }

  // ===== HABIT-SPECIFIC REMINDERS =====

  /// Lên lịch thông báo nhắc nhở cho một thói quen cụ thể.
  /// [reminderTime] có dạng "H:mm" hoặc "HH:mm", ví dụ "7:0" hoặc "08:30".
  /// [habitId] dùng để tính notification ID: 100 + habitId
  static Future<void> scheduleHabitReminders({
    required int habitId,
    required String habitName,
    required String reminderTime,
  }) async {
    await init();

    final parts = reminderTime.split(':');
    if (parts.length < 2) return;
    final hour = int.tryParse(parts[0]) ?? 8;
    final minute = int.tryParse(parts[1]) ?? 0;

    final prefs = await SharedPreferences.getInstance();
    final locale = prefs.getString('locale') ?? 'vi';
    final isVietnamese = locale == 'vi';

    final canExact = await canScheduleExact();
    final scheduleMode = canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexact;

    final notifId = 100 + habitId;

    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        notifId,
        isVietnamese ? '⏰ Đến giờ rồi!' : '⏰ Time for your habit!',
        isVietnamese
            ? 'Đã đến lúc thực hiện thói quen "$habitName" rồi 💪'
            : 'It\'s time to do your habit "$habitName" 💪',
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'viora_habit_reminder',
            'Nhắc nhở thói quen',
            channelDescription: 'Thông báo nhắc nhở từng thói quen theo giờ thiết lập',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'tab:0',
      );
      print('[HabitReminder] Scheduled habit reminder id=$notifId ($habitName) at $hour:${minute.toString().padLeft(2, "0")} using $scheduleMode');
    } catch (e) {
      print('[HabitReminder] Error scheduling habit reminder id=$notifId: $e');
    }
  }

  /// Hủy thông báo nhắc nhở của một thói quen.
  /// Gọi khi người dùng đạt đủ mục tiêu trong ngày.
  static Future<void> cancelHabitReminders(int habitId) async {
    await init();
    final notifId = 100 + habitId;
    await _plugin.cancel(notifId);
    print('[HabitReminder] Cancelled habit reminder notifId=$notifId (habit=$habitId)');
  }
}
