import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/flow_prefs.dart';
import '../services/notification_inbox_store.dart';
import '../services/notification_service.dart';
import '../navigation/app_navigation.dart';
import '../widgets/achievement_popup.dart';
import '../widgets/all_habits_completed_dialog.dart';
import '../widgets/first_checkin_dialog.dart';
import '../widgets/points_fly_animation.dart';
import '../widgets/habit_icon.dart';
import '../widgets/app_confirm_dialog.dart';
import '../widgets/app_notification_dialog.dart';
import '../widgets/app_success_dialog.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../widgets/viora_app_bar.dart';
import 'stats_screen.dart';
import 'add_habit_screen.dart';

class HabitsScreen extends StatefulWidget {
  final GlobalKey? statsCoachKey;
  final GlobalKey? addCoachKey;
  final GlobalKey? listCoachKey;
  final Future<void> Function(Map<String, dynamic>? plant)? onHabitCheckInCompleted;
  final VoidCallback? onHabitDeleted;

  const HabitsScreen({
    super.key,
    this.statsCoachKey,
    this.addCoachKey,
    this.listCoachKey,
    this.onHabitCheckInCompleted,
    this.onHabitDeleted,
  });

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  List<dynamic> habits = [];
  bool isLoading = true;
  String token = "";
  int? _highlightHabitId;
  int _activeTabIndex = 0;
  final List<Widget> _flyingAnimations = [];
  final GlobalKey _treeIconKey = GlobalKey();
  final GlobalKey _stackKey = GlobalKey();
  final Map<int, GlobalKey> _habitCardKeys = {};

  List<Map<String, dynamic>> get categories {
    final l10n = AppLocalizations.of(context)!;
    return [
      {"id": "eat", "label": l10n.categoryEat, "icon": "ðŸ¥—"},
      {"id": "exercise", "label": l10n.categoryExercise, "icon": "ðŸƒ"},
      {"id": "sleep", "label": l10n.categorySleep, "icon": "ðŸ˜´"},
      {"id": "mental", "label": l10n.categoryMental, "icon": "ðŸ§˜"},
      {"id": "hydration", "label": l10n.categoryHydration, "icon": "ðŸ’§"},
      {"id": "other", "label": l10n.categoryOther, "icon": "â­"},
    ];
  }

  @override
  void initState() {
    super.initState();
    loadHabits();
  }

  Future<void> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token") ?? "";

    final res = await ApiService.getTodayHabits(token);
    final list = res["habits"] ?? [];
    
