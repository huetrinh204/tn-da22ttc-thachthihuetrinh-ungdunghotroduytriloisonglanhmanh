import 'package:flutter/material.dart';
import 'dart:math' as math;

class TreasureRewardAnimation extends StatefulWidget {
  const TreasureRewardAnimation({super.key});

  @override
  State<TreasureRewardAnimation> createState() => _TreasureRewardAnimationState();
}

class _TreasureRewardAnimationState extends State<TreasureRewardAnimation>
    with TickerProviderStateMixin {
  late AnimationController _chestController;
  late AnimationController _fireworksController;
  late AnimationController _textController;
  late Animation<double> _chestScale;
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();

    // Chest animation
    _chestController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _chestScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _chestController, curve: Curves.elasticOut),
    );

    // Fireworks animation
    _fireworksController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Text animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await _chestController.forward();
    _fireworksController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    await _textController.forward();
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _chestController.dispose();
    _fireworksController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Fireworks particles
            AnimatedBuilder(
              animation: _fireworksController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(400, 400),
                  painter: FireworksPainter(
                    progress: _fireworksController.value,
                  ),
                );
              },
            ),

            // Treasure chest
            AnimatedBuilder(
              animation: _chestScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _chestScale.value,
                  child: child,
                );
              },
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/khobau.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Text message
            Positioned(
              bottom: 150,
              left: 20,
              right: 20,
              child: AnimatedBuilder(
                animation: _textFade,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textFade.value,
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '🎉 BẠN NHẬN ĐƯỢC NƯỚC THẦN 🎉',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF8F00),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'VẬT PHẨM CÓ THỂ HỒI PHỤC LẠI SỰ SỐNG CỦA CÂY KHI CÂY HÉO',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FireworksPainter extends CustomPainter {
  final double progress;
  final List<Firework> fireworks;

  FireworksPainter({required this.progress})
      : fireworks = List.generate(
          50,
          (index) => Firework(
            angle: (index / 50) * 2 * math.pi,
            speed: 1.0 + (index % 5) * 0.3,
            color: _getFireworkColor(index),
            size: 3.0 + (index % 3) * 2.0,
          ),
        );

  static Color _getFireworkColor(int index) {
    final colors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFFF8F00), // Orange
      const Color(0xFFFF6B6B), // Red
      const Color(0xFF4CAF50), // Green
      const Color(0xFF2196F3), // Blue
      const Color(0xFF9C27B0), // Purple
    ];
    return colors[index % colors.length];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final firework in fireworks) {
      final distance = progress * 200 * firework.speed;
      final x = center.dx + math.cos(firework.angle) * distance;
      final y = center.dy + math.sin(firework.angle) * distance;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = firework.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      // Draw star shape
      final path = _createStarPath(
        Offset(x, y),
        firework.size * (1.0 + progress * 0.5),
      );
      canvas.drawPath(path, paint);

      // Draw glow
      final glowPaint = Paint()
        ..color = firework.color.withValues(alpha: opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(Offset(x, y), firework.size * 2, glowPaint);
    }
  }

  Path _createStarPath(Offset center, double size) {
    final path = Path();
    final points = 5;
    final angle = (math.pi * 2) / points;

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? size : size / 2;
      final x = center.dx + radius * math.cos(i * angle / 2 - math.pi / 2);
      final y = center.dy + radius * math.sin(i * angle / 2 - math.pi / 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(FireworksPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class Firework {
  final double angle;
  final double speed;
  final Color color;
  final double size;

  Firework({
    required this.angle,
    required this.speed,
    required this.color,
    required this.size,
  });
}
