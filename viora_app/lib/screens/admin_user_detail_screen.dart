import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../theme/theme_extensions.dart';

class AdminUserDetailScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const AdminUserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết người dùng'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar and basic info
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: user['avatar_url'] != null
                        ? NetworkImage(ApiService.resolveImageUrl(user['avatar_url']))
                        : null,
                    child: user['avatar_url'] == null
                        ? Text(
                            user['name']?[0]?.toUpperCase() ?? 'U',
                            style: const TextStyle(fontSize: 40),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user['name'] ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user['email'] ?? '',
                    style: TextStyle(fontSize: 16, color: context.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  if (user['role'] == 'admin')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'ADMIN',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Personal Info
            _buildSection('Thông tin cá nhân', [
              _buildInfoRow('Giới tính', _getGenderText(user['gender'])),
              _buildInfoRow('Năm sinh', user['birth_year']?.toString() ?? 'Chưa cập nhật'),
              _buildInfoRow('Chiều cao', user['height'] != null ? '${user['height']} cm' : 'Chưa cập nhật'),
              _buildInfoRow('Cân nặng', user['weight'] != null ? '${user['weight']} kg' : 'Chưa cập nhật'),
            ]),
            
            const SizedBox(height: 24),
            
            // Goals
            _buildSection('Mục tiêu', [
              _buildGoalsWidget(user['goals']),
            ]),
            
            const SizedBox(height: 24),
            
            // Statistics
            _buildSection('Thống kê', [
              _buildInfoRow('Số thói quen', user['habit_count']?.toString() ?? '0'),
              _buildInfoRow('Số bài viết', user['post_count']?.toString() ?? '0'),
              _buildInfoRow('Ngày tham gia', _formatDate(user['created_at'])),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Builder(
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: context.isDark 
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: TextStyle(color: context.textSecondary, fontSize: 14),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsWidget(dynamic goals) {
    if (goals == null) {
      return Builder(
        builder: (context) => Text(
          'Chưa thiết lập mục tiêu',
          style: TextStyle(color: context.textSecondary),
        ),
      );
    }

    List<dynamic> goalsList;
    try {
      if (goals is String) {
        goalsList = jsonDecode(goals);
      } else if (goals is List) {
        goalsList = goals;
      } else {
        return Builder(
          builder: (context) => Text(
            'Chưa thiết lập mục tiêu',
            style: TextStyle(color: context.textSecondary),
          ),
        );
      }
    } catch (e) {
      return Builder(
        builder: (context) => Text(
          'Chưa thiết lập mục tiêu',
          style: TextStyle(color: context.textSecondary),
        ),
      );
    }

    if (goalsList.isEmpty) {
      return Builder(
        builder: (context) => Text(
          'Chưa thiết lập mục tiêu',
          style: TextStyle(color: context.textSecondary),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: goalsList.map((goal) {
        return Builder(
          builder: (context) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: context.isDark ? Colors.blue[900]!.withValues(alpha: 0.3) : Colors.blue[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.isDark ? Colors.blue[700]! : Colors.blue[200]!,
              ),
            ),
            child: Text(
              _getGoalText(goal.toString()),
              style: TextStyle(
                color: context.isDark ? Colors.blue[300] : Colors.blue[700],
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getGenderText(dynamic gender) {
    if (gender == null) return 'Chưa cập nhật';
    switch (gender.toString().toLowerCase()) {
      case 'male':
        return 'Nam';
      case 'female':
        return 'Nữ';
      case 'other':
        return 'Khác';
      default:
        return 'Chưa cập nhật';
    }
  }

  String _getGoalText(String goal) {
    final goalMap = {
      'exercise': 'Tập thể dục',
      'eat_healthy': 'Ăn uống lành mạnh',
      'sleep': 'Ngủ đủ giấc',
      'hydration': 'Uống đủ nước',
      'weight': 'Quản lý cân nặng',
      'mental': 'Sức khỏe tinh thần',
    };

    if (goal.startsWith('other:')) {
      return goal.substring(6);
    }

    return goalMap[goal] ?? goal;
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Chưa có';
    try {
      final dateTime = DateTime.parse(date.toString());
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'Chưa có';
    }
  }
}
