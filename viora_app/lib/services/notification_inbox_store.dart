import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

/// Notification type enum
enum NotifType { like, comment, follow, achievement, plantLevel, other }

class InboxItem {
  final String id;
  final String title;
  final String body;
  final String emoji;
  final int? targetTab;
  final bool isRead;
  final DateTime createdAt;
  // Extended fields for social notifications
  final NotifType type;
  final String? actorName;
  final String? actorAvatar;
  final String? postId;
  final String? actorId;

  InboxItem({
    required this.id,
    required this.title,
    required this.body,
    this.emoji = '🔔',
    this.targetTab,
    this.isRead = false,
    required this.createdAt,
    this.type = NotifType.other,
    this.actorName,
    this.actorAvatar,
    this.postId,
    this.actorId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'emoji': emoji,
        'target_tab': targetTab,
        'is_read': isRead,
        'created_at': createdAt.toIso8601String(),
        'type': type.name,
        'actor_name': actorName,
        'actor_avatar': actorAvatar,
        'post_id': postId,
        'actor_id': actorId,
      };

  factory InboxItem.fromJson(Map<String, dynamic> json) {
    NotifType parsedType = NotifType.other;
    final typeStr = json['type'] as String? ?? '';
    switch (typeStr) {
      case 'like': parsedType = NotifType.like; break;
      case 'comment': parsedType = NotifType.comment; break;
      case 'follow': parsedType = NotifType.follow; break;
      case 'achievement': parsedType = NotifType.achievement; break;
      case 'plantLevel': parsedType = NotifType.plantLevel; break;
    }

    return InboxItem(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      emoji: json['emoji'] as String? ?? '🔔',
      targetTab: json['target_tab'] as int?,
      isRead: json['is_read'] == true,
      createdAt: DateTime.parse(json['created_at'] as String),
      type: parsedType,
      actorName: json['actor_name'] as String?,
      actorAvatar: json['actor_avatar'] as String?,
      postId: json['post_id'] as String?,
      actorId: json['actor_id'] as String?,
    );
  }

  /// Build InboxItem from backend notification payload
  static InboxItem fromBackendNotif(Map<String, dynamic> n, {bool isRead = false}) {
    final type = n['type'] as String? ?? 'other';
    final actorName = n['actor_name'] as String? ?? 'Someone';
    final postId = n['post_id'] as String?;
    final actorId = n['actor_id'] as String?;
    final actorAvatar = n['actor_avatar'] as String?;
    DateTime createdAt;
    try {
      createdAt = DateTime.parse(n['created_at'].toString()).toLocal();
    } catch (_) {
      createdAt = DateTime.now();
    }

    String title, body, emoji;
    NotifType notifType;

    switch (type) {
      case 'like':
        title = '$actorName liked your post';
        final postContent = (n['post_content'] as String? ?? '').trim();
        body = postContent.isNotEmpty
            ? '"${postContent.length > 60 ? postContent.substring(0, 60) + "..." : postContent}"'
            : 'liked your post.';
        emoji = '❤️';
        notifType = NotifType.like;
        break;
      case 'comment':
        title = '$actorName commented on your post';
        final commentContent = (n['comment_content'] as String? ?? '').trim();
        body = commentContent.isNotEmpty ? '"$commentContent"' : 'commented on your post.';
        emoji = '💬';
        notifType = NotifType.comment;
        break;
      case 'follow':
        title = '$actorName started following you';
        body = 'Tap to view their profile.';
        emoji = '👤';
        notifType = NotifType.follow;
        break;
      default:
        title = 'New notification';
        body = '';
        emoji = '🔔';
        notifType = NotifType.other;
    }

    return InboxItem(
      id: n['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      emoji: emoji,
      targetTab: 2,
      isRead: isRead,
      createdAt: createdAt,
      type: notifType,
      actorName: actorName,
      actorAvatar: actorAvatar,
      postId: postId,
      actorId: actorId,
    );
  }
}

class NotificationInboxStore {
  static const _key = 'notification_inbox_v2'; // bumped version
  static const _readKey = 'notification_read_ids_v2';
  static const _maxItems = 50;

  /// Load notifications: merges backend social notifs + local achievement/plant notifs
  static Future<List<InboxItem>> load({String? token}) async {
    final prefs = await SharedPreferences.getInstance();
    final readIds = Set<String>.from(prefs.getStringList(_readKey) ?? []);

    // --- Local items (achievements, plant level-ups) ---
    final localRaw = prefs.getString(_key);
    List<InboxItem> localItems = [];
    if (localRaw != null && localRaw.isNotEmpty) {
      try {
        final list = jsonDecode(localRaw) as List;
        localItems = list
            .map((e) => InboxItem.fromJson(e as Map<String, dynamic>))
            .where((e) => e.type == NotifType.achievement || e.type == NotifType.plantLevel)
            .toList();
      } catch (_) {}
    }

    // --- Backend social notifications ---
    List<InboxItem> backendItems = [];
    final tkn = token ?? prefs.getString('token') ?? '';
    if (tkn.isNotEmpty) {
      try {
        final res = await ApiService.getCommunityNotifications(tkn);
        final notifs = res['notifications'] as List? ?? [];
        backendItems = notifs
            .map((n) => InboxItem.fromBackendNotif(
                  n as Map<String, dynamic>,
                  isRead: readIds.contains(n['id'] as String? ?? ''),
                ))
            .toList();
      } catch (_) {}
    }

    // --- Merge: backend first, then local achievements ---
    final all = [...backendItems, ...localItems];
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all.take(_maxItems).toList();
  }

  /// Add a local notification (achievement/plant level)
  static Future<void> add({
    required String title,
    required String body,
    String emoji = '🔔',
    int? targetTab,
    NotifType type = NotifType.other,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    List<InboxItem> items = [];
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        items = list.map((e) => InboxItem.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }

    final item = InboxItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      emoji: emoji,
      targetTab: targetTab,
      createdAt: DateTime.now(),
      type: type,
    );
    items.insert(0, item);
    if (items.length > _maxItems) {
      items.removeRange(_maxItems, items.length);
    }
    await prefs.setString(
      _key,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> markRead(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final readIds = Set<String>.from(prefs.getStringList(_readKey) ?? []);
    readIds.add(id);
    await prefs.setStringList(_readKey, readIds.toList());
  }
}
