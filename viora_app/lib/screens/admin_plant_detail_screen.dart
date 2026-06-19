import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/viora_app_bar.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';
import '../l10n/app_localizations.dart';
import '../models/plant_type.dart';
import '../widgets/habit_icon.dart';

class AdminPlantDetailScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const AdminPlantDetailScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<AdminPlantDetailScreen> createState() => _AdminPlantDetailScreenState();
}

class _AdminPlantDetailScreenState extends State<AdminPlantDetailScreen> {
  bool _isLoading = true;
  String _token = '';
  Map<String, dynamic>? _plant;
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _streak;
  Map<String, dynamic>? _stats;
  List<dynamic> _history = [];

  @override
  void initState() {
    super.initState();
    _loadPlantHistory();
  }

  Future<void> _loadPlantHistory() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';

    try {
      final res = await ApiService.getPlantHistory(_token, widget.userId);
      if (!mounted) return;
      setState(() {
        _plant = res['plant'];
        _user = res['user'];
        _streak = res['streak'];
        _stats = res['stats'];
        _history = res['history'] ?? [];
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
    // Map key to localized string
    return _resolveStageName(loc, key) ?? '${plantType.emoji} Level $level';
  }

  String? _resolveStageName(AppLocalizations loc, String key) {
    // Bamboo
    final bambooMap = {
      'bambooLevel1': loc.bambooLevel1, 'bambooLevel2': loc.bambooLevel2,
      'bambooLevel3': loc.bambooLevel3, 'bambooLevel4': loc.bambooLevel4,
      'bambooLevel5': loc.bambooLevel5, 'bambooLevel6': loc.bambooLevel6,
      'bambooLevel7': loc.bambooLevel7, 'bambooLevel8': loc.bambooLevel8,
      'bambooLevel9': loc.bambooLevel9, 'bambooLevel10': loc.bambooLevel10,
      'bambooLevel11': loc.bambooLevel11, 'bambooLevel12': loc.bambooLevel12,
      'bambooLevel13': loc.bambooLevel13, 'bambooLevel14': loc.bambooLevel14,
      'bambooLevel15': loc.bambooLevel15,
    };
    final cactusMap = {
      'cactusLevel1': loc.cactusLevel1, 'cactusLevel2': loc.cactusLevel2,
      'cactusLevel3': loc.cactusLevel3, 'cactusLevel4': loc.cactusLevel4,
      'cactusLevel5': loc.cactusLevel5, 'cactusLevel6': loc.cactusLevel6,
      'cactusLevel7': loc.cactusLevel7, 'cactusLevel8': loc.cactusLevel8,
      'cactusLevel9': loc.cactusLevel9, 'cactusLevel10': loc.cactusLevel10,
      'cactusLevel11': loc.cactusLevel11, 'cactusLevel12': loc.cactusLevel12,
      'cactusLevel13': loc.cactusLevel13,
    };
    final sakuraMap = {
      'sakuraLevel1': loc.sakuraLevel1, 'sakuraLevel2': loc.sakuraLevel2,
      'sakuraLevel3': loc.sakuraLevel3, 'sakuraLevel4': loc.sakuraLevel4,
      'sakuraLevel5': loc.sakuraLevel5, 'sakuraLevel6': loc.sakuraLevel6,
      'sakuraLevel7': loc.sakuraLevel7, 'sakuraLevel8': loc.sakuraLevel8,
      'sakuraLevel9': loc.sakuraLevel9, 'sakuraLevel10': loc.sakuraLevel10,
      'sakuraLevel11': loc.sakuraLevel11, 'sakuraLevel12': loc.sakuraLevel12,
      'sakuraLevel13': loc.sakuraLevel13, 'sakuraLevel14': loc.sakuraLevel14,
    };
    final sunflowerMap = {
      'sunflowerLevel1': loc.sunflowerLevel1, 'sunflowerLevel2': loc.sunflowerLevel2,
      'sunflowerLevel3': loc.sunflowerLevel3, 'sunflowerLevel4': loc.sunflowerLevel4,
      'sunflowerLevel5': loc.sunflowerLevel5, 'sunflowerLevel6': loc.sunflowerLevel6,
      'sunflowerLevel7': loc.sunflowerLevel7, 'sunflowerLevel8': loc.sunflowerLevel8,
      'sunflowerLevel9': loc.sunflowerLevel9, 'sunflowerLevel10': loc.sunflowerLevel10,
      'sunflowerLevel11': loc.sunflowerLevel11, 'sunflowerLevel12': loc.sunflowerLevel12,
      'sunflowerLevel13': loc.sunflowerLevel13, 'sunflowerLevel14': loc.sunflowerLevel14,
      'sunflowerLevel15': loc.sunflowerLevel15, 'sunflowerLevel16': loc.sunflowerLevel16,
    };
    return bambooMap[key] ?? cactusMap[key] ?? sakuraMap[key] ?? sunflowerMap[key];
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: VioraAppBar(
        title: loc.plantOwnerOf(widget.userName),
        showBack: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _plant == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.park_outlined, size: 64, color: context.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        loc.userHasNoPlant,
                        style: TextStyle(
                          fontSize: 16,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPlantHistory,
                  color: AppColors.primary,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildOwnerCard(),
                      const SizedBox(height: 16),
                      _buildPlantCard(),
                      const SizedBox(height: 16),
                      _buildStatsCard(),
                      const SizedBox(height: 24),
                      _buildHistorySection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildOwnerCard() {
    final loc = AppLocalizations.of(context)!;
    final userName = _user?['name'] ?? widget.userName;
    final userEmail = _user?['email'] ?? '';
    final userAvatar = _user?['avatar_url'] as String?;
    final userCreatedAt = _user?['created_at'] as String?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.infoBoxBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: userAvatar != null
                ? ClipOval(
                    child: Image.network(
                      ApiService.resolveImageUrl(userAvatar),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          userName[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      userName[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: context.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      loc.owner,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                if (userEmail.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.textSecondary,
                    ),
                  ),
                ],
                if (userCreatedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${loc.joinedDate}: ${_formatDate(userCreatedAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantCard() {
    final loc = AppLocalizations.of(context)!;
    final level = _plant!['level'] as int? ?? 1;
    final experience = _plant!['experience'] as int? ?? 0;
    final plantType = _plant!['plant_type'] as String? ?? 'bamboo';
    final lastWatered = _plant!['last_watered'] as String?;

    // Calculate planting date (from user created_at or estimate)
    String? plantingDate;
    if (_user?['created_at'] != null) {
      plantingDate = _formatDate(_user!['created_at']);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Plant image
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Image.asset(
              _getPlantImagePath(level, plantType),
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Center(
                child: Text(
                  PlantType.fromIdOrDefault(plantType).emoji,
                  style: const TextStyle(fontSize: 64),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Plant name
          Text(
            _getPlantName(context, level, plantType),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${loc.plantType}: ${_getPlantTypeName(context, plantType)}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          // Level and experience
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              loc.levelWithExp(level, experience),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Planting date and last watered
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (plantingDate != null) ...[
                const Icon(Icons.spa, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${loc.planted}: $plantingDate',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
              if (plantingDate != null && lastWatered != null) ...[
                const SizedBox(width: 16),
                Container(
                  width: 1,
                  height: 12,
                  color: Colors.white54,
                ),
                const SizedBox(width: 16),
              ],
              if (lastWatered != null) ...[
                const Icon(Icons.water_drop, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${loc.watered}: ${_formatDate(lastWatered)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _getPlantTypeName(BuildContext context, String type) {
    final loc = AppLocalizations.of(context)!;
    switch (type) {
      case 'bamboo':
        return loc.plantTypeBamboo;
      case 'cactus':
        return loc.plantTypeCactus;
      case 'sunflower':
        return loc.plantTypeSunflower;
      case 'flower':
        return loc.plantTypeFlower;
      default:
        return type;
    }
  }

  Widget _buildStatsCard() {
    final loc = AppLocalizations.of(context)!;
    final currentStreak = _streak?['current'] ?? 0;
    final totalHabits = _stats?['total_habits'] ?? 0;
    final daysCompleted = _stats?['days_completed'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.infoBoxBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assessment,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                loc.statistics,
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
              Expanded(
                child: _buildStatItem(
                  icon: Icons.local_fire_department,
                  label: loc.streakDays,
                  value: '$currentStreak',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.check_circle,
                  label: loc.habitsLabel,
                  value: '$totalHabits',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.calendar_month,
                  label: loc.daysCompleted,
                  value: '$daysCompleted',
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    final loc = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              loc.expHistory,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          loc.expPerHabit,
          style: TextStyle(
            fontSize: 13,
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        if (_history.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.event_busy, size: 48, color: context.textSecondary),
                  const SizedBox(height: 12),
                  Text(
                    loc.noExpHistory,
                    style: TextStyle(
                      fontSize: 15,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...(_history.map((entry) => _buildHistoryItem(entry)).toList()),
      ],
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> entry) {
    final loc = AppLocalizations.of(context)!;
    final date = entry['date'] as String;
    final habitsCompleted = entry['habits_completed'] as int? ?? 0;
    final expGained = entry['exp_gained'] as int? ?? 0;
    final habits = entry['habits'] as List? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.infoBoxBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: context.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(date),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+$expGained ${loc.exp}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            loc.habitsCompletedCount(habitsCompleted),
            style: TextStyle(
              fontSize: 13,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: habits.map<Widget>((habit) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HabitIcon(
                      iconString: habit['icon']?.toString() ?? '⭐',
                      size: 12,
                      color: context.textPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      habit['name'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    final loc = AppLocalizations.of(context)!;
    
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date).inDays;

      if (diff == 0) return loc.today;
      if (diff == 1) return loc.yesterday;
      if (diff < 7) return loc.daysAgoCount(diff);

      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
