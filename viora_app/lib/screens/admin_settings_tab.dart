import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/theme_extensions.dart';
import '../screens/login_screen.dart';
import '../services/api_service.dart';
import '../widgets/app_notification_dialog.dart';
import '../widgets/app_confirm_dialog.dart';
import '../l10n/app_localizations.dart';
import '../constants/app_icons.dart';
import '../services/notification_service.dart';

class AdminSettingsTab extends StatefulWidget {
  const AdminSettingsTab({super.key});

  @override
  State<AdminSettingsTab> createState() => _AdminSettingsTabState();
}

class _AdminSettingsTabState extends State<AdminSettingsTab> {
  TimeOfDay _morningTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 20, minute: 0);
  bool _isAutoReminderEnabled = false;
  bool _sendMorning = true;
  bool _sendEvening = true;
  List<dynamic> _reminderMessages = [];
  bool _isLoadingMessages = true;
  String _token = '';
  bool _isMessagesExpanded = false;

  // Admin profile
  String _adminName = '';
  String _adminEmail = '';
  String? _adminAvatarUrl;
  bool _isLoadingProfile = true;
  bool _isUploadingAvatar = false;

  bool get _isVietnamese => LocaleProvider.global.locale.languageCode == 'vi';

  String t(String vi, String en) => _isVietnamese ? vi : en;

  @override
  void initState() {
    super.initState();
    _loadAdminProfile();
    _loadReminderData();
  }

  Future<void> _loadAdminProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    if (token.isEmpty) return;
    final res = await ApiService.getProfile(token);
    if (res['user'] != null) {
      setState(() {
        _adminName = res['user']['name'] ?? '';
        _adminEmail = res['user']['email'] ?? '';
        _adminAvatarUrl = res['user']['avatar_url'] as String?;
        _isLoadingProfile = false;
      });
    } else {
      setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _isUploadingAvatar = true);
    final res = await ApiService.uploadAvatar(_token, picked.path);
    setState(() => _isUploadingAvatar = false);
    if (res['avatar_url'] != null) {
      final resolved = ApiService.resolveImageUrl(res['avatar_url'] as String);
      setState(() => _adminAvatarUrl = resolved);
      if (mounted) AppNotificationDialog.show(context, type: NotificationType.success, title: 'Avatar updated');
    } else {
      if (mounted) AppNotificationDialog.show(context, type: NotificationType.error, title: 'Failed to update avatar');
    }
  }

  Future<void> _loadReminderData() async {
    setState(() => _isLoadingMessages = true);
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';
    try {
      final settingsRes = await ApiService.getAutoReminderSettings(_token);
      if (settingsRes['is_enabled'] != null) {
        setState(() {
          _isAutoReminderEnabled =
              (settingsRes['is_enabled'] as int? ?? 0) == 1;
          _sendMorning = (settingsRes['send_morning'] as int? ?? 1) == 1;
          _sendEvening = (settingsRes['send_evening'] as int? ?? 1) == 1;
          final morningTimeStr = settingsRes['morning_time'] as String?;
          if (morningTimeStr != null) {
            final parts = morningTimeStr.split(':');
            _morningTime = TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          }
          final eveningTimeStr = settingsRes['evening_time'] as String?;
          if (eveningTimeStr != null) {
            final parts = eveningTimeStr.split(':');
            _eveningTime = TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          }
        });
      }
      final messagesRes = await ApiService.getReminderMessages(_token);
      if (!mounted) return;
      setState(() {
        _reminderMessages = messagesRes['messages'] ?? [];
        _isLoadingMessages = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMessages = false);
    }
  }

  Future<void> _saveReminderSettings() async {
    final morningTimeStr =
        '${_morningTime.hour.toString().padLeft(2, '0')}:${_morningTime.minute.toString().padLeft(2, '0')}:00';
    final eveningTimeStr =
        '${_eveningTime.hour.toString().padLeft(2, '0')}:${_eveningTime.minute.toString().padLeft(2, '0')}:00';
    final res = await ApiService.updateAutoReminderSettings(
      _token,
      _isAutoReminderEnabled,
      morningTimeStr,
      eveningTimeStr,
      _sendMorning,
      _sendEvening,
    );
    if (!mounted) return;
    if (res['message']?.contains('success') ?? false) {
      AppNotificationDialog.show(context, type: NotificationType.success, title: t('Đã cập nhật cài đặt', 'Settings updated'));
    } else {
      AppNotificationDialog.show(context, type: NotificationType.error, title: res['message'] ?? t('Cập nhật thất bại', 'Update failed'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxxl,
      ),
      children: [
        _buildHeader(l10n),
        _buildAdminProfileCard(l10n),
        const SizedBox(height: AppSpacing.xxl),
        _buildAutoReminderSection(),
        const SizedBox(height: AppSpacing.xxl),
        _buildReminderMessagesSection(),
        const SizedBox(height: AppSpacing.xxl),
        _buildAppearanceSection(l10n),
        const SizedBox(height: AppSpacing.xxl),
        _buildLogoutButton(l10n),
      ],
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, AppSpacing.lg, 0, AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              AppIcons.settings, color: AppColors.primary, size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(
                  l10n.adminSettings,
                  style: AppTypography.headingMedium.copyWith(color: context.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  t('Quản lý cài đặt hệ thống', 'Manage system settings'),
                  style: AppTypography.caption,
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Admin Profile ─────────────────────────────────────

  Widget _buildAdminProfileCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary, Color(0xFF00845F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
            child: Stack(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.3),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2),
                  ),
                  child: _isUploadingAvatar
                      ? const Center(
                          child: SizedBox(
                            width: 28, height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white,
                            ),
                          ),
                        )
                      : _adminAvatarUrl != null
                          ? ClipOval(
                              child: Image.network(
                                _adminAvatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Text(
                                    _adminName.isNotEmpty ? _adminName[0].toUpperCase() : 'A',
                                    style: const TextStyle(
                                      fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                _adminName.isNotEmpty ? _adminName[0].toUpperCase() : 'A',
                                style: const TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white,
                                ),
                              ),
                            ),
                ),
                if (!_isUploadingAvatar)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 1.5),
                      ),
                      child: const Icon(Icons.camera_alt, size: 14, color: AppColors.primary),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.admin,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                if (_isLoadingProfile)
                  const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                else ...[
                  Text(
                    _adminName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _adminEmail,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Auto Reminder ─────────────────────────────────────

  Widget _buildAutoReminderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                AppIcons.notifications, color: AppColors.primary, size: 18,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                t('Thông báo tự động', 'Auto Reminder'),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
            ),
            Switch(
              value: _isAutoReminderEnabled,
              onChanged: (value) {
                setState(() => _isAutoReminderEnabled = value);
                _saveReminderSettings();
              },
              activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
              activeThumbColor: AppColors.primary,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.only(left: 42),
          child: Text(
            _isAutoReminderEnabled
                ? t(
                    'Đang bật - Gửi nhắc nhở đến user chưa hoàn thành thói quen',
                    'Enabled - Send reminders to incomplete users',
                  )
                : t('Đang tắt - Không gửi thông báo tự động', 'Disabled'),
            style: AppTypography.bodySecondary.copyWith(
              height: 1.4,
              color: _isAutoReminderEnabled
                  ? AppColors.success
                  : AppColors.warning,
            ),
          ),
        ),
        if (_isAutoReminderEnabled) ...[
          const SizedBox(height: AppSpacing.md),
          _buildTimeSettingsCard(),
        ],
      ],
    );
  }

  Widget _buildTimeSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDark
              ? const Color(0xFF2E433C)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          _buildTimeTile(
            icon: AppIcons.sun,
            iconColor: AppColors.warning,
            title: t('Gửi buổi sáng', 'Send Morning'),
            time: _morningTime.format(context),
            enabled: _sendMorning,
            onToggle: (v) {
              setState(() => _sendMorning = v);
              _saveReminderSettings();
            },
            onSelectTime: () => _selectTime(context, true),
          ),
          const Divider(height: 1, indent: 52),
          _buildTimeTile(
            icon: AppIcons.moon,
            iconColor: const Color(0xFF4F46E5),
            title: t('Gửi buổi tối', 'Send Evening'),
            time: _eveningTime.format(context),
            enabled: _sendEvening,
            onToggle: (v) {
              setState(() => _sendEvening = v);
              _saveReminderSettings();
            },
            onSelectTime: () => _selectTime(context, false),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String time,
    required bool enabled,
    required ValueChanged<bool> onToggle,
    required VoidCallback onSelectTime,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      title,
                      style: AppTypography.title,
                    ),
                    const Spacer(),
                    Text(
                      time,
                      style: AppTypography.captionBold.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(
                      height: 32,
                      child: Switch(
                        value: enabled,
                        onChanged: onToggle,
                        activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
                        activeThumbColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    GestureDetector(
                      onTap: onSelectTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              AppIcons.clock,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              t('Đổi giờ', 'Change'),
                              style: AppTypography.captionBold.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Reminder Messages ─────────────────────────────────

  Widget _buildReminderMessagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                AppIcons.message, color: AppColors.primary, size: 18,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                t('Thông điệp nhắc nhở', 'Reminder Messages'),
                style: AppTypography.title.copyWith(fontSize: 17),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(AppIcons.add, color: AppColors.primary, size: 22),
                onPressed: _showAddMessageDialog,
                tooltip: t('Thêm thông điệp', 'Add message'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.only(left: 42),
          child: Text(
            t(
              'Hệ thống sẽ chọn ngẫu nhiên 1 thông điệp mỗi ngày để gửi',
              'System randomly selects 1 message each day to send',
            ),
            style: TextStyle(fontSize: 12, color: context.textSecondary),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (_isLoadingMessages)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.xxl),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_reminderMessages.isEmpty)
          _buildEmptyMessages()
        else
          _buildMessagesList(),
      ],
    );
  }

  Widget _buildEmptyMessages() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDark
              ? const Color(0xFF2E433C)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          Icon(AppIcons.message, size: 40, color: context.textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: AppSpacing.md),
          Text(
            t('Chưa có thông điệp nào', 'No messages yet'),
            style: TextStyle(fontSize: 14, color: context.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDark
              ? const Color(0xFF2E433C)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isMessagesExpanded = !_isMessagesExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_reminderMessages.length}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      t('$_count thông điệp', '$_count messages'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isMessagesExpanded
                            ? t('Thu gọn', 'Collapse')
                            : t('Xem tất cả', 'View all'),
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isMessagesExpanded
                            ? AppIcons.chevronUp
                            : AppIcons.chevronDown,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isMessagesExpanded)
            ...List.generate(_reminderMessages.length, (i) {
              final msg = _reminderMessages[i];
              final isActive = (msg['is_active'] as int? ?? 1) == 1;
              return Column(
                children: [
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            isActive
                                ? AppIcons.checkCircle
                                : AppIcons.close,
                            size: 18,
                            color: isActive
                                ? AppColors.success
                                : context.textSecondary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg['message'] ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: isActive
                                      ? context.textPrimary
                                      : context.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isActive
                                    ? t('Đang hoạt động', 'Active')
                                    : t('Đã tắt', 'Inactive'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isActive
                                      ? AppColors.success
                                      : context.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _buildMessageActions(msg, isActive),
                      ],
                    ),
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildMessageActions(Map<String, dynamic> msg, bool isActive) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _smallIconButton(
          icon: isActive ? AppIcons.close : AppIcons.check,
          color: isActive ? AppColors.warning : AppColors.success,
          tooltip: isActive ? t('Tắt', 'Disable') : t('Bật', 'Enable'),
          onTap: () => _toggleMessageActive(msg),
        ),
        const SizedBox(width: 2),
        _smallIconButton(
          icon: AppIcons.edit,
          color: AppColors.primary,
          tooltip: t('Sửa', 'Edit'),
          onTap: () => _showEditMessageDialog(msg),
        ),
        const SizedBox(width: 2),
        _smallIconButton(
          icon: AppIcons.delete,
          color: AppColors.error,
          tooltip: t('Xóa', 'Delete'),
          onTap: () => _deleteMessage(msg),
        ),
      ],
    );
  }

  Widget _smallIconButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        icon: Icon(icon, size: 16, color: color),
        onPressed: onTap,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        splashRadius: 16,
      ),
    );
  }

  int get _count => _reminderMessages.length;

  // ─── Appearance ────────────────────────────────────────

  Widget _buildAppearanceSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                AppIcons.sun, color: AppColors.primary, size: 18,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('Giao diện', 'Appearance'),
                    style: AppTypography.title.copyWith(fontSize: 17),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.isDark
                  ? const Color(0xFF2E433C)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Column(
            children: [
              _buildThemeToggleTile(),
              const Divider(height: 1, indent: 52),
              _buildLanguageTile(),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Logout ────────────────────────────────────────────

  Widget _buildLogoutButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: _handleLogout,
        style: OutlinedButton.styleFrom(
          foregroundColor: context.isDark
              ? Colors.red.shade400
              : Colors.red.shade700,
          side: BorderSide(
            color: context.isDark
                ? Colors.red.shade700.withValues(alpha: 0.6)
                : Colors.red.shade200,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(AppIcons.logout, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Text(
              l10n.logout,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AppConfirmDialog(
        icon: AppIcons.logout,
        iconColor: Colors.red,
        iconBackgroundColor: Colors.red.withValues(alpha: 0.1),
        title: l10n.logout,
        content: l10n.logoutConfirm,
        cancelText: l10n.no,
        confirmText: l10n.yes,
        confirmColor: Colors.red,
        onCancel: () => Navigator.pop(ctx, false),
        onConfirm: () => Navigator.pop(ctx, true),
      ),
    );
    if (confirmed != true) return;
    await NotificationService.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("cached_user_id");
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Widget _buildThemeToggleTile() {
    final l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.sm, AppSpacing.md, AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                isDark ? AppIcons.moon : AppIcons.sun,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDark ? l10n.darkMode : l10n.lightMode,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: context.textPrimary,
                      ),
                    ),
                    Text(
                      isDark ? l10n.usingDarkMode : l10n.usingLightMode,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isDark,
                onChanged: (val) {
                  themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                },
                activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageTile() {
    final localeProvider = LocaleProvider.global;
    return ListenableBuilder(
      listenable: localeProvider,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;
        final languageCode = localeProvider.locale.languageCode;
        final isVietnamese = languageCode == 'vi';
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.sm, AppSpacing.md, AppSpacing.sm,
          ),
          child: Row(
            children: [
              const Icon(
                AppIcons.globe,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.language,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: context.textPrimary,
                      ),
                    ),
                    Text(
                      isVietnamese ? l10n.vietnamese : l10n.english,
                      style: TextStyle(
                        fontSize: 13,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showLanguageSheet(languageCode),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isVietnamese ? '🇻🇳 VI' : '🇬🇧 EN',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        AppIcons.chevronDown,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageSheet(String currentLanguageCode) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = LocaleProvider.global;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: context.isDark
                      ? const Color(0xFF2E433C)
                      : const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.selectLanguage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildLanguageOption(
              ctx: ctx,
              flag: '🇻🇳',
              language: l10n.vietnamese,
              code: 'Tiếng Việt',
              isSelected: currentLanguageCode == 'vi',
              onTap: () async {
                await localeProvider.setLocale(const Locale('vi'));
                if (!mounted) return;
                Navigator.pop(ctx);
                AppNotificationDialog.show(context, type: NotificationType.success, title: l10n.languageChanged);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildLanguageOption(
              ctx: ctx,
              flag: '🇬🇧',
              language: l10n.english,
              code: 'English',
              isSelected: currentLanguageCode == 'en',
              onTap: () async {
                await localeProvider.setLocale(const Locale('en'));
                if (!mounted) return;
                Navigator.pop(ctx);
                AppNotificationDialog.show(context, type: NotificationType.success, title: l10n.languageChangedEn);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext ctx,
    required String flag,
    required String language,
    required String code,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.4)
                : context.isDark
                    ? const Color(0xFF2E433C)
                    : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : context.textPrimary,
                    ),
                  ),
                  Text(
                    code,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Time Picker ───────────────────────────────────────

  Future<void> _selectTime(BuildContext context, bool isMorning) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isMorning ? _morningTime : _eveningTime,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isMorning) {
          _morningTime = picked;
        } else {
          _eveningTime = picked;
        }
      });
      _saveReminderSettings();
    }
  }

  // ─── Dialogs ───────────────────────────────────────────

  void _showAddMessageDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      AppIcons.message, color: AppColors.primary, size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      t('Thêm thông điệp mới', 'Add New Message'),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: controller,
                maxLines: 5,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: t(
                    'Nhập nội dung thông điệp nhắc nhở...',
                    'Enter reminder message content...',
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (controller.text.trim().isEmpty) {
                      AppNotificationDialog.show(context, type: NotificationType.error, title: t('Vui lòng nhập nội dung', 'Please enter content'));
                      return;
                    }
                    Navigator.pop(ctx);
                    final res = await ApiService.addReminderMessage(
                      _token, controller.text.trim(),
                    );
                    if (!mounted) return;
                    if (res['message']?.contains('success') ?? false) {
                      AppNotificationDialog.show(context, type: NotificationType.success, title: t('Đã thêm thông điệp mới', 'Message added'));
                      _loadReminderData();
                    } else {
                      AppNotificationDialog.show(context, type: NotificationType.error, title: res['message'] ?? t('Thêm thất bại', 'Failed to add'));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    t('Thêm', 'Add'),
                    style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  t('Hủy', 'Cancel'),
                  style: TextStyle(
                    fontSize: 15,
                    color: context.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditMessageDialog(Map<String, dynamic> msg) {
    final controller = TextEditingController(text: msg['message']);
    Future.delayed(const Duration(milliseconds: 100), () {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        AppIcons.edit, color: AppColors.primary, size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        t('Sửa thông điệp', 'Edit Message'),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: controller,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: t(
                      'Nhập nội dung thông điệp...',
                      'Enter message content...',
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (controller.text.trim().isEmpty) return;
                      Navigator.pop(ctx);
                      final res = await ApiService.updateReminderMessage(
                        _token,
                        msg['id'].toString(),
                        controller.text.trim(),
                        (msg['is_active'] as int? ?? 1) == 1,
                      );
                      if (!mounted) return;
                      if (res['message']?.contains('success') ?? false) {
                        AppNotificationDialog.show(context, type: NotificationType.success, title: t('Đã cập nhật thông điệp', 'Message updated'));
                        _loadReminderData();
                      } else {
                        AppNotificationDialog.show(context, type: NotificationType.error, title: res['message'] ?? t('Cập nhật thất bại', 'Failed to update'));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      t('Lưu', 'Save'),
                      style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    t('Hủy', 'Cancel'),
                    style: TextStyle(
                      fontSize: 15,
                      color: context.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _toggleMessageActive(Map<String, dynamic> msg) async {
    final isActive = (msg['is_active'] as int? ?? 1) == 1;
    Future.delayed(const Duration(milliseconds: 100), () async {
      final res = await ApiService.updateReminderMessage(
        _token,
        msg['id'].toString(),
        msg['message'],
        !isActive,
      );
      if (!mounted) return;
      if (res['message']?.contains('success') ?? false) {
        AppNotificationDialog.show(context, type: NotificationType.success, title: isActive
            ? t('Đã tắt thông điệp', 'Message disabled')
            : t('Đã bật thông điệp', 'Message enabled'));
        _loadReminderData();
      } else {
        AppNotificationDialog.show(context, type: NotificationType.error, title: res['message'] ?? t('Thao tác thất bại', 'Operation failed'));
      }
    });
  }

  void _deleteMessage(Map<String, dynamic> msg) async {
    Future.delayed(const Duration(milliseconds: 100), () async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AppConfirmDialog(
          icon: AppIcons.delete,
          iconColor: Colors.red,
          iconBackgroundColor: Colors.red.withValues(alpha: 0.1),
          title: t('Xóa thông điệp', 'Delete Message'),
          content: t(
            'Bạn có chắc chắn muốn xóa thông điệp này?',
            'Are you sure you want to delete this message?',
          ),
          cancelText: t('Hủy', 'Cancel'),
          confirmText: t('Xóa', 'Delete'),
          confirmColor: Colors.red,
          onCancel: () => Navigator.pop(ctx, false),
          onConfirm: () => Navigator.pop(ctx, true),
        ),
      );
      if (confirmed != true) return;
      final res = await ApiService.deleteReminderMessage(
        _token, msg['id'].toString(),
      );
      if (!mounted) return;
      if (res['message']?.contains('success') ?? false) {
        AppNotificationDialog.show(context, type: NotificationType.success, title: t('Đã xóa thông điệp', 'Message deleted'));
        _loadReminderData();
      } else {
        AppNotificationDialog.show(context, type: NotificationType.error, title: res['message'] ?? t('Xóa thất bại', 'Failed to delete'));
      }
    });
  }


}
