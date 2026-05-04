import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/achievement_popup.dart';
import '../widgets/viora_app_bar.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  List<dynamic> habits = [];
  bool isLoading = true;
  String token = "";

  final List<Map<String, dynamic>> categories = [
    {"id": "eat", "label": "Ăn uống", "icon": "🥗"},
    {"id": "exercise", "label": "Vận động", "icon": "🏃"},
    {"id": "sleep", "label": "Giấc ngủ", "icon": "😴"},
    {"id": "mental", "label": "Tinh thần", "icon": "🧘"},
    {"id": "hydration", "label": "Uống nước", "icon": "💧"},
    {"id": "other", "label": "Khác", "icon": "⭐"},
  ];

  @override
  void initState() {
    super.initState();
    loadHabits();
  }

  void loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token") ?? "";

    final res = await ApiService.getTodayHabits(token);
    if (mounted) {
      setState(() {
        habits = res["habits"] ?? [];
        isLoading = false;
      });
    }
  }

  void handleCheckIn(int habitId, bool isCompleted) async {
    // Nếu đã hoàn thành rồi thì không làm gì
    if (isCompleted) return;

    // Hiện dialog xác nhận
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text("✅ ", style: TextStyle(fontSize: 22)),
            Text(
              "Xác nhận hoàn thành",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ctx.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          "Bạn có chắc chắn đã hoàn thành thói quen này hôm nay không?\n\nSau khi xác nhận, bạn sẽ không thể bỏ tick trong ngày.",
          style: TextStyle(
            fontSize: 14,
            color: ctx.textPrimary,
            height: 1.5,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ctx.textSecondary,
                    side: BorderSide(color: ctx.textSecondary.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Chưa chắc"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Đã hoàn thành!"),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Optimistic update
    setState(() {
      final idx = habits.indexWhere((h) => h["id"] == habitId);
      if (idx != -1) habits[idx]["is_completed"] = 1;
    });

    final res = await ApiService.checkInHabit(token, habitId);

    // Hiện popup nếu có achievement mới unlock
    if (!mounted) return;
    final newAchievements = res["new_achievements"] as List?;
    if (newAchievements != null && newAchievements.isNotEmpty) {
      AchievementPopup.show(context, newAchievements);
    }
  }

  void handleDelete(int habitId) async {
    await ApiService.deleteHabit(token, habitId);
    setState(() => habits.removeWhere((h) => h["id"] == habitId));
  }

  void showAddHabitSheet() {
    final nameController = TextEditingController();
    String selectedCategory = "other";
    String selectedIcon = "⭐";

    final icons = ["⭐", "🏃", "🥗", "💧", "😴", "🧘", "📚", "🎯", "💪", "🌿"];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Thêm thói quen mới",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              // ICON PICKER
              const Text("Chọn icon",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
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
                          : const Color(0xFFF7F7F7),
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
              const Text("Tên thói quen",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "VD: Uống 2L nước mỗi ngày",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xFFF7F7F7),
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
              const Text("Danh mục",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
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
                          : const Color(0xFFF7F7F7),
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
                            : Colors.black87,
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
                    Navigator.pop(ctx);
                    final res = await ApiService.createHabit(
                      token: token,
                      name: nameController.text.trim(),
                      category: selectedCategory,
                      icon: selectedIcon,
                    );
                    if (res["habit"] != null) {
                      setState(() {
                        habits.insert(0, {
                          ...res["habit"],
                          "is_completed": 0,
                        });
                      });
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
                  child: const Text("Thêm thói quen",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
    final completed = habits.where((h) => h["is_completed"] == 1).length;
    final total = habits.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: VioraAppBar(
        title: "Thói quen hôm nay",
        actions: [
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

  Widget _buildProgressCard(int completed, int total, double progress) {
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
                ? "Tuyệt vời! Hoàn thành hết rồi 🎉"
                : "Hôm nay của bạn",
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
              const Text(
                "thói quen",
                style: TextStyle(color: Colors.white70, fontSize: 14),
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
    final isCompleted = habit["is_completed"] == 1;
    final categoryIcon = categories.firstWhere(
      (c) => c["id"] == habit["category"],
      orElse: () => {"icon": "⭐"},
    )["icon"];

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
            title: const Text("Xóa thói quen?"),
            content: Text("Bạn có chắc muốn xóa \"${habit["name"]}\" không?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Xóa", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => handleDelete(habit["id"]),
      child: GestureDetector(
        onTap: isCompleted ? null : () => handleCheckIn(habit["id"], isCompleted),
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
              color: isCompleted ? const Color(0xFF4CAF50) : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
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
                      "$categoryIcon ${categories.firstWhere((c) => c["id"] == habit["category"], orElse: () => {"label": "Khác"})["label"]}",
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
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("🌱", style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            "Chưa có thói quen nào",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Thêm thói quen đầu tiên để bắt đầu\nhành trình sống lành mạnh",
            textAlign: TextAlign.center,
            style: TextStyle(color: context.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: showAddHabitSheet,
            icon: const Icon(Icons.add),
            label: const Text("Thêm thói quen"),
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
