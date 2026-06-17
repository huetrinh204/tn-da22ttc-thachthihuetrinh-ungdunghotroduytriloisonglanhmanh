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
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                l10n.longestStreakDetail,
                "$longestStreak ${l10n.days}",
                const Color(0xFF2196F3),
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
              ),
            ),
            const SizedBox(width: 12),
            if (unit.isNotEmpty)
              Expanded(
                child: _buildSummaryCard(
                  l10n.average,
                  "${avgValue.toStringAsFixed(1)} $unit",
                  const Color(0xFF9C27B0),
                ),
              ),
          ],
        ),
        if (unit.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildSummaryCard(
            l10n.totalSum,
            "${totalValue.toStringAsFixed(1)} $unit",
            const Color(0xFF00BCD4),
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color) {
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
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
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
    
    // Build list of spots với TẤT CẢ các ngày (bao gồm cả ngày không có dữ liệu)
    final List<FlSpot> spots = [];
    final List<String> allDateLabels = [];
    
    for (int i = 0; i < metrics.length; i++) {
      final m = metrics[i];
      final metricValue = m["metric_value"];
      final logDate = m["log_date"] as String;
      
      // Thêm tất cả các ngày vào dateLabels
      allDateLabels.add(logDate);
      
      // Chỉ thêm spot nếu có metric_value
      if (metricValue != null) {
        double value = 0.0;
        if (metricValue is num) {
          value = metricValue.toDouble();
        } else if (metricValue is String) {
          value = double.tryParse(metricValue) ?? 0.0;
        }
        
        if (value > 0) {
          // Sử dụng index thực tế từ metrics array làm X
          spots.add(FlSpot(i.toDouble(), value));
        }
      }
    }

    // Nếu không có dữ liệu, không hiển thị biểu đồ
    if (spots.isEmpty) {
      return const SizedBox.shrink();
    }

    // Tính maxY dựa trên giá trị lớn nhất
    final maxValue = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final maxY = maxValue * 1.3; // Thêm 30% để có khoảng trống phía trên
    
    // Tính interval cho grid Y
    final interval = (maxY / 5).clamp(0.1, double.infinity);
    
    // Tính số lượng labels tối đa để hiển thị trên X axis
    final maxLabels = 7; // Hiển thị tối đa 7 labels
    final labelStep = (allDateLabels.length / maxLabels).ceil().clamp(1, allDateLabels.length);

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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: context.textGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unit.isNotEmpty 
                ? l10n.dailyRecordedValuesWithUnit(unit)
                : l10n.dailyRecordedValues,
            style: TextStyle(fontSize: 12, color: context.textSecondary),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                maxY: maxY,
                minY: 0,
                maxX: (allDateLabels.length - 1).toDouble(),
                minX: 0,
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
                    color: context.textSecondary.withValues(alpha: 0.15),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: interval,
                      getTitlesWidget: (v, _) {
                        // Chỉ hiển thị số nguyên
                        if (v == 0 || v == maxY) {
                          return Text(
                            v.toInt().toString(),
                            style: TextStyle(
                              fontSize: 11,
                              color: context.textSecondary,
                            ),
                          );
                        }
                        return Text(
                          v.toInt().toString(),
                          style: TextStyle(
                            fontSize: 11,
                            color: context.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= allDateLabels.length) {
                          return const SizedBox();
                        }
                        
                        // Chỉ hiển thị label tại các vị trí được chọn
                        // Luôn hiển thị ngày đầu tiên và ngày cuối cùng
                        final isFirst = idx == 0;
                        final isLast = idx == allDateLabels.length - 1;
                        final isStepPosition = idx % labelStep == 0;
                        
                        if (!isFirst && !isLast && !isStepPosition) {
                          return const SizedBox();
                        }
                        
                        // Format date label as D/M in local timezone
                        final dateStr = allDateLabels[idx];
                        final formattedDate = _formatChartDateLabel(dateStr);
                        if (formattedDate != null) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 11,
                                color: context.textSecondary,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
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
