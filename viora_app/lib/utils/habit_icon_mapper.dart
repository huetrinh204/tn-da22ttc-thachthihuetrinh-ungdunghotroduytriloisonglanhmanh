import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Utility class to map habit icon strings to IconData
class HabitIconMapper {
  /// Map emoji strings to Lucide Icons
  static IconData getIconData(String iconString) {
    switch (iconString) {
      case '⭐':
        return LucideIcons.star;
      case '🏃':
        return LucideIcons.activity; // Running/Exercise
      case '🥗':
        return LucideIcons.salad; // Eating healthy
      case '💧':
        return LucideIcons.droplet; // Water/Hydration
      case '😴':
        return LucideIcons.moon; // Sleep
      case '🧘':
        return LucideIcons.flower2; // Meditation/Mental
      case '📚':
        return LucideIcons.bookOpen; // Reading/Learning
      case '📖':
        return LucideIcons.bookOpen; // Reading/Learning
      case '🎯':
        return LucideIcons.target; // Goals/Target
      case '💪':
        return LucideIcons.dumbbell; // Strength/Exercise
      case '🌿':
        return LucideIcons.leaf; // Nature/Health
      case '❤️':
        return LucideIcons.heart; // Heart/Health
      case '🍴':
        return LucideIcons.utensils; // Eating/Utensils
      case '⚖️':
        return LucideIcons.scale; // Weight/Balance
      default:
        return LucideIcons.circle; // Default fallback
    }
  }

  /// Get all available icon options with their IconData
  static List<Map<String, dynamic>> getAvailableIcons() {
    return [
      {'emoji': '⭐', 'icon': LucideIcons.star},
      {'emoji': '🏃', 'icon': LucideIcons.activity},
      {'emoji': '🥗', 'icon': LucideIcons.salad},
      {'emoji': '💧', 'icon': LucideIcons.droplet},
      {'emoji': '😴', 'icon': LucideIcons.moon},
      {'emoji': '🧘', 'icon': LucideIcons.flower2},
      {'emoji': '📚', 'icon': LucideIcons.bookOpen},
      {'emoji': '📖', 'icon': LucideIcons.bookOpen},
      {'emoji': '🎯', 'icon': LucideIcons.target},
      {'emoji': '💪', 'icon': LucideIcons.dumbbell},
      {'emoji': '🌿', 'icon': LucideIcons.leaf},
      {'emoji': '❤️', 'icon': LucideIcons.heart},
      {'emoji': '🍴', 'icon': LucideIcons.utensils},
      {'emoji': '⚖️', 'icon': LucideIcons.scale},
    ];
  }

  /// Check if an icon exists in our mapping
  static bool isValidIcon(String iconString) {
    return getAvailableIcons().any((item) => item['emoji'] == iconString);
  }
}
