import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'admin_user_detail_screen.dart';
import '../widgets/app_notification_dialog.dart';
import '../widgets/admin_card_skeleton.dart';
import '../widgets/admin_state_widgets.dart';
import '../theme/theme_extensions.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../l10n/app_localizations.dart';
import '../constants/app_icons.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
  final FocusNode _searchFocus = FocusNode();
  
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
    _searchFocus.dispose();
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
    final isDark = context.isDark;
    
    return Scaffold(
      appBar: _isSelectionMode
          ? _buildSelectionAppBar(l10n)
          : null,
      body: Column(
        children: [
          _buildSearchBar(l10n, isDark),
          Expanded(child: _buildUserList(l10n, isDark)),
        ],
      ),
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton.extended(
              onPressed: _showAddUserDialog,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
              icon: const Icon(Icons.person_add_rounded, size: 20),
              label: Text(l10n.addUser, style: AppTypography.captionBold),
            ),
    );
  }

  PreferredSizeWidget _buildSelectionAppBar(AppLocalizations l10n) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close_rounded),
        onPressed: () {
          setState(() {
            _isSelectionMode = false;
            _selectedUserIds.clear();
          });
        },
      ),
      title: Text(
        '${_selectedUserIds.length} ${l10n.selected}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      actions: [
        if (_selectedUserIds.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: l10n.delete,
            onPressed: _bulkDeleteUsers,
          ),
      ],
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n, bool isDark) {
    return Container(
      margin: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.18),
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        onChanged: _onSearchChanged,
        style: TextStyle(fontSize: 14, color: context.textPrimary),
        decoration: InputDecoration(
          hintText: l10n.searchByNameEmail,
          hintStyle: TextStyle(fontSize: 14, color: context.textSecondary.withValues(alpha: 0.6)),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(LucideIcons.search, size: 20, color: context.textSecondary),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded, size: 18, color: context.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                    _searchFocus.unfocus();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildUserList(AppLocalizations l10n, bool isDark) {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            itemBuilder: (_, __) => const AdminCardSkeleton(),
          ),
        ),
      );
    }

    if (_filteredUsers.isEmpty) {
      return AdminEmptyState(
        icon: LucideIcons.users,
        title: _searchController.text.isNotEmpty
            ? l10n.noUsersFound
            : l10n.noUsersYet,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadUsers(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        itemCount: _filteredUsers.length,
        itemBuilder: (context, index) {
          final user = _filteredUsers[index];
          final isAdmin = user['role'] == 'admin';
          final userId = user['id'] as int;
          final isSelected = _selectedUserIds.contains(userId);

          return _buildUserCard(user, isAdmin, userId, isSelected, l10n, isDark);
        },
      ),
    );
  }

  Widget _buildUserCard(
    dynamic user,
    bool isAdmin,
    int userId,
    bool isSelected,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final name = user['name'] ?? 'Unknown';
    final email = user['email'] ?? '';
    final avatarUrl = user['avatar_url'] as String?;
    final habitCount = user['habit_count'] ?? 0;
    final postCount = user['post_count'] ?? 0;
    final isActive = _getUserActivityStatus(user['created_at'], l10n) == l10n.active;
    final createdDate = user['created_at']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.06)
            : context.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: InkWell(
          onTap: () {
            if (_isSelectionMode) {
              setState(() {
                if (isSelected) {
                  _selectedUserIds.remove(userId);
                  if (_selectedUserIds.isEmpty) {
                    _isSelectionMode = false;
                  }
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
            if (!_isSelectionMode) {
              setState(() {
                _isSelectionMode = true;
                _selectedUserIds.add(userId);
              });
            }
          },
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.grey.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                if (_isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: isSelected,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedUserIds.add(userId);
                            } else {
                              _selectedUserIds.remove(userId);
                              if (_selectedUserIds.isEmpty) {
                                _isSelectionMode = false;
                              }
                            }
                          });
                        },
                      ),
                    ),
                  ),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: avatarUrl != null
                          ? NetworkImage(ApiService.resolveImageUrl(avatarUrl))
                          : null,
                      child: avatarUrl == null
                          ? Text(
                              name[0]?.toUpperCase() ?? 'U',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                    if (isActive)
                      Positioned(
                        right: 1,
                        bottom: 1,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                            border: Border.all(color: context.cardColor, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: AppTypography.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isAdmin)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE53935).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'ADMIN',
                                style: AppTypography.captionBold.copyWith(
                                  fontSize: 9,
                                  color: const Color(0xFFE53935),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: AppTypography.caption.copyWith(
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildStatChip(
                            icon: AppIcons.checkCircle,
                            value: '$habitCount',
                            label: l10n.habits,
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildStatChip(
                            icon: LucideIcons.fileText,
                            value: '$postCount',
                            label: l10n.postsLabel,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!_isSelectionMode)
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    iconSize: 20,
                    icon: Icon(
                      Icons.more_horiz_rounded,
                      color: context.textSecondary.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        height: 40,
                        child: Row(
                          children: [
                            Icon(
                              isAdmin ? Icons.person_outline_rounded : Icons.shield_outlined,
                              size: 18,
                              color: context.textSecondary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              isAdmin ? l10n.demoteToUser : l10n.promoteToAdmin,
                              style: AppTypography.body,
                            ),
                          ],
                        ),
                        onTap: () => _toggleRole(user['id'], isAdmin),
                      ),
                      PopupMenuItem(
                        height: 40,
                        child: Row(
                          children: [
                            Icon(Icons.block_rounded, size: 18, color: context.textSecondary),
                            const SizedBox(width: 10),
                            Text(l10n.blockUser, style: AppTypography.body),
                          ],
                        ),
                        onTap: () => _blockUser(user['id'], name),
                      ),
                      PopupMenuItem(
                        height: 40,
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded, size: 18, color: const Color(0xFFE53935)),
                            const SizedBox(width: 10),
                            Text(l10n.delete, style: AppTypography.body.copyWith(color: const Color(0xFFE53935))),
                          ],
                        ),
                        onTap: () => _deleteUser(user['id'], name),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: context.textSecondary.withValues(alpha: 0.7)),
          const SizedBox(width: 4),
          Text(
            value,
            style: AppTypography.captionBold,
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontSize: 11,
            ),
          ),
        ],
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
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, 28, AppSpacing.xxl, AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.person_add_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.addNewUser,
                  style: AppTypography.headingMedium.copyWith(color: context.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  Localizations.localeOf(context).languageCode == 'vi' ? 'Nhập thông tin người dùng mới' : 'Enter new user information',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySecondary.copyWith(height: 1.4),
                ),
                const SizedBox(height: 24),
                _buildDialogField(
                  controller: nameController,
                  label: l10n.name,
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 14),
                _buildDialogField(
                  controller: emailController,
                  label: l10n.email,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                _buildDialogField(
                  controller: passwordController,
                  label: l10n.password,
                  icon: Icons.lock_outline_rounded,
                  obscureText: true,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  style: TextStyle(fontSize: 14, color: context.textPrimary),
                  decoration: _dialogFieldDecoration(
                    label: l10n.role,
                    icon: Icons.admin_panel_settings_outlined,
                  ),
                  items: [
                    DropdownMenuItem(value: 'user', child: Text(l10n.user, style: TextStyle(fontSize: 14, color: context.textPrimary))),
                    DropdownMenuItem(value: 'admin', child: Text(l10n.admin, style: TextStyle(fontSize: 14, color: context.textPrimary))),
                  ],
                  onChanged: (value) {
                    setState(() => selectedRole = value ?? 'user');
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.textSecondary,
                          side: BorderSide(color: context.textSecondary.withValues(alpha: 0.25)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(l10n.cancel, style: AppTypography.captionBold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.isEmpty ||
                              emailController.text.isEmpty ||
                              passwordController.text.isEmpty) {
                            AppNotificationDialog.show(
                              context,
                              type: NotificationType.warning,
                              title: l10n.pleaseEnterAllFields,
                            );
                            return;
                          }
                          try {
                            await ApiService.createUser(
                              _token, nameController.text, emailController.text,
                              passwordController.text, selectedRole,
                            );
                            if (context.mounted) Navigator.pop(context, true);
                          } catch (e) {
                            if (context.mounted) {
                              AppNotificationDialog.show(
                                context,
                                type: NotificationType.error,
                                title: l10n.failed,
                                content: '$e',
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(l10n.create, style: AppTypography.captionBold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (result == true) {
      _loadUsers();
      if (mounted) {
        AppNotificationDialog.show(context, type: NotificationType.success, title: l10n.userCreated);
      }
    }
  }

  Widget _buildDialogField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 14, color: context.textPrimary),
      decoration: _dialogFieldDecoration(label: label, icon: icon),
    );
  }

  InputDecoration _dialogFieldDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 13, color: context.textSecondary),
      prefixIcon: Icon(icon, size: 20, color: context.textSecondary),
      filled: true,
      fillColor: context.inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Future<void> _toggleRole(int userId, bool isCurrentlyAdmin) async {
    try {
      await ApiService.updateUserRole(
        _token, userId.toString(), isCurrentlyAdmin ? 'user' : 'admin',
      );
      _loadUsers();
      if (mounted) {
        final loc = AppLocalizations.of(context)!;
        AppNotificationDialog.show(context, type: NotificationType.success, title: loc.roleUpdated);
      }
    } catch (e) {
      if (mounted) {
        AppNotificationDialog.show(context, type: NotificationType.error, title: 'Lỗi', content: '$e');
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

  Future<void> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, 28, AppSpacing.xxl, AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: confirmColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: confirmColor,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppTypography.headingMedium.copyWith(fontSize: 18, color: context.textPrimary),
              ),
              const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySecondary.copyWith(height: 1.4),
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.textSecondary,
                        side: BorderSide(color: context.textSecondary.withValues(alpha: 0.25)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(AppLocalizations.of(context)!.cancel, style: AppTypography.captionBold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(confirmLabel, style: AppTypography.captionBold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true) {
      onConfirm();
    }
  }

  Future<void> _blockUser(int userId, String? userName) async {
    _showConfirmDialog(
      title: Localizations.localeOf(context).languageCode == 'vi' ? 'Xác nhận chặn' : 'Confirm Block',
      message: Localizations.localeOf(context).languageCode == 'vi'
          ? 'Bạn có chắc muốn chặn người dùng "$userName"?'
          : 'Are you sure you want to block "$userName"?',
      confirmLabel: Localizations.localeOf(context).languageCode == 'vi' ? 'Chặn' : 'Block',
      confirmColor: Colors.orange,
      onConfirm: () {
        final loc = AppLocalizations.of(context)!;
        AppNotificationDialog.show(context, type: NotificationType.info, title: loc.blockFeatureInDev);
      },
    );
  }

  Future<void> _deleteUser(int userId, String? userName) async {
    final loc = AppLocalizations.of(context)!;
    _showConfirmDialog(
      title: loc.confirmDelete,
      message: loc.confirmDeleteUserMessage(userName ?? ''),
      confirmLabel: loc.delete,
      confirmColor: const Color(0xFFE53935),
      onConfirm: () async {
        try {
          await ApiService.deleteUser(_token, userId.toString());
          _loadUsers();
          if (mounted) {
            AppNotificationDialog.show(context, type: NotificationType.success, title: loc.userDeleted);
          }
        } catch (e) {
          if (mounted) {
            AppNotificationDialog.show(context, type: NotificationType.error, title: 'Lỗi', content: '$e');
          }
        }
      },
    );
  }

  Future<void> _bulkDeleteUsers() async {
    final loc = AppLocalizations.of(context)!;
    final count = _selectedUserIds.length;
    final title = loc.confirmDelete;
    final message = loc.confirmBulkDeleteMessage(count);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, 28, AppSpacing.xxl, AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE53935), size: 26),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppTypography.headingMedium.copyWith(fontSize: 18, color: context.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.bodySecondary.copyWith(height: 1.4),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.textSecondary,
                        side: BorderSide(color: context.textSecondary.withValues(alpha: 0.25)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(loc.cancel, style: AppTypography.captionBold),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(loc.deleteAll, style: AppTypography.captionBold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ApiService.bulkDeleteUsers(_token, _selectedUserIds.toList());
      setState(() {
        _isSelectionMode = false;
        _selectedUserIds.clear();
      });
      _loadUsers();
      if (mounted) {
        AppNotificationDialog.show(context, type: NotificationType.success, title: loc.usersDeleted(count));
      }
    } catch (e) {
      if (mounted) {
        AppNotificationDialog.show(context, type: NotificationType.error, title: 'Lỗi', content: '$e');
      }
    }
  }
}
