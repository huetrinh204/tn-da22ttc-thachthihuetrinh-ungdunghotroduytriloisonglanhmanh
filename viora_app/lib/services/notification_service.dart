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
    
    // Get locale from SharedPreferences
    final locale = prefs.getString('locale') ?? 'vi';
    final isVietnamese = locale == 'vi';

    await _plugin.cancelAll();

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
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'tab:1',
      );
      print('[Notification] Scheduled id=$id at $hour:$minute');
    } catch (e) {
      print('[Notification] Schedule error id=$id: $e');
    }
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // Gửi thông báo test ngay lập tức (không schedule)
  static Future<void> sendTestNotification() async {
    try {
      await init();
      await requestPermission();

      // Test zonedSchedule sau 10 giây
      final now = tz.TZDateTime.now(tz.local);
      final scheduled = now.add(const Duration(seconds: 10));

      await _plugin.zonedSchedule(
        99,
        "🌱 Thông báo test (10s)",
        "zonedSchedule hoạt động! Notification theo giờ sẽ hoạt động.",
        scheduled,
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
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('[Notification] Test scheduled for 10 seconds from now');
    } catch (e) {
      print('[Notification] Test error: $e');
      // Fallback: show ngay
      await _plugin.show(
        99,
        "🌱 Thông báo test",
        "Local notification hoạt động!",
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'viora_test', 'Test',
            importance: Importance.max,
            priority: Priority.max,
          ),
        ),
      );
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
}
