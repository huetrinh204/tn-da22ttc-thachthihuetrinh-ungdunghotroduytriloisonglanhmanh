import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
import 'post_detail_screen.dart';
import '../models/post.dart';

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
    return Column(
      children: [
        // Search and filter bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Column(
            children: [
              // Search bar
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm bài viết hoặc tác giả...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _loadPosts();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Mới nhất', 'latest'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Cũ nhất', 'oldest'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Xu hướng', 'trending'),
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
                            ? 'Không tìm thấy bài viết'
                            : 'Chưa có bài viết nào',
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
                                        icon: const Icon(Icons.flag, color: Colors.orange),
                                        onPressed: () => _reportViolation(post['id'], post['user_id'], post['content']),
                                        tooltip: 'Cảnh báo vi phạm',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.visibility, color: Colors.blue),
                                        onPressed: () => _viewPostDetails(post),
                                        tooltip: 'Xem chi tiết',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deletePost(post['id'], post['content']),
                                        tooltip: 'Xóa bài viết',
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
                                          child: const Icon(Icons.broken_image),
                                        ),
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Icon(Icons.favorite, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text('${post['like_count'] ?? 0}'),
                                      const SizedBox(width: 16),
                                      Icon(Icons.comment, size: 16, color: Colors.grey[600]),
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

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _currentSort == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _changeSortOrder(value);
        }
      },
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue[700],
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
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _deletePost(int postId, String? content) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa bài viết này?\n\n"${content ?? ''}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
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
          const SnackBar(content: Text('Đã xóa bài viết')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _reportViolation(int postId, dynamic userId, String? content) async {
    final customReasonController = TextEditingController();
    String? selectedReason;

    final reasons = [
      'Nội dung bạo lực hoặc gây shock',
      'Nội dung spam hoặc lừa đảo',
      'Ngôn từ thù địch hoặc phân biệt đối xử',
      'Thông tin sai sự thật',
      'Nội dung khiêu dâm',
      'Vi phạm quyền sở hữu trí tuệ',
      'Lý do khác',
    ];

    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Cảnh báo vi phạm'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nội dung: "${content ?? ''}"',
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 16),
                const Text('Chọn lý do vi phạm:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                if (selectedReason == 'Lý do khác') ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: customReasonController,
                    decoration: const InputDecoration(
                      labelText: 'Nhập lý do',
                      border: OutlineInputBorder(),
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
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                String? finalReason;
                if (selectedReason == 'Lý do khác') {
                  finalReason = customReasonController.text.trim();
                } else {
                  finalReason = selectedReason;
                }
                Navigator.pop(context, finalReason);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
              child: const Text('Gửi cảnh báo'),
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
          const SnackBar(
            content: Text('Đã gửi cảnh báo đến người dùng (in-app + email)'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }
}
