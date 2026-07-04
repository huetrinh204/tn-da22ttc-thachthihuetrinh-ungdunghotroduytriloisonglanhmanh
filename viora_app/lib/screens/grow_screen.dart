import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../navigation/app_navigation.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../constants/app_icons.dart';
import '../widgets/viora_app_bar.dart';
import '../widgets/secondary_button.dart';
import 'achievements_screen.dart';
import 'plant_screen.dart';

/// Tab Phát triển: chuỗi, thành tựu, cây.
class GrowScreen extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic>? plant)? onCheckInCompleted;

  const GrowScreen({super.key, this.onCheckInCompleted});

  @override
  State<GrowScreen> createState() => _GrowScreenState();
}

class _GrowScreenState extends State<GrowScreen> {
  int currentStreak = 0;
  int longestStreak = 0;
  int freezeTokens = 0;
  bool streakLoading = true;
  int _plantKey = 0;

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
      freezeTokens = res['streak']?['freeze_tokens'] ?? 0;
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
          Expanded(
            child: PlantScreen(key: ValueKey('plant_$_plantKey'), embedded: true),
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
            children: [
              Icon(AppIcons.streak, color: Colors.white, size: 32),
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
                  Icon(AppIcons.trophy, color: Colors.amber.shade300, size: 22),
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
              const SizedBox(width: 16),
              Tooltip(
                message: 'Duy trì 7 ngày liên tục để nhận Freeze\nTối đa 2 Freeze • Bảo vệ streak khi bỏ 1 ngày',
                triggerMode: TooltipTriggerMode.longPress,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(color: Colors.white, fontSize: 12),
                child: Column(
                  children: [
                    const Text('🧊', style: TextStyle(fontSize: 22)),
                    Text(
                      '$freezeTokens',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Freeze',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              if (freezeTokens > 0) ...[
                const SizedBox(width: 16),
                Column(
                  children: [
                    const Text('🧊', style: TextStyle(fontSize: 22)),
                    Text(
                      '$freezeTokens',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Freeze',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
    );
  }

  Widget _buildQuickActions(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: SecondaryButton(
            text: l10n.achievements,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AchievementsScreen(),
                ),
              );
            },
            icon: Icon(AppIcons.trophy, size: 20),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SecondaryButton(
            text: l10n.habits,
            onPressed: () async {
              await AppNavigation.openHabits(
                onCheckInCompleted: (plant) async {
                  await widget.onCheckInCompleted?.call(plant);
                  if (mounted) setState(() => _plantKey++);
                },
              );
            },
            icon: Icon(AppIcons.habits, size: 20),
          ),
        ),
      ],
    );
  }
}
