import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/viora_app_bar.dart';
import '../theme/theme_extensions.dart';
import '../theme/app_theme.dart';
import 'habit_detail_screen.dart';
import '../l10n/app_localizations.dart';

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
  List<dynamic> habitsOverview = [];

  Map<String, String> get _categoryLabels => {
    "eat": AppLocalizations.of(context)!.categoryEat,
    "exercise": AppLocalizations.of(context)!.categoryExercise,
    "sleep": AppLocalizations.of(context)!.categorySleep,
    "mental": AppLocalizations.of(context)!.categoryMental,
    "hydration": AppLocalizations.of(context)!.categoryHydration,
    "other": AppLocalizations.of(context)!.categoryOther,
  };

  static const List<Color> _categoryColors = [
    Color(0xFF4CAF50), Color(0xFF2196F3), Color(0xFF9C27B0),
    Color(0xFFFF9800), Color(0xFF00BCD4), Color(0xFF607D8B),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      ApiService.getHabitsOverview(token),
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
      habitsOverview = results[4]["habits"] ?? [];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: VioraAppBar(
        title: l10n.statsTitle,
        showBack: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4CAF50),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4CAF50),
          indicatorWeight: 3,
          tabs: [
            Tab(text: l10n.thisWeek),
            Tab(text: l10n.thisMonth),
            Tab(text: l10n.details),
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
                  _buildDetailTab(),
                ],
              ),
            ),
    );
  }

  Widget _buildWeeklyTab() {
    final l10n = AppLocalizations.of(context)!;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSummaryCards(),
        const SizedBox(height: 16),
        _buildSimpleBarChart(weeklyData, 7, l10n.habitsCompletedDaily),
        const SizedBox(height: 16),
        _buildCategoryChart(),
      ],
    );
  }

  Widget _buildMonthlyTab() {
    final l10n = AppLocalizations.of(context)!;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSummaryCards(),
        const SizedBox(height: 16),
        _buildSimpleBarChart(monthlyData, 30, l10n.habitsCompleted30Days),
        const SizedBox(height: 16),
        _buildCategoryChart(),
      ],
    );
  }

  Widget _buildDetailTab() {
    final l10n = AppLocalizations.of(context)!;
    
    if (habitsOverview.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("📊", style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              l10n.noHabitsYetStats,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.createHabitsToSeeStats,
              style: TextStyle(
                fontSize: 14,
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: habitsOverview.length,
      itemBuilder: (context, index) {
        final habit = habitsOverview[index];
        return _buildHabitOverviewCard(habit);
      },
    );
  }

  Widget _buildHabitOverviewCard(Map habit) {
    final l10n = AppLocalizations.of(context)!;
    final totalLogs = habit["total_logs"] ?? 0;
    final currentStreak = habit["current_streak"] ?? 0;
    final totalMetric = habit["total_metric"];
    final avgMetric = habit["avg_metric"];
    final unit = habit["metric_unit"];

    // Parse to double safely
    double? totalMetricValue;
    if (totalMetric != null) {
      if (totalMetric is num) {
        totalMetricValue = totalMetric.toDouble();
      } else if (totalMetric is String) {
        totalMetricValue = double.tryParse(totalMetric);
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HabitDetailScreen(
              habitId: habit["id"],
              habitName: habit["name"],
              habitIcon: habit["icon"] ?? "⭐",
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  habit["icon"] ?? "⭐",
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit["name"],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$totalLogs ${l10n.timesCheckin}",
                        style: TextStyle(
                          fontSize: 13,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: context.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (currentStreak > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                          "$currentStreak ${l10n.days}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFFF9800),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (unit != null && totalMetricValue != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${l10n.totalLabel}: ${totalMetricValue.toStringAsFixed(1)} $unit",
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final l10n = AppLocalizations.of(context)!;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard(l10n.totalCheckins, "$totalCheckins", "✅",
            const Color(0xFF4CAF50)),
        _buildSummaryCard(l10n.activeDaysLabel, "$activeDays", "📅",
            const Color(0xFF2196F3)),
        _buildSummaryCard(l10n.longestStreakLabel, "$longestStreak ${l10n.days}", "🔥",
            const Color(0xFFFF9800)),
        _buildSummaryCard(l10n.habitsCount, "$totalHabits", "🎯",
            const Color(0xFF9C27B0)),
      ],
    );
  }

  Widget _buildSummaryCard(
      String label, String value, String emoji, Color color) {
    final cardColor = context.cardColor;
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
                  style: TextStyle(fontSize: 12, color: context.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleBarChart(List<dynamic> data, int days, String title) {
    final l10n = AppLocalizations.of(context)!;
    
    // Nếu không có dữ liệu
    if (data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Text("📊", style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              l10n.noDataYet,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.completeHabitsToSeeStats,
              style: TextStyle(fontSize: 14, color: context.textSecondary),
            ),
          ],
        ),
      );
    }

    // Tạo spots cho biểu đồ đường
    final spots = <FlSpot>[];
    double maxValue = 0;
    
    for (int i = 0; i < data.length; i++) {
      final count = (data[i]["count"] as num).toDouble();
      spots.add(FlSpot(i.toDouble(), count));
      if (count > maxValue) maxValue = count;
    }

    // Đảm bảo maxY > 0 và làm tròn lên số chẵn
    final maxY = maxValue > 0 ? ((maxValue + 2) / 2).ceil() * 2.0 : 6.0;
    // Interval phải là số nguyên >= 1
    final interval = maxY <= 6 ? 2.0 : (maxY / 3).ceilToDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: context.textGreen)),
          const SizedBox(height: 4),
          Text(l10n.quantityLabel,
              style: TextStyle(fontSize: 12, color: context.textSecondary)),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: AppColors.primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: context.textSecondary.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: interval,
                      getTitlesWidget: (value, meta) {
                        // Chỉ hiển thị số nguyên
                        if (value % 1 != 0) return const SizedBox();
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= data.length) {
                          return const SizedBox();
                        }
                        
                        // Chỉ hiển thị một số ngày để không bị chật
                        if (days > 7 && index % 2 != 0) {
                          return const SizedBox();
                        }
                        if (days > 14 && index % 5 != 0) {
                          return const SizedBox();
                        }
                        
                        // Parse date từ format YYYY-MM-DD
                        final dateStr = data[index]["log_date"] as String;
                        try {
                          final parts = dateStr.split('-');
                          if (parts.length == 3) {
                            final day = int.parse(parts[2]);
                            final month = int.parse(parts[1]);
                            // Format: 14/5 (bỏ số 0 đầu)
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                "$day/$month",
                                style: TextStyle(
                                  color: context.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        } catch (e) {
                          return const SizedBox();
                        }
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionRateChart(List<dynamic> data, int days, String title) {
    final l10n = AppLocalizations.of(context)!;
    
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

    // Tính % hoàn thành cho mỗi ngày
    final bars = dates.asMap().entries.map((e) {
      final count = countMap[e.value] ?? 0;
      final percentage = totalHabits > 0 ? (count / totalHabits * 100) : 0.0;
      
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: percentage,
            color: percentage >= 80
                ? const Color(0xFF4CAF50)
                : percentage >= 50
                    ? const Color(0xFFFF9800)
                    : const Color(0xFFE57373),
            width: 24,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: context.textGreen)),
          const SizedBox(height: 4),
          Text(l10n.completionPercentageDaily,
              style: TextStyle(fontSize: 12, color: context.textSecondary)),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: 100,
                minY: 0,
                barGroups: bars,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: context.textSecondary.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      interval: 25,
                      getTitlesWidget: (v, _) => Text(
                        "${v.toInt()}%",
                        style: TextStyle(fontSize: 10, color: context.textSecondary),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= dates.length) {
                          return const SizedBox();
                        }
                        final parts = dates[idx].split("-");
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "${parts[1]}/${parts[0]}",
                            style: TextStyle(fontSize: 10, color: context.textSecondary),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(l10n.goodPercent, const Color(0xFF4CAF50)),
              const SizedBox(width: 16),
              _buildLegendItem(l10n.fairPercent, const Color(0xFFFF9800)),
              const SizedBox(width: 16),
              _buildLegendItem(l10n.needsImprovementPercent, const Color(0xFFE57373)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 11, color: context.textSecondary)),
      ],
    );
  }

  Widget _buildStreakCard() {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF8C42), Color(0xFFFFA94D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text("🔥", style: TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.currentStreak,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$longestStreak ${l10n.consecutiveDaysLabel}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  longestStreak >= 7
                      ? l10n.greatKeepGoing
                      : l10n.maintainDaily,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapCalendar(List<dynamic> data) {
    final l10n = AppLocalizations.of(context)!;
    
    // Build map date → count
    final Map<String, int> countMap = {};
    for (final d in data) {
      final date = d["log_date"] as String; // YYYY-MM-DD
      countMap[date] = (d["count"] as num).toInt();
    }

    // Generate last 30 days
    final now = DateTime.now();
    final days = List.generate(30, (i) {
      return now.subtract(Duration(days: 29 - i));
    });

    // Tính max count để scale màu
    final maxCount = countMap.values.isEmpty ? 1 : countMap.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.activityCalendar30Days,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: context.textGreen)),
          const SizedBox(height: 4),
          Text(l10n.darkerMoreHabits,
              style: TextStyle(fontSize: 12, color: context.textSecondary)),
          const SizedBox(height: 20),
          // Heatmap grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: 30,
            itemBuilder: (context, index) {
              final day = days[index];
              final dateStr = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
              final count = countMap[dateStr] ?? 0;
              final intensity = maxCount > 0 ? count / maxCount : 0.0;

              Color cellColor;
              if (count == 0) {
                cellColor = context.inputFill;
              } else if (intensity <= 0.25) {
                cellColor = const Color(0xFFC8E6C9);
              } else if (intensity <= 0.5) {
                cellColor = const Color(0xFF81C784);
              } else if (intensity <= 0.75) {
                cellColor = const Color(0xFF4CAF50);
              } else {
                cellColor = const Color(0xFF2E7D32);
              }

              return Container(
                decoration: BoxDecoration(
                  color: cellColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    "${day.day}",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: count > 0 ? Colors.white : context.textSecondary,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.less, style: TextStyle(fontSize: 11, color: context.textSecondary)),
              const SizedBox(width: 8),
              Container(width: 16, height: 16, decoration: BoxDecoration(color: context.inputFill, borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 4),
              Container(width: 16, height: 16, decoration: BoxDecoration(color: const Color(0xFFC8E6C9), borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 4),
              Container(width: 16, height: 16, decoration: BoxDecoration(color: const Color(0xFF81C784), borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 4),
              Container(width: 16, height: 16, decoration: BoxDecoration(color: const Color(0xFF4CAF50), borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 4),
              Container(width: 16, height: 16, decoration: BoxDecoration(color: const Color(0xFF2E7D32), borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 8),
              Text(l10n.more, style: TextStyle(fontSize: 11, color: context.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart() {
    final l10n = AppLocalizations.of(context)!;
    
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
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.byCategory,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: context.textGreen)),
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
                                style: TextStyle(
                                    fontSize: 12, color: context.textPrimary)),
                          ),
                          Text(
                            "${d["completed"]}",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: context.textGreen),
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

