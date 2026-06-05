import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';

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

  @override
  void initState() {
    super.initState();
    _loadSettings();
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
        const Text(
          'Thông báo tự động',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        Card(
          child: ListTile(
            leading: const Icon(Icons.wb_sunny, color: Colors.orange),
            title: const Text('Thông báo buổi sáng'),
            subtitle: Text('Gửi lúc ${_morningTime.format(context)}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _selectTime(context, true),
          ),
        ),
        const SizedBox(height: 12),
        
        Card(
          child: ListTile(
            leading: const Icon(Icons.nightlight_round, color: Colors.indigo),
            title: const Text('Thông báo buổi tối'),
            subtitle: Text('Gửi lúc ${_eveningTime.format(context)}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _selectTime(context, false),
          ),
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
              activeColor: AppColors.primary,
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
              activeColor: AppColors.primary,
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
      ],
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
      
      // TODO: Save to backend/preferences
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã đặt thời gian ${isMorning ? "buổi sáng" : "buổi tối"}: ${picked.format(context)}',
            ),
          ),
        );
      }
    }
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
