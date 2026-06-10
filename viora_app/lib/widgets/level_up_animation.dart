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
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Fade in animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    // Scale animation (subtle bounce)
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Confetti animation
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    _fadeController.forward();
    _scaleController.forward();
    _confettiController.forward();

    // Display for longer duration (3.5 seconds total)
    await Future.delayed(const Duration(milliseconds: 3500));
    widget.onComplete();
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
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      color: Colors.black.withValues(alpha: 0.7), // Dark overlay
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Confetti particles
            AnimatedBuilder(
              animation: _confettiController,
              builder: (context, child) {
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: ConfettiPainter(
                    progress: _confettiController.value,
                  ),
                );
              },
            ),

            // Main card
            AnimatedBuilder(
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
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title with emoji
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🎉', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 8),
                        Text(
                          l10n.congratulations.toUpperCase().replaceAll('!', ''),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.brown.shade700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('🎉', style: TextStyle(fontSize: 28)),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Plant image in circle
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade100,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: _buildPlantImage(),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Level badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.amber.shade300,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.level(widget.oldLevel),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown.shade700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 18, color: Color(0xFF4CAF50)),
                          const SizedBox(width: 8),
                          Text(
                            l10n.level(widget.newLevel),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Message
                    Text(
                      l10n.plantLeveledUp,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      l10n.keepGrowing.replaceAll('✨', ''),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
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
      width: 100,
      height: 100,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Text(
          '🌳',
          style: TextStyle(fontSize: 80),
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

// Confetti painter with colorful squares falling
class ConfettiPainter extends CustomPainter {
  final double progress;
  final List<ConfettiParticle> particles;

  ConfettiPainter({required this.progress})
      : particles = List.generate(
          40,
          (index) {
            final random = math.Random(index);
            return ConfettiParticle(
              x: random.nextDouble(),
              startY: -0.1 - random.nextDouble() * 0.2,
              speed: 0.3 + random.nextDouble() * 0.4,
              size: 8.0 + random.nextDouble() * 8.0,
              rotation: random.nextDouble() * 2 * math.pi,
              rotationSpeed: -math.pi + random.nextDouble() * 2 * math.pi,
              color: [
                const Color(0xFFFFD700), // Gold
                const Color(0xFF4CAF50), // Green
                const Color(0xFFFF9800), // Orange
                const Color(0xFF2196F3), // Blue
                const Color(0xFFE91E63), // Pink
                const Color(0xFF9C27B0), // Purple
              ][random.nextInt(6)],
            );
          },
        );

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final y = particle.startY + (progress * particle.speed * 1.5);
      if (y > 1.1) continue; // Don't draw if off screen

      final x = particle.x * size.width;
      final yPos = y * size.height;
      final rotation = particle.rotation + (progress * particle.rotationSpeed * 3);

      final paint = Paint()
        ..color = particle.color.withValues(alpha: (1.0 - progress * 0.3))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, yPos);
      canvas.rotate(rotation);
      
      // Draw square confetti
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: particle.size,
        height: particle.size,
      );
      canvas.drawRect(rect, paint);
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class ConfettiParticle {
  final double x;
  final double startY;
  final double speed;
  final double size;
  final double rotation;
  final double rotationSpeed;
  final Color color;

  ConfettiParticle({
    required this.x,
    required this.startY,
    required this.speed,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
  });
}
