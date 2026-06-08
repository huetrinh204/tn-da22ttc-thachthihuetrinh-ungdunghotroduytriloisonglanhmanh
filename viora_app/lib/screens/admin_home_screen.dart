import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/viora_app_bar.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: VioraAppBar(
        title: _getTitle(l10n),
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
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: l10n.users,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.article),
            label: l10n.postsLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.eco),
            label: l10n.plants,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }

  String _getTitle(AppLocalizations l10n) {
    switch (_currentIndex) {
      case 0:
        return l10n.adminDashboard;
      case 1:
        return l10n.adminUsers;
      case 2:
        return l10n.adminPosts;
      case 3:
        return l10n.adminPlants;
      case 4:
        return l10n.adminSettings;
      default:
        return l10n.admin;
    }
  }

  Future<void> _logout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.logout),
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
