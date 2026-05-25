import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class InboxItem {
  final String id;
  final String title;
  final String body;
  final String emoji;
  final int? targetTab;
  final bool isRead;
  final DateTime createdAt;

  InboxItem({
    required this.id,
    required this.title,
    required this.body,
    this.emoji = '🔔',
    this.targetTab,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'emoji': emoji,
        'target_tab': targetTab,
        'is_read': isRead,
        'created_at': createdAt.toIso8601String(),
      };

  factory InboxItem.fromJson(Map<String, dynamic> json) => InboxItem(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        emoji: json['emoji'] as String? ?? '🔔',
        targetTab: json['target_tab'] as int?,
        isRead: json['is_read'] == true,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class NotificationInboxStore {
  static const _key = 'notification_inbox_v1';
  static const _maxItems = 50;

  static Future<List<InboxItem>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => InboxItem.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return [];
    }
  }

  static Future<void> add({
    required String title,
    required String body,
    String emoji = '🔔',
    int? targetTab,
  }) async {
    final items = await load();
    final item = InboxItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      emoji: emoji,
      targetTab: targetTab,
      createdAt: DateTime.now(),
    );
    items.insert(0, item);
    if (items.length > _maxItems) {
      items.removeRange(_maxItems, items.length);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> markRead(String id) async {
    final items = await load();
    for (var i = 0; i < items.length; i++) {
      if (items[i].id == id) {
        items[i] = InboxItem(
          id: items[i].id,
          title: items[i].title,
          body: items[i].body,
          emoji: items[i].emoji,
          targetTab: items[i].targetTab,
          isRead: true,
          createdAt: items[i].createdAt,
        );
        break;
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }
}
