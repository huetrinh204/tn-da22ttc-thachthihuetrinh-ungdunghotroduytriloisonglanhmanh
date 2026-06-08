import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';
import '../screens/login_screen.dart';
import '../services/api_service.dart';
import '../widgets/app_snackbar.dart';

class AdminSettingsTab extends StatefulWidget {
  const AdminSettingsTab({super.key});

  @override
  State<AdminSettingsTab> createState() => _AdminSettingsTabState();
}

class _AdminSettingsTabState extends State<AdminSettingsTab> {
  TimeOfDay _morningTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 20, minute: 0);
  String _currentLanguage = 'vi';
  bool _isDarkMode = false;
  bool _isAutoReminderEnabled = false;
  bool _sendMorning = true;
  bool _sendEvening = true;
  List<dynamic> _reminderMessages = [];
  bool _isLoadingMessages = true;
  String _token = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
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
          _isAutoReminderEnabled = (settingsRes['is_enabled'] as int? ?? 0) == 1;
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
    final morningTimeStr = '${_morningTime.hour.toString().padLeft(2, '0')}:${_morningTime.minute.toString().padLeft(2, '0')}:00';
    final eveningTimeStr = '${_eveningTime.hour.toString().padLeft(2, '0')}:${_eveningTime.minute.toString().padLeft(2, '0')}:00';
    
    final res = await ApiService.updateAutoReminderSettings(
      _token,
      _isAutoReminderEnabled,
      morningTimeStr,
      eveningTimeStr,
      _sendMorning,
      _sendEvening,
    );
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(res['message'] ?? 'Đã cập nhật cài đặt'),
        backgroundColor: res['message']?.contains('success') ?? false 
            ? Colors.green 
            : null,
      ),
    );
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLanguage = prefs.getString('language_code') ?? 'vi';
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Auto Reminder Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Thông báo tự động',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              ? '✅ Đang bật - Tự động gửi nhắc nhở đến user chưa hoàn thành thói quen'
              : '⚠️ Đang tắt - Không gửi thông báo tự động',
          style: TextStyle(
            fontSize: 13,
            color: _isAutoReminderEnabled ? Colors.green : Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        
        // Time settings
        Card(
          child: Column(
            children: [
              CheckboxListTile(
                value: _sendMorning,
                onChanged: (value) {
                  setState(() => _sendMorning = value ?? true);
                  _saveReminderSettings();
                },
                title: const Text('Gửi buổi sáng'),
                subtitle: Text('Lúc ${_morningTime.format(context)}'),
                secondary: const Icon(Icons.wb_sunny, color: Colors.orange),
                activeColor: AppColors.primary,
              ),
              if (_sendMorning)
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                  child: ElevatedButton.icon(
                    onPressed: () => _selectTime(context, true),
                    icon: const Icon(Icons.access_time, size: 18),
                    label: const Text('Chọn giờ'),
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
                title: const Text('Gửi buổi tối'),
                subtitle: Text('Lúc ${_eveningTime.format(context)}'),
                secondary: const Icon(Icons.nightlight_round, color: Colors.indigo),
                activeColor: AppColors.primary,
              ),
              if (_sendEvening)
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                  child: ElevatedButton.icon(
                    onPressed: () => _selectTime(context, false),
                    icon: const Icon(Icons.access_time, size: 18),
                    label: const Text('Chọn giờ'),
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
            const Text(
              'Thông điệp nhắc nhở',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 28),
              onPressed: _showAddMessageDialog,
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Hệ thống sẽ chọn ngẫu nhiên 1 thông điệp mỗi ngày để gửi',
          style: TextStyle(fontSize: 12, color: Colors.grey),
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
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.message_outlined, 
                                size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              'Chưa có thông điệp nào',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: _reminderMessages.map((msg) {
                      final isActive = (msg['is_active'] as int? ?? 1) == 1;
                      return Card(
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
                              color: isActive ? null : Colors.grey,
                            ),
                          ),
                          subtitle: Text(
                            isActive ? 'Đang hoạt động' : 'Đã tắt',
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
                                    Text(isActive ? 'Tắt' : 'Bật'),
                                  ],
                                ),
                                onTap: () => _toggleMessageActive(msg),
                              ),
                              PopupMenuItem(
                                child: const Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('Sửa'),
                                  ],
                                ),
                                onTap: () => _showEditMessageDialog(msg),
                              ),
                              PopupMenuItem(
                                child: const Row(
                                  children: [
                                    Icon(Icons.delete, size: 20, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Xóa', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                                onTap: () => _deleteMessage(msg),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
        
        const SizedBox(height: 30),
        const Text(
          'Cài đặt ứng dụng',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        Card(
          child: ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Ngôn ngữ'),
            subtitle: Text(_currentLanguage == 'vi' ? 'Tiếng Việt' : 'English'),
            trailing: Switch(
              value: _currentLanguage == 'en',
              onChanged: (value) => _changeLanguage(value ? 'en' : 'vi'),
              activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
              activeThumbColor: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        Card(
          child: ListTile(
            leading: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
            title: const Text('Chế độ tối'),
            subtitle: Text(_isDarkMode ? 'Đang bật' : 'Đang tắt'),
            trailing: Switch(
              value: _isDarkMode,
              onChanged: _toggleDarkMode,
              activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
              activeThumbColor: AppColors.primary,
            ),
          ),
        ),
        
        const SizedBox(height: 30),
        const Text(
          'Quản lý dữ liệu',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        Card(
          child: ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Sao lưu dữ liệu'),
            subtitle: const Text('Backup database'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng đang phát triển')),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        
        Card(
          child: ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Báo cáo chi tiết'),
            subtitle: const Text('Xem báo cáo và phân tích'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng đang phát triển')),
              );
            },
          ),
        ),
        
        const SizedBox(height: 32),
        
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
              color: context.isDark 
                  ? Colors.red.shade700
                  : Colors.red.shade200,
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
                    size: 20
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Đăng xuất',
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
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Có'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isMorning) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isMorning ? _morningTime : _eveningTime,
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
        title: const Text('Thêm thông điệp mới'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Nhập nội dung thông điệp nhắc nhở...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              
              final res = await ApiService.addReminderMessage(_token, controller.text.trim());
              if (!mounted) return;
              
              if (res['message']?.contains('success') ?? false) {
                AppSnackbar.showSuccess(context, 'Đã thêm thông điệp mới');
                _loadReminderData();
              } else {
                AppSnackbar.showError(context, res['message'] ?? 'Thêm thất bại');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Thêm'),
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
          title: const Text('Sửa thông điệp'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Nhập nội dung thông điệp nhắc nhở...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
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
                  AppSnackbar.showSuccess(context, 'Đã cập nhật thông điệp');
                  _loadReminderData();
                } else {
                  AppSnackbar.showError(context, res['message'] ?? 'Cập nhật thất bại');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Lưu'),
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
          isActive ? 'Đã tắt thông điệp' : 'Đã bật thông điệp'
        );
        _loadReminderData();
      } else {
        AppSnackbar.showError(context, res['message'] ?? 'Thao tác thất bại');
      }
    });
  }

  void _deleteMessage(Map<String, dynamic> msg) async {
    // Delay to avoid popup menu conflict
    Future.delayed(const Duration(milliseconds: 100), () async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Xóa thông điệp'),
          content: const Text('Bạn có chắc chắn muốn xóa thông điệp này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Xóa'),
            ),
          ],
        ),
      );
      
      if (confirmed != true) return;
      
      final res = await ApiService.deleteReminderMessage(_token, msg['id'].toString());
      if (!mounted) return;
      
      if (res['message']?.contains('success') ?? false) {
        AppSnackbar.showSuccess(context, 'Đã xóa thông điệp');
        _loadReminderData();
      } else {
        AppSnackbar.showError(context, res['message'] ?? 'Xóa thất bại');
      }
    });
  }

  Future<void> _changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    
    setState(() {
      _currentLanguage = languageCode;
    });
    
    if (context.mounted) {
      final localeProvider = LocaleProvider.global;
      await localeProvider.setLocale(Locale(languageCode));
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              languageCode == 'vi' ? 'Đã chuyển sang Tiếng Việt' : 'Changed to English',
            ),
          ),
        );
      }
    }
  }

  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    
    setState(() {
      _isDarkMode = value;
    });
    
    // TODO: Implement dark mode theme switching
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'Chế độ tối đang phát triển' : 'Chế độ sáng',
          ),
        ),
      );
    }
  }
}
