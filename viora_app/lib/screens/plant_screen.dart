import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import '../services/api_service.dart';
import '../widgets/plant_widget.dart';
import '../widgets/viora_app_bar.dart';
import '../widgets/level_up_animation.dart';
import '../theme/theme_extensions.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../models/plant_type.dart';
import '../constants/app_icons.dart';

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
  String plantType = "bamboo";
  int plantLevel = 1;
  int plantExp = 0;
  bool plantWilted = false;
  int daysWithoutCheckin = 0; // Add days without check-in counter
  bool isLoading = true;
  bool showLevelUpAnimation = false;
  int? previousLevel;
  int? levelUpFromLevel;

  @override
  bool get wantKeepAlive => false; // Không cache → reload mỗi lần vào tab

  String _getLevelDescription(int level, AppLocalizations l10n) {
    return switch (level) {
      1 => l10n.levelDesc1,
      2 => l10n.levelDesc2,
      3 => l10n.levelDesc3,
      4 => l10n.levelDesc4,
      5 => l10n.levelDesc5,
      6 => l10n.levelDesc6,
      7 => l10n.levelDesc7,
      8 => l10n.levelDesc8,
      9 => l10n.levelDesc9,
      10 => l10n.levelDesc10,
      11 => l10n.levelDesc11,
      12 => l10n.levelDesc12,
      13 => l10n.levelDesc13,
      14 => l10n.levelDesc14,
      15 => l10n.levelDesc15,
      _ => '',
    };
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
      
      // Only show animation if:
      // 1. We have a previous level recorded
      // 2. Level increased by exactly 1 (to avoid showing animation after long absence)
      final shouldShowAnimation = lastSeenLevel != null && 
                                   newLevel == lastSeenLevel + 1;
      
      // Update state
      setState(() {
        plantType = plant["plant_type"] ?? "bamboo";
        plantExp = exp;
        plantWilted = plant["is_wilted"] == true;
        daysWithoutCheckin = plant["days_without_checkin"] ?? 0;
        plantLevel = newLevel;
        isLoading = false;
        
        // Show animation only if level increased by 1
        if (shouldShowAnimation) {
          showLevelUpAnimation = true;
          levelUpFromLevel = lastSeenLevel.clamp(1, 15);
        }
      });
      
      // Update last seen level
      await prefs.setInt(_lastSeenPlantLevelKey, newLevel);
      previousLevel = newLevel;
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

  // Get progressive warning message based on days without check-in
  String _getWarningMessage(int days, AppLocalizations l10n) {
    switch (days) {
      case 0:
        return '';
      case 1:
        return l10n.plantWarningDay1;
      case 2:
        return l10n.plantWarningDay2;
      case 3:
        return l10n.plantWarningDay3;
      default:
        return l10n.plantWarningDay3Plus;
    }
  }

  Color _getWarningColor(int days) {
    switch (days) {
      case 0:
        return AppColors.success;
      case 1:
        return AppColors.warning;
      case 2:
        return const Color(0xFFEA580C);
      default:
        return AppColors.error;
    }
  }

  IconData _getWarningIcon(int days) {
    switch (days) {
      case 0:
        return AppIcons.checkCircle;
      case 1:
        return AppIcons.warning;
      case 2:
        return AppIcons.error;
      default:
        return AppIcons.error;
    }
  }

  /// Get localized stage name based on plant type and level
  String _getStageName(int level, AppLocalizations l10n) {
    final plantTypeModel = PlantType.fromIdOrDefault(plantType);
    final stageKey = plantTypeModel.getStageNameKey(level);
    
    // Use reflection-like approach to get the localized string
    // Map stage keys to l10n getter calls
    switch (stageKey) {
      // Bamboo stages
      case 'bambooLevel1': return l10n.bambooLevel1;
      case 'bambooLevel2': return l10n.bambooLevel2;
      case 'bambooLevel3': return l10n.bambooLevel3;
      case 'bambooLevel4': return l10n.bambooLevel4;
      case 'bambooLevel5': return l10n.bambooLevel5;
      case 'bambooLevel6': return l10n.bambooLevel6;
      case 'bambooLevel7': return l10n.bambooLevel7;
      case 'bambooLevel8': return l10n.bambooLevel8;
      case 'bambooLevel9': return l10n.bambooLevel9;
      case 'bambooLevel10': return l10n.bambooLevel10;
      case 'bambooLevel11': return l10n.bambooLevel11;
      case 'bambooLevel12': return l10n.bambooLevel12;
      case 'bambooLevel13': return l10n.bambooLevel13;
      case 'bambooLevel14': return l10n.bambooLevel14;
      case 'bambooLevel15': return l10n.bambooLevel15;
      
      // Cactus stages
      case 'cactusLevel1': return l10n.cactusLevel1;
      case 'cactusLevel2': return l10n.cactusLevel2;
      case 'cactusLevel3': return l10n.cactusLevel3;
      case 'cactusLevel4': return l10n.cactusLevel4;
      case 'cactusLevel5': return l10n.cactusLevel5;
      case 'cactusLevel6': return l10n.cactusLevel6;
      case 'cactusLevel7': return l10n.cactusLevel7;
      case 'cactusLevel8': return l10n.cactusLevel8;
      case 'cactusLevel9': return l10n.cactusLevel9;
      case 'cactusLevel10': return l10n.cactusLevel10;
      case 'cactusLevel11': return l10n.cactusLevel11;
      case 'cactusLevel12': return l10n.cactusLevel12;
      case 'cactusLevel13': return l10n.cactusLevel13;
      
      // Sakura stages
      case 'sakuraLevel1': return l10n.sakuraLevel1;
      case 'sakuraLevel2': return l10n.sakuraLevel2;
      case 'sakuraLevel3': return l10n.sakuraLevel3;
      case 'sakuraLevel4': return l10n.sakuraLevel4;
      case 'sakuraLevel5': return l10n.sakuraLevel5;
      case 'sakuraLevel6': return l10n.sakuraLevel6;
      case 'sakuraLevel7': return l10n.sakuraLevel7;
      case 'sakuraLevel8': return l10n.sakuraLevel8;
      case 'sakuraLevel9': return l10n.sakuraLevel9;
      case 'sakuraLevel10': return l10n.sakuraLevel10;
      case 'sakuraLevel11': return l10n.sakuraLevel11;
      case 'sakuraLevel12': return l10n.sakuraLevel12;
      case 'sakuraLevel13': return l10n.sakuraLevel13;
      case 'sakuraLevel14': return l10n.sakuraLevel14;
      
      // Sunflower stages
      case 'sunflowerLevel1': return l10n.sunflowerLevel1;
      case 'sunflowerLevel2': return l10n.sunflowerLevel2;
      case 'sunflowerLevel3': return l10n.sunflowerLevel3;
      case 'sunflowerLevel4': return l10n.sunflowerLevel4;
      case 'sunflowerLevel5': return l10n.sunflowerLevel5;
      case 'sunflowerLevel6': return l10n.sunflowerLevel6;
      case 'sunflowerLevel7': return l10n.sunflowerLevel7;
      case 'sunflowerLevel8': return l10n.sunflowerLevel8;
      case 'sunflowerLevel9': return l10n.sunflowerLevel9;
      case 'sunflowerLevel10': return l10n.sunflowerLevel10;
      case 'sunflowerLevel11': return l10n.sunflowerLevel11;
      case 'sunflowerLevel12': return l10n.sunflowerLevel12;
      case 'sunflowerLevel13': return l10n.sunflowerLevel13;
      case 'sunflowerLevel14': return l10n.sunflowerLevel14;
      case 'sunflowerLevel15': return l10n.sunflowerLevel15;
      case 'sunflowerLevel16': return l10n.sunflowerLevel16;
      
      default:
        // Fallback to generic level names
        return l10n.level(level);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    final level = plantLevel.clamp(1, 15);
    final info = {
      "name": _getStageName(level, l10n),
      "desc": _getLevelDescription(level, l10n),
      "color": _getLevelColor(level),
    };
    final cardColor = Theme.of(context).cardTheme.color ?? Colors.white;

    final plantBody = isLoading
        ? const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          )
        : RefreshIndicator(
            onRefresh: _loadPlant,
            color: AppColors.primary,
            child: ListView(
              padding: EdgeInsets.all(widget.embedded ? 16 : 20),
              children: [
                  // Plant display card
                  GestureDetector(
                    onTap: _showChangePlantDialog,
                    child: Container(
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
                          // Progressive warning based on days without check-in
                          if (daysWithoutCheckin > 0) ...[
                            const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getWarningColor(daysWithoutCheckin).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getWarningColor(daysWithoutCheckin).withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getWarningIcon(daysWithoutCheckin),
                                  color: _getWarningColor(daysWithoutCheckin),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _getWarningMessage(daysWithoutCheckin, l10n),
                                    style: TextStyle(
                                      color: _getWarningColor(daysWithoutCheckin),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
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
                            Icon(AppIcons.trendingUp, size: 20, color: context.textGreen),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.howToEarnPoints,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: context.textGreen)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTip(AppIcons.zap, AppColors.success, AppLocalizations.of(context)!.earnTip1, AppLocalizations.of(context)!.earnReward1),
                        const Divider(height: 1, indent: 28),
                        const SizedBox(height: 8),
                        _buildTip(AppIcons.trendingUp, const Color(0xFFFB8C00), AppLocalizations.of(context)!.earnTip2, AppLocalizations.of(context)!.earnReward2),
                        const Divider(height: 1, indent: 28),
                        const SizedBox(height: 8),
                        _buildTip(AppIcons.star, Colors.amber, AppLocalizations.of(context)!.earnTip3, AppLocalizations.of(context)!.earnReward3),
                        const Divider(height: 1, indent: 28),
                        const SizedBox(height: 8),
                        _buildTip(AppIcons.warning, AppColors.error, AppLocalizations.of(context)!.earnTip4, AppLocalizations.of(context)!.earnReward4),
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
        _buildStatChip(l10n.totalPoints, l10n.points(plantExp), AppIcons.star, Colors.amber),
        _buildStatChip(l10n.levelProgress, "$plantLevel / 15", AppIcons.trendingUp, AppColors.primary),
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
    final stages = [
      {"level": 1, "name": _getStageName(1, l10n), "exp": 0},
      {"level": 2, "name": _getStageName(2, l10n), "exp": 5},
      {"level": 3, "name": _getStageName(3, l10n), "exp": 15},
      {"level": 4, "name": _getStageName(4, l10n), "exp": 30},
      {"level": 5, "name": _getStageName(5, l10n), "exp": 50},
      {"level": 6, "name": _getStageName(6, l10n), "exp": 75},
      {"level": 7, "name": _getStageName(7, l10n), "exp": 105},
      {"level": 8, "name": _getStageName(8, l10n), "exp": 140},
      {"level": 9, "name": _getStageName(9, l10n), "exp": 180},
      {"level": 10, "name": _getStageName(10, l10n), "exp": 225},
      {"level": 11, "name": _getStageName(11, l10n), "exp": 275},
      {"level": 12, "name": _getStageName(12, l10n), "exp": 330},
      {"level": 13, "name": _getStageName(13, l10n), "exp": 390},
      {"level": 14, "name": _getStageName(14, l10n), "exp": 455},
      {"level": 15, "name": _getStageName(15, l10n), "exp": 525},
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

      // Treasure chest nodes removed
    }

    return roadmapWidgets;
  }

  Future<void> _showChangePlantDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              l10n.changePlantType,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.keepGrowing,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ...PlantType.all.map((type) {
              final isSelected = type.id == plantType;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx, type.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipOval(
                          child: Image.asset(
                            type.getAssetPath(type.maxStages),
                            width: 52,
                            height: 52,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getPlantTypeName(type.id, l10n),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? const Color(0xFF00695C)
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.points(plantExp),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              AppIcons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(l10n.cancel, style: const TextStyle(fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
    if (result == null || result == plantType) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    await ApiService.setPlantType(token, result);
    if (!mounted) return;
    _loadPlant();
  }

  String _getPlantTypeName(String typeId, AppLocalizations l10n) {
    switch (typeId) {
      case 'bamboo': return l10n.plantTypeBamboo;
      case 'cactus': return l10n.plantTypeCactus;
      case 'sunflower': return l10n.plantTypeSunflower;
      case 'flower': return l10n.plantFlower;
      default: return typeId;
    }
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

    // Get plant image path based on current user's plant type
    final plantType = PlantType.fromIdOrDefault(this.plantType);
    final plantImagePath = plantType.getAssetPath(level);

    if (isDone) {
      nodeColor = AppColors.primary;
      // Show plant image for completed levels
      icon = Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryLight, // Light green background
        ),
        child: ClipOval(
          child: Image.asset(
            plantImagePath,
            width: 58,
            height: 58,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(AppIcons.check, color: Color.fromARGB(255, 22, 160, 27), size: 28);
            },
          ),
        ),
      );
    } else if (isCurrent) {
      nodeColor = AppColors.primary;
      // Show plant image for current level
      icon = Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryLight,
        ),
        child: ClipOval(
          child: Image.asset(
            plantImagePath,
            width: 58,
            height: 58,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(AppIcons.star, color: AppColors.primary, size: 28);
            },
          ),
        ),
      );
    } else {
      nodeColor = Colors.grey.shade400; // Medium gray background for locked nodes
      // Show grayscale plant image for locked levels with RepaintBoundary isolation
      icon = Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade200,
        ),
        child: RepaintBoundary(
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
                  plantImagePath,
                  width: 58,
                  height: 58,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(AppIcons.lock, color: context.textSecondary, size: 24);
                  },
                ),
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
              color: AppColors.primary,
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
                      color: AppColors.primary.withValues(alpha: 0.4),
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

  Widget _buildTip(IconData icon, Color iconColor, String text, String reward) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: TextStyle(fontSize: 13, color: context.textGreenLight)),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(reward,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: iconColor)),
        ),
      ],
    );
  }
}
