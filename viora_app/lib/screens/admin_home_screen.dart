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
  double _bubbleDx = -1;
  double _bubbleDy = -1;

  @override
  void initState() {
    super.initState();
    _tabsWithCallback = [
      AdminDashboardTab(onNavigateToTab: switchTab),
      const AdminUsersTab(),
      const AdminPostsTab(),
      const AdminHabitsTab(),
      const AdminSettingsTab(),
    ];
  }

  void switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  void _openAiChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: VioraAppBar(
            title: Localizations.localeOf(context).languageCode == 'vi' ? 'Trợ lý AI' : 'AI Assistant',
            showBack: true,
          ),
          body: const AdminAiAssistantTab(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (_tabsWithCallback.length > 5) {
      _tabsWithCallback = [
        AdminDashboardTab(onNavigateToTab: switchTab),
        const AdminUsersTab(),
        const AdminPostsTab(),
        const AdminHabitsTab(),
        const AdminSettingsTab(),
      ];
    }
    if (_currentIndex >= _tabsWithCallback.length) _currentIndex = 0;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Scaffold(
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
            ],
          ),
        ),
        // Floating AI chat bubble — draggable
        Positioned(
          left: _bubbleDx < 0 ? screenWidth - 72 : _bubbleDx,
          top: _bubbleDy < 0 ? screenHeight - 220 : _bubbleDy,
          child: GestureDetector(
            onTap: _openAiChat,
            onPanUpdate: (details) {
              setState(() {
                final currentX = _bubbleDx < 0 ? screenWidth - 72 : _bubbleDx;
                final currentY = _bubbleDy < 0 ? screenHeight - 220 : _bubbleDy;
                _bubbleDx = (currentX + details.delta.dx).clamp(0, screenWidth - 56);
                _bubbleDy = (currentY + details.delta.dy).clamp(0, screenHeight - 160);
              });
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ],
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
      default:
        return l10n.admin;
    }
  }
}
