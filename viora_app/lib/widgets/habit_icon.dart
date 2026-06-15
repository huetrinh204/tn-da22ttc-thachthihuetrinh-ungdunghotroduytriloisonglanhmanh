import 'package:flutter/material.dart';
import '../utils/habit_icon_mapper.dart';

/// Widget to display habit icon using Lucide Icons instead of emoji
class HabitIcon extends StatelessWidget {
  final String iconString;
  final double size;
  final Color? color;

  const HabitIcon({
    super.key,
    required this.iconString,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = HabitIconMapper.getIconData(iconString);
    
    return Icon(
      iconData,
      size: size,
      color: color,
    );
  }
}
