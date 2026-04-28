import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/plant_widget.dart';
import 'login_screen.dart';
import 'habits_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _DashboardTab(),
    const HabitsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Trang chủ",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            activeIcon: Icon(Icons.check_circle),
            label: "Thói quen",
          ),
        ],
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

  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("onboarding_done");
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Viora 🌱",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            onPressed: _handleLogout,
            tooltip: "Đăng xuất",
          ),
        ],
      ),
      body: isLoading
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
    );
  }

  String _getTodayLabel() {
    final now = DateTime.now();
    const days = ["Thứ 2", "Thứ 3", "Thứ 4", "Thứ 5", "Thứ 6", "Thứ 7", "Chủ nhật"];
    final dayName = days[now.weekday - 1];
    return "$dayName, ${now.day}/${now.month}/${now.year}";
  }

  Widget _buildPlantCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text("🔥", style: TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$currentStreak ngày liên tiếp",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                "Giữ vững phong độ nhé!",
                style: TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayCard(double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Hôm nay",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                "$completedToday/$totalToday",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFE8F5E9),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            totalToday == 0
                ? "Chưa có thói quen nào. Thêm ngay nhé!"
                : completedToday == totalToday
                    ? "Tuyệt vời! Bạn đã hoàn thành tất cả hôm nay 🎉"
                    : "Còn ${totalToday - completedToday} thói quen chưa hoàn thành",
            style: const TextStyle(fontSize: 13, color: Colors.grey),
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
