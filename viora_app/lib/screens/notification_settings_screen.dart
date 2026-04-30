import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../widgets/app_snackbar.dart';

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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await NotificationService.getSettings();
    setState(() {
      morningEnabled = settings['morning_enabled'];
      eveningEnabled = settings['evening_enabled'];
      morningHour = settings['morning_hour'];
      morningMinute = settings['morning_minute'];
      eveningHour = settings['evening_hour'];
      eveningMinute = settings['evening_minute'];
      isLoading = false;
    });
  }

  Future<void> _save() async {
    await NotificationService.saveSettings(
      morningEnabled: morningEnabled,
      eveningEnabled: eveningEnabled,
      morningHour: morningHour,
      morningMinute: morningMinute,
      eveningHour: eveningHour,
      eveningMinute: eveningMinute,
    );
    if (!mounted) return;
    AppSnackbar.showSuccess(context, "Đã lưu cài đặt thông báo");
  }

  Future<void> _pickTime(bool isMorning) async {
    final initial = TimeOfDay(
      hour: isMorning ? morningHour : eveningHour,
      minute: isMorning ? morningMinute : eveningMinute,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF4CAF50),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Thông báo nhắc nhở",
          style: TextStyle(
              color: Color(0xFF1B5E20),
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFC8E6C9)),
                  ),
                  child: const Row(
                    children: [
                      Text("💡", style: TextStyle(fontSize: 20)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Thông báo sẽ nhắc bạn check-in thói quen mỗi ngày để cây phát triển.",
                          style: TextStyle(
                              fontSize: 13, color: Color(0xFF2E7D32)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Morning notification
                _buildNotifCard(
                  emoji: "🌅",
                  title: "Nhắc buổi sáng",
                  subtitle: "Bắt đầu ngày mới với thói quen lành mạnh",
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
                  title: "Nhắc buổi tối",
                  subtitle: "Hoàn thành thói quen trước khi ngủ",
                  enabled: eveningEnabled,
                  time: _formatTime(eveningHour, eveningMinute),
                  onToggle: (val) async {
                    setState(() => eveningEnabled = val);
                    await _save();
                  },
                  onTimeTap: () => _pickTime(false),
                ),

                const SizedBox(height: 24),

                // Test ngay
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await NotificationService.sendTestNotification();
                      if (!mounted) return;
                      AppSnackbar.showSuccess(
                          context, "Thông báo test sẽ hiện sau 10 giây!");
                    },
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: const Text("Gửi thông báo test ngay",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Áp dụng cài đặt
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await NotificationService.scheduleAll();
                      if (!mounted) return;
                      AppSnackbar.showSuccess(
                          context, "Đã lên lịch thông báo!");
                    },
                    icon: const Icon(Icons.notifications_active_outlined,
                        color: Color(0xFF4CAF50)),
                    label: const Text("Áp dụng cài đặt",
                        style: TextStyle(color: Color(0xFF4CAF50))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF4CAF50)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
            title: Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15)),
            subtitle: Text(subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            trailing: Switch(
              value: enabled,
              onChanged: onToggle,
              activeColor: const Color(0xFF4CAF50),
            ),
          ),
          if (enabled) ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.access_time,
                  color: Color(0xFF4CAF50), size: 22),
              title: const Text("Giờ nhắc",
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20)),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, color: Colors.grey),
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
