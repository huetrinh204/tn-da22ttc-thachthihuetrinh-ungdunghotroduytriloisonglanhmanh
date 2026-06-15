import 'package:flutter/material.dart';
import '../theme/theme_extensions.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final bool showBorder;
  final List<BoxShadow>? customShadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.radius = 20.0,
    this.showBorder = false,
    this.customShadow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(radius),
        border: showBorder
            ? Border.all(
                color: isDark 
                    ? const Color(0xFF2E433C) 
                    : const Color(0xFFE5E7EB),
                width: 1.0,
              )
            : null,
        boxShadow: customShadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
