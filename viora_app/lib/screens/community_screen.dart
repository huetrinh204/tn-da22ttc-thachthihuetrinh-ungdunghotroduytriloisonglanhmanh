import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../widgets/viora_app_bar.dart';
import '../widgets/app_notification_dialog.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../constants/app_icons.dart';
import '../navigation/app_navigation.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';
import 'notifications_inbox_screen.dart';
import 'user_profile_screen.dart';
import '../widgets/report_reason_sheet.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _postsScrollController = ScrollController();
  
  List<Post> _posts = [];
  List<Post> _filteredPosts = [];
  List<Post> _filteredAchievementPosts = [];
  List<Map<String, dynamic>> _searchUsers = [];
  List<Post> _achievementPosts = [];
  bool _isLoading = false;
  bool _isLoadingAchievements = false;
  bool _isSearching = false;
  String? _loadError;
  final Set<String> _reportedPostIds = {};
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
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _searchController.addListener(_onSearchChanged);
    AppNavigation.pendingCommunitySubTab.addListener(_applyPendingSubTab);
    _applyPendingSubTab();
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
    AppNavigation.pendingCommunitySubTab.removeListener(_applyPendingSubTab);
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _postsScrollController.dispose();
    super.dispose();
  }

  void _applyPendingSubTab() {
    final pending = AppNavigation.pendingCommunitySubTab.value;
    if (pending != null) {
      AppNavigation.pendingCommunitySubTab.value = null;
      _tabController.index = pending;
    }
  }

  Future<void> _initSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("token") ?? "";
    final saved = prefs.getStringList("following_user_ids") ?? [];
    _followingIds.addAll(saved);

    // Dùng cached userId nếu có, tránh gọi getProfile mỗi lần
    final cachedUserId = prefs.getString("cached_user_id");
    if (cachedUserId != null && cachedUserId.isNotEmpty) {
      _currentUserId = cachedUserId;
      if (mounted) {
        await _loadPosts();
        _loadUnreadCount();
        _loadAchievementPosts();
      }
    } else {
      final profile = await ApiService.getProfile(_token!);
      if (profile["user"] != null) {
        _currentUserId = profile["user"]["id"]?.toString();
        if (_currentUserId != null) {
          await prefs.setString("cached_user_id", _currentUserId!);
        }
      }
      if (mounted) {
        await _loadPosts();
        _loadUnreadCount();
        _loadAchievementPosts();
      }
    }
  }

  Future<void> _loadUnreadCount() async {
    if (_token == null) return;
    final prefs = await SharedPreferences.getInstance();
    final lastSeenStr = prefs.getString('notifications_last_seen_at');
    final lastSeen = lastSeenStr != null ? DateTime.tryParse(lastSeenStr) : null;

    final notificationsRes = await ApiService.getNotifications(_token!);
    if (!mounted) return;
    if (notificationsRes["notifications"] != null) {
      final notifs = notificationsRes["notifications"] as List;
      setState(() {
        if (lastSeen == null) {
          _unreadNotificationsCount = notifs.length;
        } else {
          _unreadNotificationsCount = notifs.where((n) {
            final createdAt = DateTime.tryParse(n['created_at']?.toString() ?? '');
            if (createdAt == null) return false;
            return createdAt.isAfter(lastSeen);
          }).length;
        }
      });
    }
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      if (_tabController.index == 2) {
        _loadAchievementPosts();
      } else {
        _loadPosts();
      }
    }
  }

  void _onSearchChanged() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _filteredPosts = [];
        _filteredAchievementPosts = [];
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
      _filteredAchievementPosts = _achievementPosts.where((post) {
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
        _filteredAchievementPosts = searchPosts;
        _searchUsers = searchUsers;
      });
    }
  }

  Future<void> _loadPosts() async {
    // Nếu đã có data, chỉ reload ngầm (không show loading spinner)
    final isFirstLoad = _posts.isEmpty;
    if (isFirstLoad) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    } else {
      _loadError = null;
    }

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

    String type = "latest";
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

  Future<void> _loadAchievementPosts() async {
    final isFirstLoad = _achievementPosts.isEmpty;
    if (isFirstLoad) {
      if (!mounted) return;
      setState(() => _isLoadingAchievements = true);
    }

    final token = _token ?? "";
    if (token.isEmpty) return;

    final response = await ApiService.getPosts(token, type: "achievements");
    if (!mounted) return;

    final postsData = response["posts"] as List? ?? [];
    setState(() {
      _achievementPosts = postsData.map((json) => Post.fromJson(json)).toList();
      _isLoadingAchievements = false;
    });

    if (_isSearching) {
      _onSearchChanged();
    }
  }

  void _navigateToCreatePost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreatePostScreen()),
    );
    if (result == true) {
      await _refreshPosts();
      _scrollToTop();
      // Navigate to the newly created post (first post after refresh)
      if (mounted && _posts.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PostDetailScreen(post: _posts.first),
            ),
          );
        }
      }
    }
  }

  void _scrollToTop() {
    if (_postsScrollController.hasClients) {
      _postsScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _editPost(Post post) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatePostScreen(existingPost: post),
      ),
    );
    if (result == true) {
      _refreshPosts();
    }
  }

  Future<void> _deletePost(Post post) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa bài viết'),
        content: const Text('Bạn có chắc muốn xóa bài viết này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    final res = await ApiService.deletePost(token, post.id);

    if (!mounted) return;
    if (res["message"] == null || res["message"] == "Deleted") {
      _refreshPosts();
    } else {
      if (mounted) {
        AppNotificationDialog.show(
          context,
          type: NotificationType.error,
          title: 'Xóa thất bại',
          content: res["message"] as String? ?? 'Xóa thất bại',
        );
      }
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
          
          // Tabs
          _buildTabs(l10n),
          
          // Posts list
          Expanded(
            child: _isLoading && _posts.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : RefreshIndicator(
                    onRefresh: () async {
                      if (_tabController.index == 2) {
                        await _loadAchievementPosts();
                      } else {
                        await _refreshPosts();
                      }
                    },
                    color: AppColors.primary,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPostsList(), // Xu hướng
                        _buildPostsList(), // Đang theo dõi
                        _buildAchievementPostsList(), // Thành tích
                      ],
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreatePost,
        backgroundColor: AppColors.primary,
        elevation: 4,
        icon: Icon(AppIcons.add, color: Colors.white),
        label: Text(
          l10n.createPost, // "Thêm bài đăng"
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
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
          Tab(text: l10n.latest),
          Tab(text: l10n.following),
          Tab(text: l10n.achievementsTitle),
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

    if (_visiblePosts.isEmpty && !_isLoading) {
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
      controller: _postsScrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: _visiblePosts.length,
      itemBuilder: (context, index) {
        return _buildPostCard(_visiblePosts[index]);
      },
    );
  }

  Widget _buildAchievementPostsList() {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoadingAchievements) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_isSearching) {
      final hasUsers = _searchUsers.isNotEmpty;
      final hasPosts = _filteredAchievementPosts.isNotEmpty;

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
            ...(_filteredAchievementPosts.map((post) => _buildPostCard(post))),
          ],
        ],
      );
    }

    if (_achievementPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("🏆", style: TextStyle(fontSize: 64)),
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
              l10n.achievementsTitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: context.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: _achievementPosts.length,
      itemBuilder: (context, index) {
        return _buildPostCard(_achievementPosts[index]);
      },
    );
  }

  Widget _buildPostCard(Post post) {
    final l10n = AppLocalizations.of(context)!;
    
    return Stack(
      children: [
        Container(
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
                if (post.isOwnPost)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, size: 20, color: context.textSecondary),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') _editPost(post);
                      if (value == 'delete') _deletePost(post);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Chỉnh sửa'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Xóa', style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  _buildFollowButton(post),
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
                        Icon(AppIcons.streak, color: AppColors.warning, size: 14),
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
                const Spacer(),
                if (!post.isOwnPost)
                  InkWell(
                    onTap: () => _handleReport(post),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Icon(
                        _reportedPostIds.contains(post.id) ? Icons.flag : Icons.flag_outlined,
                        size: 20,
                        color: _reportedPostIds.contains(post.id)
                            ? AppColors.error
                            : context.textSecondary.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  ],
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

  void _updatePostsFollowing(String userId, bool isFollowing) {
    for (int i = 0; i < _posts.length; i++) {
      if (_posts[i].userId == userId) {
        _posts[i] = _posts[i].copyWith(isFollowing: isFollowing);
      }
    }
    for (int i = 0; i < _achievementPosts.length; i++) {
      if (_achievementPosts[i].userId == userId) {
        _achievementPosts[i] = _achievementPosts[i].copyWith(isFollowing: isFollowing);
      }
    }
    for (int i = 0; i < _filteredPosts.length; i++) {
      if (_filteredPosts[i].userId == userId) {
        _filteredPosts[i] = _filteredPosts[i].copyWith(isFollowing: isFollowing);
      }
    }
  }

  bool _canFollow(String userId) =>
      _currentUserId != null && userId != _currentUserId;

  bool _isFollowing(String userId) => _followingIds.contains(userId);

  Widget _buildFollowButton(Post post) {
    final l10n = AppLocalizations.of(context)!;
    final following = post.isFollowing;
    final isFriend = following && post.isFollowedBack;

    return TextButton(
      onPressed: () => _toggleFollow(post.userId),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: isFriend
            ? AppColors.success.withValues(alpha: 0.1)
            : following
                ? Colors.grey.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.1),
      ),
      child: Text(
        isFriend
            ? l10n.friends
            : following
                ? l10n.followingUser
                : l10n.followUser,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isFriend
              ? AppColors.success
              : following
                  ? Colors.grey.shade600
                  : AppColors.primary,
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
      _updatePostsFollowing(userId, !wasFollowing);
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
        _updatePostsFollowing(userId, wasFollowing);
      });
      await prefs.setStringList("following_user_ids", _followingIds.toList());
      if (mounted) {
        AppNotificationDialog.show(
          context,
          type: NotificationType.error,
          title: 'Thao tác thất bại',
          content: response["message"] as String,
        );
      }
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

  void _handleReport(Post post) async {
    final token = await SharedPreferences.getInstance().then((p) => p.getString('token') ?? '');

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReportReasonSheet(
        onReport: (reason, description) async {
          Navigator.pop(context);
          final res = await ApiService.reportPost(token, post.id, reason, description: description);
          if (!mounted) return;
          if (res['message'] != null && (res['message'] as String).contains('success')) {
            setState(() => _reportedPostIds.add(post.id));
            if (!mounted) return;
            AppNotificationDialog.show(
              context,
              type: NotificationType.success,
              title: 'Cảm ơn bạn đã báo cáo!',
              content: 'Admin sẽ xem xét và xử lý sớm nhất.',
            );
          } else {
            final msg = res['message'] as String? ?? 'Gửi báo cáo thất bại';
            if (!mounted) return;
            final isDuplicate = msg.contains('đã báo cáo');
            AppNotificationDialog.show(
              context,
              type: isDuplicate ? NotificationType.warning : NotificationType.error,
              title: isDuplicate ? 'Đã báo cáo trước đó' : 'Gửi báo cáo thất bại',
              content: isDuplicate ? 'Bài viết này đã được bạn báo cáo trước đó và đang chờ admin xem xét.' : msg,
            );
          }
        },
      ),
    );
  }
}
