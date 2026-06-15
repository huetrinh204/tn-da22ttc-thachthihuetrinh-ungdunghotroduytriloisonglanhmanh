import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../widgets/viora_app_bar.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../constants/app_icons.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';
import 'notifications_inbox_screen.dart';
import 'user_profile_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  List<Post> _posts = [];
  List<Post> _filteredPosts = [];
  List<Map<String, dynamic>> _searchUsers = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _loadError;
  String? _currentUserId;
  final Set<String> _followingIds = {};
  String? _token;
  int _unreadNotificationsCount = 0;

  List<Post> get _visiblePosts =>
      _isSearching ? _filteredPosts : _posts;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _searchController.addListener(_onSearchChanged);
    _initSession();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUnreadCount();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("token") ?? "";
    final saved = prefs.getStringList("following_user_ids") ?? [];
    _followingIds.addAll(saved);

    final profile = await ApiService.getProfile(_token!);
    if (profile["user"] != null) {
      _currentUserId = profile["user"]["id"]?.toString();
    }

    if (mounted) {
      await _loadPosts();
      _loadUnreadCount();
    }
  }

  Future<void> _loadUnreadCount() async {
    if (_token == null) return;
    final notificationsRes = await ApiService.getNotifications(_token!);
    if (!mounted) return;
    if (notificationsRes["notifications"] != null) {
      final notifs = notificationsRes["notifications"] as List;
      setState(() {
        _unreadNotificationsCount = notifs.where((n) => (n['is_read'] as int? ?? 0) == 0).length;
      });
    }
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _loadPosts();
    }
  }

  void _onSearchChanged() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _filteredPosts = [];
        _searchUsers = [];
      });
      return;
    }

    // Local filter first
    setState(() {
      _isSearching = true;
      _filteredPosts = _posts.where((post) {
        return post.content.toLowerCase().contains(query.toLowerCase()) ||
               post.userName.toLowerCase().contains(query.toLowerCase()) ||
               post.hashtags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
      }).toList();
    });

    // Backend search (debounce by using token check)
    if (query.length >= 2 && (_token ?? '').isNotEmpty) {
      final res = await ApiService.searchCommunity(_token!, query);
      if (!mounted) return;
      final searchPosts = (res['posts'] as List? ?? [])
          .map((j) => Post.fromJson(j as Map<String, dynamic>))
          .toList();
      final searchUsers = (res['users'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .toList();
      setState(() {
        _filteredPosts = searchPosts;
        _searchUsers = searchUsers;
      });
    }
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    final token = _token ?? "";
    if (token.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = "Unauthorized";
        _posts = [];
      });
      return;
    }

    String type = "trending";
    if (_tabController.index == 1) {
      type = "following";
    }

    final response = await ApiService.getPosts(token, type: type);

    if (!mounted) return;

    if (response["message"] != null) {
      setState(() {
        _posts = [];
        _loadError = response["message"] as String;
        _isLoading = false;
      });
      return;
    }

    final postsData = response["posts"] as List? ?? [];
    setState(() {
      _posts = postsData.map((json) => Post.fromJson(json)).toList();
      _isLoading = false;
      _loadError = null;
    });

    if (_isSearching) {
      _onSearchChanged();
    }
  }

  Future<void> _refreshPosts() async {
    await _loadPosts();
  }

  void _navigateToCreatePost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreatePostScreen()),
    );
    if (result == true) {
      _refreshPosts();
    }
  }

  void _navigateToPostDetail(Post post) async {
    final deleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(post: post),
      ),
    );
    if (deleted == true && mounted) {
      _refreshPosts();
    }
  }

  void _navigateToUserProfile(String userId, String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(userId: userId, userName: userName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: VioraAppBar(
        title: l10n.community,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(AppIcons.notifications, size: 24),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsInboxScreen(),
                    ),
                  );
                  // Reload unread count after viewing notifications
                  _loadUnreadCount();
                },
              ),
              if (_unreadNotificationsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Center(
                      child: Text(
                        '$_unreadNotificationsCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(l10n),
          
          // Create post section
          _buildCreatePostSection(l10n),
          
          // Tabs
          _buildTabs(l10n),
          
          // Posts list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : RefreshIndicator(
                    onRefresh: _refreshPosts,
                    color: AppColors.primary,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPostsList(), // Xu hướng
                        _buildPostsList(), // Đang theo dõi
                      ],
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePost,
        backgroundColor: AppColors.primary,
        child: Icon(AppIcons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: context.textPrimary),
        decoration: InputDecoration(
          hintText: l10n.searchCommunity,
          hintStyle: TextStyle(color: context.textSecondary, fontSize: 14),
          prefixIcon: Icon(AppIcons.search, color: context.textSecondary, size: 22),
          filled: true,
          fillColor: context.inputFill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCreatePostSection(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        children: [
          GestureDetector(
            onTap: _navigateToCreatePost,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(AppIcons.edit, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.shareYourProgress,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: AppIcons.image,
            label: l10n.photo,
            onTap: _navigateToCreatePost,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: context.infoBoxBorder),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: context.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: context.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.inputFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: context.textSecondary,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicatorPadding: const EdgeInsets.all(4),
        tabs: [
          Tab(text: l10n.trending),
          Tab(text: l10n.following),
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    final l10n = AppLocalizations.of(context)!;

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(AppIcons.refresh, size: 56, color: context.textSecondary),
              const SizedBox(height: 16),
              Text(
                l10n.loadFeedError,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _loadError!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: context.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadPosts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_isSearching) {
      final hasUsers = _searchUsers.isNotEmpty;
      final hasPosts = _filteredPosts.isNotEmpty;

      if (!hasUsers && !hasPosts) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(AppIcons.search, size: 56, color: context.textSecondary),
              const SizedBox(height: 16),
              Text(
                l10n.noSearchResults,
                style: TextStyle(fontSize: 15, color: context.textSecondary),
              ),
            ],
          ),
        );
      }

      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          // User results
          if (hasUsers) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l10n.searchResultsUsers,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: context.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            ...(_searchUsers.map((u) {
              final uid = u['id']?.toString() ?? '';
              final uname = u['name'] as String? ?? '';
              final uavatar = u['avatar_url'] as String?;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  onTap: () => _navigateToUserProfile(uid, uname),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                    child: uavatar != null
                        ? ClipOval(
                            child: Image.network(
                              uavatar,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(uname.isNotEmpty ? uname[0].toUpperCase() : '?',
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18)),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(uname.isNotEmpty ? uname[0].toUpperCase() : '?',
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                  ),
                  title: Text(uname,
                    style: TextStyle(fontWeight: FontWeight.w600, color: context.textPrimary)),
                  trailing: Icon(AppIcons.chevronRight, color: AppColors.primary),
                ),
              );
            })),
            const SizedBox(height: 8),
          ],
          // Post results
          if (hasPosts) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l10n.searchResultsPosts,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: context.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            ...(_filteredPosts.map((post) => _buildPostCard(post))),
          ],
        ],
      );
    }

    if (_visiblePosts.isEmpty) {
      final isFollowingTab = _tabController.index == 1;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("📝", style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              l10n.noPosts,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFollowingTab ? l10n.followingTabEmpty : l10n.createFirstPost,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: context.textSecondary,
              ),
            ),
            if (!isFollowingTab) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _navigateToCreatePost,
                icon: Icon(AppIcons.add),
                label: Text(l10n.createPost),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: _visiblePosts.length,
      itemBuilder: (context, index) {
        return _buildPostCard(_visiblePosts[index]);
      },
    );
  }

  Widget _buildPostCard(Post post) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar - tappable to view profile
                GestureDetector(
                  onTap: () => _navigateToUserProfile(post.userId, post.userName),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: post.userAvatar != null
                        ? ClipOval(
                            child: Image.network(
                              post.userAvatar!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  post.userName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              post.userName[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name & time - tappable to view profile
                Expanded(
                  child: GestureDetector(
                    onTap: () => _navigateToUserProfile(post.userId, post.userName),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.userName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatTime(post.createdAt, l10n),
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_canFollow(post.userId))
                  _buildFollowButton(post.userId),
                if (post.daysStreak != null && post.daysStreak! > 0) ...[
                  if (_canFollow(post.userId)) const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("🔥", style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          "${post.daysStreak} ${l10n.days}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Content
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                post.content,
                style: TextStyle(
                  fontSize: 14,
                  color: context.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          
          // Image
          if (post.imageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 400,
                ),
                child: Image.network(
                  post.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: context.inputFill,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: AppColors.primary,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: context.inputFill,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(AppIcons.image, 
                              size: 48, 
                              color: context.textSecondary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Không load được ảnh',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
          
          // Hashtags
          if (post.hashtags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: post.hashtags.map((tag) => Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                )).toList(),
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildActionIcon(
                  icon: post.isLiked ? AppIcons.heartFilled : AppIcons.heart,
                  label: l10n.likes(post.likeCount),
                  color: post.isLiked ? AppColors.error : context.textSecondary,
                  onTap: () => _handleLike(post),
                ),
                const SizedBox(width: 20),
                _buildActionIcon(
                  icon: AppIcons.message,
                  label: l10n.comments(post.commentCount),
                  color: context.textSecondary,
                  onTap: () => _navigateToPostDetail(post),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w500,
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

  bool _canFollow(String userId) =>
      _currentUserId != null && userId != _currentUserId;

  bool _isFollowing(String userId) => _followingIds.contains(userId);

  Widget _buildFollowButton(String userId) {
    final l10n = AppLocalizations.of(context)!;
    final following = _isFollowing(userId);

    return TextButton(
      onPressed: () => _toggleFollow(userId),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: following
            ? context.inputFill
            : AppColors.primary.withValues(alpha: 0.1),
      ),
      child: Text(
        following ? l10n.followingUser : l10n.followUser,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: following ? context.textSecondary : AppColors.primary,
        ),
      ),
    );
  }

  Future<void> _toggleFollow(String userId) async {
    final token = _token ?? "";
    if (token.isEmpty) return;

    final wasFollowing = _isFollowing(userId);
    setState(() {
      if (wasFollowing) {
        _followingIds.remove(userId);
      } else {
        _followingIds.add(userId);
      }
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("following_user_ids", _followingIds.toList());

    final response = wasFollowing
        ? await ApiService.unfollowUser(token, userId)
        : await ApiService.followUser(token, userId);

    if (response["message"] != null && mounted) {
      setState(() {
        if (wasFollowing) {
          _followingIds.add(userId);
        } else {
          _followingIds.remove(userId);
        }
      });
      await prefs.setStringList("following_user_ids", _followingIds.toList());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"] as String),
          backgroundColor: AppColors.error,
        ),
      );
    } else if (_tabController.index == 1 && mounted) {
      _loadPosts();
    }
  }

  void _handleLike(Post post) async {
    final token = _token ?? "";
    final wasLiked = post.isLiked;

    setState(() {
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        _posts[index] = post.copyWith(
          isLiked: !wasLiked,
          likeCount: wasLiked ? post.likeCount - 1 : post.likeCount + 1,
        );
      }
    });

    final response = wasLiked
        ? await ApiService.unlikePost(token, post.id)
        : await ApiService.likePost(token, post.id);

    if (response["message"] != null && mounted) {
      setState(() {
        final index = _posts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          _posts[index] = post;
        }
      });
    }
  }
}
