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
import '../theme/theme_extensions.dart';
import '../l10n/app_localizations.dart';
import '../constants/app_icons.dart';
import 'habits_screen.dart';
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
  static const String _lastSeenPlantLevelKey = "last_seen_plant_level";
  int _currentIndex = 0;
  final GlobalKey<_DashboardTabState> _dashboardKey = GlobalKey<_DashboardTabState>();
  bool _isCheckingPlantLevel = false;
  bool _showGlobalLevelUpAnimation = false;
  int? _levelUpFromLevel;
  int? _levelUpToLevel;
  String _globalPlantType = "sprout";

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
    switchToTab(AppTabs.habits);
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

  Future<void> _checkAndShowGlobalPlantLevelUp() async {
    if (_isCheckingPlantLevel || _showGlobalLevelUpAnimation) return;
    _isCheckingPlantLevel = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";
      if (token.isEmpty) return;

      final res = await ApiService.getPlant(token);
      if (!mounted) return;
      final plant = res["plant"];
      if (plant == null) return;

      final exp = plant["experience"] ?? 0;
      final newLevel = _calculatePlantLevel(exp);
      final lastSeenLevel = prefs.getInt(_lastSeenPlantLevelKey);
      if (lastSeenLevel == null) {
        await prefs.setInt(_lastSeenPlantLevelKey, newLevel);
        return;
      }
      if (newLevel <= lastSeenLevel) return;

      setState(() {
        _globalPlantType = (plant["plant_type"] ?? "sprout").toString();
        _levelUpFromLevel = lastSeenLevel.clamp(1, 15);
        _levelUpToLevel = newLevel.clamp(1, 15);
        _showGlobalLevelUpAnimation = true;
      });

      // Add level up notification
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
    } finally {
      _isCheckingPlantLevel = false;
    }
  }

  Future<void> _onHabitCheckInCompleted() async {
    await _checkAndShowGlobalPlantLevelUp();
  }

  void switchToTab(int index) {
    _onTabTapped(AppTabs.normalize(index));
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case AppTabs.today:
        return _DashboardTab(key: _dashboardKey);
      case AppTabs.habits:
        return HabitsScreen(onHabitCheckInCompleted: _onHabitCheckInCompleted);
      case AppTabs.community:
        return const CommunityScreen();
      case AppTabs.grow:
        return const GrowScreen();
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
    final globalLevelUpOverlay =
        _showGlobalLevelUpAnimation && _levelUpFromLevel != null && _levelUpToLevel != null
            ? LevelUpAnimation(
                plantType: _globalPlantType,
                oldLevel: _levelUpFromLevel!,
                newLevel: _levelUpToLevel!,
                onComplete: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setInt(_lastSeenPlantLevelKey, _levelUpToLevel!);
                  if (!mounted) return;
                  setState(() {
                    _showGlobalLevelUpAnimation = false;
                    _levelUpFromLevel = null;
                    _levelUpToLevel = null;
                  });
                },
              )
            : null;
    return Stack(
      children: [
        Scaffold(
          body: _buildScreen(_currentIndex),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurface
                  : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: _onTabTapped,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: const Color(0xFFBDBDBD),
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkSurface
                    : Colors.white,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedFontSize: 11,
                unselectedFontSize: 11,
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(AppIcons.home, size: 22),
                    activeIcon: const Icon(AppIcons.home, size: 22),
                    label: AppLocalizations.of(context)!.today,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(AppIcons.habits, size: 22),
                    activeIcon: const Icon(AppIcons.habits, size: 22),
                    label: AppLocalizations.of(context)!.habits,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(AppIcons.community, size: 22),
                    activeIcon: const Icon(AppIcons.community, size: 22),
                    label: AppLocalizations.of(context)!.community,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(AppIcons.growth, size: 22),
                    activeIcon: const Icon(AppIcons.growth, size: 22),
                    label: AppLocalizations.of(context)!.grow,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(AppIcons.profile, size: 22),
                    activeIcon: const Icon(AppIcons.profile, size: 22),
                    label: AppLocalizations.of(context)!.navMe,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (globalLevelUpOverlay != null) globalLevelUpOverlay,
      ],
    );
  }
}

class _DashboardTab extends StatefulWidget {
  const _DashboardTab({super.key});

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

  // Plant data
  String plantType = "sprout";
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
    final token = prefs.getString("token") ?? "";

    final profileRes = await ApiService.getProfile(token);
    final streakRes = await ApiService.getStreak(token);
    final habitsRes = await ApiService.getTodayHabits(token);
    final plantRes = await ApiService.getPlant(token);
    final incomplete = await FlowPrefs.isProfileIncomplete();
    
