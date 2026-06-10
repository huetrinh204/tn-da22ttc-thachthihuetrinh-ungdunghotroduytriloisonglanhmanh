import 'package:flutter/material.dart';
import '../theme/theme_extensions.dart';
import '../l10n/app_localizations.dart';

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
    'sprout': [
      'assets/images/tree/1_hatgiong.png',
      'assets/images/tree/2_hatnaymam.png',
      'assets/images/tree/3_mamnon.png',
      'assets/images/tree/4_caynon.png',
      'assets/images/tree/5_caycon.png',
      'assets/images/tree/6_caynho.png',
      'assets/images/tree/7_caydanglon.png',
      'assets/images/tree/8_caytruongthanh.png',
      'assets/images/tree/9_cayphattrientot.png',
      'assets/images/tree/10_cayrahoa.png',
      'assets/images/tree/11_caykettrainon.png',
      'assets/images/tree/12_caytrailondan.png',
      'assets/images/tree/13_caykettraichin.png',
      'assets/images/tree/14_caysaiqua.png',
      'assets/images/tree/15_caytruongthanh.png',
    ],
    'cactus': [
      'assets/images/tree/1_hatgiong.png',
      'assets/images/tree/2_hatnaymam.png',
      'assets/images/tree/3_mamnon.png',
      'assets/images/tree/4_caynon.png',
      'assets/images/tree/5_caycon.png',
      'assets/images/tree/6_caynho.png',
      'assets/images/tree/7_caydanglon.png',
      'assets/images/tree/8_caytruongthanh.png',
      'assets/images/tree/9_cayphattrientot.png',
      'assets/images/tree/10_cayrahoa.png',
      'assets/images/tree/11_caykettrainon.png',
      'assets/images/tree/12_caytrailondan.png',
      'assets/images/tree/13_caykettraichin.png',
      'assets/images/tree/14_caysaiqua.png',
      'assets/images/tree/15_caytruongthanh.png',
    ],
    'bonsai': [
      'assets/images/tree/1_hatgiong.png',
      'assets/images/tree/2_hatnaymam.png',
      'assets/images/tree/3_mamnon.png',
      'assets/images/tree/4_caynon.png',
      'assets/images/tree/5_caycon.png',
      'assets/images/tree/6_caynho.png',
      'assets/images/tree/7_caydanglon.png',
      'assets/images/tree/8_caytruongthanh.png',
      'assets/images/tree/9_cayphattrientot.png',
      'assets/images/tree/10_cayrahoa.png',
      'assets/images/tree/11_caykettrainon.png',
      'assets/images/tree/12_caytrailondan.png',
      'assets/images/tree/13_caykettraichin.png',
      'assets/images/tree/14_caysaiqua.png',
      'assets/images/tree/15_caytruongthanh.png',
    ],
    'flower': [
      'assets/images/tree/1_hatgiong.png',
      'assets/images/tree/2_hatnaymam.png',
      'assets/images/tree/3_mamnon.png',
      'assets/images/tree/4_caynon.png',
      'assets/images/tree/5_caycon.png',
      'assets/images/tree/6_caynho.png',
      'assets/images/tree/7_caydanglon.png',
      'assets/images/tree/8_caytruongthanh.png',
      'assets/images/tree/9_cayphattrientot.png',
      'assets/images/tree/10_cayrahoa.png',
      'assets/images/tree/11_caykettrainon.png',
      'assets/images/tree/12_caytrailondan.png',
      'assets/images/tree/13_caykettraichin.png',
      'assets/images/tree/14_caysaiqua.png',
      'assets/images/tree/15_caytruongthanh.png',
    ],
    'bamboo': [
      'assets/images/tree/1_hatgiong.png',
      'assets/images/tree/2_hatnaymam.png',
      'assets/images/tree/3_mamnon.png',
      'assets/images/tree/4_caynon.png',
      'assets/images/tree/5_caycon.png',
      'assets/images/tree/6_caynho.png',
      'assets/images/tree/7_caydanglon.png',
      'assets/images/tree/8_caytruongthanh.png',
      'assets/images/tree/9_cayphattrientot.png',
      'assets/images/tree/10_cayrahoa.png',
      'assets/images/tree/11_caykettrainon.png',
      'assets/images/tree/12_caytrailondan.png',
      'assets/images/tree/13_caykettraichin.png',
      'assets/images/tree/14_caysaiqua.png',
      'assets/images/tree/15_caytruongthanh.png',
    ],
    'sunflower': [
      'assets/images/tree/1_hatgiong.png',
      'assets/images/tree/2_hatnaymam.png',
      'assets/images/tree/3_mamnon.png',
      'assets/images/tree/4_caynon.png',
      'assets/images/tree/5_caycon.png',
      'assets/images/tree/6_caynho.png',
      'assets/images/tree/7_caydanglon.png',
      'assets/images/tree/8_caytruongthanh.png',
      'assets/images/tree/9_cayphattrientot.png',
      'assets/images/tree/10_cayrahoa.png',
      'assets/images/tree/11_caykettrainon.png',
      'assets/images/tree/12_caytrailondan.png',
      'assets/images/tree/13_caykettraichin.png',
      'assets/images/tree/14_caysaiqua.png',
      'assets/images/tree/15_caytruongthanh.png',
    ],
  };



  String get _emoji {
    if (widget.isWilted) return '🥀';
    final stages = _plantStages[widget.plantType] ?? _plantStages['sprout']!;
    final idx = (widget.level - 1).clamp(0, stages.length - 1);
    return stages[idx];
  }
  
  bool get _isImagePath {
    return _emoji.endsWith('.png') || _emoji.endsWith('.jpg');
  }

  String _getLevelName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final levelNames = [
      '',
      l10n.plantLevel1, l10n.plantLevel2, l10n.plantLevel3, l10n.plantLevel4, l10n.plantLevel5,
      l10n.plantLevel6, l10n.plantLevel7, l10n.plantLevel8, l10n.plantLevel9, l10n.plantLevel10,
      l10n.plantLevel11, l10n.plantLevel12, l10n.plantLevel13, l10n.plantLevel14, l10n.plantLevel15,
    ];
    return levelNames[widget.level.clamp(1, 15)];
  }
  
  String _getPlantName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final plantNames = {
      'sprout':    l10n.plantSprout,
      'cactus':    l10n.plantCactus,
      'bonsai':    l10n.plantBonsai,
      'flower':    l10n.plantFlower,
      'bamboo':    l10n.plantBamboo,
      'sunflower': l10n.plantSunflower,
    };
    return plantNames[widget.plantType] ?? l10n.plantSprout;
  }
  
  String _getWiltedStatus(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return '😢 ${l10n.plantWiltingStatus}';
  }

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
          child: _isImagePath
              ? Image.asset(
                  _emoji,
                  width: widget.size * 1.5,
                  height: widget.size * 1.5,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to emoji if image fails to load
                    return Text(
                      '🌰',
                      style: TextStyle(fontSize: widget.size),
                    );
                  },
                )
              : Text(
                  _emoji,
                  style: TextStyle(fontSize: widget.size),
                ),
        ),
        const SizedBox(height: 6),
        Text(
          _getPlantName(context),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: context.textGreen,
          ),
        ),
        Text(
          widget.isWilted ? _getWiltedStatus(context) : _getLevelName(context),
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

  static const List<int> _thresholds = [
    0, 5, 15, 30, 50, 75, 105, 140, 180, 225, 275, 330, 390, 455, 525, 999999
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (level >= 15) {
      return Text(
        l10n.maxLevel,
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
              l10n.levelRange(level, level + 1),
              style: TextStyle(fontSize: 12, color: context.textSecondary),
            ),
            Text(
              '$experience / $nextThreshold',
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
