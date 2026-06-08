import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../navigation/app_navigation.dart';

class FcmService {
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotif = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    try {
      // Initialize local notifications plugin
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      await _localNotif.initialize(
        const InitializationSettings(android: android, iOS: ios),
        onDidReceiveNotificationResponse: (response) {
          final tab = response.payload;
          if (tab != null) {
            final index = int.tryParse(tab.toString());
            if (index != null) AppNavigation.switchToTab(index);
          } else {
            AppNavigation.openHabits();
          }
        },
      );

      // Create notification channel for FCM
      final androidPlugin = _localNotif
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'viora_fcm',
            'FCM Notifications',
            description: 'Thông báo nhắc nhở từ Viora',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            showBadge: true,
          ),
        );
      }

      // Xin quyền FCM
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Lấy FCM token và gửi lên server
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveFcmToken(token);
      }

      // Lắng nghe token refresh
      _messaging.onTokenRefresh.listen(_saveFcmToken);

      // Xử lý notification khi app đang foreground
      FirebaseMessaging.onMessage.listen((message) {
        _showLocalNotification(message);
      });

      // Xử lý khi user tap notification (app background)
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        final tab = message.data['tab'];
        if (tab != null) {
          final index = int.tryParse(tab.toString());
          if (index != null) AppNavigation.switchToTab(index);
        } else {
          AppNavigation.openHabits();
        }
      });
    } catch (e) {
      print('[FCM] Init error: $e');
    }
  }

  static Future<void> _saveFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString("token") ?? "";
    if (authToken.isEmpty) return;
    await ApiService.saveFcmToken(authToken, token);
    await prefs.setString("fcm_token", token);
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotif.show(
      message.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'viora_fcm',
          'FCM Notifications',
          channelDescription: 'Thông báo nhắc nhở từ Viora',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          showWhen: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
        ),
      ),
    );
  }
}