    final showOnboardingReady = await FlowPrefs.consumeOnboardingHabitsReady();
    if (mounted) {
      setState(() {
        habits = list;
        isLoading = false;
        if (showOnboardingReady && list.isNotEmpty) {
          _highlightHabitId = list.first["id"] as int?;
        }
      });
      if (showOnboardingReady && list.isNotEmpty) {
        final l10n = AppLocalizations.of(context)!;
        AppNotificationDialog.show(context, type: NotificationType.success, title: l10n.onboardingReadyCheckHabits);
      }
    }
  }

  void handleCheckIn(int habitId, bool isCompleted, {Offset? cardPosition}) async {
    // Náº¿u Ä‘Ã£ hoÃ n thÃ nh rá»“i thÃ¬ khÃ´ng lÃ m gÃ¬
    if (isCompleted) return;

    // Láº¥y thÃ´ng tin habit Ä‘á»ƒ biáº¿t category
    final habit = habits.firstWhere((h) => h["id"] == habitId);
    final category = habit["category"] as String;

    // Hiá»‡n dialog xÃ¡c nháº­n
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => _buildCheckInDialog(ctx, category),
    );

    if (result == null || result["confirmed"] != true) return;

    if (!mounted) return;

    // Get habit card position for animation start
    final habitPosition = cardPosition ?? Offset.zero;

    final currentCountGlobal = double.tryParse(habit["completed_count"]?.toString() ?? '') ?? 0.0;
    final targetCountGlobal = double.tryParse(habit["target_count"]?.toString() ?? '') ?? 1.0;
    final remaining = targetCountGlobal - currentCountGlobal;
    final metricValue = result["metric_value"] as double? ?? (remaining > 0 ? remaining : 1.0);

    // Optimistic update: chá»‰ cáº­p nháº­t completed_count, KHÃ”NG set is_completed
    // vÃ¬ pháº£i Ä‘á»£i server xÃ¡c nháº­n má»›i biáº¿t cÃ³ Ä‘á»§ má»¥c tiÃªu chÆ°a
    setState(() {
      final idx = habits.indexWhere((h) => h["id"] == habitId);
      if (idx != -1) {
        final currentCount = double.tryParse(habits[idx]["completed_count"]?.toString() ?? '') ?? 0.0;
        habits[idx]["completed_count"] = currentCount + metricValue;
        // KHÃ”NG set is_completed á»Ÿ Ä‘Ã¢y â€” chá» server tráº£ vá» káº¿t quáº£ thá»±c
      }
    });

    final res = await ApiService.checkInHabit(
      token,
      habitId,
      metricValue: metricValue,
      metricUnit: result["metric_unit"],
    );

    // Cáº­p nháº­t is_completed Dá»°A THEO káº¿t quáº£ tá»« server
    if (!mounted) return;
    final serverCompleted = res["is_completed"] == true;
    setState(() {
      final idx = habits.indexWhere((h) => h["id"] == habitId);
      if (idx != -1) {
        habits[idx]["is_completed"] = serverCompleted ? 1 : 0;
      }
    });

    // Náº¿u Ä‘Ã£ hoÃ n thÃ nh má»¥c tiÃªu, há»§y cÃ¡c thÃ´ng bÃ¡o nháº¯c nhá»Ÿ cÃ²n láº¡i trong ngÃ y
    if (serverCompleted) {
      await NotificationService.cancelHabitReminders(habitId);
    }

    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    // Show flying points animation if points earned
    final pointsEarned = res["points_earned"] as int?;
    if (pointsEarned != null && pointsEarned > 0) {
      _showPointsFlyAnimation(habitPosition, pointsEarned);
    }

    final newAchievements = res["new_achievements"] as List?;
    if (newAchievements != null && newAchievements.isNotEmpty) {
      for (final a in newAchievements) {
        await NotificationInboxStore.add(
          title: a["title"]?.toString() ?? l10n.achievements,
          body: a["description"]?.toString() ?? '',
          emoji: a["icon"]?.toString() ?? 'ðŸ†',
          targetTab: 1,
        );
      }
      AchievementPopup.show(context, newAchievements);
    }

    if (serverCompleted) {
      final postCheckinStep = await FlowPrefs.getPostCheckinCoachStep();
      if (postCheckinStep > 0 && mounted) {
        await _showFirstCheckInDialog();
        await FlowPrefs.completePostCheckinCoachFlow();
        await FlowPrefs.markFirstCheckInDone();
        return;
      }

      final firstDone = await FlowPrefs.hasCompletedFirstCheckIn();
      if (!firstDone && mounted) {
        await FlowPrefs.markFirstCheckInDone();
        await _showFirstCheckInDialog();
      }
    }

    await widget.onHabitCheckInCompleted?.call(res["plant"] as Map<String, dynamic>?);

    // Refresh habits from server to ensure accuracy
    await loadHabits();

    // Show celebration if all habits completed today
    if (mounted && habits.isNotEmpty && habits.every((h) => h["is_completed"] == 1)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) AllHabitsCompletedDialog.show(context);
      });
    }

  }

  Future<void> _onHabitCreated(Map<String, dynamic> habit) async {
    final wasFirst = habits.isEmpty;
    final habitId = habit['id'] as int;

    setState(() {
      habits.insert(0, {...habit, 'is_completed': 0});
      if (wasFirst) _highlightHabitId = habitId;
    });

    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    AppSuccessDialog.show(
      context,
      title: l10n.habitCreatedSuccess,
    );

    if (wasFirst) {
      await _showAfterFirstHabitDialog(habitId);
    }

  }

  void _showPointsFlyAnimation(Offset startPosition, int points) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Get tree icon position
      final RenderBox? treeBox =
          _treeIconKey.currentContext?.findRenderObject() as RenderBox?;
      if (treeBox == null) return;

      // Convert start position from global to Stack-local coordinates
      final RenderBox? stackBox =
          _stackKey.currentContext?.findRenderObject() as RenderBox?;
      if (stackBox == null) return;

      final stackLocalStart = stackBox.globalToLocal(startPosition);
      final treeGlobal = treeBox.localToGlobal(Offset.zero);
      final treeCenterGlobal = Offset(
        treeGlobal.dx + treeBox.size.width / 2,
        treeGlobal.dy + treeBox.size.height / 2,
      );
      final stackLocalEnd = stackBox.globalToLocal(treeCenterGlobal);

      // Create animation widget with Stack-local coordinates
      final animationWidget = PointsFlyAnimation(
        points: points,
        startPosition: Offset(
          stackLocalStart.dx + 40,
          stackLocalStart.dy + 40,
        ),
        endPosition: stackLocalEnd,
        onComplete: () {
          if (mounted) {
            setState(() {
              _flyingAnimations.removeAt(0);
            });
          }
        },
      );

      setState(() {
        _flyingAnimations.add(animationWidget);
      });
    });
  }

  Future<void> _showAfterFirstHabitDialog(int habitId) async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.afterFirstHabitTitle),
        content: Text(l10n.afterFirstHabitBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.addAnotherHabit),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppNavigation.openToday();
            },
            child: Text(l10n.goToTodayTab),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final h = habits.cast<Map<String, dynamic>?>().firstWhere(
                    (x) => x?['id'] == habitId,
                    orElse: () => null,
                  );
              if (h != null) {
                handleCheckIn(habitId, h['is_completed'] == 1);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.completeHabitToday),
          ),
        ],
      ),
    );
  }

  Future<void> _showFirstCheckInDialog() async {
    await FirstCheckinDialog.show(
      context,
      onViewStats: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StatsScreen()),
        );
      },
      onViewPlant: () {
        if (context.mounted) Navigator.pop(context);
        AppNavigation.openPlant();
      },
    );
  }

  Widget _buildCheckInDialog(BuildContext ctx, String category) {
    final l10n = AppLocalizations.of(context)!;
    final metricController = TextEditingController();
    String? metricUnit;
    String? metricLabel;
    String metricHint = l10n.enterNumberOptional;

    // XÃ¡c Ä‘á»‹nh metric theo category
    switch (category) {
      case "hydration":
        metricLabel = l10n.metricWater;
        metricUnit = l10n.unitMl;
        break;
      case "exercise":
        metricLabel = l10n.metricExercise;
        metricUnit = l10n.unitMinutes;
        break;
      case "sleep":
        metricLabel = l10n.metricSleepMinutes;
        metricUnit = l10n.unitMinutes;
        break;
      case "eat":
        metricLabel = l10n.metricCalories;
        metricUnit = l10n.unitCal;
        break;
      case "mental":
        metricLabel = l10n.metricExercise;
        metricUnit = l10n.unitMinutes;
        break;
      default:
        metricLabel = null;
        metricUnit = null;
    }

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Success/Confirmation
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            // Title
            Text(
              l10n.confirmCompletion,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ctx.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            // Message Description
            Text(
              l10n.confirmHabitMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: ctx.textSecondary,
                height: 1.45,
              ),
            ),
            if (metricLabel != null) ...[
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  metricLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ctx.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: metricController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: ctx.textPrimary),
                decoration: InputDecoration(
                  hintText: metricHint,
                  hintStyle: TextStyle(color: ctx.textSecondary.withValues(alpha: 0.6), fontSize: 14),
                  suffixText: metricUnit,
                  filled: true,
                  fillColor: ctx.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
            const SizedBox(height: 28),
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, {"confirmed": false}),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: context.isDark ? const Color(0xFF2E433C) : Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      l10n.notSure,
                      style: TextStyle(
                        color: context.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final metricValue = metricController.text.trim().isNotEmpty
                          ? double.tryParse(metricController.text.trim())
                          : null;
                      Navigator.pop(ctx, {
                        "confirmed": true,
                        "metric_value": metricValue,
                        "metric_unit": metricUnit,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      l10n.completedExclaim,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void handleDelete(int habitId) async {
    await ApiService.deleteHabit(token, habitId);
    await NotificationService.cancelHabitReminders(habitId);
    setState(() => habits.removeWhere((h) => h["id"] == habitId));
    // Notify parent to refresh plant data (GrowScreen + Dashboard)
    widget.onHabitDeleted?.call();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    AppSuccessDialog.show(
      context,
      title: l10n.habitDeletedSuccess,
    );
  }

  void showEditHabitSheet(Map habit) async {
    final l10n = AppLocalizations.of(context)!;
    final habitId = habit["id"] as int;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddHabitScreen(initialHabit: habit),
      ),
    );

    if (result == null || !mounted) return;

    final habitData = result as Map<String, dynamic>;
    final reminderEnabled = habitData['reminder_enabled'] as bool? ?? false;
    final reminderTimeStr = habitData['reminder_time'] as String?;

    final res = await ApiService.updateHabit(
      token: token,
      habitId: habitId,
      name: habitData['name'],
      category: habitData['category'],
      icon: habitData['icon'],
      reminderTime: reminderTimeStr,
      reminderEnabled: reminderEnabled,
      targetCount: (habitData['daily_goal'] as double?)?.toInt(),
    );

    if (!mounted) return;

      if (res["message"] == null || res["message"] == "Habit updated") {
        loadHabits();
      AppSuccessDialog.show(
        context,
        title: l10n.habitUpdated,
      );
    } else {
      AppNotificationDialog.show(context, type: NotificationType.error, title: res['message']?.toString() ?? l10n.failed);
    }
  }

  void showAddHabitSheet() async {
    final l10n = AppLocalizations.of(context)!;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddHabitScreen(),
      ),
    );
    
    if (result == null || !mounted) return;
    
    final habitData = result as Map<String, dynamic>;
    final reminderEnabled = habitData['reminder_enabled'] as bool? ?? false;
    final reminderTime = habitData['reminder_time'] as String?;

    final res = await ApiService.createHabit(
      token: token,
      name: habitData['name'],
      category: habitData['category'],
      icon: habitData['icon'],
      targetCount: (habitData['daily_goal'] as double?)?.toInt(),
      reminderTime: reminderEnabled ? reminderTime : null,
      reminderEnabled: reminderEnabled,
    );
    
    if (!mounted) return;
    
    if (res['habit'] != null) {
      final newHabit = Map<String, dynamic>.from(res['habit'] as Map);
      await _onHabitCreated(newHabit);

    } else {
      AppNotificationDialog.show(context, type: NotificationType.error, title: res['message']?.toString() ?? l10n.failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filteredHabits = habits.where((h) {
      final isCompleted = h["is_completed"] == 1;
      if (_activeTabIndex == 0) {
        return !isCompleted;
      } else {
        return isCompleted;
      }
    }).toList();

    Widget bodyContent;
    if (isLoading) {
      bodyContent = const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    } else if (habits.isEmpty) {
      bodyContent = _buildEmptyState();
    } else {
      bodyContent = ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildTabSelector(),
          const SizedBox(height: 8),
          if (filteredHabits.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Text(
                  _activeTabIndex == 1
                      ? l10n.noHabitsCompletedToday
                      : l10n.addHabitToStart,
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...filteredHabits.map((h) => _buildHabitCard(h)),
          _buildQuoteCard(),
          const SizedBox(height: 100),
        ],
      );
    }

    return Stack(
      key: _stackKey,
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: VioraAppBar(
            title: l10n.habits,
            showBack: true,
            actions: [
              IconButton(
                key: _treeIconKey,
                icon: const Icon(Icons.eco_rounded, size: 26),
                tooltip: l10n.myPlant,
                onPressed: () {
                  if (context.mounted) Navigator.pop(context);
                  AppNavigation.openPlant();
                },
              ),
              IconButton(
                key: widget.statsCoachKey,
                icon: const Icon(Icons.bar_chart_rounded, size: 24),
                tooltip: l10n.statsTitle,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StatsScreen()),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: bodyContent,
          floatingActionButton: isLoading
              ? null
              : FloatingActionButton.extended(
                  onPressed: showAddHabitSheet,
                  backgroundColor: AppColors.primary,
                  elevation: 4,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    l10n.addHabitButton,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
        ),
        // Flying animations overlay
        ..._flyingAnimations,
      ],
    );
  }

  Widget _buildTabSelector() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.inputFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTabIndex = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _activeTabIndex == 0 ? context.cardColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    l10n.habitsInProgress,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _activeTabIndex == 0 ? AppColors.primary : context.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTabIndex = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _activeTabIndex == 1 ? context.cardColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    l10n.habitsCompleted,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _activeTabIndex == 1 ? AppColors.primary : context.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.quote.replaceAll(r'\n', '\n'),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Icon(
            LucideIcons.sprout,
            size: 48,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitCard(Map habit) {
    final l10n = AppLocalizations.of(context)!;
    final isCompleted = habit["is_completed"] == 1;
    final currentStreak = habit["current_streak"] ?? 0;
    final category = habit["category"]?.toString() ?? "other";
    final categoryIcon = categories.firstWhere(
      (c) => c["id"] == category,
      orElse: () => {"icon": "â­"},
    )["icon"];

    final habitId = habit['id'] as int;
    final cardKey = _habitCardKeys.putIfAbsent(habitId, () => GlobalKey());

    // Safely parse target and completed count
    final double target = double.tryParse(habit["target_count"]?.toString() ?? '') ?? 1.0;
    final double current = double.tryParse(habit["completed_count"]?.toString() ?? '') ?? (isCompleted ? target : 0.0);
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

    // Format progress text
    String progressText = "";
    if (isCompleted) {
      progressText = l10n.completedExclaim;
    } else {
      if (category == 'hydration') {
        progressText = "${current.toInt()} / ${target.toInt()} ${l10n.unitMl}";
      } else if (category == 'exercise' || category == 'sleep' || category == 'mental') {
        progressText = "${current.toInt()} / ${target.toInt()} ${l10n.unitMinutes}";
      } else if (category == 'eat') {
        progressText = "${current.toInt()} / ${target.toInt()} ${l10n.unitCal}";
      } else {
        progressText = "${current.toInt()} / ${target.toInt()} ${l10n.times}";
      }
    }

    // Determine right action button
    Widget actionButton;
    if (isCompleted) {
      actionButton = Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 20),
      );
    } else {
      final isProgressType = category == 'hydration' || category == 'eat';
      actionButton = Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: context.cardColor,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Icon(
          isProgressType ? Icons.add : Icons.play_arrow,
          color: AppColors.primary,
          size: 20,
        ),
      );
    }

    return Dismissible(
      key: Key("habit_${habit["id"]}"),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: context.isDark ? const Color(0xFF7F1D1D) : Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
      ),
      confirmDismiss: (_) async {
        return await showDialog(
          context: context,
          builder: (dialogCtx) => AppConfirmDialog(
            icon: Icons.delete_outline_rounded,
            iconColor: AppColors.error,
            iconBackgroundColor: AppColors.error.withValues(alpha: 0.1),
            title: l10n.deleteHabit,
            content: l10n.confirmDeleteHabit(habit["name"]),
            cancelText: l10n.cancel,
            confirmText: l10n.delete,
            confirmColor: AppColors.error,
            onCancel: () => Navigator.pop(dialogCtx, false),
            onConfirm: () => Navigator.pop(dialogCtx, true),
          ),
        );
      },
      onDismissed: (_) => handleDelete(habit["id"]),
      child: GestureDetector(
        onLongPress: () => showEditHabitSheet(habit),
        onTap: isCompleted
            ? null
            : () {
                if (_highlightHabitId == habitId) {
                  setState(() => _highlightHabitId = null);
                }
                // Capture card position for fly animation
                final RenderBox? cardBox = cardKey.currentContext?.findRenderObject() as RenderBox?;
                final pos = cardBox?.localToGlobal(Offset.zero) ?? Offset.zero;
                handleCheckIn(habitId, isCompleted, cardPosition: pos);
              },
        child: Container(
          key: cardKey,
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: context.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Circular Left Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: HabitIcon(
                        iconString: habit["icon"] ?? categoryIcon,
                        size: 24,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Center Title + Streak
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit["name"] ?? "",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        if (currentStreak > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.local_fire_department,
                                size: 14,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$currentStreak ${l10n.days}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Right Action Button
                  GestureDetector(
                    onTap: isCompleted
                        ? null
                        : () {
                            if (_highlightHabitId == habitId) {
                              setState(() => _highlightHabitId = null);
                            }
                            final RenderBox? cardBox = cardKey.currentContext?.findRenderObject() as RenderBox?;
                            final pos = cardBox?.localToGlobal(Offset.zero) ?? Offset.zero;
                            handleCheckIn(habitId, isCompleted, cardPosition: pos);
                          },
                    child: actionButton,
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: context.textSecondary,
                      size: 22,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        showEditHabitSheet(habit);
                      } else if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (dialogCtx) => AppConfirmDialog(
                            icon: Icons.delete_outline_rounded,
                            iconColor: AppColors.error,
                            iconBackgroundColor: AppColors.error.withValues(alpha: 0.1),
                            title: l10n.deleteHabit,
                            content: l10n.confirmDeleteHabit(habit["name"] ?? ""),
                            cancelText: l10n.cancel,
                            confirmText: l10n.delete,
                            confirmColor: AppColors.error,
                            onCancel: () => Navigator.pop(dialogCtx, false),
                            onConfirm: () => Navigator.pop(dialogCtx, true),
                          ),
                        );
                        if (confirm == true) {
                          handleDelete(habitId);
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18, color: context.textPrimary),
                            const SizedBox(width: 8),
                            Text(
                              l10n.editHabit,
                              style: TextStyle(color: context.textPrimary),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                            const SizedBox(width: 8),
                            Text(
                              l10n.delete,
                              style: TextStyle(color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Progress Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.habitProgress,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    progressText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? AppColors.primary : context.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: context.inputFill,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("ðŸŒ±", style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            l10n.noHabits,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.addFirstHabit,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: showAddHabitSheet,
            icon: const Icon(Icons.add),
            label: Text(l10n.addHabit),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

