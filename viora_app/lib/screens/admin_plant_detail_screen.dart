import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../widgets/viora_app_bar.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';

class AdminPlantDetailScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const AdminPlantDetailScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<AdminPlantDetailScreen> createState() => _AdminPlantDetailScreenState();
}

class _AdminPlantDetailScreenState extends State<AdminPlantDetailScreen> {
  bool _isLoading = true;
  String _token = '';
  Map<String, dynamic>? _plant;
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _streak;
  Map<String, dynamic>? _stats;
  List<dynamic> _history = [];

  @override
  void initState() {
    super.initState();
    _loadPlantHistory();
  }

  Future<void> _loadPlantHistory() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';

    try {
      final res = await ApiService.getPlantHistory(_token, widget.userId);
      if (!mounted) return;
      setState(() {
        _plant = res['plant'];
        _user = res['user'];
        _streak = res['streak'];
        _stats = res['stats'];
        _history = res['history'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  String _getPlantImagePath(int level) {
    const imagePaths = [
      'assets/images/tree/1_hatgiong.png',
      'assets/images/tree/2_hatnaymam.png',
      'assets/images/tree/3_mamnon.png',
      'assets/images/tree/4_caynon.png',
      'assets/images/tree/5_caycon.png',
      'assets/images/tree/6_caynho.png',
      'assets/images/tree/7_caylon.png',
      'assets/images/tree/8_cayxanhtot.png',
      'assets/images/tree/9_cayphattrien.png',
      'assets/images/tree/10_cayrahoa.png',
      'assets/images/tree/11_caykettrainon.png',
      'assets/images/tree/12_caytrailondan.png',
      'assets/images/tree/13_caykettraichin.png',
      'assets/images/tree/14_caysaiqua.png',
      'assets/images/tree/15_caytruongthanh.png',
    ];
    return imagePaths[level - 1];
  }

  String _getPlantName(int level) {
    const names = [
      'Hạt giống',
      'Hạt nảy mầm',
      'Mầm non',
      'Cây non',
      'Cây con',
      'Cây nhỏ',
      'Cây lớn',
      'Cây xanh tốt',
      'Cây phát triển',
      'Cây ra hoa',
      'Cây kết trái non',
      'Cây trái lớn dần',
      'Cây kết trái chín',
      'Cây sai quả',
      'Cây trưởng thành',
    ];
    return names[level - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: VioraAppBar(
        title: 'Cây của ${widget.userName}',
        showBack: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _plant == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.park_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'Người dùng chưa có cây',
                        style: TextStyle(
                          fontSize: 16,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPlantHistory,
                  color: AppColors.primary,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildOwnerCard(),
                      const SizedBox(height: 16),
                      _buildPlantCard(),
                      const SizedBox(height: 16),
                      _buildStatsCard(),
                      const SizedBox(height: 24),
                      _buildHistorySection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildOwnerCard() {
    final userName = _user?['name'] ?? widget.userName;
    final userEmail = _user?['email'] ?? '';
    final userAvatar = _user?['avatar_url'] as String?;
    final userCreatedAt = _user?['created_at'] as String?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.infoBoxBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: userAvatar != null
                ? ClipOval(
                    child: Image.network(
                      ApiService.resolveImageUrl(userAvatar),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          userName[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      userName[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: context.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Chủ sở hữu',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                if (userEmail.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.textSecondary,
                    ),
                  ),
                ],
                if (userCreatedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Tham gia: ${_formatDate(userCreatedAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantCard() {
    final level = _plant!['level'] as int? ?? 1;
    final experience = _plant!['experience'] as int? ?? 0;
    final plantType = _plant!['plant_type'] as String? ?? 'sprout';
    final lastWatered = _plant!['last_watered'] as String?;

    // Calculate planting date (from user created_at or estimate)
    String? plantingDate;
    if (_user?['created_at'] != null) {
      plantingDate = _formatDate(_user!['created_at']);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Plant image
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Image.asset(
              _getPlantImagePath(level),
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          // Plant name
          Text(
            _getPlantName(level),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Loại cây: ${_getPlantTypeName(plantType)}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          // Level and experience
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Cấp độ $level • $experience EXP',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Planting date and last watered
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (plantingDate != null) ...[
                const Icon(Icons.spa, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Gieo: $plantingDate',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
              if (plantingDate != null && lastWatered != null) ...[
                const SizedBox(width: 16),
                Container(
                  width: 1,
                  height: 12,
                  color: Colors.white54,
                ),
                const SizedBox(width: 16),
              ],
              if (lastWatered != null) ...[
                const Icon(Icons.water_drop, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Tưới: ${_formatDate(lastWatered)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _getPlantTypeName(String type) {
    switch (type) {
      case 'sprout':
        return 'Cây mầm';
      case 'cactus':
        return 'Xương rồng';
      case 'sunflower':
        return 'Hướng dương';
      case 'flower':
        return 'Hoa';
      default:
        return type;
    }
  }

  Widget _buildStatsCard() {
    final currentStreak = _streak?['current'] ?? 0;
    final totalHabits = _stats?['total_habits'] ?? 0;
    final daysCompleted = _stats?['days_completed'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.infoBoxBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assessment,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Thống kê',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.local_fire_department,
                  label: 'Chuỗi ngày',
                  value: '$currentStreak',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.check_circle,
                  label: 'Thói quen',
                  value: '$totalHabits',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.calendar_month,
                  label: 'Ngày hoàn thành',
                  value: '$daysCompleted',
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              'Lịch sử nhận điểm',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Mỗi thói quen hoàn thành = +1 EXP',
          style: TextStyle(
            fontSize: 13,
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        if (_history.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.event_busy, size: 48, color: context.textSecondary),
                  const SizedBox(height: 12),
                  Text(
                    'Chưa có lịch sử nhận điểm',
                    style: TextStyle(
                      fontSize: 15,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...(_history.map((entry) => _buildHistoryItem(entry)).toList()),
      ],
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> entry) {
    final date = entry['date'] as String;
    final habitsCompleted = entry['habits_completed'] as int? ?? 0;
    final expGained = entry['exp_gained'] as int? ?? 0;
    final habits = entry['habits'] as List? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.infoBoxBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: context.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(date),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+$expGained EXP',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$habitsCompleted thói quen hoàn thành:',
            style: TextStyle(
              fontSize: 13,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: habits.map<Widget>((habit) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${habit['icon'] ?? '⭐'} ${habit['name']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date).inDays;

      if (diff == 0) return 'Hôm nay';
      if (diff == 1) return 'Hôm qua';
      if (diff < 7) return '$diff ngày trước';

      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
