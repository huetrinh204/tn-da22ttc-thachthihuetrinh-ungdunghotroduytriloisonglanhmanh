import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/viora_app_bar.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';
import '../l10n/app_localizations.dart';
import '../services/notification_inbox_store.dart';

class NotificationsInboxScreen extends StatefulWidget {
  const NotificationsInboxScreen({super.key});

  @override
  State<NotificationsInboxScreen> createState() =>
      _NotificationsInboxScreenState();
}

class _NotificationsInboxScreenState extends State<NotificationsInboxScreen> {
  List<InboxItem> _items = [];
  bool _loading = true;
  String? _token;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';

    final items = await NotificationInboxStore.load(token: _token);
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  void _openItem(InboxItem item) async {
    await NotificationInboxStore.markRead(item.id);
    setState(() {
      final idx = _items.indexWhere((e) => e.id == item.id);
      if (idx != -1) {
        _items[idx] = InboxItem(
          id: item.id,
          title: item.title,
          body: item.body,
          emoji: item.emoji,
          targetTab: item.targetTab,
          isRead: true,
          createdAt: item.createdAt,
          type: item.type,
          actorName: item.actorName,
          actorAvatar: item.actorAvatar,
          postId: item.postId,
          actorId: item.actorId,
        );
      }
    });
  }

  String _typeEmoji(NotifType type) {
    switch (type) {
      case NotifType.like: return '❤️';
      case NotifType.comment: return '💬';
      case NotifType.follow: return '👤';
      case NotifType.achievement: return '🏆';
      case NotifType.plantLevel: return '🌳';
      case NotifType.other: return '🔔';
    }
  }

  Color _typeColor(NotifType type) {
    switch (type) {
      case NotifType.like: return Colors.red;
      case NotifType.comment: return AppColors.primary;
      case NotifType.follow: return const Color(0xFF9C27B0);
      case NotifType.achievement: return const Color(0xFFFF9800);
      case NotifType.plantLevel: return AppColors.primary;
      case NotifType.other: return Colors.grey;
    }
  }

  String _formatTime(DateTime time, AppLocalizations l10n) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inHours < 1) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return l10n.hoursAgo(diff.inHours);
    return l10n.daysAgo(diff.inDays);
  }

  Widget _buildAvatar(InboxItem item) {
    final avatarUrl = item.actorAvatar;
    final name = item.actorName ?? '';
    final color = _typeColor(item.type);

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          avatarUrl,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildInitialsAvatar(name, color),
        ),
      );
    }

    if (name.isNotEmpty) {
      return _buildInitialsAvatar(name, color);
    }

    // System notifications (achievement, plant)
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(item.emoji, style: const TextStyle(fontSize: 22)),
      ),
    );
  }

  Widget _buildInitialsAvatar(String name, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name[0].toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: VioraAppBar(
        title: l10n.notificationsTitle,
        showBack: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.primary,
              child: _items.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('🔔', style: TextStyle(fontSize: 56)),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.noNotifications,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: context.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 40),
                                  child: Text(
                                    l10n.noNotificationsHint,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: context.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final item = _items[i];
                        final color = _typeColor(item.type);
                        return Material(
                          color: item.isRead
                              ? context.cardColor
                              : color.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => _openItem(item),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Avatar / emoji
                                  Stack(
                                    children: [
                                      _buildAvatar(item),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).scaffoldBackgroundColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            _typeEmoji(item.type),
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  // Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: TextStyle(
                                            fontWeight: item.isRead
                                                ? FontWeight.w500
                                                : FontWeight.w700,
                                            color: context.textPrimary,
                                            fontSize: 14,
                                          ),
                                        ),
                                        if (item.body.isNotEmpty) ...[
                                          const SizedBox(height: 3),
                                          Text(
                                            item.body,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: context.textSecondary,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatTime(item.createdAt, l10n),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: color,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Unread dot
                                  if (!item.isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(top: 4),
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
