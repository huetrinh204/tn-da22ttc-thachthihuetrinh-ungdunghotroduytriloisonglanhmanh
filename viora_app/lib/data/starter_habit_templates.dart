import '../l10n/app_localizations.dart';

/// Gợi ý thói quen mẫu theo mục tiêu onboarding.
class StarterHabitOption {
  const StarterHabitOption({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
  });

  final String id;
  final String name;
  final String category;
  final String icon;
}

abstract final class StarterHabitTemplates {
  static const _goalHabitIds = <String, List<String>>{
    'eat_healthy': ['starter_healthy_breakfast', 'starter_eat_veggies'],
    'exercise': ['starter_exercise_30', 'starter_walk_20'],
    'sleep': ['starter_sleep_23'],
    'mental': ['starter_meditation_10'],
    'weight': ['starter_walk_20', 'starter_healthy_breakfast'],
    'hydration': ['starter_hydration_2l'],
  };

  static const _defaultIds = [
    'starter_hydration_2l',
    'starter_walk_20',
    'starter_meditation_10',
  ];

  static StarterHabitOption? _byId(String id, AppLocalizations l10n) {
    switch (id) {
      case 'starter_hydration_2l':
        return StarterHabitOption(
          id: id,
          name: l10n.starterHabitHydration2L,
          category: 'hydration',
          icon: '💧',
        );
      case 'starter_walk_20':
        return StarterHabitOption(
          id: id,
          name: l10n.starterHabitWalk20,
          category: 'exercise',
          icon: '🚶',
        );
      case 'starter_exercise_30':
        return StarterHabitOption(
          id: id,
          name: l10n.starterHabitExercise30,
          category: 'exercise',
          icon: '🏃',
        );
      case 'starter_sleep_23':
        return StarterHabitOption(
          id: id,
          name: l10n.starterHabitSleep23,
          category: 'sleep',
          icon: '😴',
        );
      case 'starter_meditation_10':
        return StarterHabitOption(
          id: id,
          name: l10n.starterHabitMeditation10,
          category: 'mental',
          icon: '🧘',
        );
      case 'starter_healthy_breakfast':
        return StarterHabitOption(
          id: id,
          name: l10n.starterHabitHealthyBreakfast,
          category: 'eat',
          icon: '🥗',
        );
      case 'starter_eat_veggies':
        return StarterHabitOption(
          id: id,
          name: l10n.starterHabitEatVeggies,
          category: 'eat',
          icon: '🥦',
        );
      default:
        return null;
    }
  }

  /// Tối đa [maxCount] gợi ý, không trùng id.
  static List<StarterHabitOption> forGoals(
    Set<String> selectedGoals,
    AppLocalizations l10n, {
    int maxCount = 4,
  }) {
    final orderedIds = <String>[];
    final goals = selectedGoals.where((g) => g != 'other').toList();

    for (final goal in goals) {
      for (final id in _goalHabitIds[goal] ?? const []) {
        if (!orderedIds.contains(id)) orderedIds.add(id);
      }
    }

    if (orderedIds.isEmpty) {
      orderedIds.addAll(_defaultIds);
    }

    final options = <StarterHabitOption>[];
    for (final id in orderedIds) {
      if (options.length >= maxCount) break;
      final opt = _byId(id, l10n);
      if (opt != null) options.add(opt);
    }

    return options;
  }
}
