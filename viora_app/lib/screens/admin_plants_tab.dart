import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';
import '../l10n/app_localizations.dart';
import '../models/plant_type.dart';
import 'admin_plant_detail_screen.dart';

class AdminPlantsTab extends StatefulWidget {
  const AdminPlantsTab({super.key});

  @override
  State<AdminPlantsTab> createState() => _AdminPlantsTabState();
}

class _AdminPlantsTabState extends State<AdminPlantsTab> {
  bool _isLoading = true;
  String _token = '';
  List<dynamic> _plants = [];

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';
    
    try {
      final res = await ApiService.getAdminPlants(_token);
      if (!mounted) return;
      setState(() {
        _plants = res['plants'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  String _getPlantImagePath(int level, String plantTypeId) {
    final plantType = PlantType.fromIdOrDefault(plantTypeId);
    return plantType.getAssetPath(level);
  }

  String _getPlantName(BuildContext context, int level, String plantTypeId) {
    final loc = AppLocalizations.of(context)!;
    final plantType = PlantType.fromIdOrDefault(plantTypeId);
    final key = plantType.getStageNameKey(level);
    // Map key → localized string
    final all = {
      'bambooLevel1': loc.bambooLevel1, 'bambooLevel2': loc.bambooLevel2,
      'bambooLevel3': loc.bambooLevel3, 'bambooLevel4': loc.bambooLevel4,
      'bambooLevel5': loc.bambooLevel5, 'bambooLevel6': loc.bambooLevel6,
      'bambooLevel7': loc.bambooLevel7, 'bambooLevel8': loc.bambooLevel8,
      'bambooLevel9': loc.bambooLevel9, 'bambooLevel10': loc.bambooLevel10,
      'bambooLevel11': loc.bambooLevel11, 'bambooLevel12': loc.bambooLevel12,
      'bambooLevel13': loc.bambooLevel13, 'bambooLevel14': loc.bambooLevel14,
      'bambooLevel15': loc.bambooLevel15,
      'cactusLevel1': loc.cactusLevel1, 'cactusLevel2': loc.cactusLevel2,
      'cactusLevel3': loc.cactusLevel3, 'cactusLevel4': loc.cactusLevel4,
      'cactusLevel5': loc.cactusLevel5, 'cactusLevel6': loc.cactusLevel6,
      'cactusLevel7': loc.cactusLevel7, 'cactusLevel8': loc.cactusLevel8,
      'cactusLevel9': loc.cactusLevel9, 'cactusLevel10': loc.cactusLevel10,
      'cactusLevel11': loc.cactusLevel11, 'cactusLevel12': loc.cactusLevel12,
      'cactusLevel13': loc.cactusLevel13,
      'sakuraLevel1': loc.sakuraLevel1, 'sakuraLevel2': loc.sakuraLevel2,
      'sakuraLevel3': loc.sakuraLevel3, 'sakuraLevel4': loc.sakuraLevel4,
      'sakuraLevel5': loc.sakuraLevel5, 'sakuraLevel6': loc.sakuraLevel6,
      'sakuraLevel7': loc.sakuraLevel7, 'sakuraLevel8': loc.sakuraLevel8,
      'sakuraLevel9': loc.sakuraLevel9, 'sakuraLevel10': loc.sakuraLevel10,
      'sakuraLevel11': loc.sakuraLevel11, 'sakuraLevel12': loc.sakuraLevel12,
      'sakuraLevel13': loc.sakuraLevel13, 'sakuraLevel14': loc.sakuraLevel14,
      'sunflowerLevel1': loc.sunflowerLevel1, 'sunflowerLevel2': loc.sunflowerLevel2,
      'sunflowerLevel3': loc.sunflowerLevel3, 'sunflowerLevel4': loc.sunflowerLevel4,
      'sunflowerLevel5': loc.sunflowerLevel5, 'sunflowerLevel6': loc.sunflowerLevel6,
      'sunflowerLevel7': loc.sunflowerLevel7, 'sunflowerLevel8': loc.sunflowerLevel8,
      'sunflowerLevel9': loc.sunflowerLevel9, 'sunflowerLevel10': loc.sunflowerLevel10,
      'sunflowerLevel11': loc.sunflowerLevel11, 'sunflowerLevel12': loc.sunflowerLevel12,
      'sunflowerLevel13': loc.sunflowerLevel13, 'sunflowerLevel14': loc.sunflowerLevel14,
      'sunflowerLevel15': loc.sunflowerLevel15, 'sunflowerLevel16': loc.sunflowerLevel16,
    };
    return all[key] ?? '${plantType.emoji} Level $level';
  }

  double _getProgressToNextLevel(int level, int experience) {
    if (level >= 15) return 1.0;
    
    final expForCurrentLevel = _getExpForLevel(level);
    final expForNextLevel = _getExpForLevel(level + 1);
    
    if (expForNextLevel == expForCurrentLevel) return 1.0;
    
    final progress = (experience - expForCurrentLevel) / (expForNextLevel - expForCurrentLevel);
    return progress.clamp(0.0, 1.0);
  }

  int _getExpForLevel(int level) {
    const levelThresholds = [0, 5, 15, 30, 50, 75, 105, 140, 180, 225, 275, 330, 390, 455, 525];
    if (level <= 0) return 0;
    if (level > levelThresholds.length) return levelThresholds.last;
    return levelThresholds[level - 1];
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_plants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.park_outlined, size: 64, color: context.textSecondary),
            const SizedBox(height: 16),
            Text(
              loc.noPlantsYet,
              style: TextStyle(
                fontSize: 16,
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPlants,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _plants.length,
        itemBuilder: (context, index) {
          final plant = _plants[index];
          final level = plant['level'] as int? ?? 1;
          final experience = plant['experience'] as int? ?? 0;
          final userName = plant['user_name'] ?? 'Unknown';
          final userId = plant['user_id']?.toString() ?? '';
          final userAvatar = plant['user_avatar'] as String?;
          final plantTypeId = plant['plant_type'] as String? ?? 'bamboo';
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: context.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminPlantDetailScreen(
                      userId: userId,
                      userName: userName,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Plant image
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        _getPlantImagePath(level, plantTypeId),
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(
                            PlantType.fromIdOrDefault(plantTypeId).emoji,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Plant info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User info
                          Row(
                            children: [
                              if (userAvatar != null) ...[
                                ClipOval(
                                  child: Image.network(
                                    ApiService.resolveImageUrl(userAvatar),
                                    width: 24,
                                    height: 24,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          userName[0].toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Expanded(
                                child: Text(
                                  userName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: context.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Plant name and level
                          Text(
                            '${_getPlantName(context, level, plantTypeId)} (${loc.level(level)})',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$experience ${loc.exp}',
                            style: TextStyle(
                              fontSize: 13,
                              color: context.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _getProgressToNextLevel(level, experience),
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      color: context.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
