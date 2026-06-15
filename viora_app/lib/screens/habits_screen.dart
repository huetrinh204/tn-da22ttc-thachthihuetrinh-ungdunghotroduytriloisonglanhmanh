import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/flow_prefs.dart';
import '../services/notification_inbox_store.dart';
import '../navigation/app_navigation.dart';
import '../widgets/achievement_popup.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/points_fly_animation.dart';
import '../widgets/habit_icon.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';
import '../l10n/app_localizations.dart';
import 'stats_screen.dart';
import 'add_habit_screen.dart';

class HabitsScreen extends StatefulWidget {
  final GlobalKey? statsCoachKey;
  final GlobalKey? addCoachKey;
  final GlobalKey? listCoachKey;
  final Future<void> Function()? onHabitCheckInCompleted;

  const HabitsScreen({
    super.key,
    this.statsCoachKey,
    this.addCoachKey,
    this.listCoachKey,
    this.onHabitCheckInCompleted,
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

    if (!mounted) return;

    // Get habit card position for animation start
    final RenderBox? habitBox = context.findRenderObject() as RenderBox?;
    final habitPosition = habitBox?.localToGlobal(Offset.zero) ?? Offset.zero;

    final currentCountGlobal = double.tryParse(habit["completed_count"]?.toString() ?? '') ?? 0.0;
    final targetCountGlobal = double.tryParse(habit["target_count"]?.toString() ?? '') ?? 1.0;
    final remaining = targetCountGlobal - currentCountGlobal;
    final metricValue = result["metric_value"] as double? ?? (remaining > 0 ? remaining : 1.0);

    // Optimistic update: chỉ cập nhật completed_count, KHÔNG set is_completed
    // vì phải đợi server xác nhận mới biết có đủ mục tiêu chưa
    setState(() {
      final idx = habits.indexWhere((h) => h["id"] == habitId);
      if (idx != -1) {
        final currentCount = double.tryParse(habits[idx]["completed_count"]?.toString() ?? '') ?? 0.0;
        habits[idx]["completed_count"] = currentCount + metricValue;
        // KHÔNG set is_completed ở đây — chờ server trả về kết quả thực
      }
    });

    final res = await ApiService.checkInHabit(
      token,
      habitId,
      metricValue: metricValue,
      metricUnit: result["metric_unit"],
    );

    // Cập nhật is_completed DỰA THEO kết quả từ server
    if (!mounted) return;
    final serverCompleted = res["is_completed"] == true;
    setState(() {
      final idx = habits.indexWhere((h) => h["id"] == habitId);
      if (idx != -1) {
        habits[idx]["is_completed"] = serverCompleted ? 1 : 0;
      }
    });

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
          emoji: a["icon"]?.toString() ?? '🏆',
          targetTab: 1,
        );
      }
      AchievementPopup.show(context, newAchievements);
    }

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

    await widget.onHabitCheckInCompleted?.call();
    
    // Refresh habits from server to ensure accuracy
    loadHabits();

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

  void _showPointsFlyAnimation(Offset startPosition, int points) {
    // Get tree icon position
    final RenderBox? treeBox =
        _treeIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (treeBox == null) return;

    final treePosition = treeBox.localToGlobal(Offset.zero);
    final treeCenter = Offset(
      treePosition.dx + treeBox.size.width / 2,
      treePosition.dy + treeBox.size.height / 2,
    );

    // Create animation widget
    final animationWidget = PointsFlyAnimation(
      points: points,
      startPosition: Offset(
        startPosition.dx + 40, // Adjust to start from habit card center
        startPosition.dy + 40,
      ),
      endPosition: treeCenter,
      onComplete: () {
        setState(() {
          _flyingAnimations.removeAt(0);
        });
      },
    );

    setState(() {
      _flyingAnimations.add(animationWidget);
    });
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
                    label: HabitIcon(
                      iconString: icon,
                      size: 20,
                      color: selectedIcon == icon ? const Color(0xFF4CAF50) : null,
                    ),
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
    final res = await ApiService.createHabit(
      token: token,
      name: habitData['name'],
      category: habitData['category'],
      icon: habitData['icon'],
      targetCount: (habitData['daily_goal'] as double?)?.toInt(),
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
        child: CircularProgressIndicator(color: Color(0xFF0F623F)),
      );
    } else if (habits.isEmpty) {
      bodyContent = _buildEmptyState();
    } else {
      bodyContent = ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Thói quen của tôi',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E352F),
              ),
            ),
          ),
          _buildTabSelector(),
          const SizedBox(height: 8),
          if (filteredHabits.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Text(
                  _activeTabIndex == 1
                      ? 'Chưa có thói quen nào hoàn thành hôm nay 🌱'
                      : 'Hãy thêm thói quen mới để bắt đầu nhé! 🌱',
                  style: const TextStyle(
                    color: Color(0xFF7E8A85),
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
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF9FAF7),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            actions: [
              IconButton(
                key: _treeIconKey,
                icon: const Icon(Icons.eco_rounded, color: Color(0xFF0F623F), size: 26),
                tooltip: l10n.myPlant,
                onPressed: () => AppNavigation.openPlant(),
              ),
              IconButton(
                key: widget.statsCoachKey,
                icon: const Icon(Icons.bar_chart_rounded, color: Color(0xFF0F623F), size: 24),
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
                  backgroundColor: const Color(0xFF0F623F),
                  elevation: 4,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Thêm thói quen',
                    style: TextStyle(
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFECEFEB),
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
                  color: _activeTabIndex == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Đang thực hiện',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _activeTabIndex == 0 ? const Color(0xFF0F623F) : const Color(0xFF7E8A85),
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
                  color: _activeTabIndex == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Đã hoàn thành',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _activeTabIndex == 1 ? const Color(0xFF0F623F) : const Color(0xFF7E8A85),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5EF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '"Sức khỏe là lựa chọn, không phải sự tình cờ. Hãy kiên trì với những thói quen nhỏ mỗi ngày nhé!"',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF0F623F),
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Icon(
            LucideIcons.sprout,
            size: 48,
            color: const Color(0xFF0F623F).withValues(alpha: 0.5),
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
      orElse: () => {"icon": "⭐"},
    )["icon"];

    final habitId = habit['id'] as int;

    // Safely parse target and completed count
    final double target = double.tryParse(habit["target_count"]?.toString() ?? '') ?? 1.0;
    final double current = double.tryParse(habit["completed_count"]?.toString() ?? '') ?? (isCompleted ? target : 0.0);
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

    // Format progress text
    String progressText = "";
    if (isCompleted) {
      progressText = "Đã hoàn thành";
    } else {
      if (category == 'hydration') {
        progressText = "${current.toInt()} / ${target.toInt()} ml";
      } else if (category == 'exercise' || category == 'sleep' || category == 'mental') {
        progressText = "${current.toInt()} / ${target.toInt()} phút";
      } else if (category == 'eat') {
        progressText = "${current.toInt()} / ${target.toInt()} calo";
      } else {
        progressText = "${current.toInt()} / ${target.toInt()} lần";
      }
    }

    // Determine right action button
    Widget actionButton;
    if (isCompleted) {
      actionButton = Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Color(0xFF0F623F),
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
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF0F623F), width: 1.5),
        ),
        child: Icon(
          isProgressType ? Icons.add : Icons.play_arrow,
          color: const Color(0xFF0F623F),
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
        child: Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
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
                      color: Color(0xFFEAF5EF),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: HabitIcon(
                        iconString: habit["icon"] ?? categoryIcon,
                        size: 24,
                        color: const Color(0xFF0F623F),
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
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E352F),
                          ),
                        ),
                        if (currentStreak > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.local_fire_department,
                                size: 14,
                                color: Color(0xFF0F623F),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$currentStreak ngày',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F623F),
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
                            handleCheckIn(habitId, isCompleted);
                          },
                    child: actionButton,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Progress Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tiến độ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7E8A85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    progressText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? const Color(0xFF0F623F) : const Color(0xFF1E352F),
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
                  backgroundColor: const Color(0xFFF4F6F4),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F623F)),
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
