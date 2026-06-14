import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
import 'post_detail_screen.dart';
import '../models/post.dart';
import '../theme/theme_extensions.dart';
import '../l10n/app_localizations.dart';
import '../constants/app_icons.dart';

class AdminPostsTab extends StatefulWidget {
  const AdminPostsTab({super.key});

  @override
  State<AdminPostsTab> createState() => _AdminPostsTabState();
}

class _AdminPostsTabState extends State<AdminPostsTab> {
  bool _isLoading = true;
  String _token = '';
  List<dynamic> _posts = [];
  final TextEditingController _searchController = TextEditingController();
  String _currentSort = 'latest'; // latest, oldest, trending

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';
    
    try {
      final search = _searchController.text.isNotEmpty ? _searchController.text : null;
      final res = await ApiService.getAdminPosts(_token, search: search, sort: _currentSort);
      if (!mounted) return;
      setState(() {
        _posts = res['posts'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String value) {
    // Debounce search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == value) {
        _loadPosts();
      }
    });
  }

  void _changeSortOrder(String sort) {
    setState(() {
      _currentSort = sort;
    });
    _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        // Search and filter bar
        Container(
          padding: const EdgeInsets.all(16),
          color: context.cardColor,
          child: Column(
            children: [
              // Search bar
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: TextStyle(color: context.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.searchPostsOrAuthors,
                  hintStyle: TextStyle(color: context.textSecondary),
                  prefixIcon: Icon(AppIcons.search, color: context.textSecondary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(AppIcons.close, color: context.textSecondary),
                          onPressed: () {
                            _searchController.clear();
                            _loadPosts();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.infoBoxBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.infoBoxBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.isDark ? Colors.white54 : Colors.grey[400]!),
                  ),
                  filled: true,
                  fillColor: context.isDark ? Colors.grey[850] : Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(l10n.latest, 'latest', l10n),
                    const SizedBox(width: 8),
                    _buildFilterChip(l10n.oldest, 'oldest', l10n),
                    const SizedBox(width: 8),
                    _buildFilterChip(l10n.trendingLabel, 'trending', l10n),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Posts list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _posts.isEmpty
                  ? Center(
                      child: Text(
                        _searchController.text.isNotEmpty
                            ? l10n.noPostsFound
                            : l10n.noPostsYet,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPosts,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _posts.length,
                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: post['user_avatar'] != null
                                        ? NetworkImage(ApiService.resolveImageUrl(post['user_avatar']))
                                        : null,
                                    child: post['user_avatar'] == null
                                        ? Text(post['user_name']?[0]?.toUpperCase() ?? 'U')
                                        : null,
                                  ),
                                  title: Text(post['user_name'] ?? 'Unknown'),
                                  subtitle: Text(post['user_email'] ?? ''),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(AppIcons.flag, color: Colors.orange),
                                        onPressed: () => _reportViolation(post['id'], post['user_id'], post['content']),
                                        tooltip: l10n.reportViolation,
                                      ),
                                      IconButton(
                                        icon: Icon(AppIcons.eye, color: Colors.blue),
                                        onPressed: () => _viewPostDetails(post),
                                        tooltip: l10n.viewDetails,
                                      ),
                                      IconButton(
                                        icon: Icon(AppIcons.delete, color: Colors.red),
                                        onPressed: () => _deletePost(post['id'], post['content']),
                                        tooltip: l10n.deletePost,
                                      ),
                                    ],
                                  ),
                                ),
                                if (post['content'] != null && post['content'].toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      post['content'],
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                if (post['image_url'] != null)
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        ApiService.resolveImageUrl(post['image_url']),
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          height: 200,
                                          color: Colors.grey[300],
                                          child: Icon(AppIcons.image, size: 48, color: Colors.grey[600]),
                                        ),
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Icon(AppIcons.heart, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text('${post['like_count'] ?? 0}'),
                                      const SizedBox(width: 16),
                                      Icon(AppIcons.message, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text('${post['comment_count'] ?? 0}'),
                                      const Spacer(),
                                      Text(
                                        _formatDate(post['created_at']),
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value, AppLocalizations l10n) {
    final isSelected = _currentSort == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected 
              ? (context.isDark ? Colors.blue[300] : Colors.blue[700])
              : context.textPrimary,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _changeSortOrder(value);
        }
      },
      backgroundColor: context.isDark ? Colors.grey[800] : Colors.grey[200],
      selectedColor: context.isDark 
          ? Colors.blue[900]!.withValues(alpha: 0.3)
          : Colors.blue[100],
      checkmarkColor: context.isDark ? Colors.blue[300] : Colors.blue[700],
      side: BorderSide(
        color: isSelected
            ? (context.isDark ? Colors.blue[700]! : Colors.blue[300]!)
            : context.infoBoxBorder,
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    try {
      final dt = DateTime.parse(date.toString());
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (e) {
      return '';
    }
  }

  void _viewPostDetails(Map<String, dynamic> postData) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // Convert post data to Post model
      final post = Post.fromJson({
        'id': postData['id'].toString(),
        'user_id': postData['user_id']?.toString() ?? '0',
        'user_name': postData['user_name'] ?? 'Unknown',
        'user_avatar': postData['user_avatar'],
        'content': postData['content'] ?? '',
        'image_url': postData['image_url'],
        'hashtags': postData['hashtags'] ?? [],
        'like_count': postData['like_count'] ?? 0,
        'comment_count': postData['comment_count'] ?? 0,
        'is_liked': false,
        'created_at': postData['created_at'],
        'challenge_name': null,
        'is_following': false,
        'is_followed_back': false,
        'is_own_post': false,
      });
      
      // Navigate to post detail screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(post: post),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.failed}: $e')),
        );
      }
    }
  }

  Future<void> _deletePost(int postId, String? content) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeletePostMessage(content ?? '')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await ApiService.deletePostAdmin(_token, postId.toString());
      _loadPosts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.postDeleted)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.failed}: $e')),
        );
      }
    }
  }

  Future<void> _reportViolation(int postId, dynamic userId, String? content) async {
    final l10n = AppLocalizations.of(context)!;
    final customReasonController = TextEditingController();
    String? selectedReason;

    final reasons = [
      l10n.violentContent,
      l10n.spamContent,
      l10n.hateSpeech,
      l10n.misinformation,
      l10n.adultContent,
      l10n.copyrightViolation,
      l10n.otherReason,
    ];

    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.warningViolation),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.content}: "${content ?? ''}"',
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 16),
                Text(l10n.selectViolationReason, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...reasons.map((reason) => RadioListTile<String>(
                      title: Text(reason, style: const TextStyle(fontSize: 14)),
                      value: reason,
                      groupValue: selectedReason,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        setState(() => selectedReason = value);
                      },
                    )),
                if (selectedReason == l10n.otherReason) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: customReasonController,
                    decoration: InputDecoration(
                      labelText: l10n.enterReason,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    maxLines: 2,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                String? finalReason;
                if (selectedReason == l10n.otherReason) {
                  finalReason = customReasonController.text.trim();
                } else {
                  finalReason = selectedReason;
                }
                Navigator.pop(context, finalReason);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
              child: Text(l10n.sendWarning),
            ),
          ],
        ),
      ),
    );

    if (result == null || result.isEmpty || !mounted) return;

    try {
      await ApiService.reportPostViolation(_token, postId.toString(), result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.warningSent),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.failed}: $e')),
        );
      }
    }
  }
}
