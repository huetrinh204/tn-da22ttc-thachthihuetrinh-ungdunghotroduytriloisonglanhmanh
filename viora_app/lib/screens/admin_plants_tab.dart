import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/theme_extensions.dart';
import '../l10n/app_localizations.dart';
import '../models/plant_type.dart';
import '../constants/app_icons.dart';
import 'admin_plant_detail_screen.dart';

class AdminPlantsTab extends StatefulWidget {
  const AdminPlantsTab({super.key});

  @override
  State<AdminPlantsTab> createState() => _AdminPlantsTabState();
}

class _AdminPlantsTabState extends State<AdminPlantsTab> {
  bool _isLoading = true;
  String _token = '';
  List<dynamic> _allPlants = [];
  List<dynamic> _filteredPlants = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPlants() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';
    try {
      final res = await ApiService.getAdminPlants(_token);
      if (!mounted) return;
      setState(() {
        _allPlants = res['plants'] ?? [];
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String value) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_searchController.text == value) {
        _applyFilter();
      }
    });
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      _filteredPlants = List.from(_allPlants);
    } else {
      _filteredPlants = _allPlants.where((p) {
        final name = (p['user_name'] as String? ?? '').toLowerCase();
        return name.contains(query);
      }).toList();
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
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        _buildHeader(loc),
        _buildSearch(loc),
        Expanded(
          child: _filteredPlants.isEmpty
              ? _buildEmptyState(loc)
              : RefreshIndicator(
                  onRefresh: _loadPlants,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg,
                    ),
                    itemCount: _filteredPlants.length,
                    itemBuilder: (context, index) =>
                        _buildPlantCard(_filteredPlants[index], loc),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(AppLocalizations loc) {
    final count = _filteredPlants.length;
    final total = _allPlants.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(AppIcons.sprout, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                total > 0 && count != total
                    ? '$count / $total ${loc.plants}'
                    : '$total ${loc.plants}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                loc.adminPlants,
                style: TextStyle(
                  fontSize: 13,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: loc.searchByNameEmail,
          prefixIcon: const Icon(AppIcons.search, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(AppIcons.close, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilter();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations loc) {
    final isSearching = _searchController.text.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.isDark
                    ? const Color(0xFF24352E)
                    : const Color(0xFFF0F1F3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearching ? AppIcons.search : AppIcons.sprout,
                size: 40,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              isSearching ? loc.noUsersFound : loc.noPlantsYet,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantCard(Map<String, dynamic> plant, AppLocalizations loc) {
    final level = plant['level'] as int? ?? 1;
    final experience = plant['experience'] as int? ?? 0;
    final userName = plant['user_name'] ?? 'Unknown';
    final userId = plant['user_id']?.toString() ?? '';
    final userAvatar = plant['user_avatar'] as String?;
    final plantTypeId = plant['plant_type'] as String? ?? 'bamboo';
    final progress = _getProgressToNextLevel(level, experience);
    final plantType = PlantType.fromIdOrDefault(plantTypeId);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDark
              ? const Color(0xFF2E433C)
              : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
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
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    _getPlantImagePath(level, plantTypeId),
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Center(
                      child: Text(
                        plantType.emoji,
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (userAvatar != null && userAvatar.isNotEmpty)
                            CircleAvatar(
                              radius: 12,
                              backgroundImage: NetworkImage(
                                ApiService.resolveImageUrl(userAvatar),
                              ),
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              child: Text(
                                userName.isNotEmpty
                                    ? userName[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          else
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              child: Text(
                                userName.isNotEmpty
                                    ? userName[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              userName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: context.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Text(
                            plantType.emoji,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _getPlantName(context, level, plantTypeId),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            loc.level(level),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: context.isDark
                                    ? const Color(0xFF2E433C)
                                    : const Color(0xFFE5E7EB),
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '$experience ${loc.exp}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  AppIcons.chevronRight,
                  size: 20,
                  color: context.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
