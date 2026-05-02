import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/plant_widget.dart';
import '../widgets/viora_app_bar.dart';
import '../theme/app_theme.dart';
import 'habits_screen.dart';
import 'plant_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  Widget _buildScreen(int index) {
    switch (index) {
      case 0: return const _DashboardTab();
      case 1: return const HabitsScreen();
      case 2: return const PlantScreen();
      case 3: return const StatsScreen();
      case 4: return const ProfileScreen();
      default: return const _DashboardTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildScreen(_currentIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
            onTap: (i) => setState(() => _currentIndex = i),
            selectedItemColor: AppColors.primary,
            unselectedItemColor: const Color(0xFFBDBDBD),
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined, size: 24),
                activeIcon: Icon(Icons.home_rounded, size: 24),
                label: "Trang chủ",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_circle_outline_rounded, size: 24),
                activeIcon: Icon(Icons.check_circle_rounded, size: 24),
                label: "Thói quen",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.eco_outlined, size: 24),
                activeIcon: Icon(Icons.eco_rounded, size: 24),
                label: "Cây",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined, size: 24),
                activeIcon: Icon(Icons.bar_chart_rounded, size: 24),
                label: "Thống kê",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded, size: 24),
                activeIcon: Icon(Icons.person_rounded, size: 24),
                label: "Hồ sơ",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
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
    _loadData();
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
        plantType = prefs.getString("plant_type") ?? plant["plant_type"] ?? "sprout";
        plantLevel = plant["level"] ?? 1;
        plantExp = plant["experience"] ?? 0;
        plantWilted = plant["is_wilted"] == true;
      }

      isLoading = false;
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Chào buổi sáng";
    if (hour < 18) return "Chào buổi chiều";
    return "Chào buổi tối";
  }

  @override
  Widget build(BuildContext context) {
    final progress = totalToday == 0 ? 0.0 : completedToday / totalToday;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F1A0F) : const Color(0xFFF1F8E9);
    final gradColors = isDark
        ? [const Color(0xFF0F1A0F), const Color(0xFF1A2E1A), const Color(0xFF1E2E1E)]
        : [const Color(0xFFE8F5E9), const Color(0xFFF1F8E9), const Color(0xFFFAFDFA)];
    final cardColor = isDark ? const Color(0xFF1E2E1E) : Colors.white;

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
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getTodayLabel(),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
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
    final now = DateTime.now();
    const days = ["Thứ 2", "Thứ 3", "Thứ 4", "Thứ 5", "Thứ 6", "Thứ 7", "Chủ nhật"];
    final dayName = days[now.weekday - 1];
    return "$dayName, ${now.day}/${now.month}/${now.year}";
  }

  Widget _buildPlantCard() {
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
          const Row(
            children: [
              Text("🌿", style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text(
                "Cây của bạn",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
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
                        child: const Text(
                          "Hãy check-in để cây hồi phục! 💧",
                          style: TextStyle(
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
                          ? "Cây chưa được tưới 3 ngày rồi..."
                          : "Hoàn thành thói quen để cây lớn lên!",
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
                  "$currentStreak ngày liên tiếp",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "Giữ vững phong độ nhé! 💪",
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
          Column(
            children: [
              const Text("🏆", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 2),
              Text(
                "Best",
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
                  const Text(
                    "Hôm nay",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
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
                  "$completedToday/$totalToday",
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
                ? "Chưa có thói quen nào. Thêm ngay nhé! ✨"
                : allDone
                    ? "Tuyệt vời! Bạn đã hoàn thành tất cả hôm nay 🎉"
                    : "Còn ${totalToday - completedToday} thói quen chưa hoàn thành",
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
    const quotes = [
      "Mỗi ngày một bước nhỏ, tạo nên thay đổi lớn. 💪",
      "Thói quen tốt là nền tảng của cuộc sống lành mạnh. 🌿",
      "Kiên trì là chìa khóa của thành công. 🗝️",
      "Hôm nay tốt hơn hôm qua là đủ rồi. ✨",
      "Sức khỏe là tài sản quý giá nhất. 🏃",
    ];
    final quote = quotes[DateTime.now().day % quotes.length];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Row(
        children: [
          const Text("💬", style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              quote,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF388E3C),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