    // Load community notifications unread count
    final notificationsRes = await ApiService.getNotifications(token);
    int unread = 0;
    if (notificationsRes["notifications"] != null) {
      final notifs = notificationsRes["notifications"] as List;
      // Count only unread notifications (is_read = 0)
      unread = notifs.where((n) => (n['is_read'] as int? ?? 0) == 0).length;
    }

    if (!mounted) return;
    setState(() {
      userName = profileRes["user"]?["name"] ?? "";
      currentStreak = streakRes["streak"]?["current_streak"] ?? 0;
      longestStreak = streakRes["streak"]?["longest_streak"] ?? 0;
      profileIncomplete = incomplete;
      unreadNotificationsCount = unread;

      final habits = habitsRes["habits"] as List? ?? [];
      totalToday = habits.length;
      completedToday = habits.where((h) => h["is_completed"] == 1).length;

      // Plant
      final plant = plantRes["plant"];
      if (plant != null) {
        plantType = plant["plant_type"] ?? "sprout";
        plantExp = plant["experience"] ?? 0;
        plantLevel = _calculateLevel(plantExp);
        plantWilted = plant["is_wilted"] == true;
      }

      isLoading = false;
    });

    _maybeShowStreakRecovery();
    _maybePromptFirstHabit();
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          icon: const Icon(AppIcons.notifications,
              color: AppColors.primary, size: 24),
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
    final progress = totalToday == 0 ? 0.0 : completedToday / totalToday;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F1A0F) : const Color(0xFFF1F8E9);
    final gradColors = isDark
        ? [const Color(0xFF0F1A0F), const Color(0xFF1A2E1A), const Color(0xFF1E2E1E)]
        : [const Color(0xFFE8F5E9), const Color(0xFFF1F8E9), const Color(0xFFFAFDFA)];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: VioraAppBar(
        showLogo: true,
        actions: [
          _buildNotificationButton(),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradColors,
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFF4CAF50),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (profileIncomplete) ...[
                    _buildProfileIncompleteBanner(),
                    const SizedBox(height: 16),
                  ],
                  // Greeting
                  Text(
                    "${_getGreeting()}${userName.isNotEmpty ? ', $userName' : ''} 👋",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
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

                  // Today progress card
                  _buildTodayCard(progress),
                  const SizedBox(height: 16),

                  // Motivational quote
                  _buildQuoteCard(),
                ],
              ),
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
    final cardColor = isDark ? const Color(0xFF1E2E1E) : Colors.white;
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
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          ).then((_) => _loadData());
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.completeProfileBanner,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    const SizedBox(height: 4),
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
              const Icon(Icons.chevron_right, color: Color(0xFF8D6E63)),
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
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
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

  Color _getProgressColor(double progress) {
    if (progress == 0.0) {
      return const Color(0xFFD32F2F); // Red
    }
    if (progress < 0.35) {
      return Color.lerp(
        const Color(0xFFD32F2F), // Red
        const Color(0xFFF57C00), // Orange
        progress / 0.35,
      )!;
    } else if (progress < 0.7) {
      return Color.lerp(
        const Color(0xFFF57C00), // Orange
        const Color(0xFFFBC02D), // Amber/Yellow
        (progress - 0.35) / 0.35,
      )!;
    } else if (progress < 1.0) {
      return Color.lerp(
        const Color(0xFFFBC02D), // Amber/Yellow
        const Color(0xFF4CAF50), // Green
        (progress - 0.7) / 0.3,
      )!;
    } else {
      return const Color(0xFF2E7D32); // Deep Green
    }
  }

  Widget _buildTodayCard(double progress) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E2E1E) : Colors.white;
    final allDone = completedToday == totalToday && totalToday > 0;
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => AppNavigation.openHabits(),
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
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(AppIcons.calendarCheck,
                            color: Color(0xFF2E7D32), size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        l10n.today,
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
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.completed(completedToday, totalToday),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: allDone
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFF666666),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: totalToday == 0
                      ? 0.0
                      : (completedToday == 0 ? 0.06 : progress),
                  minHeight: 10,
                  backgroundColor: (totalToday > 0 && completedToday == 0)
                      ? const Color(0xFFFFEBEE)
                      : const Color(0xFFE8F5E9),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    totalToday == 0
                        ? const Color(0xFFBDBDBD)
                        : _getProgressColor(progress),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                totalToday == 0
                    ? l10n.noHabitsYet
                    : allDone
                        ? l10n.allDoneToday
                        : l10n.habitsRemaining(totalToday - completedToday),
                style: TextStyle(
                  fontSize: 13,
                  color: allDone ? const Color(0xFF2E7D32) : Colors.grey,
                  fontWeight: allDone ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
              if (totalToday == 0) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.tapToAddFirstHabit,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
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
