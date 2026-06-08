import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'admin_user_detail_screen.dart';
import '../theme/theme_extensions.dart';
import '../l10n/app_localizations.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  bool _isLoading = true;
  String _token = '';
  List<dynamic> _users = [];
  List<dynamic> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();
  
  // Selection mode
  bool _isSelectionMode = false;
  final Set<int> _selectedUserIds = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers({String? search}) async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';
    
    try {
      final res = await ApiService.getAdminUsers(_token, search: search);
      if (!mounted) return;
      setState(() {
        _users = res['users'] ?? [];
        _filteredUsers = _users;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        _filteredUsers = _users;
      } else {
        _filteredUsers = _users.where((user) {
          final name = (user['name'] ?? '').toLowerCase();
          final email = (user['email'] ?? '').toLowerCase();
          final searchLower = value.toLowerCase();
          return name.contains(searchLower) || email.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: _isSelectionMode
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isSelectionMode = false;
                    _selectedUserIds.clear();
                  });
                },
              ),
              title: Text('${_selectedUserIds.length} ${l10n.selected}'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _selectedUserIds.isEmpty ? null : _bulkDeleteUsers,
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: TextStyle(color: context.textPrimary),
              decoration: InputDecoration(
                hintText: l10n.searchByNameEmail,
                hintStyle: TextStyle(color: context.textSecondary),
                prefixIcon: Icon(Icons.search, color: context.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: context.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
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
                fillColor: context.cardColor,
              ),
            ),
          ),
          
          // User list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _loadUsers(),
                    child: _filteredUsers.isEmpty
                        ? Center(
                            child: Text(
                              _searchController.text.isNotEmpty
                                  ? l10n.noUsersFound
                                  : l10n.noUsersYet,
                              style: TextStyle(fontSize: 16, color: context.textSecondary),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index];
                              final isAdmin = user['role'] == 'admin';
                              final userId = user['id'] as int;
                              final isSelected = _selectedUserIds.contains(userId);
                              
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  onTap: () {
                                    if (_isSelectionMode) {
                                      setState(() {
                                        if (isSelected) {
                                          _selectedUserIds.remove(userId);
                                        } else {
                                          _selectedUserIds.add(userId);
                                        }
                                      });
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AdminUserDetailScreen(user: user),
                                        ),
                                      );
                                    }
                                  },
                                  onLongPress: () {
                                    setState(() {
                                      _isSelectionMode = true;
                                      _selectedUserIds.add(userId);
                                    });
                                  },
                                  leading: _isSelectionMode
                                      ? Checkbox(
                                          value: isSelected,
                                          onChanged: (value) {
                                            setState(() {
                                              if (value == true) {
                                                _selectedUserIds.add(userId);
                                              } else {
                                                _selectedUserIds.remove(userId);
                                              }
                                            });
                                          },
                                        )
                                      : CircleAvatar(
                                          backgroundImage: user['avatar_url'] != null
                                              ? NetworkImage(ApiService.resolveImageUrl(user['avatar_url']))
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
                                          color: _getUserActivityStatus(user['created_at'], l10n) == l10n.active 
                                              ? Colors.green 
                                              : Colors.grey,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _getUserActivityStatus(user['created_at'], l10n),
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
                                        '${user['habit_count'] ?? 0} ${l10n.habits.toLowerCase()} • ${user['post_count'] ?? 0} ${l10n.postsLabel.toLowerCase()}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  trailing: _isSelectionMode
                                      ? null
                                      : PopupMenuButton(
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        child: Text(isAdmin ? l10n.demoteToUser : l10n.promoteToAdmin),
                                        onTap: () => _toggleRole(user['id'], isAdmin),
                                      ),
                                      PopupMenuItem(
                                        child: Text(l10n.blockUser),
                                        onTap: () => _blockUser(user['id'], user['name']),
                                      ),
                                      PopupMenuItem(
                                        child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                                        onTap: () => _deleteUser(user['id'], user['name']),
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
      ),
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton.extended(
              onPressed: _showAddUserDialog,
              icon: const Icon(Icons.person_add),
              label: Text(l10n.addUser),
            ),
    );
  }

  Future<void> _showAddUserDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'user';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.addNewUser),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.name,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    labelText: l10n.role,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'user', child: Text(l10n.user)),
                    DropdownMenuItem(value: 'admin', child: Text(l10n.admin)),
                  ],
                  onChanged: (value) {
                    setState(() => selectedRole = value ?? 'user');
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    emailController.text.isEmpty ||
                    passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.pleaseEnterAllFields)),
                  );
                  return;
                }

                try {
                  await ApiService.createUser(
                    _token,
                    nameController.text,
                    emailController.text,
                    passwordController.text,
                    selectedRole,
                  );
                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${l10n.failed}: $e')),
                    );
                  }
                }
              },
              child: Text(l10n.create),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.userCreated)),
        );
      }
    }
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

  String _getUserActivityStatus(dynamic lastActivity, AppLocalizations l10n) {
    if (lastActivity == null) return l10n.inactive;
    
    try {
      final lastDate = DateTime.parse(lastActivity.toString());
      final daysSinceLastActivity = DateTime.now().difference(lastDate).inDays;
      
      return daysSinceLastActivity <= 7 ? l10n.active : l10n.inactive;
    } catch (e) {
      return l10n.inactive;
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

    if (confirm != true || !mounted) return;

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

    if (confirm != true || !mounted) return;

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

  Future<void> _bulkDeleteUsers() async {
    final count = _selectedUserIds.length;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa $count người dùng đã chọn?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await ApiService.bulkDeleteUsers(_token, _selectedUserIds.toList());
      setState(() {
        _isSelectionMode = false;
        _selectedUserIds.clear();
      });
      _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa $count người dùng')),
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
