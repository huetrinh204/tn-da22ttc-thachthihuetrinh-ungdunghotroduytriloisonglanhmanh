import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../navigation/app_navigation.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';
import '../widgets/viora_app_bar.dart';
import 'achievements_screen.dart';
import 'plant_screen.dart';

/// Tab Phát triển: chuỗi, thành tựu, cây.
class GrowScreen extends StatefulWidget {
  const GrowScreen({super.key});

  @override
  State<GrowScreen> createState() => _GrowScreenState();
}

class _GrowScreenState extends State<GrowScreen> {
  int currentStreak = 0;
  int longestStreak = 0;
  bool streakLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final res = await ApiService.getStreak(token);
    if (!mounted) return;
    setState(() {
      currentStreak = res['streak']?['current_streak'] ?? 0;
      longestStreak = res['streak']?['longest_streak'] ?? 0;
      streakLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: VioraAppBar(title: l10n.grow),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                _buildStreakCard(l10n),
                const SizedBox(height: 12),
                _buildQuickActions(l10n),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Expanded(
            child: PlantScreen(embedded: true),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(AppLocalizations l10n) {
    if (streakLoading) {
      return const SizedBox(
        height: 88,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => AppNavigation.openHabits(),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.daysStreak(currentStreak),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.keepItUp,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 18)),
                  Text(
                    '$longestStreak',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    l10n.longestStreakLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AchievementsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.emoji_events_outlined, size: 20),
            label: Text(l10n.achievements),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => AppNavigation.openHabits(),
            icon: const Icon(Icons.check_circle_outline, size: 20),
            label: Text(l10n.habits),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
