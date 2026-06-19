import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';
import '../screens/login_screen.dart';
import '../services/api_service.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/app_confirm_dialog.dart';
import '../l10n/app_localizations.dart';
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
  bool _isMessagesExpanded = false; // Add state for collapse/expand messages

  bool get _isVietnamese => LocaleProvider.global.locale.languageCode == 'vi';

  @override
  void initState() {
    super.initState();
    _loadReminderData();
  }

  Future<void> _loadReminderData() async {
    setState(() => _isLoadingMessages = true);
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';

    try {
      // Load settings
      final settingsRes = await ApiService.getAutoReminderSettings(_token);
      if (settingsRes['is_enabled'] != null) {
        setState(() {
          _isAutoReminderEnabled =
              (settingsRes['is_enabled'] as int? ?? 0) == 1;
          _sendMorning = (settingsRes['send_morning'] as int? ?? 1) == 1;
          _sendEvening = (settingsRes['send_evening'] as int? ?? 1) == 1;

          // Parse time
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

      // Load messages
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
      AppSnackbar.showSuccess(
        context,
        _isVietnamese ? 'Đã cập nhật cài đặt' : 'Settings updated successfully',
      );
    } else {
      AppSnackbar.showError(
        context,
        res['message'] ?? (_isVietnamese ? 'Cập nhật thất bại' : 'Update failed'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Auto Reminder Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isVietnamese ? 'Thông báo tự động' : 'Auto Reminder',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
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
        const SizedBox(height: 8),
        Text(
          _isAutoReminderEnabled
              ? (_isVietnamese
                    ? '✅ Đang bật - Tự động gửi nhắc nhở đến user chưa hoàn thành thói quen'
                    : '✅ Enabled - Automatically send reminders to users who haven\'t completed habits')
              : (_isVietnamese
                    ? '⚠️ Đang tắt - Không gửi thông báo tự động'
                    : '⚠️ Disabled - No automatic reminders'),
          style: TextStyle(
            fontSize: 13,
            color: _isAutoReminderEnabled ? Colors.green : Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),

        // Time settings - Only show when Auto Reminder is enabled
        if (_isAutoReminderEnabled)
          Card(
            color: context.cardColor,
            child: Column(
              children: [
                CheckboxListTile(
                  value: _sendMorning,
                  onChanged: (value) {
                    setState(() => _sendMorning = value ?? true);
                    _saveReminderSettings();
                  },
                  title: Text(
                    _isVietnamese ? 'Gửi buổi sáng' : 'Send Morning',
                    style: TextStyle(color: context.textPrimary),
                  ),
                  subtitle: Text(
                    '${_isVietnamese ? 'Lúc' : 'At'} ${_morningTime.format(context)}',
                    style: TextStyle(color: context.textSecondary),
                  ),
                  secondary: const Icon(Icons.wb_sunny, color: Colors.orange),
                  activeColor: AppColors.primary,
                ),
                if (_sendMorning)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 8,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _selectTime(context, true),
                      icon: const Icon(Icons.access_time, size: 18),
                      label: Text(_isVietnamese ? 'Chọn giờ' : 'Select Time'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                const Divider(),
                CheckboxListTile(
                  value: _sendEvening,
                  onChanged: (value) {
                    setState(() => _sendEvening = value ?? true);
                    _saveReminderSettings();
                  },
                  title: Text(
                    _isVietnamese ? 'Gửi buổi tối' : 'Send Evening',
                    style: TextStyle(color: context.textPrimary),
                  ),
                  subtitle: Text(
                    '${_isVietnamese ? 'Lúc' : 'At'} ${_eveningTime.format(context)}',
                    style: TextStyle(color: context.textSecondary),
                  ),
                  secondary: const Icon(
                    Icons.nightlight_round,
                    color: Colors.indigo,
                  ),
                  activeColor: AppColors.primary,
                ),
                if (_sendEvening)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 8,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _selectTime(context, false),
                      icon: const Icon(Icons.access_time, size: 18),
                      label: Text(_isVietnamese ? 'Chọn giờ' : 'Select Time'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),

        const SizedBox(height: 24),

        // Reminder Messages Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isVietnamese ? 'Thông điệp nhắc nhở' : 'Reminder Messages',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.add_circle,
                color: AppColors.primary,
                size: 28,
              ),
              onPressed: _showAddMessageDialog,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _isVietnamese
              ? 'Hệ thống sẽ chọn ngẫu nhiên 1 thông điệp mỗi ngày để gửi'
              : 'System will randomly select 1 message each day to send',
          style: TextStyle(fontSize: 12, color: context.textSecondary),
        ),
        const SizedBox(height: 12),

        _isLoadingMessages
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            : _reminderMessages.isEmpty
            ? Card(
                color: context.cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.message_outlined,
                          size: 48,
                          color: context.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isVietnamese
                              ? 'Chưa có thông điệp nào'
                              : 'No messages yet',
                          style: TextStyle(color: context.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Column(
                children: [
                  // Summary card showing count
                  Card(
                    color: context.cardColor,
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${_reminderMessages.length}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      title: Text(
                        _isVietnamese
                            ? '${_reminderMessages.length} thông điệp'
                            : '${_reminderMessages.length} messages',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        _isVietnamese
                            ? 'Nhấn để ${_isMessagesExpanded ? "thu gọn" : "xem tất cả"}'
                            : 'Tap to ${_isMessagesExpanded ? "collapse" : "view all"}',
                        style: TextStyle(fontSize: 12, color: context.textSecondary),
                      ),
                      trailing: Icon(
                        _isMessagesExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.primary,
                      ),
                      onTap: () {
                        setState(() => _isMessagesExpanded = !_isMessagesExpanded);
                      },
                    ),
                  ),

                  // Messages list (expandable)
                  if (_isMessagesExpanded)
                    ..._reminderMessages.map((msg) {
                      final isActive = (msg['is_active'] as int? ?? 1) == 1;
                      return Card(
                        color: context.cardColor,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            isActive ? Icons.check_circle : Icons.cancel,
                            color: isActive ? Colors.green : Colors.grey,
                          ),
                          title: Text(
                            msg['message'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: isActive
                                  ? context.textPrimary
                                  : context.textSecondary,
                            ),
                          ),
                          subtitle: Text(
                            isActive
                                ? (_isVietnamese ? 'Đang hoạt động' : 'Active')
                                : (_isVietnamese ? 'Đã tắt' : 'Inactive'),
                            style: TextStyle(
                              fontSize: 12,
                              color: isActive ? Colors.green : Colors.grey,
                            ),
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(
                                      isActive ? Icons.toggle_on : Icons.toggle_off,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isActive
                                          ? (_isVietnamese ? 'Tắt' : 'Disable')
                                          : (_isVietnamese ? 'Bật' : 'Enable'),
                                    ),
                                  ],
                                ),
                                onTap: () => _toggleMessageActive(msg),
                              ),
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    const Icon(Icons.edit, size: 20),
                                    const SizedBox(width: 8),
                                    Text(_isVietnamese ? 'Sửa' : 'Edit'),
                                  ],
                                ),
                                onTap: () => _showEditMessageDialog(msg),
                              ),
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.delete,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isVietnamese ? 'Xóa' : 'Delete',
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                                onTap: () => _deleteMessage(msg),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),

        const SizedBox(height: 30),

        // Appearance Section
        Text(
          l10n.appearance,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        Card(
          color: context.cardColor,
          child: Column(
            children: [
              _buildThemeToggleTile(),
              const Divider(height: 1),
              _buildLanguageTile(),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // Logout button
        Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: context.isDark
                ? Colors.red.shade900.withValues(alpha: 0.2)
                : Colors.red.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: context.isDark ? Colors.red.shade700 : Colors.red.shade200,
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _handleLogout,
              borderRadius: BorderRadius.circular(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout,
                    color: context.isDark
                        ? Colors.red.shade400
                        : Colors.red.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.logout,
                    style: TextStyle(
                      color: context.isDark
                          ? Colors.red.shade400
                          : Colors.red.shade700,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  void _handleLogout() async {
    final l10n = AppLocalizations.of(context)!;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AppConfirmDialog(
        icon: Icons.logout,
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
        return ListTile(
          leading: Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: AppColors.primary,
            size: 22,
          ),
          title: Text(
            isDark ? l10n.darkMode : l10n.lightMode,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: context.textPrimary,
            ),
          ),
          subtitle: Text(
            isDark ? l10n.usingDarkMode : l10n.usingLightMode,
            style: TextStyle(fontSize: 13, color: context.textSecondary),
          ),
          trailing: Switch(
            value: isDark,
            onChanged: (val) {
              themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
            },
            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
            activeThumbColor: AppColors.primary,
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

        return ListTile(
          leading: const Icon(
            Icons.language_rounded,
            color: AppColors.primary,
            size: 22,
          ),
          title: Text(
            l10n.language,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: context.textPrimary,
            ),
          ),
          subtitle: Text(
            isVietnamese ? l10n.vietnamese : l10n.english,
            style: TextStyle(fontSize: 13, color: context.textSecondary),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isVietnamese ? "🇻🇳 VI" : "🇬🇧 EN",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.primary,
                  size: 18,
                ),
              ],
            ),
          ),
          onTap: () => _showLanguageSheet(languageCode),
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
          color: Theme.of(context).cardTheme.color ?? Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.selectLanguage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Vietnamese option
            _buildLanguageOption(
              context: ctx,
              flag: "🇻🇳",
              language: l10n.vietnamese,
              code: "Vietnamese",
              isSelected: currentLanguageCode == 'vi',
              onTap: () async {
                await localeProvider.setLocale(const Locale('vi'));
                if (!mounted) return;
                Navigator.pop(ctx);
                AppSnackbar.showSuccess(context, l10n.languageChanged);
              },
            ),

            const SizedBox(height: 12),

            // English option
            _buildLanguageOption(
              context: ctx,
              flag: "🇬🇧",
              language: l10n.english,
              code: "English",
              isSelected: currentLanguageCode == 'en',
              onTap: () async {
                await localeProvider.setLocale(const Locale('en'));
                if (!mounted) return;
                Navigator.pop(ctx);
                AppSnackbar.showSuccess(context, l10n.languageChangedEn);
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String flag,
    required String language,
    required String code,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : Colors.grey.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : this.context.textPrimary,
                      ),
                    ),
                    Text(
                      code,
                      style: TextStyle(
                        fontSize: 13,
                        color: this.context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

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

  void _showAddMessageDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add_comment,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _isVietnamese ? 'Thêm thông điệp mới' : 'Add New Message',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isVietnamese ? 'Nội dung nhắc nhở' : 'Reminder content',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              maxLines: 5,
              autofocus: true,
              style: TextStyle(fontSize: 15, color: context.textPrimary),
              decoration: InputDecoration(
                hintText: _isVietnamese
                    ? 'Nhập nội dung thông điệp nhắc nhở...'
                    : 'Enter reminder message content...',
                hintStyle: TextStyle(color: context.textSecondary),
                filled: true,
                fillColor: context.isDark
                    ? Colors.grey.shade800.withValues(alpha: 0.3)
                    : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        actions: [
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (controller.text.trim().isEmpty) {
                      AppSnackbar.showError(
                        context,
                        _isVietnamese
                            ? 'Vui lòng nhập nội dung'
                            : 'Please enter content',
                      );
                      return;
                    }
                    Navigator.pop(ctx);

                    final res = await ApiService.addReminderMessage(
                      _token,
                      controller.text.trim(),
                    );
                    if (!mounted) return;

                    if (res['message']?.contains('success') ?? false) {
                      AppSnackbar.showSuccess(
                        context,
                        _isVietnamese ? 'Đã thêm thông điệp mới' : 'Message added',
                      );
                      _loadReminderData();
                    } else {
                      AppSnackbar.showError(
                        context,
                        res['message'] ??
                            (_isVietnamese ? 'Thêm thất bại' : 'Failed to add'),
                      );
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
                  icon: const Icon(Icons.send, size: 18),
                  label: Text(
                    _isVietnamese ? 'Thêm' : 'Add',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  _isVietnamese ? 'Hủy' : 'Cancel',
                  style: TextStyle(
                    fontSize: 15,
                    color: context.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditMessageDialog(Map<String, dynamic> msg) {
    final controller = TextEditingController(text: msg['message']);
    // Need to delay to avoid popup menu conflict
    Future.delayed(const Duration(milliseconds: 100), () {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(_isVietnamese ? 'Sửa thông điệp' : 'Edit Message'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: _isVietnamese
                  ? 'Nhập nội dung thông điệp nhắc nhở...'
                  : 'Enter reminder message content...',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(_isVietnamese ? 'Hủy' : 'Cancel'),
            ),
            ElevatedButton(
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
                  AppSnackbar.showSuccess(
                    context,
                    _isVietnamese
                        ? 'Đã cập nhật thông điệp'
                        : 'Message updated',
                  );
                  _loadReminderData();
                } else {
                  AppSnackbar.showError(
                    context,
                    res['message'] ??
                        (_isVietnamese
                            ? 'Cập nhật thất bại'
                            : 'Failed to update'),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(_isVietnamese ? 'Lưu' : 'Save'),
            ),
          ],
        ),
      );
    });
  }

  void _toggleMessageActive(Map<String, dynamic> msg) async {
    final isActive = (msg['is_active'] as int? ?? 1) == 1;
    // Delay to avoid popup menu conflict
    Future.delayed(const Duration(milliseconds: 100), () async {
      final res = await ApiService.updateReminderMessage(
        _token,
        msg['id'].toString(),
        msg['message'],
        !isActive,
      );
      if (!mounted) return;

      if (res['message']?.contains('success') ?? false) {
        AppSnackbar.showSuccess(
          context,
          isActive
              ? (_isVietnamese ? 'Đã tắt thông điệp' : 'Message disabled')
              : (_isVietnamese ? 'Đã bật thông điệp' : 'Message enabled'),
        );
        _loadReminderData();
      } else {
        AppSnackbar.showError(
          context,
          res['message'] ??
              (_isVietnamese ? 'Thao tác thất bại' : 'Operation failed'),
        );
      }
    });
  }

  void _deleteMessage(Map<String, dynamic> msg) async {
    // Delay to avoid popup menu conflict
    Future.delayed(const Duration(milliseconds: 100), () async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AppConfirmDialog(
          icon: Icons.delete_outline_rounded,
          iconColor: Colors.red,
          iconBackgroundColor: Colors.red.withValues(alpha: 0.1),
          title: _isVietnamese ? 'Xóa thông điệp' : 'Delete Message',
          content: _isVietnamese
              ? 'Bạn có chắc chắn muốn xóa thông điệp này?'
              : 'Are you sure you want to delete this message?',
          cancelText: _isVietnamese ? 'Hủy' : 'Cancel',
          confirmText: _isVietnamese ? 'Xóa' : 'Delete',
          confirmColor: Colors.red,
          onCancel: () => Navigator.pop(ctx, false),
          onConfirm: () => Navigator.pop(ctx, true),
        ),
      );

      if (confirmed != true) return;

      final res = await ApiService.deleteReminderMessage(
        _token,
        msg['id'].toString(),
      );
      if (!mounted) return;

      if (res['message']?.contains('success') ?? false) {
        AppSnackbar.showSuccess(
          context,
          _isVietnamese ? 'Đã xóa thông điệp' : 'Message deleted',
        );
        _loadReminderData();
      } else {
        AppSnackbar.showError(
          context,
          res['message'] ??
              (_isVietnamese ? 'Xóa thất bại' : 'Failed to delete'),
        );
      }
    });
  }
}
