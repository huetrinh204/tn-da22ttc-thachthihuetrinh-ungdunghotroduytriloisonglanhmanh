import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../theme/theme_extensions.dart';
import '../l10n/app_localizations.dart';

class AdminUserDetailScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const AdminUserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.userDetails),
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
                      child: Text(
                        l10n.admin.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Personal Info
            _buildSection(context, l10n.personalInfo, [
              _buildInfoRow(context, l10n.gender, _getGenderText(user['gender'], l10n)),
              _buildInfoRow(context, l10n.birthYear, user['birth_year']?.toString() ?? l10n.notUpdated),
              _buildInfoRow(context, l10n.height, user['height'] != null ? '${user['height']} cm' : l10n.notUpdated),
              _buildInfoRow(context, l10n.weight, user['weight'] != null ? '${user['weight']} kg' : l10n.notUpdated),
            ]),
            
            const SizedBox(height: 24),
            
            // Goals
            _buildSection(context, l10n.goals, [
              _buildGoalsWidget(context, user['goals'], l10n),
            ]),
            
            const SizedBox(height: 24),
            
            // Statistics
            _buildSection(context, l10n.stats, [
              _buildInfoRow(context, l10n.habitCount, user['habit_count']?.toString() ?? '0'),
              _buildInfoRow(context, l10n.postCount, user['post_count']?.toString() ?? '0'),
              _buildInfoRow(context, l10n.joinedDate, _formatDate(user['created_at'], l10n)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Container(
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
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
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
    );
  }

  Widget _buildGoalsWidget(BuildContext context, dynamic goals, AppLocalizations l10n) {
    if (goals == null) {
      return Text(
        l10n.noGoalsSet,
        style: TextStyle(color: context.textSecondary),
      );
    }

    List<dynamic> goalsList;
    try {
      if (goals is String) {
        goalsList = jsonDecode(goals);
      } else if (goals is List) {
        goalsList = goals;
      } else {
        return Text(
          l10n.noGoalsSet,
          style: TextStyle(color: context.textSecondary),
        );
      }
    } catch (e) {
      return Text(
        l10n.noGoalsSet,
        style: TextStyle(color: context.textSecondary),
      );
    }

    if (goalsList.isEmpty) {
      return Text(
        l10n.noGoalsSet,
        style: TextStyle(color: context.textSecondary),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: goalsList.map((goal) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: context.isDark ? Colors.blue[900]!.withValues(alpha: 0.3) : Colors.blue[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.isDark ? Colors.blue[700]! : Colors.blue[200]!,
            ),
          ),
          child: Text(
            _getGoalText(goal.toString(), l10n),
            style: TextStyle(
              color: context.isDark ? Colors.blue[300] : Colors.blue[700],
              fontSize: 12,
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getGenderText(dynamic gender, AppLocalizations l10n) {
    if (gender == null) return l10n.notUpdated;
    switch (gender.toString().toLowerCase()) {
      case 'male':
        return l10n.male;
      case 'female':
        return l10n.female;
      case 'other':
        return l10n.other;
      default:
        return l10n.notUpdated;
    }
  }

  String _getGoalText(String goal, AppLocalizations l10n) {
    final goalMap = {
      'exercise': l10n.goalExercise,
      'eat_healthy': l10n.goalEatHealthy,
      'sleep': l10n.goalSleep,
      'hydration': l10n.goalHydration,
      'weight': l10n.goalWeight,
      'mental': l10n.goalMental,
    };

    if (goal.startsWith('other:')) {
      return goal.substring(6);
    }

    return goalMap[goal] ?? goal;
  }

  String _formatDate(dynamic date, AppLocalizations l10n) {
    if (date == null) return l10n.noDate;
    try {
      final dateTime = DateTime.parse(date.toString());
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return l10n.noDate;
    }
  }
}
