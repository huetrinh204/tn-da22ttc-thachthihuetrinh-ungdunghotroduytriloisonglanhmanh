import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import '../services/api_service.dart';
import '../widgets/plant_widget.dart';
import '../widgets/viora_app_bar.dart';
import '../widgets/level_up_animation.dart';
import '../widgets/treasure_reward_animation.dart';
import '../theme/theme_extensions.dart';
import '../l10n/app_localizations.dart';

class PlantScreen extends StatefulWidget {
  const PlantScreen({super.key, this.embedded = false});

  /// Nhúng trong [GrowScreen] — không dùng Scaffold/AppBar riêng.
  final bool embedded;

  @override
  State<PlantScreen> createState() => _PlantScreenState();
}

class _PlantScreenState extends State<PlantScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  static const String _lastSeenPlantLevelKey = "last_seen_plant_level";
  String plantType = "sprout";
  int plantLevel = 1;
  int plantExp = 0;
  bool plantWilted = false;
  bool isLoading = true;
  bool showLevelUpAnimation = false;
  int? previousLevel;
  int? levelUpFromLevel;

  @override
  bool get wantKeepAlive => false; // Không cache → reload mỗi lần vào tab

  String _getLevelDescription(int level, AppLocalizations l10n) {
    const descriptions = [
      "Hành trình bắt đầu từ đây",
      "Hạt đang nảy mầm",
      "Cây đang nảy mầm, tiếp tục nhé!",
      "Cây đang lớn dần mỗi ngày",
      "Cây đang phát triển tốt",
      "Cây đang vững chắc hơn",
      "Cây đang lớn mạnh",
      "Cây đã vững chắc",
      "Cây đang phát triển rất tốt",
      "Cây bắt đầu ra hoa",
      "Cây đang kết trái",
      "Trái đang lớn dần",
      "Trái đã chín",
      "Cây đầy trái chín",
      "Tuyệt vời! Cây đã đạt đỉnh cao 🏆",
    ];
    return descriptions[level - 1];
  }

  int _getLevelColor(int level) {
    const colors = [
      0xFF8D6E63, 0xFFA1887F, 0xFF81C784, 0xFF66BB6A, 0xFF4CAF50,
      0xFF43A047, 0xFF388E3C, 0xFF2E7D32, 0xFF1B5E20, 0xFFE91E63,
      0xFFF06292, 0xFFFF9800, 0xFFFFA726, 0xFFFFB74D, 0xFFFFD54F,
    ];
    return colors[level - 1];
  }

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
      final lastSeenLevel = prefs.getInt(_lastSeenPlantLevelKey);
      final oldLevel = previousLevel ?? lastSeenLevel ?? newLevel;
      
      // Update state first
      setState(() {
        plantType = plant["plant_type"] ?? "sprout";
        plantExp = exp;
        plantWilted = plant["is_wilted"] == true;
        isLoading = false;
      });
      
      // Check if level up happened (only if we have a previous level and it's different)
      if (previousLevel != null && oldLevel < newLevel) {
        setState(() {
          plantLevel = newLevel;
          levelUpFromLevel = oldLevel.clamp(1, 15);
          showLevelUpAnimation = true;
        });
        
        // Check if reached treasure milestone (every 3 levels)
        if (newLevel % 3 == 0 && newLevel > oldLevel) {
          // Show treasure reward after level up animation
          Future.delayed(const Duration(milliseconds: 2500), () {
            if (mounted) {
              _showTreasureReward();
            }
          });
        }
      } else {
        // First load or no level change
        final hasLeveledUpSinceLastSeen = oldLevel < newLevel;
        setState(() {
          plantLevel = newLevel;
          showLevelUpAnimation = hasLeveledUpSinceLastSeen;
          levelUpFromLevel =
              hasLeveledUpSinceLastSeen ? oldLevel.clamp(1, 15) : null;
        });

        if (hasLeveledUpSinceLastSeen && newLevel % 3 == 0) {
          Future.delayed(const Duration(milliseconds: 2500), () {
            if (mounted) {
              _showTreasureReward();
            }
          });
        }
      }
      
      // Update previous level for next comparison
      previousLevel = newLevel;
      await prefs.setInt(_lastSeenPlantLevelKey, newLevel);
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
    final l10n = AppLocalizations.of(context)!;
    final level = plantLevel.clamp(1, 15);
    final levelNames = [
      l10n.plantLevel1, l10n.plantLevel2, l10n.plantLevel3, l10n.plantLevel4, l10n.plantLevel5,
      l10n.plantLevel6, l10n.plantLevel7, l10n.plantLevel8, l10n.plantLevel9, l10n.plantLevel10,
      l10n.plantLevel11, l10n.plantLevel12, l10n.plantLevel13, l10n.plantLevel14, l10n.plantLevel15,
    ];
    final info = {
      "name": levelNames[level - 1],
      "desc": _getLevelDescription(level, l10n),
      "color": _getLevelColor(level),
    };
    final cardColor = Theme.of(context).cardTheme.color ?? Colors.white;

    final plantBody = isLoading
        ? const Center(
            child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
          )
        : RefreshIndicator(
            onRefresh: _loadPlant,
            color: const Color(0xFF4CAF50),
            child: ListView(
              padding: EdgeInsets.all(widget.embedded ? 16 : 20),
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
                            "${AppLocalizations.of(context)!.level(level)} — ${info["name"]}",
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.warning_amber_rounded,
                                    color: Colors.red, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.plantWiltedWarning,
                                  style: const TextStyle(
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
                        Text(AppLocalizations.of(context)!.developmentProgress,
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
                        Text(AppLocalizations.of(context)!.developmentRoadmap,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: context.textGreen)),
                        const SizedBox(height: 16),
                        Center(
                          child: Column(
                            children: _buildRoadmap(level),
                          ),
                        ),
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
                            Text(AppLocalizations.of(context)!.howToEarnPoints,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: context.textGreen)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTip(AppLocalizations.of(context)!.earnTip1, AppLocalizations.of(context)!.earnReward1),
                        _buildTip(AppLocalizations.of(context)!.earnTip2, AppLocalizations.of(context)!.earnReward2),
                        _buildTip(AppLocalizations.of(context)!.earnTip3, AppLocalizations.of(context)!.earnReward3),
                        _buildTip(AppLocalizations.of(context)!.earnTip4, AppLocalizations.of(context)!.earnReward4),
                      ],
                    ),
                  ),
              ],
            ),
          );

    final levelUpOverlay = showLevelUpAnimation && levelUpFromLevel != null
        ? LevelUpAnimation(
            plantType: plantType,
            oldLevel: levelUpFromLevel!,
            newLevel: plantLevel,
            onComplete: () {
              setState(() {
                showLevelUpAnimation = false;
                levelUpFromLevel = null;
              });
            },
          )
        : null;

    if (widget.embedded) {
      return Stack(
        children: [
          plantBody,
          if (levelUpOverlay != null) levelUpOverlay,
        ],
      );
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: VioraAppBar(title: AppLocalizations.of(context)!.myPlant),
          body: plantBody,
        ),
        if (levelUpOverlay != null) levelUpOverlay,
      ],
    );
  }

  Widget _buildPointsInfo() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatChip(l10n.totalPoints, l10n.points(plantExp), Icons.star_rounded, Colors.amber),
        _buildStatChip(l10n.levelProgress, "$plantLevel / 15", Icons.trending_up, const Color(0xFF4CAF50)),
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
    final l10n = AppLocalizations.of(context)!;
    final levelNames = [
      l10n.plantLevel1, l10n.plantLevel2, l10n.plantLevel3, l10n.plantLevel4, l10n.plantLevel5,
      l10n.plantLevel6, l10n.plantLevel7, l10n.plantLevel8, l10n.plantLevel9, l10n.plantLevel10,
      l10n.plantLevel11, l10n.plantLevel12, l10n.plantLevel13, l10n.plantLevel14, l10n.plantLevel15,
    ];
    final stages = [
      {"level": 1, "name": levelNames[0], "exp": 0},
      {"level": 2, "name": levelNames[1], "exp": 5},
      {"level": 3, "name": levelNames[2], "exp": 15},
      {"level": 4, "name": levelNames[3], "exp": 30},
      {"level": 5, "name": levelNames[4], "exp": 50},
      {"level": 6, "name": levelNames[5], "exp": 75},
      {"level": 7, "name": levelNames[6], "exp": 105},
      {"level": 8, "name": levelNames[7], "exp": 140},
      {"level": 9, "name": levelNames[8], "exp": 180},
      {"level": 10, "name": levelNames[9], "exp": 225},
      {"level": 11, "name": levelNames[10], "exp": 275},
      {"level": 12, "name": levelNames[11], "exp": 330},
      {"level": 13, "name": levelNames[12], "exp": 390},
      {"level": 14, "name": levelNames[13], "exp": 455},
      {"level": 15, "name": levelNames[14], "exp": 525},
    ];

    final List<Widget> roadmapWidgets = [];

    for (var entry in stages.asMap().entries) {
      final index = entry.key;
      final stage = entry.value;
      final lvl = stage["level"] as int;
      final isDone = currentLevel > lvl;
      final isCurrent = currentLevel == lvl;
      final isLocked = currentLevel < lvl;

      // Calculate horizontal offset for wave effect with more curve
      final amplitude = 60.0; // Increased from 30 to 60 for more curve
      final frequency = 0.8; // Increased from 0.5 to 0.8 for more waves
      final offset = amplitude * math.sin(frequency * index);

      roadmapWidgets.add(
        Padding(
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
        ),
      );

      // Add treasure chest every 3 levels (after level 3, 6, 9, 12)
      if (lvl % 3 == 0 && lvl < 15) {
        final treasureUnlocked = currentLevel > lvl;
        roadmapWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildTreasureChest(
              isUnlocked: treasureUnlocked,
              afterLevel: lvl,
            ),
          ),
        );
      }
    }

    return roadmapWidgets;
  }

  Widget _buildTreasureChest({
    required bool isUnlocked,
    required int afterLevel,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: isUnlocked
          ? () {
              // Show treasure reward animation
              _showTreasureReward();
            }
          : null,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked
                  ? const Color(0xFFFFD700).withValues(alpha: 0.2)
                  : Colors.grey.shade200,
              border: Border.all(
                color: isUnlocked ? const Color(0xFFFFD700) : Colors.grey.shade400,
                width: 3,
              ),
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: isUnlocked
                  ? Image.asset(
                      'assets/images/khobau.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    )
                  : RepaintBoundary(
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.matrix([
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0,      0,      0,      1, 0,
                        ]),
                        child: Opacity(
                          opacity: 0.7,
                          child: Image.asset(
                            'assets/images/khobau.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? const Color(0xFFFFD700).withValues(alpha: 0.2)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isUnlocked ? const Color(0xFFFFD700) : Colors.grey.shade400,
                width: 1,
              ),
            ),
            child: Text(
              isUnlocked ? l10n.treasureUnlocked : l10n.treasureLocked,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? const Color(0xFFFF8F00) : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTreasureReward() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const TreasureRewardAnimation(),
    );
  }

  Widget _buildLevelNode({
    required int level,
    required String name,
    required int exp,
    required bool isDone,
    required bool isCurrent,
    required bool isLocked,
  }) {
    final l10n = AppLocalizations.of(context)!;
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
      nodeColor = Colors.grey.shade400; // Medium gray background for locked nodes
      // Show grayscale plant image for locked levels with RepaintBoundary isolation
      icon = RepaintBoundary(
        child: ClipOval(
          child: ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0,      0,      0,      1, 0,
            ]),
            child: Opacity(
              opacity: 0.7,
              child: Image.asset(
                plantImages[level - 1],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.lock, color: Colors.grey.shade600, size: 20);
                },
              ),
            ),
          ),
        ),
      );
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
              l10n.level(level),
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
                l10n.points(exp),
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
