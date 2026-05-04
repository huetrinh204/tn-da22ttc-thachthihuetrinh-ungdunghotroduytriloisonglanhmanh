import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/viora_app_bar.dart';
import '../theme/theme_extensions.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLoading = true;
  String token = "";

  // Summary
  int totalCheckins = 0;
  int activeDays = 0;
  int longestStreak = 0;
  int totalHabits = 0;

  // Chart data
  List<dynamic> weeklyData = [];
  List<dynamic> monthlyData = [];
  List<dynamic> categoryData = [];

  static const Map<String, String> _categoryLabels = {
    "eat": "Ăn uống",
    "exercise": "Vận động",
    "sleep": "Giấc ngủ",
    "mental": "Tinh thần",
    "hydration": "Uống nước",
    "other": "Khác",
  };

  static const List<Color> _categoryColors = [
    Color(0xFF4CAF50), Color(0xFF2196F3), Color(0xFF9C27B0),
    Color(0xFFFF9800), Color(0xFF00BCD4), Color(0xFF607D8B),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token") ?? "";

    final results = await Future.wait([
      ApiService.getStatsSummary(token),
      ApiService.getWeeklyStats(token),
      ApiService.getMonthlyStats(token),
      ApiService.getCategoryStats(token),
    ]);

    if (!mounted) return;
    setState(() {
      final summary = results[0]["summary"] ?? {};
      totalCheckins = summary["total_checkins"] ?? 0;
      activeDays = summary["active_days"] ?? 0;
      longestStreak = summary["longest_streak"] ?? 0;
      totalHabits = summary["total_habits"] ?? 0;

      weeklyData = results[1]["data"] ?? [];
      monthlyData = results[2]["data"] ?? [];
      categoryData = results[3]["data"] ?? [];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: VioraAppBar(
        title: "Thống kê",
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4CAF50),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4CAF50),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "Tuần này"),
            Tab(text: "Tháng này"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFF4CAF50),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildWeeklyTab(),
                  _buildMonthlyTab(),
                ],
              ),
            ),
    );
  }

  Widget _buildWeeklyTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSummaryCards(),
        const SizedBox(height: 16),
        _buildBarChart(weeklyData, 7, "Tuần này"),
        const SizedBox(height: 16),
        _buildCategoryChart(),
      ],
    );
  }

  Widget _buildMonthlyTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSummaryCards(),
        const SizedBox(height: 16),
        _buildBarChart(monthlyData, 30, "30 ngày qua"),
        const SizedBox(height: 16),
        _buildCategoryChart(),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard("Tổng check-in", "$totalCheckins", "✅",
            const Color(0xFF4CAF50)),
        _buildSummaryCard("Ngày hoạt động", "$activeDays", "📅",
            const Color(0xFF2196F3)),
        _buildSummaryCard("Streak dài nhất", "$longestStreak ngày", "🔥",
            const Color(0xFFFF9800)),
        _buildSummaryCard("Thói quen", "$totalHabits", "🎯",
            const Color(0xFF9C27B0)),
      ],
    );
  }

  Widget _buildSummaryCard(
      String label, String value, String emoji, Color color) {
    final cardColor = Theme.of(context).cardTheme.color ?? Colors.white;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color)),
              Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<dynamic> data, int days, String title) {
    // Build map date → count
    final Map<String, int> countMap = {};
    for (final d in data) {
      final date = (d["log_date"] as String).substring(5); // MM-DD
      countMap[date] = (d["count"] as num).toInt();
    }

    // Generate last N days
    final now = DateTime.now();
    final dates = List.generate(days, (i) {
      final d = now.subtract(Duration(days: days - 1 - i));
      return "${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
    });

    final bars = dates.asMap().entries.map((e) {
      final count = countMap[e.value] ?? 0;
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: count > 0 ? const Color(0xFF4CAF50) : const Color(0xFFE0E0E0),
            width: days <= 7 ? 20 : 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    final maxY = (data.isEmpty
            ? 5
            : data
                .map((d) => (d["count"] as num).toInt())
                .reduce((a, b) => a > b ? a : b)) +
        2;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: context.textGreen)),
          const SizedBox(height: 4),
          const Text("Số habit hoàn thành mỗi ngày",
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxY.toDouble(),
                barGroups: bars,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.grey.shade100,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(
                            fontSize: 10, color: Colors.grey),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: days <= 7,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= dates.length) {
                          return const SizedBox();
                        }
                        final parts = dates[idx].split("-");
                        return Text(
                          "${parts[1]}/${parts[0]}",
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart() {
    if (categoryData.isEmpty) return const SizedBox();

    final total = categoryData.fold<int>(
        0, (sum, d) => sum + (d["completed"] as num).toInt());
    if (total == 0) return const SizedBox();

    final sections = categoryData.asMap().entries.map((e) {
      final d = e.value;
      final count = (d["completed"] as num).toInt();
      final pct = count / total * 100;
      final color = _categoryColors[e.key % _categoryColors.length];
      return PieChartSectionData(
        value: count.toDouble(),
        color: color,
        title: "${pct.toStringAsFixed(0)}%",
        radius: 60,
        titleStyle: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Theo danh mục",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1B5E20))),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                height: 160,
                width: 160,
                child: PieChart(PieChartData(
                  sections: sections,
                  centerSpaceRadius: 30,
                  sectionsSpace: 2,
                )),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categoryData.asMap().entries.map((e) {
                    final d = e.value;
                    final color =
                        _categoryColors[e.key % _categoryColors.length];
                    final label = _categoryLabels[d["category"]] ??
                        d["category"];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(label,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black87)),
                          ),
                          Text(
                            "${d["completed"]}",
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

