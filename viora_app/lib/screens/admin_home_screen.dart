import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/viora_app_bar.dart';
import '../theme/app_theme.dart';
import 'admin_dashboard_tab.dart';
import 'admin_users_tab.dart';
import 'admin_posts_tab.dart';
import 'admin_plants_tab.dart';
import 'admin_settings_tab.dart';
import 'login_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;
  
  late final List<Widget> _tabsWithCallback;

  @override
  void initState() {
    super.initState();
    _tabsWithCallback = [
      AdminDashboardTab(onNavigateToTab: switchTab),
      const AdminUsersTab(),
      const AdminPostsTab(),
      const AdminPlantsTab(),
      const AdminSettingsTab(),
    ];
  }

  void switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VioraAppBar(
        title: _getTitle(),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _tabsWithCallback[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Người dùng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'Bài viết',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco),
            label: 'Cây',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Admin Dashboard';
      case 1:
        return 'Quản lý người dùng';
      case 2:
        return 'Quản lý bài viết';
      case 3:
        return 'Quản lý cây';
      case 4:
        return 'Cài đặt';
      default:
        return 'Admin';
    }
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      // Clear token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}
