import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/flow_prefs.dart';
import '../services/notification_inbox_store.dart';
import '../navigation/app_navigation.dart';
import '../widgets/achievement_popup.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/viora_app_bar.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';
import '../l10n/app_localizations.dart';
import 'stats_screen.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  List<dynamic> habits = [];
  bool isLoading = true;
  String token = "";
  int? _highlightHabitId;

  List<Map<String, dynamic>> get categories {
    final l10n = AppLocalizations.of(context)!;
    return [
      {"id": "eat", "label": l10n.categoryEat, "icon": "🥗"},
      {"id": "exercise", "label": l10n.categoryExercise, "icon": "🏃"},
      {"id": "sleep", "label": l10n.categorySleep, "icon": "😴"},
      {"id": "mental", "label": l10n.categoryMental, "icon": "🧘"},
      {"id": "hydration", "label": l10n.categoryHydration, "icon": "💧"},
      {"id": "other", "label": l10n.categoryOther, "icon": "⭐"},
    ];
  }

  @override
  void initState() {
    super.initState();
    loadHabits();
  }

  void loadHabits() async {
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
        AppSnackbar.showSuccess(context, l10n.onboardingReadyCheckHabits);
      }
    }
  }

  void handleCheckIn(int habitId, bool isCompleted) async {
    // Nếu đã hoàn thành rồi thì không làm gì
    if (isCompleted) return;

    // Lấy thông tin habit để biết category
    final habit = habits.firstWhere((h) => h["id"] == habitId);
    final category = habit["category"] as String;

    // Hiện dialog xác nhận
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => _buildCheckInDialog(ctx, category),
    );

    if (result == null || result["confirmed"] != true) return;

    // Optimistic update
    setState(() {
      final idx = habits.indexWhere((h) => h["id"] == habitId);
      if (idx != -1) habits[idx]["is_completed"] = 1;
    });

    final res = await ApiService.checkInHabit(
      token,
      habitId,
      metricValue: result["metric_value"],
      metricUnit: result["metric_unit"],
    );

    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    final newAchievements = res["new_achievements"] as List?;
    if (newAchievements != null && newAchievements.isNotEmpty) {
      for (final a in newAchievements) {
        await NotificationInboxStore.add(
          title: a["title"]?.toString() ?? l10n.achievements,
          body: a["description"]?.toString() ?? '',
          emoji: a["icon"]?.toString() ?? '🏆',
          targetTab: 1,
        );
      }
      AchievementPopup.show(context, newAchievements);
    }

    final firstDone = await FlowPrefs.hasCompletedFirstCheckIn();
    if (!firstDone && mounted) {
      await FlowPrefs.markFirstCheckInDone();
      await _showFirstCheckInDialog();
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
    AppSnackbar.showSuccess(context, l10n.habitCreatedSuccess);

    if (wasFirst) {
      await _showAfterFirstHabitDialog(habitId);
    }
  }

  Future<void> _showAfterFirstHabitDialog(int habitId) async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.firstCheckInTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.firstCheckInBody),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF81C784)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.bar_chart_rounded,
                    color: Color(0xFF2E7D32),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.firstCheckInStatsHint,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: Color(0xFF1B5E20),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.gotIt),
          ),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              );
            },
            icon: const Icon(Icons.bar_chart_rounded, size: 18),
            label: Text(l10n.viewHabitStats),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppNavigation.openPlant();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.viewYourPlant),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInDialog(BuildContext ctx, String category) {
    final l10n = AppLocalizations.of(context)!;
    final metricController = TextEditingController();
    String? metricUnit;
    String? metricLabel;

    // Xác định metric theo category
    switch (category) {
      case "hydration":
        metricLabel = l10n.metricWater;
        metricUnit = l10n.unitMl;
        break;
      case "exercise":
        metricLabel = l10n.metricDistance;
        metricUnit = l10n.unitM;
        break;
      case "sleep":
        metricLabel = l10n.metricSleepHours;
        metricUnit = l10n.unitHours;
        break;
      case "eat":
        metricLabel = l10n.metricCalories;
        metricUnit = l10n.unitCal;
        break;
      default:
        metricLabel = null;
        metricUnit = null;
    }

    return AlertDialog(
      backgroundColor: ctx.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Text("✅ ", style: TextStyle(fontSize: 22)),
          Text(
            l10n.confirmCompletion,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ctx.textPrimary,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.confirmHabitMessage,
            style: TextStyle(
              fontSize: 14,
              color: ctx.textPrimary,
              height: 1.5,
            ),
          ),
          if (metricLabel != null) ...[
            const SizedBox(height: 16),
            Text(
              metricLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ctx.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: metricController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: ctx.textPrimary),
              decoration: InputDecoration(
                hintText: l10n.enterNumberOptional,
                hintStyle: TextStyle(color: ctx.textSecondary, fontSize: 14),
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
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx, {"confirmed": false}),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ctx.textSecondary,
                  side: BorderSide(color: ctx.textSecondary.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(l10n.notSure),
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(l10n.completedExclaim),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void handleDelete(int habitId) async {
    await ApiService.deleteHabit(token, habitId);
    setState(() => habits.removeWhere((h) => h["id"] == habitId));
  }

  void showEditHabitSheet(Map habit) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: habit["name"]?.toString() ?? '');
    String selectedCategory = habit["category"]?.toString() ?? "other";
    String selectedIcon = habit["icon"]?.toString() ?? "⭐";
    final habitId = habit["id"] as int;
    final icons = ["⭐", "🏃", "🥗", "💧", "😴", "🧘", "📚", "🎯", "💪", "🌿"];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.editHabit,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ctx.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                style: TextStyle(color: ctx.textPrimary),
                decoration: InputDecoration(
                  labelText: l10n.habitName,
                  filled: true,
                  fillColor: ctx.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: categories.map((c) {
                  final id = c["id"] as String;
                  final selected = selectedCategory == id;
                  return ChoiceChip(
                    label: Text("${c["icon"]} ${c["label"]}"),
                    selected: selected,
                    onSelected: (_) =>
                        setSheetState(() => selectedCategory = id),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: icons.map((icon) {
                  return ChoiceChip(
                    label: Text(icon),
                    selected: selectedIcon == icon,
                    onSelected: (_) => setSheetState(() => selectedIcon = icon),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) return;
                    Navigator.pop(ctx);
                    final res = await ApiService.updateHabit(
                      token: token,
                      habitId: habitId,
                      name: nameController.text.trim(),
                      category: selectedCategory,
                      icon: selectedIcon,
                    );
                    if (!mounted) return;
                    if (res["message"] == null ||
                        res["message"] == "Habit updated") {
                      loadHabits();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.habitUpdated),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(l10n.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showAddHabitSheet() {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    String selectedCategory = "other";
    String selectedIcon = "⭐";

    final icons = ["⭐", "🏃", "🥗", "💧", "😴", "🧘", "📚", "🎯", "💪", "🌿"];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // handle bar
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: ctx.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(l10n.addNewHabit,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ctx.textPrimary)),
              const SizedBox(height: 24),

              // ICON PICKER
              Text(l10n.selectIcon,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ctx.textSecondary)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: icons.map((icon) => GestureDetector(
                  onTap: () => setSheetState(() => selectedIcon = icon),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: selectedIcon == icon
                          ? const Color(0xFFE8F5E9)
                          : ctx.inputFill,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selectedIcon == icon
                            ? const Color(0xFF4CAF50)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(icon, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 20),

              // NAME
              Text(l10n.habitName,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ctx.textSecondary)),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                autofocus: true,
                style: TextStyle(color: ctx.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.habitNameExample,
                  hintStyle: TextStyle(color: ctx.textSecondary, fontSize: 14),
                  filled: true,
                  fillColor: ctx.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // CATEGORY
              Text(l10n.category,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ctx.textSecondary)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((c) => GestureDetector(
                  onTap: () => setSheetState(() => selectedCategory = c["id"]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selectedCategory == c["id"]
                          ? const Color(0xFFE8F5E9)
                          : ctx.inputFill,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selectedCategory == c["id"]
                            ? const Color(0xFF4CAF50)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      "${c["icon"]} ${c["label"]}",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: selectedCategory == c["id"]
                            ? const Color(0xFF2E7D32)
                            : ctx.textPrimary,
                      ),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 28),

              // SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) return;
                    final name = nameController.text.trim();
                    Navigator.pop(ctx);
                    final res = await ApiService.createHabit(
                      token: token,
                      name: name,
                      category: selectedCategory,
                      icon: selectedIcon,
                    );
                    if (!mounted) return;
                    if (res['habit'] != null) {
                      await _onHabitCreated(
                        Map<String, dynamic>.from(res['habit'] as Map),
                      );
                    } else {
                      AppSnackbar.showError(
                        context,
                        res['message']?.toString() ?? l10n.failed,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(l10n.addHabit,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final completed = habits.where((h) => h["is_completed"] == 1).length;
    final total = habits.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: VioraAppBar(
        title: l10n.habitsToday,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded,
                color: AppColors.primary, size: 24),
            tooltip: l10n.statsTitle,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: AppColors.primary, size: 26),
            onPressed: showAddHabitSheet,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
          : habits.isEmpty
              ? _buildEmptyState()
              : CustomScrollView(
                  slivers: [
                    if (_highlightHabitId != null)
                      SliverToBoxAdapter(child: _buildTapToCompleteHint()),
                    SliverToBoxAdapter(
                      child: _buildProgressCard(completed, total, progress),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _buildHabitCard(habits[i]),
                          childCount: habits.length,
                        ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: habits.isNotEmpty
          ? FloatingActionButton(
              onPressed: showAddHabitSheet,
              backgroundColor: const Color(0xFF4CAF50),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildTapToCompleteHint() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.touch_app_rounded, color: Color(0xFF2E7D32), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.tapHabitToCompleteHint,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Color(0xFF2E7D32)),
            onPressed: () => setState(() => _highlightHabitId = null),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(int completed, int total, double progress) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            completed == total && total > 0
                ? l10n.amazingAllDone
                : l10n.yourToday,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                "$completed/$total",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.habitsLabel,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitCard(Map habit) {
    final l10n = AppLocalizations.of(context)!;
    final isCompleted = habit["is_completed"] == 1;
    final currentStreak = habit["current_streak"] ?? 0;
    final categoryIcon = categories.firstWhere(
      (c) => c["id"] == habit["category"],
      orElse: () => {"icon": "⭐"},
    )["icon"];

    final habitId = habit['id'] as int;
    final isHighlighted = _highlightHabitId == habitId;

    return Dismissible(
      key: Key("habit_${habit["id"]}"),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
      ),
      confirmDismiss: (_) async {
        return await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(l10n.deleteHabit),
            content: Text(l10n.confirmDeleteHabit(habit["name"])),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
              ),
            ],
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
                handleCheckIn(habitId, isCompleted);
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isCompleted
                ? const Color(0xFFE8F5E9)
                : Theme.of(context).cardTheme.color ?? Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted
                  ? const Color(0xFF4CAF50)
                  : isHighlighted
                      ? const Color(0xFF66BB6A)
                      : Colors.transparent,
              width: isHighlighted ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
                          : const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        habit["icon"] ?? categoryIcon,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // name + category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit["name"],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isCompleted
                                ? const Color(0xFF2E7D32)
                                : context.textPrimary,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "$categoryIcon ${categories.firstWhere((c) => c["id"] == habit["category"], orElse: () => {"label": l10n.categoryOther})["label"]}",
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  // checkbox
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFF4CAF50)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCompleted
                            ? const Color(0xFF4CAF50)
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                ],
              ),
              // Streak indicator
              if (currentStreak > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("🔥", style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        l10n.consecutiveDays(currentStreak),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFFF9800),
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("🌱", style: TextStyle(fontSize: 64)),
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
              backgroundColor: const Color(0xFF4CAF50),
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
