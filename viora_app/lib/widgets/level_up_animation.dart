import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/plant_type.dart';
import '../constants/app_icons.dart';

class LevelUpAnimation extends StatefulWidget {
  final String plantType;
  final int oldLevel;
  final int newLevel;
  final VoidCallback onComplete;

  const LevelUpAnimation({
    super.key,
    required this.plantType,
    required this.oldLevel,
    required this.newLevel,
    required this.onComplete,
  });

  @override
  State<LevelUpAnimation> createState() => _LevelUpAnimationState();
}

class _LevelUpAnimationState extends State<LevelUpAnimation>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    _fadeController.forward();
    _scaleController.forward();
    _confettiController.repeat();

    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final lvl = widget.newLevel.clamp(1, 15);
    final plantType = PlantType.fromIdOrDefault(widget.plantType);
    final imagePath = plantType.getAssetPath(lvl);

    return PopScope(
      canPop: false,
      child: SizedBox.expand(
        child: Stack(
        children: [
          // Dark overlay
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value * 0.45,
                  child: const ColoredBox(
                    color: Colors.black,
                  ),
                );
              },
            ),
          ),
          // Confetti layer (behind card)
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _confettiController,
              builder: (context, child) {
                return CustomPaint(
                  size: screenSize,
                  painter: _ConfettiPainter(
                    progress: _confettiController.value,
                  ),
                );
              },
            ),
          ),
          // Animated card
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                );
              },
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: screenSize.height * 0.72,
                ),
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.08),
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            AppIcons.sprout,
                            color: Color(0xFF2E7D32),
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Title
                        const Text(
                          'CHÚC MỪNG!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2E7D32),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Plant image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            imagePath,
                            width: 130,
                            height: 130,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                plantType.emoji,
                                style: const TextStyle(fontSize: 72),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Level badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Cấp ${widget.oldLevel}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF66BB6A),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2E7D32),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  AppIcons.arrowRight,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Cấp ${widget.newLevel}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Motivational text
                        const Text(
                          'Cây của bạn đã lớn thêm một chút rồi!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF555555),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Continue button
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: widget.onComplete,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Tiếp tục',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Confetti layer (on top of card)
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _confettiController,
              builder: (context, child) {
                return CustomPaint(
                  size: screenSize,
                  painter: _ConfettiPainter(
                    progress: _confettiController.value,
                    seedOffset: 500,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
  }
}

class _ConfettiParticle {
  final double x;
  final double startY;
  final double speed;
  final double size;
  final double rotation;
  final double rotationSpeed;
  final Color color;
  final double phase;

  _ConfettiParticle({
    required this.x,
    required this.startY,
    required this.speed,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.phase,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final int seedOffset;
  final List<_ConfettiParticle> particles;

  _ConfettiPainter({required this.progress, this.seedOffset = 0})
      : particles = List.generate(
          24,
          (index) {
            final random = math.Random(index + 200 + seedOffset);
            final phase = random.nextDouble();
            return _ConfettiParticle(
              x: random.nextDouble(),
              startY: -random.nextDouble() * 0.3,
              speed: 0.25 + random.nextDouble() * 0.35,
              size: 4.0 + random.nextDouble() * 5.0,
              rotation: random.nextDouble() * 2 * math.pi,
              rotationSpeed: -math.pi + random.nextDouble() * 2 * math.pi,
              phase: phase,
              color: [
                const Color(0xFF66BB6A),
                const Color(0xFF4CAF50),
                const Color(0xFF00796B),
                const Color(0xFFFFD54F),
                const Color(0xFFFFF176),
                const Color(0xFF81C784),
              ][index % 6],
            );
          },
        );

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final cyclePos = (progress + p.phase) % 1.0;
      final y = p.startY + (cyclePos * p.speed * 1.5);
      if (y > 1.3) continue;

      final x = p.x * size.width;
      final yPos = y * size.height;
      final rotation = p.rotation + (cyclePos * p.rotationSpeed * 3);

      final paint = Paint()
        ..color = p.color.withValues(alpha: cyclePos < 0.15 ? cyclePos / 0.15 : (1.0 - cyclePos * 0.3))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, yPos);
      canvas.rotate(rotation);

      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: p.size,
        height: p.size,
      );
      canvas.drawRect(rect, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) =>
      old.progress != progress || old.seedOffset != seedOffset;
}
