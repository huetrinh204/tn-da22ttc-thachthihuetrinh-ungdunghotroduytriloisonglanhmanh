import '../l10n/app_localizations.dart';

/// Gợi ý thói quen mẫu theo mục tiêu onboarding.
class StarterHabitOption {
  const StarterHabitOption({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.targetCount,
  });

  final String id;
  final String name;
  final String category;
  final String icon;
  final int targetCount;
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
          targetCount: 2000,
        );
      case 'starter_walk_20':
        return StarterHabitOption(
          id: id,
          name: l10n.starterHabitWalk20,
          category: 'exercise',
          icon: '🚶',
          targetCount: 20,
        );
      case 'starter_exercise_30':
        return StarterHabitOption(
          id: id,
          name: l10n.starterHabitExercise30,
          category: 'exercise',
          icon: '🏃',
          targetCount: 30,
        );
      case 'starter_sleep_23':
        return StarterHabitOption(
          id: id,
          name: l10n.starterHabitSleep23,
          category: 'sleep',
          icon: '😴',
          targetCount: 480,
        );
      case 'starter_meditation_10':
        return StarterHabitOption(
          id: id,
          name: l10n.starterHabitMeditation10,
          category: 'mental',
          icon: '🧘',
          targetCount: 10,
        );
      case 'starter_healthy_breakfast':
        return StarterHabitOption(
          id: id,
          name: l10n.starterHabitHealthyBreakfast,
          category: 'eat',
          icon: '🥗',
          targetCount: 500,
        );
      case 'starter_eat_veggies':
        return StarterHabitOption(
          id: id,
          name: l10n.starterHabitEatVeggies,
          category: 'eat',
          icon: '🥦',
          targetCount: 300,
        );
      case 'starter_read_30':
        return StarterHabitOption(
          id: id,
          name: l10n.starterHabitRead30,
          category: 'mental',
          icon: '📚',
          targetCount: 30,
        );
      case 'starter_study_60':
        return StarterHabitOption(
          id: id,
          name: l10n.starterHabitStudy60,
          category: 'mental',
          icon: '✏️',
          targetCount: 60,
        );
      case 'starter_review_notes':
        return StarterHabitOption(
          id: id,
          name: l10n.starterHabitReviewNotes,
          category: 'other',
          icon: '📝',
          targetCount: 1,
        );
      default:
        return null;
    }
  }

  /// Suy luận gợi ý từ mục tiêu tự nhập (mục "Khác").
  static List<String> _habitIdsForCustomGoal(String raw) {
    final t = raw.toLowerCase().trim();
    if (t.isEmpty) return const [];

    if (_containsAny(t, [
      'học',
      'hoc',
      'học tập',
      'hoc tap',
      'study',
      'learn',
      'learning',
      'education',
      'giáo dục',
      'giao duc',
      'đọc',
      'doc',
      'sách',
      'sach',
      'book',
      'read',
      'reading',
      'ôn',
      'on thi',
      'thi',
      'exam',
      'bài',
      'bai',
    ])) {
      return ['starter_study_60', 'starter_read_30', 'starter_review_notes'];
    }

    if (_containsAny(t, [
      'ăn',
      'an ',
      'eat',
      'food',
      'diet',
      'healthy',
      'lành mạnh',
      'lanh manh',
      'rau',
      'vegetable',
    ])) {
      return ['starter_healthy_breakfast', 'starter_eat_veggies'];
    }

    if (_containsAny(t, [
      'tập',
      'tap',
      'gym',
      'sport',
      'exercise',
      'workout',
      'chạy',
      'chay',
      'run',
      'vận động',
      'van dong',
    ])) {
      return ['starter_exercise_30', 'starter_walk_20'];
    }

    if (_containsAny(t, [
      'ngủ',
      'ngu',
      'sleep',
      'rest',
    ])) {
      return ['starter_sleep_23'];
    }

    if (_containsAny(t, [
      'nước',
      'nuoc',
      'water',
      'hydrat',
      'uống',
      'uong',
    ])) {
      return ['starter_hydration_2l'];
    }

    if (_containsAny(t, [
      'thiền',
      'thien',
      'meditat',
      'mindful',
      'tâm',
      'tam linh',
      'mental',
      'stress',
      'relax',
    ])) {
      return ['starter_meditation_10'];
    }

    if (_containsAny(t, [
      'cân',
      'can nang',
      'weight',
      'giảm cân',
      'giam can',
      'lose weight',
      'fat',
    ])) {
      return ['starter_walk_20', 'starter_healthy_breakfast'];
    }

    return const [];
  }

  static bool _containsAny(String haystack, List<String> needles) {
    for (final n in needles) {
      if (haystack.contains(n)) return true;
    }
    return false;
  }

  /// Tối đa [maxCount] gợi ý, không trùng id.
  static List<StarterHabitOption> forGoals(
    Set<String> selectedGoals,
    AppLocalizations l10n, {
    int maxCount = 4,
    String? customGoalText,
  }) {
    final orderedIds = <String>[];
    final goals = selectedGoals.where((g) => g != 'other').toList();

    for (final goal in goals) {
      for (final id in _goalHabitIds[goal] ?? const []) {
        if (!orderedIds.contains(id)) orderedIds.add(id);
      }
    }

    if (selectedGoals.contains('other')) {
      final customIds = _habitIdsForCustomGoal(customGoalText ?? '');
      for (final id in customIds) {
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
