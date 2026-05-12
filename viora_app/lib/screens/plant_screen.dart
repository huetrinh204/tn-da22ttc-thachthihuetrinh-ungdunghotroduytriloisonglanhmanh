import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import '../services/api_service.dart';
import '../widgets/plant_widget.dart';
import '../widgets/viora_app_bar.dart';
import '../widgets/level_up_animation.dart';
import '../theme/theme_extensions.dart';

class PlantScreen extends StatefulWidget {
  const PlantScreen({super.key});

  @override
  State<PlantScreen> createState() => _PlantScreenState();
}

class _PlantScreenState extends State<PlantScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  String plantType = "sprout";
  int plantLevel = 1;
  int plantExp = 0;
  bool plantWilted = false;
  bool isLoading = true;
  bool showLevelUpAnimation = false;
  int? previousLevel;

  @override
  bool get wantKeepAlive => false; // Không cache → reload mỗi lần vào tab

  static const List<Map<String, dynamic>> _levelInfo = [
    {"name": "Hạt giống", "desc": "Hành trình bắt đầu từ đây", "color": 0xFF8D6E63},
    {"name": "Hạt nảy mầm", "desc": "Hạt đang nảy mầm", "color": 0xFFA1887F},
    {"name": "Mầm non", "desc": "Cây đang nảy mầm, tiếp tục nhé!", "color": 0xFF81C784},
    {"name": "Cây non", "desc": "Cây đang lớn dần mỗi ngày", "color": 0xFF66BB6A},
    {"name": "Cây con", "desc": "Cây đang phát triển tốt", "color": 0xFF4CAF50},
    {"name": "Cây nhỏ", "desc": "Cây đang vững chắc hơn", "color": 0xFF43A047},
    {"name": "Cây đang lớn", "desc": "Cây đang lớn mạnh", "color": 0xFF388E3C},
    {"name": "Cây trưởng thành", "desc": "Cây đã vững chắc", "color": 0xFF2E7D32},
    {"name": "Cây phát triển tốt", "desc": "Cây đang phát triển rất tốt", "color": 0xFF1B5E20},
    {"name": "Cây ra hoa", "desc": "Cây bắt đầu ra hoa", "color": 0xFFE91E63},
    {"name": "Cây kết trái non", "desc": "Cây đang kết trái", "color": 0xFFF06292},
    {"name": "Cây trái lớn dần", "desc": "Trái đang lớn dần", "color": 0xFFFF9800},
    {"name": "Cây kết trái chín", "desc": "Trái đã chín", "color": 0xFFFFA726},
    {"name": "Cây sai quả", "desc": "Cây đầy trái chín", "color": 0xFFFFB74D},
    {"name": "Cây trưởng thành hoàn hảo", "desc": "Tuyệt vời! Cây đã đạt đỉnh cao 🏆", "color": 0xFFFFD54F},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPlant();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _loadPlant();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadPlant() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    final res = await ApiService.getPlant(token);
    if (!mounted) return;
    
    final plant = res["plant"];
    if (plant != null) {
      final exp = plant["experience"] ?? 0;
      final newLevel = _calculateLevel(exp);
      
      // Check if level up happened
      if (previousLevel != null && newLevel > previousLevel!) {
        setState(() {
          showLevelUpAnimation = true;
        });
      }
      
      setState(() {
        plantType = prefs.getString("plant_type") ?? plant["plant_type"] ?? "sprout";
        plantLevel = newLevel;
        plantExp = exp;
        plantWilted = plant["is_wilted"] == true;
        isLoading = false;
        previousLevel = newLevel;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final level = plantLevel.clamp(1, 15);
    final info = _levelInfo[level - 1];
    final cardColor = Theme.of(context).cardTheme.color ?? Colors.white;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: const VioraAppBar(title: "Cây của tôi"),
          body: isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
              : RefreshIndicator(
                  onRefresh: _loadPlant,
                  color: const Color(0xFF4CAF50),
                  child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Plant display card
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(info["color"] as int).withValues(alpha: 0.15),
                          cardColor,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: Color(info["color"] as int).withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        PlantWidget(
                          plantType: plantType,
                          level: plantLevel,
                          isWilted: plantWilted,
                          size: 90,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(info["color"] as int),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Cấp $level — ${info["name"]}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          info["desc"] as String,
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic),
                        ),
                        if (plantWilted) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.warning_amber_rounded,
                                    color: Colors.red, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  "Cây đang héo! Hãy check-in ngay 💧",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Experience progress
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tiến trình phát triển",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: context.textGreen)),
                        const SizedBox(height: 16),
                        PlantProgressBar(experience: plantExp, level: plantLevel),
                        const SizedBox(height: 16),
                        _buildPointsInfo(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Level roadmap
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Lộ trình phát triển",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: context.textGreen)),
                        const SizedBox(height: 16),
                        ..._buildRoadmap(level),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // How to earn points
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.infoBoxColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.infoBoxBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text("💡", style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text("Cách kiếm điểm",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: context.textGreen)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTip("✅ Hoàn thành ≥ 1 habit trong ngày", "+1 điểm"),
                        _buildTip("✅ Hoàn thành ≥ 50% habits trong ngày", "+2 điểm"),
                        _buildTip("🏆 Hoàn thành 100% habits trong ngày", "+3 điểm"),
                        _buildTip("⚠️ Không check-in 3 ngày liên tiếp", "Cây héo"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ),
        
        // Level-up animation overlay
        if (showLevelUpAnimation && previousLevel != null)
          LevelUpAnimation(
            plantType: plantType,
            oldLevel: previousLevel! - 1,
            newLevel: plantLevel,
            onComplete: () {
              setState(() {
                showLevelUpAnimation = false;
              });
            },
          ),
      ],
    );
  }

  Widget _buildPointsInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatChip("Tổng điểm", "$plantExp", Icons.star_rounded, Colors.amber),
        _buildStatChip("Cấp độ", "$plantLevel / 15", Icons.trending_up, const Color(0xFF4CAF50)),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: context.textSecondary)),
      ],
    );
  }

  List<Widget> _buildRoadmap(int currentLevel) {
    final stages = [
      {"level": 1, "name": "Hạt giống", "exp": 0},
      {"level": 2, "name": "Hạt nảy mầm", "exp": 5},
      {"level": 3, "name": "Mầm non", "exp": 15},
      {"level": 4, "name": "Cây non", "exp": 30},
      {"level": 5, "name": "Cây con", "exp": 50},
      {"level": 6, "name": "Cây nhỏ", "exp": 75},
      {"level": 7, "name": "Cây đang lớn", "exp": 105},
      {"level": 8, "name": "Cây trưởng thành", "exp": 140},
      {"level": 9, "name": "Cây phát triển tốt", "exp": 180},
      {"level": 10, "name": "Cây ra hoa", "exp": 225},
      {"level": 11, "name": "Cây kết trái non", "exp": 275},
      {"level": 12, "name": "Cây trái lớn dần", "exp": 330},
      {"level": 13, "name": "Cây kết trái chín", "exp": 390},
      {"level": 14, "name": "Cây sai quả", "exp": 455},
      {"level": 15, "name": "Cây trưởng thành hoàn hảo", "exp": 525},
    ];

    return stages.asMap().entries.map((entry) {
      final index = entry.key;
      final stage = entry.value;
      final lvl = stage["level"] as int;
      final isDone = currentLevel > lvl;
      final isCurrent = currentLevel == lvl;
      final isLocked = currentLevel < lvl;

      // Calculate horizontal offset for wave effect
      // Using sine wave: offset = amplitude * sin(frequency * index)
      final amplitude = 30.0; // How far left/right the wave goes
      final frequency = 0.5; // How many waves
      final offset = amplitude * math.sin(frequency * index);

      return Padding(
        padding: EdgeInsets.only(
          bottom: 20,
          left: offset > 0 ? offset : 0,
          right: offset < 0 ? -offset : 0,
        ),
        child: _buildLevelNode(
          level: lvl,
          name: stage["name"] as String,
          exp: stage["exp"] as int,
          isDone: isDone,
          isCurrent: isCurrent,
          isLocked: isLocked,
        ),
      );
    }).toList();
  }

  Widget _buildLevelNode({
    required int level,
    required String name,
    required int exp,
    required bool isDone,
    required bool isCurrent,
    required bool isLocked,
  }) {
    Color nodeColor;
    Widget icon;

    // Get plant image path
    final plantImages = [
      'assets/images/tree/1_hatgiong.png',
      'assets/images/tree/2_hatnaymam.png',
      'assets/images/tree/3_mamnon.png',
      'assets/images/tree/4_caynon.png',
      'assets/images/tree/5_caycon.png',
      'assets/images/tree/6_caynho.png',
      'assets/images/tree/7_caydanglon.png',
      'assets/images/tree/8_caytruongthanh.png',
      'assets/images/tree/9_cayphattrientot.png',
      'assets/images/tree/10_cayrahoa.png',
      'assets/images/tree/11_caykettrainon.png',
      'assets/images/tree/12_caytrailondan.png',
      'assets/images/tree/13_caykettraichin.png',
      'assets/images/tree/14_caysaiqua.png',
      'assets/images/tree/15_caytruongthanh.png',
    ];

    if (isDone) {
      nodeColor = const Color(0xFF4CAF50);
      // Show plant image for completed levels
      icon = ClipOval(
        child: Image.asset(
          plantImages[level - 1],
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.check, color: Colors.white, size: 24);
          },
        ),
      );
    } else if (isCurrent) {
      nodeColor = const Color(0xFF4CAF50);
      // Show plant image for current level
      icon = ClipOval(
        child: Image.asset(
          plantImages[level - 1],
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.star, color: Colors.white, size: 24);
          },
        ),
      );
    } else {
      nodeColor = Colors.grey.shade300;
      icon = Icon(Icons.lock, color: Colors.grey.shade600, size: 20);
    }

    return Column(
      children: [
        // Level badge
        if (isCurrent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Cấp $level',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (isCurrent) const SizedBox(height: 8),

        // Node circle
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: nodeColor,
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
            border: Border.all(
              color: Colors.white,
              width: 4,
            ),
          ),
          child: Center(child: icon),
        ),

        const SizedBox(height: 8),

        // Level info
        SizedBox(
          width: 100,
          child: Column(
            children: [
              Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isDone || isCurrent
                      ? context.textGreen
                      : context.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '$exp điểm',
                style: TextStyle(
                  fontSize: 10,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTip(String text, String reward) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(text,
                  style: TextStyle(fontSize: 13, color: context.textGreenLight))),
          Text(reward,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: context.textGreen)),
        ],
      ),
    );
  }
}
