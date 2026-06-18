import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../theme/theme_extensions.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../widgets/habit_icon.dart';
import '../constants/app_icons.dart';

class HabitDetailScreen extends StatefulWidget {
  final int habitId;
  final String habitName;
  final String habitIcon;

  const HabitDetailScreen({
    super.key,
    required this.habitId,
    required this.habitName,
    required this.habitIcon,
  });

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  bool isLoading = true;
  String token = "";
  int selectedDays = 30;

  Map<String, dynamic> habitInfo = {};
  List<dynamic> metrics = [];
  Map<String, dynamic> summary = {};

  String? _formatChartDateLabel(String rawDate) {
    try {
      final dateTime = DateTime.parse(rawDate);
      final localDate = rawDate.contains('T') ? dateTime.toLocal() : dateTime;
      return "${localDate.day}/${localDate.month}";
    } catch (_) {
      try {
        final parts = rawDate.split("-");
        if (parts.length == 3) {
          final day = int.parse(parts[2]);
          final month = int.parse(parts[1]);
          return "$day/$month";
        }
      } catch (_) {
        return null;
      }
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token") ?? "";

    final res = await ApiService.getHabitMetrics(token, widget.habitId, days: selectedDays);
    
    if (!mounted) return;
    setState(() {
      habitInfo = res["habit"] ?? {};
      metrics = res["metrics"] ?? [];
      summary = res["summary"] ?? {};
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(AppIcons.arrowLeft, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            HabitIcon(
              iconString: widget.habitIcon,
              size: 24,
              color: context.textPrimary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.habitName,
                style: TextStyle(
                  color: context.textGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Time range selector
                  _buildTimeRangeSelector(),
                  const SizedBox(height: 16),

                  // Summary cards
                  _buildSummaryCards(),
                  const SizedBox(height: 16),

                  // Metrics chart - chỉ hiển thị khi có dữ liệu metric
                  if (metrics.isNotEmpty && 
                      metrics.any((m) => m["metric_value"] != null))
                    _buildMetricsChart(),
                  
                  if (metrics.isEmpty)
                    _buildEmptyState(),
                ],
              ),
            ),
    );
  }

  Widget _buildTimeRangeSelector() {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.inputFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildRangeButton(l10n.sevenDays, 7),
          _buildRangeButton(l10n.thirtyDays, 30),
          _buildRangeButton(l10n.ninetyDays, 90),
        ],
      ),
    );
  }

  Widget _buildRangeButton(String label, int days) {
    final isSelected = selectedDays == days;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedDays = days;
            isLoading = true;
          });
          _loadData();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : context.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final l10n = AppLocalizations.of(context)!;
    final currentStreak = habitInfo["current_streak"] ?? 0;
    final longestStreak = habitInfo["longest_streak"] ?? 0;
    final totalLogs = habitInfo["total_logs"] ?? 0;
    
    // Parse safely
    double totalValue = 0.0;
    double avgValue = 0.0;
    
    final totalValueRaw = summary["total_value"];
    if (totalValueRaw != null) {
      if (totalValueRaw is num) {
        totalValue = totalValueRaw.toDouble();
      } else if (totalValueRaw is String) {
        totalValue = double.tryParse(totalValueRaw) ?? 0.0;
      }
    }
    
    final avgValueRaw = summary["average_value"];
    if (avgValueRaw != null) {
      if (avgValueRaw is num) {
        avgValue = avgValueRaw.toDouble();
      } else if (avgValueRaw is String) {
        avgValue = double.tryParse(avgValueRaw) ?? 0.0;
      }
    }
    
    final unit = summary["unit"] ?? "";

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                l10n.currentStreakLabel,
                "$currentStreak ${l10n.days}",
                const Color(0xFFFF9800),
                Icons.local_fire_department_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                l10n.longestStreakDetail,
                "$longestStreak ${l10n.days}",
                const Color(0xFF2196F3),
                Icons.emoji_events_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                l10n.totalCheckinsLabel,
                "$totalLogs ${l10n.times}",
                AppColors.primary,
                Icons.check_circle_rounded,
              ),
            ),
            const SizedBox(width: 12),
            if (unit.isNotEmpty)
              Expanded(
                child: _buildSummaryCard(
                  l10n.average,
                  "${avgValue.toStringAsFixed(1)} $unit",
                  const Color(0xFF9C27B0),
                  Icons.bar_chart_rounded,
                ),
              ),
          ],
        ),

      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsChart() {
    final l10n = AppLocalizations.of(context)!;
    final unit = summary["unit"] ?? habitInfo["unit"] ?? "";
    final targetCount = habitInfo["target_count"];
    double? target;
    if (targetCount != null) {
      if (targetCount is num) {
        target = targetCount.toDouble();
      } else if (targetCount is String) {
        target = double.tryParse(targetCount);
      }
    }

    final List<BarChartGroupData> barGroups = [];
    final List<String> dateLabels = [];

    for (int i = 0; i < metrics.length; i++) {
      final m = metrics[i];
      final metricValue = m["metric_value"];
      final logDate = m["log_date"] as String;
      dateLabels.add(logDate);

      double value = 0.0;
      if (metricValue != null) {
        if (metricValue is num) {
          value = metricValue.toDouble();
        } else if (metricValue is String) {
          value = double.tryParse(metricValue) ?? 0.0;
        }
      }

      // Màu: xanh đầy đủ nếu đạt mục tiêu, cam nếu chưa đạt, xanh nhạt nếu = 0
      Color barColor;
      if (value <= 0) {
        barColor = AppColors.primary.withValues(alpha: 0.12);
      } else if (target != null && value < target) {
        barColor = const Color(0xFFFF9800); // cam - chưa đạt mục tiêu
      } else {
        barColor = AppColors.primary; // xanh - đạt mục tiêu
      }

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              color: barColor,
              width: metrics.length > 20 ? 6 : 12,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    if (barGroups.isEmpty || barGroups.every((g) => g.barRods.first.toY == 0)) {
      return const SizedBox.shrink();
    }

    final maxValue = barGroups.map((g) => g.barRods.first.toY).reduce((a, b) => a > b ? a : b);
    final maxY = (target != null
        ? (target > maxValue ? target * 1.25 : maxValue * 1.25)
        : maxValue * 1.25)
        .ceilToDouble()
        .clamp(1.0, double.infinity);
    final interval = (maxY / 4).clamp(1.0, double.infinity);
    final labelStep = (dateLabels.length / 7).ceil().clamp(1, dateLabels.length);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.trendOverTime,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: context.textGreen),
          ),
          const SizedBox(height: 4),
          Text(
            unit.isNotEmpty ? l10n.dailyRecordedValuesWithUnit(unit) : l10n.dailyRecordedValues,
            style: TextStyle(fontSize: 12, color: context.textSecondary),
          ),
          // Legend
          if (target != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Container(width: 12, height: 12,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 6),
                Text('Đạt mục tiêu', style: TextStyle(fontSize: 11, color: context.textSecondary)),
                const SizedBox(width: 16),
                Container(width: 12, height: 12,
                    decoration: BoxDecoration(color: const Color(0xFFFF9800), borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 6),
                Text('Chưa đạt', style: TextStyle(fontSize: 11, color: context.textSecondary)),
                const SizedBox(width: 16),
                Container(width: 20, height: 2, color: Colors.red.withValues(alpha: 0.6)),
                const SizedBox(width: 6),
                Text('Mục tiêu: ${target.toInt()}${unit.isNotEmpty ? ' $unit' : ''}',
                    style: TextStyle(fontSize: 11, color: context.textSecondary)),
              ],
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                barGroups: barGroups,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: context.textSecondary.withValues(alpha: 0.12),
                    strokeWidth: 1,
                  ),
                  // Đường target màu đỏ nhạt
                  checkToShowHorizontalLine: (value) {
                    if (target == null) return value % interval == 0;
                    return value % interval == 0 || (value - target).abs() < 0.01;
                  },
                  getDrawingVerticalLine: (_) => const FlLine(strokeWidth: 0),
                ),
                extraLinesData: target != null
                    ? ExtraLinesData(horizontalLines: [
                        HorizontalLine(
                          y: target,
                          color: Colors.red.withValues(alpha: 0.6),
                          strokeWidth: 1.5,
                          dashArray: [6, 4],
                          label: HorizontalLineLabel(
                            show: false,
                          ),
                        ),
                      ])
                    : null,
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final date = _formatChartDateLabel(dateLabels[group.x]) ?? '';
                      final val = rod.toY;
                      final hitTarget = target == null || val >= target;
                      return BarTooltipItem(
                        '$date\n${val % 1 == 0 ? val.toInt() : val.toStringAsFixed(1)}${unit.isNotEmpty ? ' $unit' : ''}'
                        '${target != null ? '\n${hitTarget ? '✅ Đạt' : '❌ Chưa đạt'}' : ''}',
                        TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: interval,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: TextStyle(fontSize: 11, color: context.textSecondary),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= dateLabels.length) return const SizedBox();
                        final isFirst = idx == 0;
                        final isLast = idx == dateLabels.length - 1;
                        if (!isFirst && !isLast && idx % labelStep != 0) return const SizedBox();
                        final formatted = _formatChartDateLabel(dateLabels[idx]);
                        if (formatted == null) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(formatted,
                              style: TextStyle(fontSize: 10, color: context.textSecondary)),
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
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    
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
            l10n.noDataForPeriod,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.startTrackingHabit,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
