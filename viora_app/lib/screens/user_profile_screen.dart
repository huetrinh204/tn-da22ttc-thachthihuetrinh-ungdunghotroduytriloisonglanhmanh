import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../widgets/viora_app_bar.dart';
import '../widgets/app_notification_dialog.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';
import '../l10n/app_localizations.dart';
import 'followers_list_screen.dart';
import 'post_detail_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const UserProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? _userProfile;
  List<Post> _userPosts = [];
  bool _isLoading = true;
  bool _isLoadingPosts = false;
  String? _error;
  bool _isFollowing = false;
  bool _isFollowedBack = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadUserPosts();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    // Get current user ID
    final profile = await ApiService.getProfile(token);
    if (profile["user"] != null) {
      _currentUserId = profile["user"]["id"]?.toString();
    }

    // Get user profile
    final response = await ApiService.getUserProfile(token, widget.userId);

    if (!mounted) return;

    if (response["user"] != null) {
      setState(() {
        _userProfile = response["user"];
        _isFollowing = response["user"]["is_following"] ?? false;
        _isFollowedBack = response["user"]["is_followed_back"] ?? false;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = response["message"] ?? "Failed to load profile";
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserPosts() async {
    setState(() {
      _isLoadingPosts = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    final response = await ApiService.getUserPosts(token, widget.userId);

    if (!mounted) return;

    if (response["posts"] != null) {
      final posts = (response["posts"] as List)
          .map((j) => Post.fromJson(j as Map<String, dynamic>))
          .toList();
      setState(() {
        _userPosts = posts;
        _isLoadingPosts = false;
      });
    } else {
      setState(() {
        _isLoadingPosts = false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    if (_currentUserId == null || _currentUserId == widget.userId) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    final wasFollowing = _isFollowing;
    setState(() {
      _isFollowing = !wasFollowing;
      if (_userProfile != null) {
        final currentFollowers = _userProfile!['follower_count'] as int? ?? 0;
        _userProfile!['follower_count'] = wasFollowing 
            ? currentFollowers - 1 
            : currentFollowers + 1;
      }
    });

    final response = wasFollowing
        ? await ApiService.unfollowUser(token, widget.userId)
        : await ApiService.followUser(token, widget.userId);

    if (response["message"] != null && mounted) {
      setState(() {
        _isFollowing = wasFollowing;
        if (_userProfile != null) {
          final currentFollowers = _userProfile!['follower_count'] as int? ?? 0;
          _userProfile!['follower_count'] = wasFollowing 
              ? currentFollowers + 1 
              : currentFollowers - 1;
        }
      });
      if (mounted) {
        AppNotificationDialog.show(
          context,
          type: NotificationType.error,
          title: 'Thao tác thất bại',
          content: response["message"] as String,
        );
      }
    }
  }

  void _navigateToFollowers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FollowersListScreen(
          userId: widget.userId,
          userName: widget.userName,
          type: 'followers',
        ),
      ),
    );
  }

  void _navigateToFollowing() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FollowersListScreen(
          userId: widget.userId,
          userName: widget.userName,
          type: 'following',
        ),
      ),
    );
  }

  void _navigateToPostDetail(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(post: post),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: VioraAppBar(
        title: widget.userName,
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
                        onPressed: _loadUserProfile,
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await _loadUserProfile();
                    await _loadUserPosts();
                  },
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildProfileHeader(l10n),
                        _buildPostsList(l10n),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildProfileHeader(AppLocalizations l10n) {
    final user = _userProfile;
    if (user == null) return const SizedBox.shrink();

    final followersCount = user['follower_count'] as int? ?? 0;
    final followingCount = user['following_count'] as int? ?? 0;
    final postsCount = user['post_count'] as int? ?? 0;
    final bio = user['bio'] as String?;
    final avatar = user['avatar_url'] as String?;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar & Name
          Row(
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: avatar != null
                    ? ClipOval(
                        child: Image.network(
                          avatar,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              widget.userName[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          widget.userName[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              // Name & Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    if (bio != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        bio,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 12),
                    // Stats
                    Row(
                      children: [
                        _buildStatItem(postsCount.toString(), l10n.posts),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: _navigateToFollowers,
                          child: _buildStatItem(
                              followersCount.toString(), l10n.followers),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: _navigateToFollowing,
                          child: _buildStatItem(
                              followingCount.toString(), l10n.following),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Follow button
          if (_currentUserId != null && _currentUserId != widget.userId) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: _toggleFollow,
                style: OutlinedButton.styleFrom(
                  backgroundColor: _isFollowing
                      ? Colors.transparent
                      : AppColors.primary,
                  foregroundColor: _isFollowing
                      ? AppColors.primary
                      : Colors.white,
                  side: BorderSide(
                    color: AppColors.primary,
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isFollowing && _isFollowedBack
                          ? Icons.people
                          : _isFollowing
                              ? Icons.person_remove_outlined
                              : Icons.person_add_outlined,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isFollowing && _isFollowedBack
                          ? l10n.friends
                          : _isFollowing
                              ? l10n.followingUser
                              : l10n.followUser,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: context.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPostsList(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.posts,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoadingPosts)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_userPosts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.article_outlined,
                        size: 48, color: context.textSecondary),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noPosts,
                      style: TextStyle(color: context.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _userPosts.length,
              itemBuilder: (context, index) {
                return _buildPostItem(_userPosts[index], l10n);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPostItem(Post post, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => _navigateToPostDetail(post),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.inputFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: post.isWarned ? AppColors.error : context.infoBoxBorder,
            width: post.isWarned ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content
            if (post.content.isNotEmpty) ...[
              Text(
                post.content,
                style: TextStyle(
                  fontSize: 14,
                  color: context.textPrimary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
            ],
            // Image preview
            if (post.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    post.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: context.inputFill,
                      child: Icon(Icons.broken_image,
                          color: context.textSecondary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            // Stats
            Row(
              children: [
                Icon(Icons.favorite,
                    size: 16,
                    color: post.isLiked ? Colors.red : context.textSecondary),
                const SizedBox(width: 4),
                Text(
                  post.likeCount.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.comment,
                    size: 16, color: context.textSecondary),
                const SizedBox(width: 4),
                Text(
                  post.commentCount.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTime(post.createdAt, l10n),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textSecondary,
                  ),
                ),
              ],
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