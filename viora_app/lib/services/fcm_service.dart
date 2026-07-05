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
            if (payload.startsWith('tab:')) {
              final tab = int.tryParse(payload.split(':').last);
              if (tab != null) {
                AppNavigation.switchToTab(tab);
                return;
              }
            }
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

      // Lấy FCM token và gửi lên server (có retry nếu lần đầu null)
      await _fetchAndSaveToken();

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

  /// Retry tới 4 lần (1s → 2s → 3s → nghỉ) để lấy token
  static Future<void> _fetchAndSaveToken() async {
    final delays = [1000, 2000, 3000];
    for (var attempt = 0; attempt <= delays.length; attempt++) {
      try {
        final token = await _messaging.getToken();
        if (token != null && token.isNotEmpty) {
          await _saveFcmToken(token);
          print('[FCM] Token saved on attempt ${attempt + 1}');
          return;
        }
      } catch (e) {
        print('[FCM] getToken attempt ${attempt + 1} failed: $e');
      }
      if (attempt < delays.length) {
        await Future.delayed(Duration(milliseconds: delays[attempt]));
      }
    }
    print('[FCM] Failed to get token after ${delays.length + 1} attempts');
  }

  /// Gọi lại sau login/register để đảm bảo token được lưu khi có auth token
  static Future<void> resyncToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await _saveFcmToken(token);
        print('[FCM] Token synced after login');
      } else {
        // Nếu vẫn null, retry với _fetchAndSaveToken
        print('[FCM] Token null on resync, retrying...');
        await _fetchAndSaveToken();
      }
    } catch (e) {
      print('[FCM] Resync error: $e');
      await _fetchAndSaveToken();
    }
  }

  static Future<void> _saveFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString("token") ?? "";
    if (authToken.isEmpty) return;
    await ApiService.saveFcmToken(authToken, token);
    await prefs.setString("fcm_token", token);
  }

  /// Lấy userId từ JWT token (không cần gọi API)
  static Future<String?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(payload);
      return json['id']?.toString();
    } catch (_) {
      return null;
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    // Chỉ hiển thị thông báo của user hiện tại
    final data = message.data;
    final notifUserId = data['userId'];
    if (notifUserId != null) {
      final currentUserId = await _getCurrentUserId();
      if (currentUserId != null && notifUserId != currentUserId) {
        print('[FCM] Skip notification for userId=$notifUserId (current=$currentUserId)');
        return;
      }
    }

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
