import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CategoryIconDotPainter extends FlDotPainter {
  final String category;
  final double size;

  CategoryIconDotPainter({
    required this.category,
    this.size = 24,
  });

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offsetInCanvas) {
    final icon = _getCategoryIcon(category);
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: icon,
        style: TextStyle(
          fontSize: size,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    final offset = Offset(
      offsetInCanvas.dx - textPainter.width / 2,
      offsetInCanvas.dy - textPainter.height / 2,
    );
    
    textPainter.paint(canvas, offset);
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'eat':
        return '🍎'; // Icon ăn uống
      case 'exercise':
        return '🏃'; // Icon vận động/chạy bộ
      case 'sleep':
        return '😴'; // Icon ngủ
      case 'mental':
        return '🧘'; // Icon tinh thần
      case 'hydration':
        return '💧'; // Icon uống nước
      case 'other':
      default:
        return '⭐'; // Icon mặc định
    }
  }

  @override
  Size getSize(FlSpot spot) {
    return Size(size, size);
  }

  @override
  Color get mainColor => Colors.transparent;

  @override
  List<Object?> get props => [category, size];

  @override
  FlDotPainter lerp(FlDotPainter a, FlDotPainter b, double t) {
    return this;
  }
}
