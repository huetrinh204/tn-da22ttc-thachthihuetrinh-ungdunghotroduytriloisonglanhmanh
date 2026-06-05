import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AdminPlantsTab extends StatefulWidget {
  const AdminPlantsTab({super.key});

  @override
  State<AdminPlantsTab> createState() => _AdminPlantsTabState();
}

class _AdminPlantsTabState extends State<AdminPlantsTab> {
  bool _isLoading = true;
  String _token = '';
  List<dynamic> _users = [];

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
      final res = await ApiService.getAdminUsers(_token);
      if (!mounted) return;
      setState(() {
        _users = res['users'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadPlants,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          final habitCount = user['habit_count'] ?? 0;
          final level = _calculatePlantLevel(habitCount);
          final experience = _calculateExperience(habitCount);
          final plantEmoji = _getPlantEmoji(level);
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Text(
                plantEmoji,
                style: const TextStyle(fontSize: 40),
              ),
              title: Text(user['name'] ?? 'Unknown'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Level $level • ${experience} EXP'),
                  Text('${habitCount} thói quen hoàn thành'),
                  LinearProgressIndicator(
                    value: _getProgressToNextLevel(experience),
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getPlantName(level),
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${experience} điểm',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  int _calculatePlantLevel(int habitCount) {
    if (habitCount == 0) return 1;
    if (habitCount < 3) return 2;
    if (habitCount < 5) return 3;
    if (habitCount < 7) return 4;
    if (habitCount < 10) return 5;
    if (habitCount < 15) return 6;
    if (habitCount < 20) return 7;
    if (habitCount < 25) return 8;
    if (habitCount < 30) return 9;
    if (habitCount < 40) return 10;
    if (habitCount < 50) return 11;
    if (habitCount < 60) return 12;
    if (habitCount < 75) return 13;
    if (habitCount < 90) return 14;
    return 15;
  }

  int _calculateExperience(int habitCount) {
    return habitCount * 10; // 10 điểm mỗi thói quen
  }

  double _getProgressToNextLevel(int experience) {
    final currentLevel = _calculatePlantLevel(experience ~/ 10);
    if (currentLevel >= 15) return 1.0;
    
    final expForCurrentLevel = _getExpForLevel(currentLevel);
    final expForNextLevel = _getExpForLevel(currentLevel + 1);
    final progress = (experience - expForCurrentLevel) / (expForNextLevel - expForCurrentLevel);
    
    return progress.clamp(0.0, 1.0);
  }

  int _getExpForLevel(int level) {
    const levelThresholds = [0, 0, 30, 50, 70, 100, 150, 200, 250, 300, 400, 500, 600, 750, 900];
    if (level <= 0) return 0;
    if (level >= levelThresholds.length) return levelThresholds.last;
    return levelThresholds[level - 1];
  }

  String _getPlantEmoji(int level) {
    const emojis = [
      '🌱', // 1 - Hạt giống
      '🌱', // 2 - Hạt nảy mầm
      '🌿', // 3 - Mầm non
      '🌿', // 4 - Cây non
      '🪴', // 5 - Cây con
      '🪴', // 6 - Cây nhỏ
      '🌳', // 7 - Cây lớn
      '🌳', // 8 - Cây xanh tốt
      '🌳', // 9 - Cây phát triển
      '🌺', // 10 - Cây ra hoa
      '🌺', // 11 - Cây kết trái non
      '🍎', // 12 - Cây trái lớn dần
      '🍎', // 13 - Cây kết trái chín
      '🎄', // 14 - Cây sai quả
      '🌲', // 15 - Cây trưởng thành
    ];
    return emojis[level - 1];
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
}
