import 'package:flutter/material.dart';
import 'dart:math' as math;

class PointsFlyAnimation extends StatefulWidget {
  final int points;
  final Offset startPosition;
  final Offset endPosition;
  final VoidCallback onComplete;

  const PointsFlyAnimation({
    super.key,
    required this.points,
    required this.startPosition,
    required this.endPosition,
    required this.onComplete,
  });

  @override
  State<PointsFlyAnimation> createState() => _PointsFlyAnimationState();
}

class _PointsFlyAnimationState extends State<PointsFlyAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offsetX = widget.endPosition.dx - widget.startPosition.dx;
    final offsetY = widget.endPosition.dy - widget.startPosition.dy;

    return Positioned(
      left: widget.startPosition.dx,
      top: widget.startPosition.dy,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final t = _animation.value;

          // Move along path with arc
          final dx = offsetX * t;
          final dy = offsetY * t - 50 * math.sin(t * math.pi);

          // Fade out near the end
          final opacity = t < 0.8 ? 1.0 : (1.0 - (t - 0.8) / 0.2);

          // Scale: grow then shrink
          final scale = t < 0.3
              ? 1.0 + t
              : t < 0.7
                  ? 1.3
                  : 1.3 - (t - 0.7) * 1.5;

          return Transform.translate(
            offset: Offset(dx, dy),
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    '+${widget.points}',
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
