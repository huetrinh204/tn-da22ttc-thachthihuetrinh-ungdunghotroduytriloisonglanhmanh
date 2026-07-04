import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../theme/theme_extensions.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../l10n/app_localizations.dart';
import '../constants/app_icons.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/habit_icon.dart';

class AdminDashboardTab extends StatefulWidget {
  final Function(int)? onNavigateToTab;
  
  const AdminDashboardTab({super.key, this.onNavigateToTab});

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  bool _isLoading = true;
  String _token = '';
  
  int _totalUsers = 0;
  int _totalPosts = 0;
  int _totalComments = 0;
  int _todayUsers = 0;
  int _todayPosts = 0;
  int _totalHabits = 0;
  int _activeUsers = 0;
  
  List<Map<String, dynamic>> _userGrowthData = [];
  List<Map<String, dynamic>> _postGrowthData = [];
  
  String _growthFilter = 'monthly';

  List<Map<String, dynamic>> _habitCategories = [];
  List<Map<String, dynamic>> _topHabits = [];
  String _habitTrendPeriod = 'weekly';

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';
    
    try {
      final stats = await ApiService.getAdminStats(_token);
      final catRes = await ApiService.getAdminHabitCategories(_token);
      await _loadGrowthData();
      await _loadHabitTrends();
      
      if (!mounted) return;
      setState(() {
        _totalUsers = stats['totalUsers'] ?? 0;
        _totalPosts = stats['totalPosts'] ?? 0;
        _totalComments = stats['totalComments'] ?? 0;
        _todayUsers = stats['todayUsers'] ?? 0;
        _todayPosts = stats['todayPosts'] ?? 0;
        _totalHabits = stats['totalHabits'] ?? 0;
        _activeUsers = stats['activeUsers'] ?? 0;
        _habitCategories = List<Map<String, dynamic>>.from(catRes['categories'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadHabitTrends() async {
    try {
      final trends = await ApiService.getAdminHabitTrends(_token, period: _habitTrendPeriod);
      if (!mounted) return;
      setState(() {
        _topHabits = List<Map<String, dynamic>>.from(trends['topHabits'] ?? []);
      });
    } catch (_) {}
  }

  Future<void> _loadGrowthData() async {
    try {
      final growthRes = await ApiService.getAdminGrowthData(_token, period: _growthFilter);
      if (!mounted) return;
      setState(() {
        _userGrowthData = List<Map<String, dynamic>>.from(growthRes['userGrowth'] ?? []);
        _postGrowthData = List<Map<String, dynamic>>.from(growthRes['postGrowth'] ?? []);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _userGrowthData = [];
        _postGrowthData = [];
      });
    }
  }

  void _navigateToTab(int tabIndex) {
    widget.onNavigateToTab?.call(tabIndex);
  }

  double _calculateYInterval(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 1;
    
    double maxVal = 0;
    for (var item in data) {
      final count = (item['count'] as num).toDouble();
      if (count > maxVal) maxVal = count;
    }
    
    if (maxVal <= 5) return 1;
    if (maxVal <= 10) return 2;
    if (maxVal <= 20) return 5;
    if (maxVal <= 50) return 10;
    if (maxVal <= 100) return 20;
    return (maxVal / 5).ceil().toDouble();
  }

  double _calculateMaxY(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 10;
    
    double maxVal = 0;
    for (var item in data) {
      final count = (item['count'] as num).toDouble();
      if (count > maxVal) maxVal = count;
    }
    
    return (maxVal * 1.2).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(l10n),
            const SizedBox(height: 28),
            _buildStatRow(l10n),
            const SizedBox(height: 28),
            _buildGrowthSection(l10n),
            const SizedBox(height: 28),
            _buildDistributionSection(l10n),
            const SizedBox(height: 28),
            _buildHabitTrendsSection(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF00897B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(AppIcons.dashboard, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.overview,
              style: AppTypography.headingLarge.copyWith(
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              Localizations.localeOf(context).languageCode == 'vi' ? 'Tổng quan hệ thống' : 'System Overview',
              style: AppTypography.caption,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatRow(AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 14) / 2;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                icon: AppIcons.users,
                label: l10n.users,
                value: _totalUsers,
                change: _todayUsers,
                color: const Color(0xFF2196F3),
                bgColor: const Color(0xFFE3F2FD),
                onTap: () => _navigateToTab(1),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                icon: LucideIcons.fileText,
                label: l10n.postsLabel,
                value: _totalPosts,
                change: _todayPosts,
                color: const Color(0xFF4CAF50),
                bgColor: const Color(0xFFE8F5E9),
                onTap: () => _navigateToTab(2),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                icon: AppIcons.message,
                label: l10n.commentsLabel,
                value: _totalComments,
                color: const Color(0xFFFF9800),
                bgColor: const Color(0xFFFFF3E0),
                onTap: () => _navigateToTab(2),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                icon: AppIcons.checkCircle,
                label: l10n.habits,
                value: _totalHabits,
                color: const Color(0xFF9C27B0),
                bgColor: const Color(0xFFF3E5F5),
                onTap: () => _navigateToTab(3),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int value,
    int? change,
    required Color color,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    final isDark = context.isDark;
    return Material(
      color: isDark ? AppColors.darkSurface : Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.md),
      elevation: isDark ? 0 : 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: isDark
                ? Border.all(color: Colors.white.withValues(alpha: 0.06))
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (_) {},
                    padding: EdgeInsets.zero,
                    iconSize: 16,
                    icon: Icon(
                      Icons.more_horiz_rounded,
                      color: context.textSecondary.withValues(alpha: 0.5),
                    ),
                    itemBuilder: (_) => [],
                  ),
                ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              formatCompact(value),
                style: AppTypography.headingLarge.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  height: 1,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (change != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_upward_rounded,
                            size: 10,
                            color: color,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '+$change',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatCompact(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.headingMedium.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    subtitle,
                    style: AppTypography.caption,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGrowthSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: LucideIcons.trendingUp,
          title: l10n.growthCharts,
          subtitle: Localizations.localeOf(context).languageCode == 'vi' ? 'Theo dõi sự tăng trưởng theo thời gian' : 'Track growth over time',
        ),
        const SizedBox(height: 18),
        _buildPeriodToggle(l10n),
        const SizedBox(height: 16),
        _buildChartCard(
          title: Localizations.localeOf(context).languageCode == 'vi' ? 'Tăng trưởng người dùng' : 'User Growth',
          icon: AppIcons.users,
          iconColor: Colors.blue,
          data: _userGrowthData,
          lineColor: Colors.blue,
          emptyText: l10n.noGrowthData,
          l10n: l10n,
        ),
        const SizedBox(height: 14),
        _buildChartCard(
          title: Localizations.localeOf(context).languageCode == 'vi' ? 'Tăng trưởng bài viết' : 'Post Growth',
          icon: LucideIcons.fileText,
          iconColor: Colors.green,
          data: _postGrowthData,
          lineColor: Colors.green,
          emptyText: l10n.noGrowthData,
          l10n: l10n,
        ),
      ],
    );
  }

  Widget _buildPeriodToggle(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.inputFill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(
            label: l10n.weekly,
            isSelected: _growthFilter == 'weekly',
            onTap: () {
              setState(() => _growthFilter = 'weekly');
              _loadGrowthData();
            },
          ),
          const SizedBox(width: 3),
          _buildToggleOption(
            label: l10n.monthly,
            isSelected: _growthFilter == 'monthly',
            onTap: () {
              setState(() => _growthFilter = 'monthly');
              _loadGrowthData();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? context.cardColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
            style: AppTypography.caption.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppColors.primary : context.textSecondary,
            ),
        ),
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Map<String, dynamic>> data,
    required Color lineColor,
    required String emptyText,
    required AppLocalizations l10n,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.grey.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppTypography.title,
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
          SizedBox(
            height: 220,
            child: data.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.barChart3,
                          size: 40,
                          color: context.textSecondary.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          emptyText,
                          style: TextStyle(color: context.textSecondary),
                        ),
                      ],
                    ),
                  )
                : LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: _calculateMaxY(data),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _calculateYInterval(data),
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: context.isDark 
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.grey.withValues(alpha: 0.15),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            interval: _calculateYInterval(data),
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Text(
                                  value.toInt().toString(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: context.textSecondary.withValues(alpha: 0.7),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            interval: data.length > 10 ? 5 : 1,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < data.length) {
                                if (data.length > 10) {
                                  if (index % 5 == 0 || index == data.length - 1) {
                                    final d = data[index]['date'] as String;
                                    final parts = d.split('-');
                                    return Text(
                                      '${parts[2]}/${parts[1]}',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: context.textSecondary.withValues(alpha: 0.6),
                                      ),
                                    );
                                  }
                                } else {
                                  final d = data[index]['date'] as String;
                                  final parts = d.split('-');
                                  return Text(
                                    '${parts[2]}/${parts[1]}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: context.textSecondary.withValues(alpha: 0.6),
                                    ),
                                  );
                                }
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: data.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              (entry.value['count'] as num).toDouble(),
                            );
                          }).toList(),
                          isCurved: true,
                          preventCurveOverShooting: true,
                          color: lineColor,
                          barWidth: 2.5,
                          dotData: FlDotData(
                            show: data.length <= 15,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 3,
                                color: lineColor,
                                strokeWidth: 0,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: lineColor.withValues(alpha: 0.08),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionSection(AppLocalizations l10n) {
    final total = _totalUsers + _totalPosts + _totalHabits;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: LucideIcons.pieChart,
          title: l10n.dataDistribution,
          subtitle: Localizations.localeOf(context).languageCode == 'vi' ? 'Phân bổ dữ liệu theo danh mục' : 'Data Distribution by Category',
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.grey.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 220,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 48,
                    sections: [
                      _pieSection(
                        value: _totalUsers.toDouble(),
                        total: total.toDouble(),
                        label: l10n.users,
                        color: const Color(0xFF2196F3),
                      ),
                      _pieSection(
                        value: _totalPosts.toDouble(),
                        total: total.toDouble(),
                        label: l10n.postsLabel,
                        color: const Color(0xFF4CAF50),
                      ),
                      _pieSection(
                        value: _totalHabits.toDouble(),
                        total: total.toDouble(),
                        label: l10n.habits,
                        color: const Color(0xFF9C27B0),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildLegendRow(
                color: const Color(0xFF2196F3),
                label: l10n.users,
                value: _totalUsers,
                total: total,
              ),
              const SizedBox(height: 10),
              _buildLegendRow(
                color: const Color(0xFF4CAF50),
                label: l10n.postsLabel,
                value: _totalPosts,
                total: total,
              ),
              const SizedBox(height: 10),
              _buildLegendRow(
                color: const Color(0xFF9C27B0),
                label: l10n.habits,
                value: _totalHabits,
                total: total,
              ),
            ],
          ),
        ),
      ],
    );
  }

  PieChartSectionData _pieSection({
    required double value,
    required double total,
    required String label,
    required Color color,
  }) {
    final pct = total > 0 ? (value / total * 100).toStringAsFixed(0) : '0';
    return PieChartSectionData(
      value: value,
      title: '$pct%',
      color: color,
      radius: 65,
      titleStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildLegendRow({
    required Color color,
    required String label,
    required int value,
    required int total,
  }) {
    final pct = total > 0 ? (value / total * 100) : 0.0;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          '${pct.toStringAsFixed(0)}%',
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        SizedBox(
          width: 56,
          child: Text(
            formatCompact(value),
            textAlign: TextAlign.right,
            style: AppTypography.caption,
          ),
        ),
      ],
    );
  }

  int _parseInt(dynamic v, [int fallback = 0]) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  Widget _buildHabitTrendsSection(AppLocalizations l10n) {
    const habitCategoryColors = {
      'eat': Color(0xFF4CAF50),
      'exercise': Color(0xFFF59E0B),
      'sleep': Color(0xFF3B82F6),
      'mental': Color(0xFF8B5CF6),
      'hydration': Color(0xFF0EA5E9),
      'other': Color(0xFF6B7280),
    };
    String catLabel(String key) {
      switch (key) {
        case 'eat': return l10n.categoryEat;
        case 'exercise': return l10n.categoryExercise;
        case 'sleep': return l10n.categorySleep;
        case 'mental': return l10n.categoryMental;
        case 'hydration': return l10n.categoryHydration;
        default: return l10n.categoryOther;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: AppIcons.habits,
          title: l10n.habitTrends,
          subtitle: '$_activeUsers ${l10n.users} · ${_habitCategories.length} ${l10n.category}',
        ),
        const SizedBox(height: 18),
        _buildHabitPeriodToggle(),
        const SizedBox(height: 16),
        // Category breakdown
        if (_habitCategories.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.grey.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.popularHabitCategories,
                  style: AppTypography.title,
                ),
                const SizedBox(height: 14),
                ...List.generate(_habitCategories.length, (i) {
                  final cat = _habitCategories[i];
                  final key = cat['category'] as String? ?? 'other';
                  final total = _parseInt(cat['total_habits']);
                  final users = _parseInt(cat['total_users']);
                  final streak = _parseInt(cat['total_streak']);
                  final color = habitCategoryColors[key] ?? AppColors.primary;
                  final label = catLabel(key);
                  final maxCount = (_habitCategories.isNotEmpty
                      ? _parseInt(_habitCategories.first['total_habits'], 1)
                      : 1);

                  return Padding(
                    padding: EdgeInsets.only(bottom: i < _habitCategories.length - 1 ? 12 : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  label,
                                  style: AppTypography.caption.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: context.textPrimary,
                                  ),
                                ),
                              ),
                            Text(
                              '$total ${l10n.habitsLabel}',
                              style: AppTypography.caption,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              '$users ${l10n.users}',
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: total / maxCount,
                            backgroundColor: context.isDark
                                ? const Color(0xFF2E433C)
                                : const Color(0xFFE5E7EB),
                            color: color,
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${l10n.habitCount}: $streak ${l10n.habitsLabel}',
                              style: AppTypography.caption.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        const SizedBox(height: 16),
        // Top habits
        if (_topHabits.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.grey.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.topCompletedHabits,
                  style: AppTypography.title,
                ),
                const SizedBox(height: 12),
                ...List.generate(_topHabits.length, (i) {
                  final h = _topHabits[i];
                  final name = h['name'] as String? ?? '';
                  final cat = h['category'] as String? ?? 'other';
                  final completions = _parseInt(h['completions']);
                  final usersCount = _parseInt(h['users_count']);
                  final icon = h['icon'] as String? ?? '✅';
                  final color = habitCategoryColors[cat] ?? AppColors.primary;
                  final maxCompletions = _topHabits.isNotEmpty
                      ? _parseInt(_topHabits.first['completions'], 1)
                      : 1;

                  return Padding(
                    padding: EdgeInsets.only(bottom: i < _topHabits.length - 1 ? 10 : 0),
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(child: HabitIcon(iconString: icon, size: 16, color: color)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: context.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: completions / maxCompletions,
                                  backgroundColor: context.isDark
                                      ? const Color(0xFF2E433C)
                                      : const Color(0xFFE5E7EB),
                                  color: color,
                                  minHeight: 4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$completions',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                            Text(
                              '$usersCount ${l10n.users}',
                              style: TextStyle(fontSize: 10, color: context.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHabitPeriodToggle() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: context.inputFill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(
            label: l10n.weekly,
            isSelected: _habitTrendPeriod == 'weekly',
            onTap: () {
              setState(() => _habitTrendPeriod = 'weekly');
              _loadHabitTrends();
            },
          ),
          const SizedBox(width: 3),
          _buildToggleOption(
            label: l10n.monthly,
            isSelected: _habitTrendPeriod == 'monthly',
            onTap: () {
              setState(() => _habitTrendPeriod = 'monthly');
              _loadHabitTrends();
            },
          ),
        ],
      ),
    );
  }
}
