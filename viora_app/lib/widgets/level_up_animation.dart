import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../l10n/app_localizations.dart';

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
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation (grow effect)
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_scaleController);

    // Glow animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Particle animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Start animations
    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // Start glow and particles
    _glowController.forward();
    _particleController.forward();

    // Wait a bit then start scale
    await Future.delayed(const Duration(milliseconds: 300));
    await _scaleController.forward();

    // Wait longer for user to read the message
    await Future.delayed(const Duration(milliseconds: 1500));
    widget.onComplete();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    _particleController.dispose();
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
            // Particles
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(300, 300),
                  painter: ParticlePainter(
                    progress: _particleController.value,
                  ),
                );
              },
            ),

            // Glow effect
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50)
                            .withValues(alpha: _glowAnimation.value * 0.5),
                        blurRadius: 60 * _glowAnimation.value,
                        spreadRadius: 20 * _glowAnimation.value,
                      ),
                    ],
                  ),
                );
              },
            ),

            // Plant image with scale animation
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                );
              },
              child: _buildPlantImage(),
            ),

            // Level up text
            Positioned(
              bottom: 100,
              child: AnimatedBuilder(
                animation: _scaleController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _scaleController.value,
                    child: child,
                  );
                },
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.congratulations,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Color(0xFF4CAF50),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.plantLeveledUp,
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.levelRange(widget.oldLevel, widget.newLevel),
                      style: const TextStyle(
                        fontSize: 24,
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.white,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.keepGrowing,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantImage() {
    final stages = _getPlantStages();
    final imagePath = stages[(widget.newLevel - 1).clamp(0, stages.length - 1)];

    return Image.asset(
      imagePath,
      width: 150,
      height: 150,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Text(
          '🌳',
          style: TextStyle(fontSize: 150),
        );
      },
    );
  }

  List<String> _getPlantStages() {
    return [
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
    ];
  }
}

class ParticlePainter extends CustomPainter {
  final double progress;
  final List<Particle> particles;

  ParticlePainter({required this.progress})
      : particles = List.generate(
          30,
          (index) => Particle(
            angle: (index / 30) * 2 * math.pi,
            speed: 1.0 + (index % 3) * 0.5,
            size: 4.0 + (index % 4) * 2.0,
          ),
        );

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    for (final particle in particles) {
      final distance = progress * 150 * particle.speed;
      final x = center.dx + math.cos(particle.angle) * distance;
      final y = center.dy + math.sin(particle.angle) * distance;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      paint.color = Color(0xFF4CAF50).withValues(alpha: opacity);
      canvas.drawCircle(
        Offset(x, y),
        particle.size * (1.0 - progress * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class Particle {
  final double angle;
  final double speed;
  final double size;

  Particle({
    required this.angle,
    required this.speed,
    required this.size,
  });
}
