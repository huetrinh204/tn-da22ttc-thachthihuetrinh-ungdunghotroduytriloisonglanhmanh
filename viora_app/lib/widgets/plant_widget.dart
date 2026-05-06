import 'package:flutter/material.dart';
import '../theme/theme_extensions.dart';

class PlantWidget extends StatefulWidget {
  final String plantType;
  final int level;
  final bool isWilted;
  final double size;

  const PlantWidget({
    super.key,
    required this.plantType,
    required this.level,
    this.isWilted = false,
    this.size = 80,
  });

  @override
  State<PlantWidget> createState() => _PlantWidgetState();
}

class _PlantWidgetState extends State<PlantWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sway;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _sway = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const Map<String, List<String>> _plantStages = {
    'sprout':    ['🌰', '🌱', '🪴', '🌿', '🌳'],
    'cactus':    ['🌰', '🌱', '🪴', '🌵', '🌵'],
    'bonsai':    ['🌰', '🌱', '🪴', '🌲', '🌳'],
    'flower':    ['🌰', '🌱', '🪴', '🌸', '💐'],
    'bamboo':    ['🌰', '🌱', '🪴', '🎋', '🎍'],
    'sunflower': ['🌰', '🌱', '🪴', '🌻', '🌻'],
  };

  static const Map<String, String> _plantNames = {
    'sprout':    'Mầm xanh',
    'cactus':    'Xương rồng',
    'bonsai':    'Bonsai',
    'flower':    'Hoa anh đào',
    'bamboo':    'Tre xanh',
    'sunflower': 'Hướng dương',
  };

  static const List<String> _levelNames = [
    '', 'Hạt giống', 'Mầm nhú', 'Cây non', 'Trưởng thành', 'Đầy hoa/quả'
  ];

  String get _emoji {
    if (widget.isWilted) return '🥀';
    final stages = _plantStages[widget.plantType] ?? _plantStages['sprout']!;
    final idx = (widget.level - 1).clamp(0, stages.length - 1);
    return stages[idx];
  }

  String get _levelName => _levelNames[widget.level.clamp(1, 5)];
  String get _plantName => _plantNames[widget.plantType] ?? 'Cây';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _sway,
          builder: (context, child) => Transform.rotate(
            angle: widget.isWilted ? 0.3 : _sway.value,
            child: child,
          ),
          child: Text(
            _emoji,
            style: TextStyle(fontSize: widget.size),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _plantName,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: context.textGreen,
          ),
        ),
        Text(
          widget.isWilted ? '😢 Cây đang héo...' : _levelName,
          style: TextStyle(
            fontSize: 12,
            color: widget.isWilted ? Colors.red : context.textSecondary,
          ),
        ),
      ],
    );
  }
}

// Progress bar cho plant experience
class PlantProgressBar extends StatelessWidget {
  final int experience;
  final int level;

  const PlantProgressBar({
    super.key,
    required this.experience,
    required this.level,
  });

  static const List<int> _thresholds = [0, 10, 30, 100, 300, 999999];

  @override
  Widget build(BuildContext context) {
    if (level >= 5) {
      return Text(
        '🏆 Cây đã đạt cấp độ tối đa!',
        style: TextStyle(
          fontSize: 13,
          color: context.textGreen,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final currentThreshold = _thresholds[level - 1];
    final nextThreshold = _thresholds[level];
    final progress = (experience - currentThreshold) /
        (nextThreshold - currentThreshold);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cấp $level → ${level + 1}',
              style: TextStyle(fontSize: 12, color: context.textSecondary),
            ),
            Text(
              '$experience / $nextThreshold điểm',
              style: TextStyle(
                  fontSize: 12,
                  color: context.textGreenLight,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: context.infoBoxColor,
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          ),
        ),
      ],
    );
  }
}
