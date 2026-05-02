import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/viora_app_bar.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<dynamic> unlocked = [];
  bool isLoading = true;

  // Danh sách tất cả achievements có thể unlock
  static const List<Map<String, dynamic>> _allAchievements = [
    {"key": "first_checkin",  "title": "Bước đầu tiên",    "icon": "🌱", "desc": "Hoàn thành check-in đầu tiên",      "color": 0xFF4CAF50},
    {"key": "streak_3",       "title": "3 ngày liên tiếp", "icon": "🔥", "desc": "Duy trì streak 3 ngày liên tiếp",   "color": 0xFFFF7043},
    {"key": "streak_7",       "title": "Tuần kiên trì",    "icon": "⚡", "desc": "Duy trì streak 7 ngày liên tiếp",   "color": 0xFFFFB300},
    {"key": "streak_30",      "title": "Tháng bền bỉ",     "icon": "🏆", "desc": "Duy trì streak 30 ngày liên tiếp",  "color": 0xFFFFD700},
    {"key": "habits_5",       "title": "Đa nhiệm",         "icon": "🎯", "desc": "Tạo 5 thói quen",                   "color": 0xFF7C4DFF},
    {"key": "checkin_50",     "title": "Nửa trăm",         "icon": "💪", "desc": "Hoàn thành 50 check-ins",           "color": 0xFF00BCD4},
    {"key": "checkin_100",    "title": "Bách chiến",       "icon": "🌟", "desc": "Hoàn thành 100 check-ins",          "color": 0xFFFF6F00},
    {"key": "plant_level_3",  "title": "Cây non",          "icon": "🪴", "desc": "Cây ảo đạt cấp độ 3",              "color": 0xFF43A047},
    {"key": "plant_level_5",  "title": "Vườn địa đàng",   "icon": "🌳", "desc": "Cây ảo đạt cấp độ tối đa",         "color": 0xFF1B5E20},
  ];

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
    final unlockedCount = _allAchievements
        .where((a) => _isUnlocked(a["key"] as String))
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const VioraAppBar(title: "Thành tích"),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
          : RefreshIndicator(
              onRefresh: _load,
              color: const Color(0xFF4CAF50),
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
                    "$unlockedCount / $total thành tích",
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    unlockedCount == total
                        ? "Bạn đã mở khóa tất cả! 🎉"
                        : "Còn ${total - unlockedCount} thành tích chưa mở",
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
          color: isUnlocked ? Colors.white : const Color(0xFFF0F0F0),
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
                    color: isUnlocked ? null : Colors.grey),
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
                color: isUnlocked ? const Color(0xFF1B5E20) : Colors.grey,
              ),
            ),
            if (!isUnlocked)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.lock_outline,
                    size: 14, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  void _showDetail(Map<String, dynamic> ach, String? date) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
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
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20)),
              ),
              const SizedBox(height: 8),
              Text(
                ach["desc"] as String,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              if (date != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Mở khóa ngày $date",
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Đóng"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocked(Map<String, dynamic> ach) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
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
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                ach["desc"] as String,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFDDDDDD)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Đóng",
                      style: TextStyle(color: Colors.grey)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
