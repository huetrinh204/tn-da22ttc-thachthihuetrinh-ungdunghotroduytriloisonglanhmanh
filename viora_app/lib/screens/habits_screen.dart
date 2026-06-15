import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/flow_prefs.dart';
import '../services/notification_inbox_store.dart';
import '../services/notification_service.dart';
import '../navigation/app_navigation.dart';
import '../widgets/achievement_popup.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/points_fly_animation.dart';
import '../widgets/habit_icon.dart';
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
    
    // Auto-schedule / update reminders on launch/load
    for (final h in list) {
      final habitId = h["id"] as int?;
      final isCompleted = h["is_completed"] == 1;
      final reminderTime = h["reminder_time"] as String?;
      if (habitId != null && reminderTime != null && reminderTime.isNotEmpty) {
        if (isCompleted) {
          await NotificationService.cancelHabitReminders(habitId);
        } else {
          await NotificationService.scheduleHabitReminders(
            habitId: habitId,
            habitName: h["name"] ?? "",
            reminderTime: reminderTime,
          );
        }
      }
    }

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

    // Nếu đã hoàn thành mục tiêu, hủy các thông báo nhắc nhở còn lại trong ngày
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
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.bar_chart_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.firstCheckInStatsHint,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: AppColors.primaryDark,
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

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: ctx.cardColor,
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
                  hintText: l10n.enterNumberOptional,
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
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      l10n.notSure,
                      style: const TextStyle(
                        color: Colors.grey,
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
    setState(() => habits.removeWhere((h) => h["id"] == habitId));
  }

  void showEditHabitSheet(Map habit) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: habit["name"]?.toString() ?? '');
    String selectedCategory = habit["category"]?.toString() ?? "other";
    String selectedIcon = habit["icon"]?.toString() ?? "⭐";
    final habitId = habit["id"] as int;
    final icons = ["⭐", "🏃", "🥗", "💧", "😴", "🧘", "📚", "🎯", "💪", "🌿"];

    TimeOfDay reminderTime = const TimeOfDay(hour: 8, minute: 0);
    bool reminderEnabled = habit["reminder_time"] != null;
    if (habit["reminder_time"] != null) {
      final parts = habit["reminder_time"].toString().split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]) ?? 8;
        final m = int.tryParse(parts[1]) ?? 0;
        reminderTime = TimeOfDay(hour: h, minute: m);
      }
    }

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
                      color: selectedIcon == icon ? AppColors.primary : null,
                    ),
                    selected: selectedIcon == icon,
                    onSelected: (_) => setSheetState(() => selectedIcon = icon),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.habitReminders,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ctx.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: reminderTime,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: AppColors.primary,
                                onPrimary: Colors.white,
                                onSurface: context.textPrimary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (time != null) {
                        setSheetState(() => reminderTime = time);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: ctx.inputFill,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${reminderTime.hour.toString().padLeft(2, '0')}:${reminderTime.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.access_time,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Switch(
                    value: reminderEnabled,
                    onChanged: (value) => setSheetState(() => reminderEnabled = value),
                    activeColor: Colors.white,
                    activeTrackColor: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) return;
                    Navigator.pop(ctx);
                    final reminderTimeStr = '${reminderTime.hour}:${reminderTime.minute}';
                    final res = await ApiService.updateHabit(
                      token: token,
                      habitId: habitId,
                      name: nameController.text.trim(),
                      category: selectedCategory,
                      icon: selectedIcon,
                      reminderTime: reminderTimeStr,
                      reminderEnabled: reminderEnabled,
                    );
                    if (!mounted) return;
                    if (res["message"] == null ||
                        res["message"] == "Habit updated") {
                      if (reminderEnabled) {
                        final isCompleted = habit["is_completed"] == 1;
                        if (isCompleted) {
                          await NotificationService.cancelHabitReminders(habitId);
                        } else {
                          await NotificationService.scheduleHabitReminders(
                            habitId: habitId,
                            habitName: nameController.text.trim(),
                            reminderTime: reminderTimeStr,
                          );
                        }
                      } else {
                        await NotificationService.cancelHabitReminders(habitId);
                      }
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

      // Lên lịch thông báo nhắc nhở nếu người dùng đã bật
      if (reminderEnabled && reminderTime != null && reminderTime.isNotEmpty) {
        final habitId = newHabit['id'] as int?;
        final habitName = newHabit['name'] as String? ?? habitData['name'];
        if (habitId != null) {
          await NotificationService.scheduleHabitReminders(
            habitId: habitId,
            habitName: habitName,
            reminderTime: reminderTime,
          );
        }
      }
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
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: VioraAppBar(
            title: l10n.habits,
            actions: [
              IconButton(
                key: _treeIconKey,
                icon: const Icon(Icons.eco_rounded, size: 26),
                tooltip: l10n.myPlant,
                onPressed: () => AppNavigation.openPlant(),
              ),
              IconButton(
                icon: const Icon(Icons.notification_important_rounded, size: 24),
                tooltip: "Test thông báo",
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đang gửi thông báo test sau 10 giây...'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  await NotificationService.sendTestNotification();
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
                    'Đang thực hiện',
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
                    'Đã hoàn thành',
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '"Sức khỏe là lựa chọn, không phải sự tình cờ. Hãy kiên trì với những thói quen nhỏ mỗi ngày nhé!"',
              style: TextStyle(
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
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
      ),
      confirmDismiss: (_) async {
        return await showDialog(
          context: context,
          builder: (dialogCtx) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: context.cardColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.deleteHabit,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.confirmDeleteHabit(habit["name"]),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogCtx, false),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            l10n.cancel,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(dialogCtx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            l10n.delete,
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
            color: context.cardColor,
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
                                '$currentStreak ngày',
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
                  Text(
                    'Tiến độ',
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
