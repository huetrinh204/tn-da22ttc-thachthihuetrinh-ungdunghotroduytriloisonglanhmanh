import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../widgets/viora_app_bar.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';
import '../l10n/app_localizations.dart';
import 'post_detail_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String? userName;

  const UserProfileScreen({
    super.key,
    required this.userId,
    this.userName,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String? _token;
  Map<String, dynamic>? _userInfo;
  List<Post> _posts = [];
  bool _isLoading = true;
  bool _isFollowLoading = false;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("token") ?? "";

    final profileRes = await ApiService.getUserProfile(_token!, widget.userId);
    final postsRes = await ApiService.getUserPosts(_token!, widget.userId);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (profileRes["user"] != null) {
        _userInfo = profileRes["user"];
        _isFollowing = _userInfo!["is_following"] == true;
      }
      if (postsRes["posts"] != null) {
        final postsData = postsRes["posts"] as List;
        _posts = postsData.map((json) => Post.fromJson(json)).toList();
      }
    });
  }

  Future<void> _toggleFollow() async {
    if (_token == null || _userInfo == null) return;
    setState(() => _isFollowLoading = true);

    final response = _isFollowing
        ? await ApiService.unfollowUser(_token!, widget.userId)
        : await ApiService.followUser(_token!, widget.userId);

    if (!mounted) return;
    setState(() => _isFollowLoading = false);

    if (response["message"] == null ||
        response["message"] == "Followed" ||
        response["message"] == "Unfollowed") {
      setState(() {
        _isFollowing = !_isFollowing;
        if (_userInfo != null) {
          final currentCount = (_userInfo!["follower_count"] as int? ?? 0);
          _userInfo!["follower_count"] =
              _isFollowing ? currentCount + 1 : (currentCount - 1).clamp(0, 999999);
        }
      });
      // Persist in prefs
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList("following_user_ids") ?? [];
      if (_isFollowing) {
        saved.add(widget.userId);
      } else {
        saved.remove(widget.userId);
      }
      await prefs.setStringList("following_user_ids", saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isOwnProfile = _userInfo?["is_own_profile"] == true;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: VioraAppBar(
        title: _userInfo?["name"] ?? widget.userName ?? l10n.profile,
        showBack: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.primary,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildProfileHeader(l10n, isOwnProfile)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Text(
                        l10n.posts,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  if (_posts.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("📝", style: TextStyle(fontSize: 56)),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noPosts,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: context.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _buildPostCard(_posts[i], l10n),
                        childCount: _posts.length,
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(AppLocalizations l10n, bool isOwnProfile) {
    final name = _userInfo?["name"] ?? widget.userName ?? "—";
    final avatarUrl = _userInfo?["avatar_url"] as String?;
    final postCount = _userInfo?["post_count"] as int? ?? 0;
    final followerCount = _userInfo?["follower_count"] as int? ?? 0;
    final followingCount = _userInfo?["following_count"] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar + name
          Row(
            children: [
              // Avatar
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              name[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          name[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              // Name + follow button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!isOwnProfile)
                      SizedBox(
                        width: double.infinity,
                        child: _isFollowLoading
                            ? const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: _toggleFollow,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isFollowing
                                      ? context.inputFill
                                      : AppColors.primary,
                                  foregroundColor: _isFollowing
                                      ? context.textSecondary
                                      : Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                      color: _isFollowing
                                          ? context.infoBoxBorder
                                          : Colors.transparent,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  _isFollowing ? l10n.followingUser : l10n.followUser,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats row
          Row(
            children: [
              _buildStat(l10n.posts, postCount),
              _buildStatDivider(),
              _buildStat(l10n.followers, followerCount),
              _buildStatDivider(),
              _buildStat(l10n.following, followingCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, int value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 32,
      color: context.infoBoxBorder,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildPostCard(Post post, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () async {
        final deleted = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
        );
        if (deleted == true && mounted) _load();
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
            // Time
            Text(
              _formatTime(post.createdAt, l10n),
              style: TextStyle(fontSize: 12, color: context.textSecondary),
            ),
            if (post.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: context.textPrimary,
                  height: 1.5,
                ),
              ),
            ],
            if (post.imageUrl != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  post.imageUrl!,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  post.isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                  color: post.isLiked ? Colors.red : context.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.likeCount}',
                  style: TextStyle(fontSize: 13, color: context.textSecondary),
                ),
                const SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline, size: 16, color: context.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${post.commentCount}',
                  style: TextStyle(fontSize: 13, color: context.textSecondary),
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
