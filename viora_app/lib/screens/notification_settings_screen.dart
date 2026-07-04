import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../widgets/app_notification_dialog.dart';
import '../theme/theme_extensions.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool morningEnabled = true;
  bool eveningEnabled = true;
  int morningHour = 8;
  int morningMinute = 0;
  int eveningHour = 21;
  int eveningMinute = 0;
  bool isLoading = true;
  bool _canExactAlarm = false;
  bool _isSendingTest = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await NotificationService.getSettings();
    final canExact = await NotificationService.canScheduleExact();
    setState(() {
      morningEnabled = settings['morning_enabled'];
      eveningEnabled = settings['evening_enabled'];
      morningHour = settings['morning_hour'];
      morningMinute = settings['morning_minute'];
      eveningHour = settings['evening_hour'];
      eveningMinute = settings['evening_minute'];
      _canExactAlarm = canExact;
      isLoading = false;
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    await NotificationService.saveSettings(
      morningEnabled: morningEnabled,
      eveningEnabled: eveningEnabled,
      morningHour: morningHour,
      morningMinute: morningMinute,
      eveningHour: eveningHour,
      eveningMinute: eveningMinute,
    );
    // Tự động lên lịch thông báo luôn
    await NotificationService.scheduleAll();
    if (!mounted) return;
    AppNotificationDialog.show(context, type: NotificationType.success, title: l10n.savedSettings);
  }

  Future<void> _pickTime(bool isMorning) async {
    final initial = TimeOfDay(
      hour: isMorning ? morningHour : eveningHour,
      minute: isMorning ? morningMinute : eveningMinute,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4CAF50),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        ),
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isMorning) {
        morningHour = picked.hour;
        morningMinute = picked.minute;
      } else {
        eveningHour = picked.hour;
        eveningMinute = picked.minute;
      }
    });
    await _save();
  }

  String _formatTime(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.notificationSettingsTitle,
          style: TextStyle(
            color: context.textGreen,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Exact alarm warning (Android 12+)
                if (!_canExactAlarm) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFFCC02)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text("⚠️", style: TextStyle(fontSize: 18)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Cần cấp quyền báo thức chính xác',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFFE65100),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Android 12+ yêu cầu cấp quyền "Báo thức & Nhắc nhở" để thông báo đúng giờ.\n\nVào: Cài đặt → Ứng dụng → Viora → Báo thức & Nhắc nhở → Bật lên',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF5D4037),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final can = await NotificationService.canScheduleExact();
                              setState(() => _canExactAlarm = can);
                              if (!can && mounted) {
                                AppNotificationDialog.show(context, type: NotificationType.error, title: 'Vào Cài đặt → Ứng dụng → Viora → Báo thức & Nhắc nhở → Bật lên');
                              }
                            },
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Kiểm tra lại'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFE65100),
                              side: const BorderSide(color: Color(0xFFE65100)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.infoBoxColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: context.infoBoxBorder),
                  ),
                  child: Row(
                    children: [
                      const Text("💡", style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.notificationInfo,
                          style: TextStyle(
                            fontSize: 13,
                            color: context.textGreenLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Test notification button
                Container(
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
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.notifications_active_outlined,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      'Gửi thông báo thử',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Ngay lập tức + hẹn giờ sau 10 giây',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondary,
                      ),
                    ),
                    trailing: _isSendingTest
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : const Icon(
                            Icons.chevron_right,
                            color: AppColors.primary,
                          ),
                    onTap: _isSendingTest
                        ? null
                        : () async {
                            setState(() => _isSendingTest = true);
                            await NotificationService.sendTestNotification();
                            if (!mounted) return;
                            setState(() => _isSendingTest = false);
                            AppNotificationDialog.show(context, type: NotificationType.success, title: 'Đã gửi! Kéo thanh thông báo xuống để xem.');
                          },
                  ),
                ),

                const SizedBox(height: 20),

                // Morning notification
                _buildNotifCard(
                  emoji: "🌅",
                  title: l10n.morningReminder,
                  subtitle: l10n.morningReminderDesc,
                  enabled: morningEnabled,
                  time: _formatTime(morningHour, morningMinute),
                  onToggle: (val) async {
                    setState(() => morningEnabled = val);
                    await _save();
                  },
                  onTimeTap: () => _pickTime(true),
                ),

                const SizedBox(height: 12),

                // Evening notification
                _buildNotifCard(
                  emoji: "🌙",
                  title: l10n.eveningReminder,
                  subtitle: l10n.eveningReminderDesc,
                  enabled: eveningEnabled,
                  time: _formatTime(eveningHour, eveningMinute),
                  onToggle: (val) async {
                    setState(() => eveningEnabled = val);
                    await _save();
                  },
                  onTimeTap: () => _pickTime(false),
                ),
              ],
            ),
    );
  }

  Widget _buildNotifCard({
    required String emoji,
    required String title,
    required String subtitle,
    required bool enabled,
    required String time,
    required ValueChanged<bool> onToggle,
    required VoidCallback onTimeTap,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
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
          ListTile(
            leading: Text(emoji, style: const TextStyle(fontSize: 28)),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: context.textPrimary,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: context.textSecondary),
            ),
            trailing: Switch(
              value: enabled,
              onChanged: onToggle,
              activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
              activeThumbColor: AppColors.primary,
            ),
          ),
          if (enabled) ...[
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.access_time,
                  color: AppColors.primary, size: 22),
              title: Text(
                l10n.reminderTime,
                style: TextStyle(fontSize: 14, color: context.textSecondary),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.textGreen,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: context.textSecondary),
                ],
              ),
              onTap: onTimeTap,
            ),
          ],
        ],
      ),
    );
  }
}
