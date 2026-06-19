import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/viora_app_bar.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _token;
  
  // Stats
  Map<String, dynamic> _stats = {};
  bool _statsLoading = true;
  
  // Users
  List<Map<String, dynamic>> _users = [];
  bool _usersLoading = true;
  
  // Posts
  List<Map<String, dynamic>> _posts = [];
  bool _postsLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _initToken();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      if (_tabController.index == 0 && _users.isEmpty) {
        _loadUsers();
      } else if (_tabController.index == 1 && _posts.isEmpty) {
        _loadPosts();
      }
    }
  }

  Future<void> _initToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("token") ?? "";
    if (_token!.isNotEmpty) {
      await _loadStats();
      await _loadUsers();
    }
  }

  Future<void> _loadStats() async {
    if (_token == null) return;
    setState(() => _statsLoading = true);
    
    final response = await ApiService.getAdminStats(_token!);
    
    if (!mounted) return;
    setState(() {
      _stats = response;
      _statsLoading = false;
    });
  }

  Future<void> _loadUsers() async {
    if (_token == null) return;
    setState(() => _usersLoading = true);
    
    final response = await ApiService.getAdminUsers(_token!);
    
    if (!mounted) return;
    setState(() {
      _users = (response["users"] as List?)?.cast<Map<String, dynamic>>() ?? [];
      _usersLoading = false;
    });
  }

  Future<void> _loadPosts() async {
    if (_token == null) return;
    setState(() => _postsLoading = true);
    
    final response = await ApiService.getAdminPosts(_token!);
    
    if (!mounted) return;
    setState(() {
      _posts = (response["posts"] as List?)?.cast<Map<String, dynamic>>() ?? [];
      _postsLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: VioraAppBar(
        title: 'Admin Panel',
        showBack: true,
      ),
      body: Column(
        children: [
          _buildStatsDashboard(),
          _buildTabs(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUsersTab(),
                _buildPostsTab(),
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsDashboard() {
    if (_statsLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.dashboard, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                Localizations.localeOf(context).languageCode == 'vi' ? 'Dashboard Thống Kê' : 'Statistics Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(AppLocalizations.of(context)!.users, _stats['totalUsers']?.toString() ?? '0', Icons.people, Colors.blue),
              const SizedBox(width: 12),
              _buildStatCard(AppLocalizations.of(context)!.posts, _stats['totalPosts']?.toString() ?? '0', Icons.article, Colors.orange),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard(AppLocalizations.of(context)!.commentsLabel, _stats['totalComments']?.toString() ?? '0', Icons.comment, Colors.green),
              const SizedBox(width: 12),
              _buildStatCard(Localizations.localeOf(context).languageCode == 'vi' ? 'Mới hôm nay' : 'New Today', '${_stats['todayUsers'] ?? 0} ${Localizations.localeOf(context).languageCode == 'vi' ? 'người dùng' : 'users'}', Icons.today, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color accentColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
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
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicatorPadding: const EdgeInsets.all(4),
        tabs: [
          Tab(text: AppLocalizations.of(context)!.users),
          Tab(text: AppLocalizations.of(context)!.posts),
          Tab(text: AppLocalizations.of(context)!.adminSettings),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    if (_usersLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_users.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noUsersFound,
          style: TextStyle(color: context.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final role = user['role'] ?? 'user';
    final isAdmin = role == 'admin';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAdmin ? AppColors.primary : context.infoBoxBorder,
          width: isAdmin ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user['name'] ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        if (isAdmin) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ADMIN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user['email'] ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: Icon(Icons.more_vert, color: context.textSecondary),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'toggle_role',
                    child: Text(isAdmin ? 'Set as User' : 'Set as Admin'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete User', style: TextStyle(color: Colors.red)),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'toggle_role') {
                    _toggleUserRole(user['id'].toString(), isAdmin ? 'user' : 'admin');
                  } else if (value == 'delete') {
                    _confirmDeleteUser(user['id'].toString(), user['name']);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip('${user['habit_count'] ?? 0} habits', Icons.check_circle),
              const SizedBox(width: 8),
              _buildInfoChip('${user['post_count'] ?? 0} posts', Icons.article),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.inputFill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: context.textSecondary),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleUserRole(String userId, String newRole) async {
    final response = await ApiService.updateUserRole(_token!, userId, newRole);
    
    if (!mounted) return;
    
    if (response['message'] != null && response['message'].toString().contains('success')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Role updated to $newRole'),
          backgroundColor: AppColors.success,
        ),
      );
      await _loadUsers();
      await _loadStats();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']?.toString() ?? 'Failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _confirmDeleteUser(String userId, String userName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete $userName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final response = await ApiService.deleteUser(_token!, userId);
      
      if (!mounted) return;
      
      if (response['message'] != null && response['message'].toString().contains('success')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User deleted'),
            backgroundColor: AppColors.success,
          ),
        );
        await _loadUsers();
        await _loadStats();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']?.toString() ?? 'Failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildPostsTab() {
    if (_postsLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_posts.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noPostsFound,
          style: TextStyle(color: context.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return _buildPostCard(post);
        },
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.infoBoxBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['user_name'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    Text(
                      post['user_email'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDeletePost(post['id'].toString(), post['content']?.toString() ?? ''),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            post['content']?.toString() ?? '',
            style: TextStyle(fontSize: 14, color: context.textPrimary),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoChip('${post['like_count'] ?? 0} likes', Icons.favorite),
              const SizedBox(width: 8),
              _buildInfoChip('${post['comment_count'] ?? 0} comments', Icons.comment),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeletePost(String postId, String content) async {
    final displayContent = content.length > 50 ? '${content.substring(0, 50)}...' : content;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Post'),
        content: Text('Delete this post?\n\n"$displayContent"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final response = await ApiService.deletePostAdmin(_token!, postId);
      
      if (!mounted) return;
      
      if (response['message'] != null && response['message'].toString().contains('success')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post deleted'),
            backgroundColor: AppColors.success,
          ),
        );
        await _loadPosts();
        await _loadStats();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']?.toString() ?? 'Failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildSettingsTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Settings Coming Soon',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Notification scheduling and other settings will be available here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
