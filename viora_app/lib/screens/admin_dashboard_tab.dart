import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../theme/theme_extensions.dart';
import '../l10n/app_localizations.dart';

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
  
  List<Map<String, dynamic>> _userGrowthData = [];
  List<Map<String, dynamic>> _postGrowthData = [];
  
  // Growth chart filter: 'weekly' or 'monthly'
  String _growthFilter = 'monthly';

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
      
      // Get total habits count from users
      final usersRes = await ApiService.getAdminUsers(_token);
      int habitCount = 0;
      for (var user in usersRes['users']) {
        habitCount += (user['habit_count'] as int?) ?? 0;
      }
      
      // Load growth data
      await _loadGrowthData();
      
      if (!mounted) return;
      setState(() {
        _totalUsers = stats['totalUsers'] ?? 0;
        _totalPosts = stats['totalPosts'] ?? 0;
        _totalComments = stats['totalComments'] ?? 0;
        _todayUsers = stats['todayUsers'] ?? 0;
        _todayPosts = stats['todayPosts'] ?? 0;
        _totalHabits = habitCount;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
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
      // If API fails, keep empty data
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
    
    // Find max value
    double maxVal = 0;
    for (var item in data) {
      final count = (item['count'] as num).toDouble();
      if (count > maxVal) maxVal = count;
    }
    
    // Calculate appropriate interval
    if (maxVal <= 5) return 1;
    if (maxVal <= 10) return 2;
    if (maxVal <= 20) return 5;
    if (maxVal <= 50) return 10;
    if (maxVal <= 100) return 20;
    return (maxVal / 5).ceil().toDouble();
  }

  double _calculateMaxY(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 10;
    
    // Find max value
    double maxVal = 0;
    for (var item in data) {
      final count = (item['count'] as num).toDouble();
      if (count > maxVal) maxVal = count;
    }
    
    // Add some padding to max value (20% more)
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.overview,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            
            // Stats Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  l10n.users,
                  _totalUsers.toString(),
                  Icons.people,
                  Colors.blue,
                  '+$_todayUsers ${l10n.todayLabel}',
                  onTap: () => _navigateToTab(1), // Navigate to Users tab
                ),
                _buildStatCard(
                  l10n.postsLabel,
                  _totalPosts.toString(),
                  Icons.article,
                  Colors.green,
                  '+$_todayPosts ${l10n.todayLabel}',
                  onTap: () => _navigateToTab(2), // Navigate to Posts tab
                ),
                _buildStatCard(
                  l10n.commentsLabel,
                  _totalComments.toString(),
                  Icons.comment,
                  Colors.orange,
                  '',
                  onTap: () => _navigateToTab(2), // Navigate to Posts tab (where comments are)
                ),
                _buildStatCard(
                  l10n.habits,
                  _totalHabits.toString(),
                  Icons.check_circle,
                  Colors.purple,
                  '',
                  onTap: () => _navigateToTab(3), // Navigate to Plants tab (habits related)
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Line Charts section
            Text(
              l10n.growthCharts,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildLineCharts(l10n),
            
            const SizedBox(height: 30),
            
            // Pie Chart section  
            Text(
              l10n.dataDistribution,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildPieChart(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.isDark 
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineCharts(AppLocalizations l10n) {
    return Column(
      children: [
        // Filter buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFilterButton(
              label: l10n.weekly,
              isSelected: _growthFilter == 'weekly',
              onTap: () {
                setState(() => _growthFilter = 'weekly');
                _loadGrowthData();
              },
            ),
            const SizedBox(width: 12),
            _buildFilterButton(
              label: l10n.monthly,
              isSelected: _growthFilter == 'monthly',
              onTap: () {
                setState(() => _growthFilter = 'monthly');
                _loadGrowthData();
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Users growth chart
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: context.isDark 
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _growthFilter == 'weekly' 
                    ? l10n.userGrowth7Days
                    : l10n.userGrowth30Days,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _userGrowthData.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noGrowthData,
                          style: TextStyle(color: context.textSecondary),
                        ),
                      )
                    : LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: _calculateMaxY(_userGrowthData),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: context.isDark 
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.3),
                                strokeWidth: 1,
                              );
                            },
                            getDrawingVerticalLine: (value) {
                              return FlLine(
                                color: context.isDark 
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.3),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                interval: _calculateYInterval(_userGrowthData),
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: context.textSecondary,
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: _userGrowthData.length > 10 ? 5 : 1,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index >= 0 && index < _userGrowthData.length) {
                                    if (_userGrowthData.length > 10) {
                                      if (index % 5 == 0 || index == _userGrowthData.length - 1) {
                                        final date = _userGrowthData[index]['date'] as String;
                                        final parts = date.split('-');
                                        return Text(
                                          '${parts[2]}/${parts[1]}',
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: context.textSecondary,
                                          ),
                                        );
                                      }
                                    } else {
                                      final date = _userGrowthData[index]['date'] as String;
                                      final parts = date.split('-');
                                      return Text(
                                        '${parts[2]}/${parts[1]}',
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: context.textSecondary,
                                        ),
                                      );
                                    }
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: context.isDark 
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _userGrowthData.asMap().entries.map((entry) {
                                return FlSpot(
                                  entry.key.toDouble(),
                                  (entry.value['count'] as num).toDouble(),
                                );
                              }).toList(),
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 3,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 3,
                                    color: Colors.blue,
                                    strokeWidth: 0,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.blue.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
        
        // Posts growth chart
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: context.isDark 
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _growthFilter == 'weekly'
                    ? l10n.postGrowth7Days
                    : l10n.postGrowth30Days,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _postGrowthData.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noGrowthData,
                          style: TextStyle(color: context.textSecondary),
                        ),
                      )
                    : LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: _calculateMaxY(_postGrowthData),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: context.isDark 
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.3),
                                strokeWidth: 1,
                              );
                            },
                            getDrawingVerticalLine: (value) {
                              return FlLine(
                                color: context.isDark 
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.3),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                interval: _calculateYInterval(_postGrowthData),
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: context.textSecondary,
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: _postGrowthData.length > 10 ? 5 : 1,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index >= 0 && index < _postGrowthData.length) {
                                    if (_postGrowthData.length > 10) {
                                      if (index % 5 == 0 || index == _postGrowthData.length - 1) {
                                        final date = _postGrowthData[index]['date'] as String;
                                        final parts = date.split('-');
                                        return Text(
                                          '${parts[2]}/${parts[1]}',
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: context.textSecondary,
                                          ),
                                        );
                                      }
                                    } else {
                                      final date = _postGrowthData[index]['date'] as String;
                                      final parts = date.split('-');
                                      return Text(
                                        '${parts[2]}/${parts[1]}',
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: context.textSecondary,
                                        ),
                                      );
                                    }
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: context.isDark 
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _postGrowthData.asMap().entries.map((entry) {
                                return FlSpot(
                                  entry.key.toDouble(),
                                  (entry.value['count'] as num).toDouble(),
                                );
                              }).toList(),
                              isCurved: true,
                              color: Colors.green,
                              barWidth: 3,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 3,
                                    color: Colors.green,
                                    strokeWidth: 0,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.green.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildFilterButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF4CAF50)
              : context.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF4CAF50)
                : context.isDark 
                    ? Colors.grey.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected 
                ? Colors.white
                : context.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(AppLocalizations l10n) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.isDark 
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l10n.dataDistribution,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: _totalUsers.toDouble(),
                    title: '$_totalUsers\n${l10n.users}',
                    color: Colors.blue,
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: _totalPosts.toDouble(),
                    title: '$_totalPosts\n${l10n.postsLabel}',
                    color: Colors.green,
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: _totalHabits.toDouble(),
                    title: '$_totalHabits\n${l10n.habits}',
                    color: Colors.purple,
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
}
