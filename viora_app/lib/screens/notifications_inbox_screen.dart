import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification.dart';
import '../services/api_service.dart';
import '../widgets/viora_app_bar.dart';
import '../widgets/app_snackbar.dart';
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

  // Search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Multi-select
  bool _selectMode = false;
  final Set<String> _selectedIds = {};

  List<CommunityNotification> get _filtered {
    if (_searchQuery.isEmpty) return _notifications;
    final q = _searchQuery.toLowerCase();
    return _notifications.where((n) {
      if (n.userName.toLowerCase().contains(q)) return true;
      if (n.content?.toLowerCase().contains(q) ?? false) return true;
      if (n.title?.toLowerCase().contains(q) ?? false) return true;
      if (n.body?.toLowerCase().contains(q) ?? false) return true;
      return false;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _markAllAsRead();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _markAllAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    if (token.isNotEmpty) {
      await ApiService.markAllNotificationsAsRead(token);
      await prefs.setString(
        'notifications_last_seen_at',
        DateTime.now().toUtc().toIso8601String(),
      );
    }
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

  void _toggleSelectMode() {
    setState(() {
      _selectMode = !_selectMode;
      if (!_selectMode) _selectedIds.clear();
    });
  }

  void _toggleSelected(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _selectMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    final ids = _selectedIds.toList();
    await ApiService.deleteNotifications(token, ids);

    setState(() {
      _notifications.removeWhere((n) => ids.contains(n.id));
      _selectedIds.clear();
      _selectMode = false;
    });
  }

  Future<void> _deleteReadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    final readIds =
        _notifications.where((n) => n.isRead).map((n) => n.id).toList();

    if (readIds.isEmpty) {
      if (mounted) AppSnackbar.showError(context, 'Không có thông báo đã đọc');
      return;
    }

    await ApiService.deleteNotifications(token, readIds);

    setState(() {
      _notifications.removeWhere((n) => readIds.contains(n.id));
    });
  }

  void _handleNotificationTap(CommunityNotification notif) async {
    if (_selectMode) {
      _toggleSelected(notif.id);
      return;
    }

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
            title: notif.title,
            body: notif.body,
            emoji: notif.emoji,
            isRead: true,
            createdAt: notif.createdAt,
          );
        }
      });
    }

    if (notif.type == 'warning') {
      if (notif.postId != null) {
        await _navigateToPost(notif.postId!, notif);
      }
    } else if (notif.type == 'follow') {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserProfileScreen(
              userId: notif.userId,
              userName: notif.userName,
            ),
          ),
        );
      }
    } else if (notif.type == 'like' || notif.type == 'comment') {
      if (notif.postId != null) {
        await _navigateToPost(notif.postId!, notif);
      }
    }
  }

  Future<void> _navigateToPost(String postId, CommunityNotification notif) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    try {
      final response = await ApiService.getPostById(token, postId);
      final postJson = response["post"];
      if (postJson != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostDetailScreen(
              post: Post.fromJson(postJson as Map<String, dynamic>),
            ),
          ),
        );
        return;
      }
    } catch (_) {}

    if (!mounted) return;
    AppSnackbar.showError(context, 'Không thể tải bài viết');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(
          post: Post(
            id: postId,
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
        actions: _isLoading || _error != null
            ? null
            : [
                if (_selectMode)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _toggleSelectMode,
                  )
                else ...[
                  IconButton(
                    icon: const Icon(Icons.delete_sweep),
                    tooltip: 'Xóa thông báo đã đọc',
                    onPressed: _deleteReadNotifications,
                  ),
                  IconButton(
                    icon: const Icon(Icons.checklist),
                    tooltip: 'Chọn nhiều',
                    onPressed: _toggleSelectMode,
                  ),
                ],
              ],
      ),
      body: Column(
        children: [
          // Search bar
          if (_notifications.isNotEmpty && _error == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm thông báo...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: context.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),

          // Delete selected banner
          if (_selectMode && _selectedIds.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.error.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Text(
                    'Đã chọn ${_selectedIds.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _deleteSelected,
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    label: const Text(
                      'Xóa',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),

          // Body
          Expanded(
            child: _isLoading
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
                    : _filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("🔔", style: TextStyle(fontSize: 64)),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Không tìm thấy thông báo'
                                      : l10n.noNotifications,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: context.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Thử từ khóa khác'
                                      : l10n.noNotificationsHint,
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
                              itemCount: _filtered.length,
                              itemBuilder: (context, index) =>
                                  _buildNotificationItem(_filtered[index]),
                            ),
                          ),
          ),
        ],
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
      case 'warning':
        icon = Icons.warning;
        iconColor = Colors.orange;
        message = notif.title ?? 'Admin Warning';
        break;
      default:
        icon = Icons.notifications;
        iconColor = context.textSecondary;
        message = notif.content ?? '';
    }

    final isSelected = _selectedIds.contains(notif.id);

    return GestureDetector(
      onTap: () => _handleNotificationTap(notif),
      onLongPress: _selectMode ? null : _toggleSelectMode,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.only(
          left: _selectMode ? 8 : 12,
          top: 12,
          right: 12,
          bottom: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : notif.isRead
                  ? context.cardColor
                  : AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : notif.isRead
                    ? context.infoBoxBorder
                    : AppColors.primary.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox in select mode
            if (_selectMode)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: SizedBox(
                  width: 40,
                  height: 48,
                  child: Center(
                    child: Icon(
                      isSelected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: isSelected ? AppColors.primary : context.textSecondary,
                      size: 22,
                    ),
                  ),
                ),
              ),
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
