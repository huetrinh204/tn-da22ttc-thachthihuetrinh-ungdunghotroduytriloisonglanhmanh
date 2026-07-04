import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/flow_prefs.dart';
import '../navigation/app_navigation.dart';
import '../navigation/app_tabs.dart';
import '../widgets/level_up_animation.dart';
import '../widgets/plant_widget.dart';
import '../widgets/viora_app_bar.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../theme/theme_extensions.dart';
import '../l10n/app_localizations.dart';
import '../constants/app_icons.dart';
import 'grow_screen.dart';
import 'community_screen.dart';
import 'profile_screen.dart';
import 'onboarding_screen.dart';
import '../services/notification_inbox_store.dart';
import 'notifications_inbox_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  final GlobalKey<_DashboardTabState> _dashboardKey = GlobalKey<_DashboardTabState>();
  double _bubbleDx = -1; // -1 = chưa khởi tạo
  double _bubbleDy = -1;
  int _growScreenVersion = 0; // increments to force GrowScreen rebuild after habit changes

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppNavigation.onSwitchTab = switchToTab;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeOpenHabitsAfterOnboarding();
      _checkAndShowGlobalPlantLevelUp();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndShowGlobalPlantLevelUp();
    }
  }

  Future<void> _maybeOpenHabitsAfterOnboarding() async {
    if (!await FlowPrefs.consumeOpenHabitsAfterOnboarding()) return;
    _currentIndex = AppTabs.today;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppNavigation.openHabits();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (AppNavigation.onSwitchTab == switchToTab) {
      AppNavigation.onSwitchTab = null;
    }
    super.dispose();
  }

  int _calculatePlantLevel(int exp) {
    const thresholds = [0, 5, 15, 30, 50, 75, 105, 140, 180, 225, 275, 330, 390, 455, 525];
    for (int i = thresholds.length - 1; i >= 0; i--) {
      if (exp >= thresholds[i]) return i + 1;
    }
    return 1;
  }

  Future<void> _showLevelUpDialog(Map<String, dynamic>? plantData) async {
    if (plantData == null) return;

    final exp = plantData["experience"] ?? 0;
    final newLevel = _calculatePlantLevel(exp);
    final prefs = await SharedPreferences.getInstance();
    const key = "last_seen_plant_level";
    final lastSeen = prefs.getInt(key);

    if (lastSeen == null) {
      await prefs.setInt(key, newLevel);
      return;
    }
    if (newLevel <= lastSeen) return;
    if (newLevel > lastSeen + 1) {
      await prefs.setInt(key, newLevel);
      return;
    }

    await prefs.setInt(key, newLevel);

    final lang = prefs.getString('language_code') ?? 'vi';
    if (lang == 'en') {
      await NotificationInboxStore.add(
        title: 'Congratulations on Level Up! 🎉',
        body: 'Your virtual plant has successfully leveled up to Level $newLevel! Keep up the good work!',
        emoji: '🌳',
        targetTab: 3,
      );
    } else {
      await NotificationInboxStore.add(
        title: 'Chúc mừng lên cấp! 🎉',
        body: 'Cây ảo của bạn đã nâng cấp thành công lên Cấp $newLevel! Hãy tiếp tục duy trì thói quen tốt nhé!',
        emoji: '🌳',
        targetTab: 3,
      );
    }

    if (!mounted) return;

    showDialog(
      context: AppNavigation.navigatorKey.currentContext!,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (ctx) => LevelUpAnimation(
        plantType: plantData["plant_type"] ?? "bamboo",
        oldLevel: lastSeen.clamp(1, 15),
        newLevel: newLevel.clamp(1, 15),
        onComplete: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  Future<void> _checkAndShowGlobalPlantLevelUp([Map<String, dynamic>? plantData]) async {
    if (plantData != null) {
      await _showLevelUpDialog(plantData);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    if (token.isEmpty) return;
    final res = await ApiService.getPlant(token);
    if (!mounted) return;
    await _showLevelUpDialog(res["plant"] as Map<String, dynamic>?);
  }

  void switchToTab(int index) {
    _onTabTapped(AppTabs.normalize(index));
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case AppTabs.today:
        return _DashboardTab(
          key: _dashboardKey,
          onPlantLoaded: _checkAndShowGlobalPlantLevelUp,
          onHabitCheckInCompleted: (plant) async {
            if (plant != null) await _checkAndShowGlobalPlantLevelUp(plant);
            setState(() => _growScreenVersion++);
          },
        );
      case AppTabs.community:
        return const CommunityScreen();
      case AppTabs.grow:
        return GrowScreen(
          key: ValueKey('grow_$_growScreenVersion'),
          onCheckInCompleted: (plant) async {
            if (plant != null) await _checkAndShowGlobalPlantLevelUp(plant);
          },
        );
      case AppTabs.me:
        return const ProfileScreen();
      default:
        return _DashboardTab(key: _dashboardKey);
    }
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    
    // Reload dashboard when switching back to home tab
    if (index == AppTabs.today && _dashboardKey.currentState != null) {
      _dashboardKey.currentState!._loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        Scaffold(
          body: _buildScreen(_currentIndex),
          bottomNavigationBar: _buildBottomNavBar(context),
        ),
        // Floating AI Coach chat bubble — draggable
        Positioned(
          left: _bubbleDx < 0 ? screenWidth - 72 : _bubbleDx,
          top: _bubbleDy < 0 ? screenHeight - 180 : _bubbleDy,
          child: GestureDetector(
            onTap: () => AppNavigation.openAiChat(),
            onPanUpdate: (details) {
              setState(() {
                final currentX = _bubbleDx < 0 ? screenWidth - 72 : _bubbleDx;
                final currentY = _bubbleDy < 0 ? screenHeight - 180 : _bubbleDy;
                _bubbleDx = (currentX + details.delta.dx).clamp(0, screenWidth - 56);
                _bubbleDy = (currentY + details.delta.dy).clamp(0, screenHeight - 160);
              });
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/CHAT_AI.png',
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final navItems = [
      _NavItem(icon: AppIcons.home, label: l10n.today),
      _NavItem(icon: AppIcons.community, label: l10n.community),
      _NavItem(icon: AppIcons.growth, label: l10n.grow),
      _NavItem(icon: AppIcons.profile, label: l10n.navMe),
    ];
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (i) {
              final item = navItems[i];
              final isSelected = _currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onTabTapped(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 22,
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _DashboardTab extends StatefulWidget {
  final void Function([Map<String, dynamic>? plantData])? onPlantLoaded;
  final Future<void> Function(Map<String, dynamic>? plant)? onHabitCheckInCompleted;

  const _DashboardTab({super.key, this.onPlantLoaded, this.onHabitCheckInCompleted});

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> with WidgetsBindingObserver {
  String userName = "";
  int currentStreak = 0;
  int longestStreak = 0;
  int completedToday = 0;
  int totalToday = 0;
  bool isLoading = true;
  bool profileIncomplete = false;
  int unreadNotificationsCount = 0;
  List _todayHabits = [];
  List _notifications = [];
  String _token = '';

  // Plant data
  String plantType = "bamboo";
  int plantLevel = 1;
  int plantExp = 0;
  bool plantWilted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("token") ?? "";

    final profileRes = await ApiService.getProfile(_token);
    final streakRes = await ApiService.getStreak(_token);
    final habitsRes = await ApiService.getTodayHabits(_token);
    final plantRes = await ApiService.getPlant(_token);
    final incomplete = await FlowPrefs.isProfileIncomplete();
    
    // Load community notifications unread count
    final notificationsRes = await ApiService.getNotifications(_token);
    int unread = 0;
    List notifList = [];
    if (notificationsRes["notifications"] != null) {
      notifList = notificationsRes["notifications"] as List;
      final lastSeenStr = prefs.getString('notifications_last_seen_at');
      final lastSeen = lastSeenStr != null ? DateTime.tryParse(lastSeenStr) : null;
      for (final n in notifList) {
        final isRead = (n['is_read'] as int? ?? 0) == 1;
        if (isRead) continue;
        // For community notifs (like/comment/follow), check against last seen timestamp
        if (lastSeen != null) {
          try {
            final createdAt = DateTime.parse(n['created_at'].toString());
            if (!createdAt.isAfter(lastSeen)) continue;
          } catch (_) {}
        }
        unread++;
      }
    }

    if (!mounted) return;
    setState(() {
      userName = profileRes["user"]?["name"] ?? "";
      currentStreak = streakRes["streak"]?["current_streak"] ?? 0;
      longestStreak = streakRes["streak"]?["longest_streak"] ?? 0;
      profileIncomplete = incomplete;
      unreadNotificationsCount = unread;
      _notifications = notifList;

      _todayHabits = habitsRes["habits"] as List? ?? [];
      totalToday = _todayHabits.length;
      completedToday = _todayHabits.where((h) => h["is_completed"] == 1).length;

      // Plant
      final plant = plantRes["plant"];
      if (plant != null) {
        plantType = plant["plant_type"] ?? "bamboo";
        plantExp = plant["experience"] ?? 0;
        plantLevel = _calculateLevel(plantExp);
        plantWilted = plant["is_wilted"] == true;
      }

      isLoading = false;
    });

    _maybeShowStreakRecovery();
    _maybePromptFirstHabit();
    widget.onPlantLoaded?.call(plantRes["plant"]);
  }

  Future<void> _maybePromptFirstHabit() async {
    if (!mounted || totalToday > 0) return;
    if (!await FlowPrefs.consumePendingFirstHabitNudge()) return;

    final l10n = AppLocalizations.of(context)!;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || totalToday > 0) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.afterOnboardingNoHabitsTitle),
          content: Text(l10n.afterOnboardingNoHabitsBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                AppNavigation.openHabits();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.createFirstHabit),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _maybeShowStreakRecovery() async {
    if (!mounted) return;
    if (currentStreak > 0) return;
    if (longestStreak < 1) return;
    if (await FlowPrefs.wasStreakRecoveryDismissedToday()) return;

    final l10n = AppLocalizations.of(context)!;
  WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.streakBrokenTitle),
          content: Text(l10n.streakBrokenBody),
          actions: [
            TextButton(
              onPressed: () async {
                await FlowPrefs.dismissStreakRecoveryForToday();
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                await FlowPrefs.dismissStreakRecoveryForToday();
                if (ctx.mounted) Navigator.pop(ctx);
                AppNavigation.openHabits();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.startFreshStreak),
            ),
          ],
        ),
      );
    });
  }

  // Calculate level based on experience (15 levels system)
  int _calculateLevel(int exp) {
    const thresholds = [0, 5, 15, 30, 50, 75, 105, 140, 180, 225, 275, 330, 390, 455, 525];
    
    for (int i = thresholds.length - 1; i >= 0; i--) {
      if (exp >= thresholds[i]) {
        return i + 1;
      }
    }
    return 1;
  }

  String _getGreeting() {
    final l10n = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 18) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  Widget _buildNotificationButton() {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(AppIcons.notifications, size: 24),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsInboxScreen()),
            );
            // Reload data to update unread count
            _loadData();
          },
        ),
        if (unreadNotificationsCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Center(
                child: Text(
                  '$unreadNotificationsCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: VioraAppBar(
        showLogo: true,
        actions: [
          _buildNotificationButton(),
        ],
      ),
      body: isLoading
        ? Center(child: CircularProgressIndicator(color: AppColors.primary))
        : RefreshIndicator(
            onRefresh: _loadData,
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                if (profileIncomplete) ...[
                  _buildProfileIncompleteBanner(),
                  const SizedBox(height: 16),
                ],
                // Greeting
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      "${_getGreeting()}${userName.isNotEmpty ? ', $userName' : ''}",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: context.textPrimary,
                      ),
                    ),

                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _getTodayLabel(),
                  style: TextStyle(fontSize: 14, color: context.textSecondary),
                ),
                const SizedBox(height: 24),

                // Streak card
                _buildStreakCard(),
                const SizedBox(height: 16),

                // Plant card
                _buildPlantCard(),
                const SizedBox(height: 16),

                // Today's Habits section
                _buildHabitsSection(),
                const SizedBox(height: 16),

                // Community section
                _buildCommunitySection(),
                const SizedBox(height: 16),

                // Motivational quote
                _buildQuoteCard(),
              ],
            ),
          ),
    );
  }

  String _getTodayLabel() {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final days = [l10n.monday, l10n.tuesday, l10n.wednesday, l10n.thursday, l10n.friday, l10n.saturday, l10n.sunday];
    final dayName = days[now.weekday - 1];
    return "$dayName, ${now.day}/${now.month}/${now.year}";
  }

  Widget _buildPlantCard() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.surface;
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => AppNavigation.openGrow(),
        borderRadius: BorderRadius.circular(20),
        child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.sprout, size: 20, color: context.textGreen),
              const SizedBox(width: 8),
              Text(
                l10n.yourPlant,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              PlantWidget(
                plantType: plantType,
                level: plantLevel,
                isWilted: plantWilted,
                size: 60,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (plantWilted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l10n.plantWilted,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.red),
                        ),
                      )
                    else
                      PlantProgressBar(
                        experience: plantExp,
                        level: plantLevel,
                      ),
                    const SizedBox(height: 8),
                    Text(
                      plantWilted
                          ? l10n.plantNotWatered
                          : l10n.completeHabitsToGrow,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildProfileIncompleteBanner() {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: const Color(0xFFFFF8E1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          ).then((_) => _loadData());
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text('✨', style: TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.completeProfileBanner,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.completeProfileBannerAction,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8D6E63),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: context.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
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
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(AppIcons.streak, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.daysStreak(currentStreak),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.keepItUp,
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
          Column(
            children: [
              const Icon(AppIcons.trophy, color: Colors.amber, size: 24),
              const SizedBox(height: 2),
              Text(
                "$longestStreak",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                l10n.longestStreakLabel,
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsSection() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final allDone = completedToday == totalToday && totalToday > 0;

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(AppIcons.calendarCheck,
                          color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${l10n.habits} ${l10n.today.toLowerCase()}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: allDone
                        ? AppColors.primaryLight
                        : AppColors.border.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.completed(completedToday, totalToday),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: allDone
                          ? AppColors.primaryDark
                          : context.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_todayHabits.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(AppIcons.calendarCheck, size: 40, color: context.textSecondary.withValues(alpha: 0.5)),
                      const SizedBox(height: 8),
                      Text(
                        l10n.noHabitsYet,
                        style: TextStyle(color: context.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...(() {
                final display = List<Map<String, dynamic>>.from(_todayHabits)
                  ..sort((a, b) {
                    final aDone = a["is_completed"] == 1 ? 1 : 0;
                    final bDone = b["is_completed"] == 1 ? 1 : 0;
                    return aDone.compareTo(bDone);
                  });
                final limited = display.take(3).toList();
                return List.generate(limited.length, (i) {
                final h = limited[i];
                final isHabitCompleted = h["is_completed"] == 1;
                final habitName = h["name"] ?? "";
                final target = double.tryParse(h["target_count"]?.toString() ?? '') ?? 1.0;
                final current = double.tryParse(h["completed_count"]?.toString() ?? '') ?? (isHabitCompleted ? target : 0.0);
                final habitProgress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

                return Padding(
                  padding: EdgeInsets.only(bottom: i < _todayHabits.length - 1 ? 8 : 0),
                  child: Material(
                    color: isHabitCompleted
                        ? AppColors.primaryLight
                        : (isDark ? AppColors.darkBackground : AppColors.background),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () async {
                        await AppNavigation.openHabits(onCheckInCompleted: widget.onHabitCheckInCompleted);
                        _loadData();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            if (isHabitCompleted)
                              const Icon(AppIcons.checkCircle, color: AppColors.primary, size: 22)
                            else
                              Icon(Icons.circle_outlined, color: AppColors.border, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    habitName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isHabitCompleted
                                          ? AppColors.primary
                                          : context.textPrimary,
                                      decoration: isHabitCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: habitProgress,
                                      minHeight: 4,
                                      backgroundColor: AppColors.border.withValues(alpha: 0.3),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isHabitCompleted ? AppColors.primary : AppColors.primaryLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${current.toInt()}/${target.toInt()}",
                              style: TextStyle(
                                fontSize: 12,
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });
            }()),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.center,
              child: TextButton.icon(
                onPressed: () async {
                  await AppNavigation.openHabits(onCheckInCompleted: widget.onHabitCheckInCompleted);
                  _loadData();
                },
                icon: const Icon(AppIcons.chevronRight, size: 16),
                label: Text(totalToday > 0 ? l10n.viewAllHabits : l10n.addHabit),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunitySection() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.surface;

    final recent = _notifications
      .where((n) => (n['is_read'] as int? ?? 0) == 0)
      .take(3)
      .toList();

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => AppNavigation.openCommunity(),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(AppIcons.community,
                        color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.community,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (unreadNotificationsCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$unreadNotificationsCount',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              if (recent.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      l10n.noCommunityActivity,
                      style: TextStyle(color: context.textSecondary),
                    ),
                  ),
                )
              else ...[
                const SizedBox(height: 12),
                ...recent.map((n) => _buildNotifItem(n)),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.viewInCommunity,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios,
                      size: 12, color: AppColors.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotifItem(Map n) {
    final l10n = AppLocalizations.of(context)!;
    final type = n['type'] as String? ?? 'like';
    final userName = (n['actor_name'] ?? n['user_name']) as String? ?? 'Unknown';

    IconData icon;
    Color iconColor;
    String message;

    switch (type) {
      case 'like':
        icon = Icons.favorite;
        iconColor = Colors.red;
        message = l10n.notifLike(userName);
      case 'comment':
        icon = Icons.chat_bubble_outline;
        iconColor = AppColors.primary;
        message = l10n.notifComment(userName);
      case 'follow':
        icon = Icons.person_add;
        iconColor = Colors.blue;
        message = l10n.notifFollow(userName);
      case 'warning':
        icon = Icons.warning_amber;
        iconColor = Colors.orange;
        message = n['title'] as String? ?? l10n.notifWarning;
      case 'post_reported':
        icon = Icons.flag;
        iconColor = Colors.orange;
        message = n['title'] as String? ?? 'Báo cáo bài viết';
      case 'post_edited':
        icon = Icons.edit;
        iconColor = AppColors.primary;
        message = n['title'] as String? ?? l10n.notifPostEdited;
      case 'warning_cleared':
        icon = Icons.check_circle;
        iconColor = AppColors.success;
        message = n['title'] as String? ?? l10n.notifWarningCleared;
      case 'new_post':
        icon = AppIcons.add;
        iconColor = AppColors.primary;
        message = l10n.notifNewPost(userName);
      default:
        icon = Icons.notifications;
        iconColor = AppColors.primary;
        message = l10n.notifDefaultActivity(userName);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: context.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard() {
    final l10n = AppLocalizations.of(context)!;
    final quotes = [
      l10n.quote1,
      l10n.quote2,
      l10n.quote3,
      l10n.quote4,
      l10n.quote5,
    ];
    final quote = quotes[DateTime.now().day % quotes.length];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.infoBoxColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.infoBoxBorder),
      ),
      child: Row(
        children: [
          Icon(AppIcons.quote, size: 24, color: context.textGreenLight),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              quote,
              style: TextStyle(
                fontSize: 14,
                color: context.textGreenLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
