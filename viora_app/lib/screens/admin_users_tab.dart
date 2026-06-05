import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  bool _isLoading = true;
  String _token = '';
  List<dynamic> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';
    
    try {
      final res = await ApiService.getAdminUsers(_token);
      if (!mounted) return;
      setState(() {
        _users = res['users'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          final isAdmin = user['role'] == 'admin';
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: user['avatar_url'] != null
                    ? NetworkImage(user['avatar_url'])
                    : null,
                child: user['avatar_url'] == null
                    ? Text(user['name']?[0]?.toUpperCase() ?? 'U')
                    : null,
              ),
              title: Row(
                children: [
                  Expanded(child: Text(user['name'] ?? 'Unknown')),
                  // Activity status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getUserActivityStatus(user['updated_at']) == 'Đang hoạt động' 
                          ? Colors.green 
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getUserActivityStatus(user['updated_at']),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isAdmin)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ADMIN',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['email'] ?? ''),
                  const SizedBox(height: 4),
                  Text(
                    '${user['habit_count'] ?? 0} thói quen • ${user['post_count'] ?? 0} bài viết',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Text(isAdmin ? 'Hạ xuống User' : 'Lên Admin'),
                    onTap: () => _toggleRole(user['id'], isAdmin),
                  ),
                  PopupMenuItem(
                    child: const Text('Chặn người dùng'),
                    onTap: () => _blockUser(user['id'], user['name']),
                  ),
                  PopupMenuItem(
                    child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                    onTap: () => _deleteUser(user['id'], user['name']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _toggleRole(int userId, bool isCurrentlyAdmin) async {
    try {
      await ApiService.updateUserRole(
        _token,
        userId.toString(),
        isCurrentlyAdmin ? 'user' : 'admin',
      );
      _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật role')),
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

  String _getUserActivityStatus(dynamic lastActivity) {
    if (lastActivity == null) return 'Không hoạt động';
    
    try {
      final lastDate = DateTime.parse(lastActivity.toString());
      final daysSinceLastActivity = DateTime.now().difference(lastDate).inDays;
      
      return daysSinceLastActivity <= 7 ? 'Đang hoạt động' : 'Không hoạt động';
    } catch (e) {
      return 'Không hoạt động';
    }
  }

  Future<void> _blockUser(int userId, String? userName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận chặn'),
        content: Text('Bạn có chắc muốn chặn user "$userName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Chặn'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // TODO: Implement block user API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng chặn user đang phát triển')),
    );
  }

  Future<void> _deleteUser(int userId, String? userName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa user "$userName"?'),
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

    if (confirm != true) return;

    try {
      await ApiService.deleteUser(_token, userId.toString());
      _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa user')),
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
