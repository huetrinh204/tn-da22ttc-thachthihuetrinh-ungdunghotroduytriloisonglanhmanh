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
    if (raw == null || raw.isEmpty) {
      final lang = prefs.getString('language_code') ?? 'vi';
      final now = DateTime.now();
      final List<InboxItem> defaultItems;
      
      if (lang == 'en') {
        defaultItems = [
          InboxItem(
            id: 'mock_1',
            title: 'Someone liked your post',
            body: 'Nguyễn Văn A and 3 others liked your post "Growing virtual plant with healthy habits...".',
            emoji: '❤️',
            targetTab: 2,
            createdAt: now.subtract(const Duration(minutes: 5)),
          ),
          InboxItem(
            id: 'mock_2',
            title: 'New comment on your post',
            body: 'Lê Thị B commented: "Your plant is growing so fast! I am also trying to complete my habits every day."',
            emoji: '💬',
            targetTab: 2,
            createdAt: now.subtract(const Duration(hours: 1)),
          ),
          InboxItem(
            id: 'mock_3',
            title: 'New post from followed user',
            body: 'Trần Minh C posted a new article: "Today completed 100% of my 2L water drinking goal!"',
            emoji: '👤',
            targetTab: 2,
            createdAt: now.subtract(const Duration(hours: 3)),
          ),
          InboxItem(
            id: 'mock_4',
            title: 'Congratulations on Level Up! 🎉',
            body: 'Your virtual plant has grown to Level 5 (Sapling). Keep up the habits to grow it bigger!',
            emoji: '🌳',
            targetTab: 3,
            createdAt: now.subtract(const Duration(days: 1)),
          ),
          InboxItem(
            id: 'mock_5',
            title: 'Achievement Unlocked 🏆',
            body: 'You unlocked the "First Step" achievement by completing your first habit check-in.',
            emoji: '🏆',
            targetTab: 1,
            createdAt: now.subtract(const Duration(days: 2)),
          ),
        ];
      } else {
        defaultItems = [
          InboxItem(
            id: 'mock_1',
            title: 'Có người thích bài đăng của bạn',
            body: 'Nguyễn Văn A và 3 người khác đã thích bài viết "Nuôi cây ảo cùng thói quen lành mạnh..." của bạn.',
            emoji: '❤️',
            targetTab: 2,
            createdAt: now.subtract(const Duration(minutes: 5)),
          ),
          InboxItem(
            id: 'mock_2',
            title: 'Bình luận mới trên bài viết',
            body: 'Lê Thị B đã bình luận: "Cây của bạn lớn nhanh quá! Mình cũng đang cố gắng hoàn thành thói quen mỗi ngày."',
            emoji: '💬',
            targetTab: 2,
            createdAt: now.subtract(const Duration(hours: 1)),
          ),
          InboxItem(
            id: 'mock_3',
            title: 'Bài viết mới từ người theo dõi',
            body: 'Trần Minh C đã đăng bài viết mới: "Hôm nay hoàn thành 100% mục tiêu uống 2L nước!"',
            emoji: '👤',
            targetTab: 2,
            createdAt: now.subtract(const Duration(hours: 3)),
          ),
          InboxItem(
            id: 'mock_4',
            title: 'Chúc mừng lên cấp! 🎉',
            body: 'Cây ảo của bạn đã phát triển lên Cấp 5 (Cây con). Hãy tiếp tục hoàn thành thói quen để cây lớn hơn nhé!',
            emoji: '🌳',
            targetTab: 3,
            createdAt: now.subtract(const Duration(days: 1)),
          ),
          InboxItem(
            id: 'mock_5',
            title: 'Thành tích đã mở khóa 🏆',
            body: 'Bạn đã mở khóa thành tích "Bước đầu tiên" nhờ hoàn thành check-in thói quen đầu tiên.',
            emoji: '🏆',
            targetTab: 1,
            createdAt: now.subtract(const Duration(days: 2)),
          ),
        ];
      }

      await prefs.setString(
        _key,
        jsonEncode(defaultItems.map((e) => e.toJson()).toList()),
      );
      return defaultItems;
    }
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
