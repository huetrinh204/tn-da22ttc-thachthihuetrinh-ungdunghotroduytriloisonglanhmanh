import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/theme_extensions.dart';
import '../l10n/app_localizations.dart';
import '../models/plant_type.dart';
import '../constants/app_icons.dart';
import '../widgets/habit_icon.dart';
import '../widgets/admin_card_skeleton.dart';
import '../widgets/admin_state_widgets.dart';
import 'admin_plant_detail_screen.dart';

class AdminHabitsTab extends StatefulWidget {
  const AdminHabitsTab({super.key});

  @override
  State<AdminHabitsTab> createState() => _AdminHabitsTabState();
}

class _AdminHabitsTabState extends State<AdminHabitsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _token = '';
  List<dynamic> _habits = [];
  List<dynamic> _filteredHabits = [];
  List<dynamic> _plants = [];
  List<dynamic> _filteredPlants = [];
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;

  static const _categoryColors = {
    'eat': Color(0xFF4CAF50),
    'exercise': Color(0xFFF59E0B),
    'sleep': Color(0xFF3B82F6),
    'mental': Color(0xFF8B5CF6),
    'hydration': Color(0xFF0EA5E9),
    'other': Color(0xFF6B7280),
  };

  String _catLabel(String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'eat': return l10n.categoryEat;
      case 'exercise': return l10n.categoryExercise;
      case 'sleep': return l10n.categorySleep;
      case 'mental': return l10n.categoryMental;
      case 'hydration': return l10n.categoryHydration;
      default: return l10n.categoryOther;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';
    try {
      final results = await Future.wait([
        ApiService.getAdminHabits(_token),
        ApiService.getAdminPlants(_token),
      ]);
      if (!mounted) return;
      setState(() {
        _habits = results[0]['habits'] ?? [];
        _plants = results[1]['plants'] ?? [];
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
      if (_searchController.text == value) _applyFilter();
    });
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase().trim();
    _filteredHabits = _habits.where((h) {
      if (query.isNotEmpty) {
        final name = (h['name'] as String? ?? '').toLowerCase();
        final userName = (h['user_name'] as String? ?? '').toLowerCase();
        if (!name.contains(query) && !userName.contains(query)) return false;
      }
      if (_selectedCategory != null && h['category'] != _selectedCategory) return false;
      return true;
    }).toList();
    _filteredPlants = _plants.where((p) {
      if (query.isEmpty) return true;
      final name = (p['user_name'] as String? ?? '').toLowerCase();
      return name.contains(query);
    }).toList();
  }

  String _getPlantImagePath(int level, String plantTypeId) {
    return PlantType.fromIdOrDefault(plantTypeId).getAssetPath(level);
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
      'cactusLevel13': loc.cactusLevel13, 'cactusLevel14': loc.cactusLevel14,
      'cactusLevel15': loc.cactusLevel15,
      'sakuraLevel1': loc.sakuraLevel1, 'sakuraLevel2': loc.sakuraLevel2,
      'sakuraLevel3': loc.sakuraLevel3, 'sakuraLevel4': loc.sakuraLevel4,
      'sakuraLevel5': loc.sakuraLevel5, 'sakuraLevel6': loc.sakuraLevel6,
      'sakuraLevel7': loc.sakuraLevel7, 'sakuraLevel8': loc.sakuraLevel8,
      'sakuraLevel9': loc.sakuraLevel9, 'sakuraLevel10': loc.sakuraLevel10,
      'sakuraLevel11': loc.sakuraLevel11, 'sakuraLevel12': loc.sakuraLevel12,
      'sakuraLevel13': loc.sakuraLevel13, 'sakuraLevel14': loc.sakuraLevel14,
      'sakuraLevel15': loc.sakuraLevel15,
      'sunflowerLevel1': loc.sunflowerLevel1, 'sunflowerLevel2': loc.sunflowerLevel2,
      'sunflowerLevel3': loc.sunflowerLevel3, 'sunflowerLevel4': loc.sunflowerLevel4,
      'sunflowerLevel5': loc.sunflowerLevel5, 'sunflowerLevel6': loc.sunflowerLevel6,
      'sunflowerLevel7': loc.sunflowerLevel7, 'sunflowerLevel8': loc.sunflowerLevel8,
      'sunflowerLevel9': loc.sunflowerLevel9, 'sunflowerLevel10': loc.sunflowerLevel10,
      'sunflowerLevel11': loc.sunflowerLevel11, 'sunflowerLevel12': loc.sunflowerLevel12,
      'sunflowerLevel13': loc.sunflowerLevel13, 'sunflowerLevel14': loc.sunflowerLevel14,
      'sunflowerLevel15': loc.sunflowerLevel15,
    };
    return all[key] ?? 'Unknown';
  }

  double _getProgressToNextLevel(int level, int experience) {
    const levels = [0, 5, 15, 30, 50, 75, 105, 140, 180, 225, 275, 330, 390, 455, 525];
    if (level < 1 || level >= levels.length) return 1.0;
    final currentLevelExp = levels[level - 1];
    final nextLevelExp = levels[level];
    final expInLevel = experience - currentLevelExp;
    final expNeeded = nextLevelExp - currentLevelExp;
    return (expInLevel / expNeeded).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildHeader(),
        _buildSearchBar(l10n),
        _buildCategoryFilter(),
        _buildTabBar(),
        Expanded(
          child: _isLoading
              ? ListView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
                  children: List.generate(6, (_) => const AdminCardSkeleton()),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildHabitsList(),
                    _buildPlantsList(l10n),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    final habitCount = _habits.length;
    final plantCount = _plants.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(AppIcons.habits, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$habitCount ${l10n.habitsLabel}',
                  style: AppTypography.headingMedium.copyWith(color: context.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  '$plantCount ${l10n.plant} · ${l10n.adminManageHabits}',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: l10n.adminSearchHint,
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

  Widget _buildCategoryFilter() {
    final l10n = AppLocalizations.of(context)!;
    final categories = <String>{};
    for (final h in _habits) {
      final cat = h['category'] as String? ?? 'other';
      categories.add(cat);
    }
    final sorted = categories.toList()..sort();
    if (sorted.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
      child: SizedBox(
        height: 34,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildCategoryChip(l10n.all, null),
            const SizedBox(width: 8),
            for (final cat in sorted) ...[
              _buildCategoryChip(
                _catLabel(cat),
                cat,
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? category) {
    final isSelected = _selectedCategory == category;
    final color = category != null
        ? (_categoryColors[category] ?? AppColors.primary)
        : AppColors.primary;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedCategory = isSelected ? null : category;
        _applyFilter();
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : context.isDark
              ? const Color(0xFF24352E)
              : const Color(0xFFF0F1F3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.4) : context.isDark
                ? const Color(0xFF2E433C)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.captionBold.copyWith(
            color: isSelected ? color : context.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF24352E) : const Color(0xFFF0F1F3),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: context.textSecondary,
        labelStyle: AppTypography.captionBold,
        unselectedLabelStyle: AppTypography.caption,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(AppIcons.habits, size: 15),
                const SizedBox(width: 6),
                Text('${l10n.habitsLabel} (${_filteredHabits.length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(AppIcons.sprout, size: 15),
                const SizedBox(width: 6),
                Text('${l10n.plant} (${_filteredPlants.length})'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsList() {
    final l10n = AppLocalizations.of(context)!;
    if (_filteredHabits.isEmpty) {
      return AdminEmptyState(
        icon: AppIcons.habits,
        title: l10n.noHabits,
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
        itemCount: _filteredHabits.length,
        itemBuilder: (_, i) => _buildHabitCard(_filteredHabits[i]),
      ),
    );
  }

  Widget _buildHabitCard(Map<String, dynamic> habit) {
    final l10n = AppLocalizations.of(context)!;
    final category = habit['category'] as String? ?? 'other';
    final catColor = _categoryColors[category] ?? AppColors.primary;
    final catLabel = _catLabel(category);
    final icon = habit['icon'] as String? ?? '✅';
    final streak = _parseInt(habit['current_streak']);
    final isActive = habit['is_active'] == true || habit['is_active'] == 1;
    final createdAt = habit['created_at'] != null
        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(habit['created_at']))
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: context.isDark ? const Color(0xFF2E433C) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Center(child: HabitIcon(iconString: icon, size: 20, color: catColor)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          habit['name'] ?? '',
                          style: AppTypography.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(l10n.inactive, style: AppTypography.captionBold.copyWith(fontSize: 10, color: AppColors.error)),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(catLabel, style: AppTypography.captionBold.copyWith(fontSize: 10, color: catColor)),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Icon(AppIcons.user, size: 12, color: context.textSecondary),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          habit['user_name'] ?? '',
                          style: AppTypography.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(AppIcons.streak, size: 13, color: AppColors.warning),
                      const SizedBox(width: 3),
                      Text('$streak ${l10n.days}', style: AppTypography.captionBold.copyWith(fontSize: 11, color: AppColors.warning)),
                      const SizedBox(width: AppSpacing.md),
                      Icon(AppIcons.clock, size: 12, color: context.textSecondary),
                      const SizedBox(width: 3),
                      Text(createdAt, style: AppTypography.caption),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantsList(AppLocalizations l10n) {
    if (_filteredPlants.isEmpty) {
      return AdminEmptyState(
        icon: AppIcons.sprout,
        title: l10n.noPlants,
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
        itemCount: _filteredPlants.length,
        itemBuilder: (_, i) => _buildPlantCard(_filteredPlants[i], l10n),
      ),
    );
  }

  Widget _buildPlantCard(Map<String, dynamic> plant, AppLocalizations l10n) {
    final level = _parseInt(plant['level'], 1);
    final exp = _parseInt(plant['experience']);
    final plantTypeId = plant['plant_type'] as String? ?? 'bamboo';
    final lastWatered = plant['last_watered'] != null
        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(plant['last_watered']))
        : '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminPlantDetailScreen(
              userId: plant['user_id']?.toString() ?? '',
              userName: plant['user_name'] as String? ?? '',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: context.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: context.isDark ? const Color(0xFF2E433C) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Image.asset(
                  _getPlantImagePath(level, plantTypeId),
                  width: 48, height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(AppIcons.sprout, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant['user_name'] as String? ?? 'Unknown',
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_getPlantName(context, level, plantTypeId)} · ${l10n.level(level)}',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _getProgressToNextLevel(level, exp),
                        backgroundColor: context.isDark ? const Color(0xFF2E433C) : const Color(0xFFE5E7EB),
                        color: AppColors.primary,
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text('${l10n.lastWatered}: $lastWatered', style: AppTypography.caption.copyWith(fontSize: 10)),
                  ],
                ),
              ),
              Icon(AppIcons.chevronRight, size: 16, color: context.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  int _parseInt(dynamic v, [int fallback = 0]) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }
}
