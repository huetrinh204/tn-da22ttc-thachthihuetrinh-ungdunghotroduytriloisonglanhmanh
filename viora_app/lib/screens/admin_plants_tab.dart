import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_extensions.dart';
import 'admin_plant_detail_screen.dart';

class AdminPlantsTab extends StatefulWidget {
  const AdminPlantsTab({super.key});

  @override
  State<AdminPlantsTab> createState() => _AdminPlantsTabState();
}

class _AdminPlantsTabState extends State<AdminPlantsTab> {
  bool _isLoading = true;
  String _token = '';
  List<dynamic> _plants = [];

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';
    
    try {
      final res = await ApiService.getAdminPlants(_token);
      if (!mounted) return;
      setState(() {
        _plants = res['plants'] ?? [];
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

  double _getProgressToNextLevel(int level, int experience) {
    if (level >= 15) return 1.0;
    
    final expForCurrentLevel = _getExpForLevel(level);
    final expForNextLevel = _getExpForLevel(level + 1);
    
    if (expForNextLevel == expForCurrentLevel) return 1.0;
    
    final progress = (experience - expForCurrentLevel) / (expForNextLevel - expForCurrentLevel);
    return progress.clamp(0.0, 1.0);
  }

  int _getExpForLevel(int level) {
    const levelThresholds = [0, 5, 15, 30, 50, 75, 105, 140, 180, 225, 275, 330, 390, 455, 525];
    if (level <= 0) return 0;
    if (level > levelThresholds.length) return levelThresholds.last;
    return levelThresholds[level - 1];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_plants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.park_outlined, size: 64, color: context.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Chưa có cây nào',
              style: TextStyle(
                fontSize: 16,
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPlants,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _plants.length,
        itemBuilder: (context, index) {
          final plant = _plants[index];
          final level = plant['level'] as int? ?? 1;
          final experience = plant['experience'] as int? ?? 0;
          final userName = plant['user_name'] ?? 'Unknown';
          final userId = plant['user_id']?.toString() ?? '';
          final userAvatar = plant['user_avatar'] as String?;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminPlantDetailScreen(
                      userId: userId,
                      userName: userName,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Plant image
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        _getPlantImagePath(level),
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Plant info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User info
                          Row(
                            children: [
                              if (userAvatar != null) ...[
                                ClipOval(
                                  child: Image.network(
                                    ApiService.resolveImageUrl(userAvatar),
                                    width: 24,
                                    height: 24,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          userName[0].toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Expanded(
                                child: Text(
                                  userName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: context.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Plant name and level
                          Text(
                            '${_getPlantName(level)} (Level $level)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$experience EXP',
                            style: TextStyle(
                              fontSize: 13,
                              color: context.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _getProgressToNextLevel(level, experience),
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      color: context.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
