import 'dart:convert';
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
          final payload = response.payload;
          if (payload != null) {
            try {
              final data = Map<String, String>.from(jsonDecode(payload));
              AppNavigation.handleFcmDeepLink(data);
            } catch (_) {
              final tab = int.tryParse(payload);
              if (tab != null) {
                AppNavigation.switchToTab(tab);
              } else {
                AppNavigation.openCommunity();
              }
            }
          } else {
            AppNavigation.openCommunity();
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

      // Xử lý khi user tap notification (app background/terminated)
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        if (message.data.isNotEmpty) {
          AppNavigation.handleFcmDeepLink(
            Map<String, String>.from(message.data),
          );
        } else {
          AppNavigation.openCommunity();
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

    final data = message.data;
    final payload = data.isNotEmpty ? jsonEncode(data) : null;

    await _localNotif.show(
      message.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
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
      payload: payload,
    );
  }
}
