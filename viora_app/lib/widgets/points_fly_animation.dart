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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Calculate current position
        final dx = widget.startPosition.dx +
            (widget.endPosition.dx - widget.startPosition.dx) * _animation.value;
        final dy = widget.startPosition.dy +
            (widget.endPosition.dy - widget.startPosition.dy) * _animation.value -
            50 * math.sin(_animation.value * math.pi); // Arc effect

        // Calculate opacity (fade out near the end)
        final opacity = _animation.value < 0.8
            ? 1.0
            : (1.0 - (_animation.value - 0.8) / 0.2);

        // Calculate scale (grow then shrink)
        final scale = _animation.value < 0.3
            ? 1.0 + _animation.value
            : _animation.value < 0.7
                ? 1.3
                : 1.3 - (_animation.value - 0.7) * 1.5;

        return Positioned(
          left: dx,
          top: dy,
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
