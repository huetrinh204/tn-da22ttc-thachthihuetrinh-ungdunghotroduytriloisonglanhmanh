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
          importance: Importance.max,
          priority: Priority.max,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }
}
