import 'package:flutter/material.dart';
import '../widgets/viora_app_bar.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../constants/app_icons.dart';
import 'admin_dashboard_tab.dart';
import 'admin_users_tab.dart';
import 'admin_posts_tab.dart';
import 'admin_habits_tab.dart';
import 'admin_settings_tab.dart';
import 'admin_ai_assistant_tab.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;
  
  List<Widget> _tabsWithCallback = [];

  @override
  void initState() {
    super.initState();
    _initTabs();
  }

  void _initTabs() {
    _tabsWithCallback = [
      AdminDashboardTab(onNavigateToTab: switchTab),
      const AdminUsersTab(),
      const AdminPostsTab(),
      const AdminHabitsTab(),
      const AdminSettingsTab(),
      const AdminAiAssistantTab(),
    ];
  }

  void switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (_tabsWithCallback.length < 6) _initTabs();
    if (_currentIndex >= _tabsWithCallback.length) _currentIndex = 0;
    
    return Scaffold(
      appBar: VioraAppBar(
        title: _getTitle(l10n),
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
            icon: const Icon(AppIcons.dashboard),
            label: l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(AppIcons.users),
            label: l10n.users,
          ),
          BottomNavigationBarItem(
            icon: const Icon(AppIcons.message),
            label: l10n.postsLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(AppIcons.habits),
            label: l10n.habitsLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(AppIcons.settings),
            label: l10n.settings,
          ),
          BottomNavigationBarItem(
            icon: const Icon(AppIcons.aiChat),
            label: 'AI',
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
        return l10n.adminHabits;
      case 4:
        return l10n.adminSettings;
      case 5:
        return Localizations.localeOf(context).languageCode == 'vi' ? 'Trợ lý AI' : 'AI Assistant';
      default:
        return l10n.admin;
    }
  }
}
