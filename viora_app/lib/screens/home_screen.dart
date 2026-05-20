import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/plant_widget.dart';
import '../widgets/viora_app_bar.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';
import '../l10n/app_localizations.dart';
import 'habits_screen.dart';
import 'plant_screen.dart';
import 'community_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<_DashboardTabState> _dashboardKey = GlobalKey<_DashboardTabState>();

  Widget _buildScreen(int index) {
    switch (index) {
      case 0: return _DashboardTab(key: _dashboardKey);
      case 1: return const HabitsScreen();
      case 2: return const PlantScreen();
      case 3: return const CommunityScreen();
      case 4: return const StatsScreen();
      case 5: return const ProfileScreen();
      default: return _DashboardTab(key: _dashboardKey);
    }
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    
    // Reload dashboard when switching back to home tab
    if (index == 0 && _dashboardKey.currentState != null) {
      _dashboardKey.currentState!._loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                icon: const Icon(Icons.home_outlined, size: 24),
                activeIcon: const Icon(Icons.home_rounded, size: 24),
                label: AppLocalizations.of(context)!.home,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.check_circle_outline_rounded, size: 24),
                activeIcon: const Icon(Icons.check_circle_rounded, size: 24),
                label: AppLocalizations.of(context)!.habits,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.eco_outlined, size: 24),
                activeIcon: const Icon(Icons.eco_rounded, size: 24),
                label: AppLocalizations.of(context)!.plant,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.people_outline_rounded, size: 24),
                activeIcon: const Icon(Icons.people_rounded, size: 24),
                label: AppLocalizations.of(context)!.community,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.bar_chart_outlined, size: 24),
                activeIcon: const Icon(Icons.bar_chart_rounded, size: 24),
                label: AppLocalizations.of(context)!.stats,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline_rounded, size: 24),
                activeIcon: const Icon(Icons.person_rounded, size: 24),
                label: AppLocalizations.of(context)!.profile,
              ),
            ],
          ),
        ),
      ),
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
  int completedToday = 0;
  int totalToday = 0;
  bool isLoading = true;

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

    if (!mounted) return;
    setState(() {
      userName = profileRes["user"]?["name"] ?? "";
      currentStreak = streakRes["streak"]?["current_streak"] ?? 0;

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
      appBar: const VioraAppBar(showLogo: true),
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
    return Container(
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
              const Text("🌿", style: TextStyle(fontSize: 18)),
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
              child: Text("🔥", style: TextStyle(fontSize: 28)),
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
              const Text("🏆", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 2),
              Text(
                l10n.best,
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

  Widget _buildTodayCard(double progress) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E2E1E) : Colors.white;
    final allDone = completedToday == totalToday && totalToday > 0;
    return Container(
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
                    child: const Icon(Icons.today_rounded,
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
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFE8F5E9),
              valueColor: AlwaysStoppedAnimation<Color>(
                allDone ? const Color(0xFF2E7D32) : const Color(0xFF4CAF50),
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
          const Text("💬", style: TextStyle(fontSize: 24)),
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
