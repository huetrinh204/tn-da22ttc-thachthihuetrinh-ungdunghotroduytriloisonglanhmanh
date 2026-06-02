import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/viora_app_bar.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';
import '../l10n/app_localizations.dart';
import 'user_profile_screen.dart';

class FollowersListScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String type; // 'followers' or 'following'

  const FollowersListScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.type,
  });

  @override
  State<FollowersListScreen> createState() => _FollowersListScreenState();
}

class _FollowersListScreenState extends State<FollowersListScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    final response = widget.type == 'followers'
        ? await ApiService.getFollowers(token, widget.userId)
        : await ApiService.getFollowing(token, widget.userId);

    if (!mounted) return;

    if (response["users"] != null) {
      setState(() {
        _users = List<Map<String, dynamic>>.from(response["users"]);
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = response["message"] ?? "Failed to load";
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFollow(String userId, bool isFollowing) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    if (isFollowing) {
      await ApiService.unfollowUser(token, userId);
    } else {
      await ApiService.followUser(token, userId);
    }

    // Reload list
    _loadUsers();
  }

  void _navigateToProfile(String userId, String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(
          userId: userId,
          userName: userName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = widget.type == 'followers'
        ? '${widget.userName} - ${l10n.followers}'
        : '${widget.userName} - ${l10n.following}';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: VioraAppBar(
        title: title,
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
                        onPressed: _loadUsers,
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : _users.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline,
                              size: 48, color: context.textSecondary),
                          const SizedBox(height: 16),
                          Text(
                            widget.type == 'followers'
                                ? 'Chưa có ${l10n.followers.toLowerCase()}'
                                : 'Chưa ${l10n.following.toLowerCase()} ai',
                            style: TextStyle(color: context.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        return _buildUserItem(_users[index]);
                      },
                    ),
    );
  }

  Widget _buildUserItem(Map<String, dynamic> user) {
    final l10n = AppLocalizations.of(context)!;
    final userId = user['id']?.toString() ?? '';
    final userName = user['name'] ?? 'Unknown';
    final userAvatar = user['avatar_url'];
    final isFollowing = user['is_following'] ?? false;
    final isFollowedBack = user['is_followed_back'] ?? false;
    final isCurrentUser = user['is_current_user'] ?? false;
    
    // Determine button text and icon
    final bool isFriend = isFollowing && isFollowedBack;
    final String buttonText = isFriend 
        ? l10n.friends 
        : isFollowing 
            ? l10n.followingUser 
            : l10n.followUser;
    final IconData buttonIcon = isFriend
        ? Icons.people
        : isFollowing
            ? Icons.person_remove_outlined
            : Icons.person_add_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: () => _navigateToProfile(userId, userName),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: userAvatar != null
                  ? ClipOval(
                      child: Image.network(
                        userAvatar,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(
                            userName[0].toUpperCase(),
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
                        userName[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Name
          Expanded(
            child: GestureDetector(
              onTap: () => _navigateToProfile(userId, userName),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                  if (user['bio'] != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      user['bio'],
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Follow button
          if (!isCurrentUser)
            SizedBox(
              height: 32,
              child: OutlinedButton.icon(
                onPressed: () => _toggleFollow(userId, isFollowing),
                style: OutlinedButton.styleFrom(
                  backgroundColor: isFollowing
                      ? Colors.transparent
                      : AppColors.primary,
                  foregroundColor: isFollowing
                      ? AppColors.primary
                      : Colors.white,
                  side: BorderSide(
                    color: AppColors.primary,
                    width: 1,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: Icon(buttonIcon, size: 16),
                label: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
