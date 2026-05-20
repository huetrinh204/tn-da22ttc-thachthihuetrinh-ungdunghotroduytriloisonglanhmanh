import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../theme/theme_extensions.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<dynamic> unlocked = [];
  bool isLoading = true;

  // Danh sách tất cả achievements có thể unlock
  List<Map<String, dynamic>> get _allAchievements {
    final l10n = AppLocalizations.of(context)!;
    return [
      {"key": "first_checkin",  "title": l10n.achievementFirstStep,    "icon": "🌱", "desc": l10n.achievementFirstStepDesc,      "color": 0xFF4CAF50},
      {"key": "streak_3",       "title": l10n.achievementStreak3, "icon": "🔥", "desc": l10n.achievementStreak3Desc,   "color": 0xFFFF7043},
      {"key": "streak_7",       "title": l10n.achievementStreak7,    "icon": "⚡", "desc": l10n.achievementStreak7Desc,   "color": 0xFFFFB300},
      {"key": "streak_30",      "title": l10n.achievementStreak30,     "icon": "🏆", "desc": l10n.achievementStreak30Desc,  "color": 0xFFFFD700},
      {"key": "habits_5",       "title": l10n.achievementHabits5,         "icon": "🎯", "desc": l10n.achievementHabits5Desc,                   "color": 0xFF7C4DFF},
      {"key": "checkin_50",     "title": l10n.achievementCheckin50,         "icon": "💪", "desc": l10n.achievementCheckin50Desc,           "color": 0xFF00BCD4},
      {"key": "checkin_100",    "title": l10n.achievementCheckin100,       "icon": "🌟", "desc": l10n.achievementCheckin100Desc,          "color": 0xFFFF6F00},
      {"key": "plant_level_3",  "title": l10n.achievementPlantLevel3,          "icon": "🪴", "desc": l10n.achievementPlantLevel3Desc,              "color": 0xFF43A047},
      {"key": "plant_level_5",  "title": l10n.achievementPlantLevel5,   "icon": "🌳", "desc": l10n.achievementPlantLevel5Desc,         "color": 0xFF1B5E20},
    ];
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    final res = await ApiService.getAchievements(token);
    if (!mounted) return;
    setState(() {
      unlocked = res["achievements"] ?? [];
      isLoading = false;
    });
  }

  bool _isUnlocked(String key) =>
      unlocked.any((a) => a["achievement_key"] == key);

  String? _unlockedAt(String key) {
    final a = unlocked.firstWhere(
      (a) => a["achievement_key"] == key,
      orElse: () => null,
    );
    if (a == null) return null;
    final dt = DateTime.tryParse(a["unlocked_at"] ?? "");
    if (dt == null) return null;
    return "${dt.day}/${dt.month}/${dt.year}";
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unlockedCount = _allAchievements
        .where((a) => _isUnlocked(a["key"] as String))
        .length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.achievementsTitle,
          style: TextStyle(
            color: context.textGreen,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Progress header
                  _buildProgressHeader(unlockedCount),
                  const SizedBox(height: 20),

                  // Grid achievements
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _allAchievements.length,
                    itemBuilder: (_, i) =>
                        _buildAchievementCard(_allAchievements[i]),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProgressHeader(int unlockedCount) {
    final l10n = AppLocalizations.of(context)!;
    final total = _allAchievements.length;
    final progress = unlockedCount / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("🏆", style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.achievementsCount(unlockedCount, total),
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    unlockedCount == total
                        ? l10n.allAchievementsUnlocked
                        : l10n.achievementsRemaining(total - unlockedCount),
                    style: const TextStyle(
                        fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> ach) {
    final key = ach["key"] as String;
    final isUnlocked = _isUnlocked(key);
    final date = _unlockedAt(key);
    final color = Color(ach["color"] as int);

    return GestureDetector(
      onTap: isUnlocked
          ? () => _showDetail(ach, date)
          : () => _showLocked(ach),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isUnlocked ? context.cardColor : context.surfaceColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked
                ? color.withValues(alpha: 0.4)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon với hiệu ứng grayscale nếu chưa unlock
            ColorFiltered(
              colorFilter: isUnlocked
                  ? const ColorFilter.mode(
                      Colors.transparent, BlendMode.saturation)
                  : const ColorFilter.matrix([
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0,      0,      0,      1, 0,
                    ]),
              child: Text(
                ach["icon"] as String,
                style: TextStyle(
                    fontSize: isUnlocked ? 32 : 28,
                    color: isUnlocked ? null : context.textSecondary),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              ach["title"] as String,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isUnlocked ? context.textGreen : context.textSecondary,
              ),
            ),
            if (!isUnlocked)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(Icons.lock_outline,
                    size: 14, color: context.textSecondary),
              ),
          ],
        ),
      ),
    );
  }

  void _showDetail(Map<String, dynamic> ach, String? date) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: ctx.cardColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(ach["icon"] as String,
                  style: const TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              Text(
                ach["title"] as String,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ctx.textGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ach["desc"] as String,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: ctx.textSecondary),
              ),
              if (date != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: ctx.infoBoxColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.unlockedOn(date),
                    style: TextStyle(
                      fontSize: 12,
                      color: ctx.textGreenLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(l10n.close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocked(Map<String, dynamic> ach) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: ctx.cardColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("🔒", style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                ach["title"] as String,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ctx.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ach["desc"] as String,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: ctx.textSecondary),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: ctx.textSecondary.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    l10n.close,
                    style: TextStyle(color: ctx.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
