import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/plant_type.dart';

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
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
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
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Main card (behind confetti)
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
                    // Title with party popper emoji
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🎉', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 8),
                        Text(
                          'CHÚC MỪNG!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.orange.shade800,
                            letterSpacing: 1.2,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Plant image in rounded square with border
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.blue.shade300,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
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
                    
                    // Level badge with arrow
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.amber.shade200,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Cấp ${widget.oldLevel}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown.shade700,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.arrow_forward, 
                              size: 20, 
                              color: Colors.brown.shade700),
                          const SizedBox(width: 12),
                          Text(
                            'Cấp ${widget.newLevel}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Main message
                    Text(
                      'Cây của bạn đã lớn thêm\nmột chút rồi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal.shade800,
                        height: 1.4,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Sub message
                    Text(
                      'Tiếp tục chăm sóc để nhận thêm\nhiều hạt giống mới nhé!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.5,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    
                    const SizedBox(height: 28),
                    
                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: widget.onComplete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Tiếp tục',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Confetti particles (in front of card)
            AnimatedBuilder(
              animation: _confettiController,
              builder: (context, child) {
                return IgnorePointer(
                  child: CustomPaint(
                    size: MediaQuery.of(context).size,
                    painter: ConfettiPainter(
                      progress: _confettiController.value,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantImage() {
    final plantType = PlantType.fromIdOrDefault(widget.plantType);
    final imagePath = plantType.getAssetPath(widget.newLevel);

    return Image.asset(
      imagePath,
      width: 140,
      height: 140,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Text(
          plantType.emoji,
          style: const TextStyle(fontSize: 100),
        );
      },
    );
  }
}

// Confetti painter with colorful squares falling
class ConfettiPainter extends CustomPainter {
  final double progress;
  final List<ConfettiParticle> particles;

  ConfettiPainter({required this.progress})
      : particles = List.generate(
          30,
          (index) {
            final random = math.Random(index);
            return ConfettiParticle(
              x: random.nextDouble(),
              startY: -0.1 - random.nextDouble() * 0.2,
              speed: 0.3 + random.nextDouble() * 0.4,
              size: 6.0 + random.nextDouble() * 6.0,
              rotation: random.nextDouble() * 2 * math.pi,
              rotationSpeed: -math.pi + random.nextDouble() * 2 * math.pi,
              color: [
                const Color(0xFFFFD700), // Gold
                const Color(0xFFFFA500), // Orange
                const Color(0xFF4CAF50), // Green
                const Color(0xFF00BCD4), // Cyan
                const Color(0xFFFF9800), // Deep Orange
              ][random.nextInt(5)],
            );
          },
        );

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final y = particle.startY + (progress * particle.speed * 1.5);
      if (y > 1.1) continue;

      final x = particle.x * size.width;
      final yPos = y * size.height;
      final rotation = particle.rotation + (progress * particle.rotationSpeed * 3);

      final paint = Paint()
        ..color = particle.color.withValues(alpha: (1.0 - progress * 0.3))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, yPos);
      canvas.rotate(rotation);
      
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
