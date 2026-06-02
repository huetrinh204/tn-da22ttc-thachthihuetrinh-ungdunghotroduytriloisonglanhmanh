import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification.dart';
import '../services/api_service.dart';
import '../widgets/viora_app_bar.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';
import '../l10n/app_localizations.dart';
import 'user_profile_screen.dart';
import 'post_detail_screen.dart';
import '../models/post.dart';

class NotificationsInboxScreen extends StatefulWidget {
  const NotificationsInboxScreen({super.key});

  @override
  State<NotificationsInboxScreen> createState() =>
      _NotificationsInboxScreenState();
}

class _NotificationsInboxScreenState extends State<NotificationsInboxScreen> {
  List<CommunityNotification> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    final response = await ApiService.getNotifications(token);

    if (!mounted) return;

    if (response["notifications"] != null) {
      final notifs = (response["notifications"] as List)
          .map((j) => CommunityNotification.fromJson(j as Map<String, dynamic>))
          .toList();
      setState(() {
        _notifications = notifs;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = response["message"] ?? "Failed to load notifications";
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    await ApiService.markNotificationAsRead(token, notificationId);
  }

  void _handleNotificationTap(CommunityNotification notif) async {
    if (!notif.isRead) {
      _markAsRead(notif.id);
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notif.id);
        if (index != -1) {
          _notifications[index] = CommunityNotification(
            id: notif.id,
            type: notif.type,
            userId: notif.userId,
            userName: notif.userName,
            userAvatar: notif.userAvatar,
            postId: notif.postId,
            commentId: notif.commentId,
            content: notif.content,
            isRead: true,
            createdAt: notif.createdAt,
          );
        }
      });
    }

    // Navigate based on notification type
    if (notif.type == 'follow') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserProfileScreen(
            userId: notif.userId,
            userName: notif.userName,
          ),
        ),
      );
    } else if (notif.type == 'like' || notif.type == 'comment') {
      if (notif.postId != null) {
        // Load post and navigate
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString("token") ?? "";
        
        // Fetch post details from API
        final response = await ApiService.getPosts(token, limit: 100);
        final posts = (response["posts"] as List? ?? [])
            .map((j) => Post.fromJson(j as Map<String, dynamic>))
            .toList();
        
        final post = posts.firstWhere(
          (p) => p.id == notif.postId,
          orElse: () => Post(
            id: notif.postId!,
            userId: notif.userId,
            userName: notif.userName,
            userAvatar: notif.userAvatar,
            content: notif.content ?? '',
            imageUrl: null,
            likeCount: 0,
            commentCount: 0,
            isLiked: false,
            hashtags: [],
            createdAt: DateTime.now(),
            daysStreak: null,
          ),
        );
        
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PostDetailScreen(post: post),
            ),
          );
        }
      }
    }
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: context.textSecondary),
                      const SizedBox(height: 16),
                      Text(_error!,
                          style: TextStyle(color: context.textSecondary)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadNotifications,
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : _notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("🔔", style: TextStyle(fontSize: 64)),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noNotifications,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.noNotificationsHint,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      color: AppColors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          return _buildNotificationItem(_notifications[index]);
                        },
                      ),
                    ),
    );
  }

  Widget _buildNotificationItem(CommunityNotification notif) {
    final l10n = AppLocalizations.of(context)!;

    IconData icon;
    Color iconColor;
    String message;

    switch (notif.type) {
      case 'like':
        icon = Icons.favorite;
        iconColor = Colors.red;
        message = l10n.notifLike(notif.userName);
        break;
      case 'comment':
        icon = Icons.comment;
        iconColor = AppColors.primary;
        message = l10n.notifComment(notif.userName);
        break;
      case 'follow':
        icon = Icons.person_add;
        iconColor = AppColors.primary;
        message = l10n.notifFollow(notif.userName);
        break;
      default:
        icon = Icons.notifications;
        iconColor = context.textSecondary;
        message = notif.content ?? '';
    }

    return GestureDetector(
      onTap: () => _handleNotificationTap(notif),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: notif.isRead
              ? context.cardColor
              : AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notif.isRead
                ? context.infoBoxBorder
                : AppColors.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: notif.userAvatar != null
                  ? ClipOval(
                      child: Image.network(
                        notif.userAvatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(
                            notif.userName[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        notif.userName[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                notif.isRead ? FontWeight.normal : FontWeight.w600,
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                      Icon(icon, size: 18, color: iconColor),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(notif.createdAt, l10n),
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
                  if (notif.content != null &&
                      notif.type != 'follow') ...[
                    const SizedBox(height: 6),
                    Text(
                      notif.content!,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inHours < 1) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return l10n.hoursAgo(diff.inHours);
    return l10n.daysAgo(diff.inDays);
  }
}
