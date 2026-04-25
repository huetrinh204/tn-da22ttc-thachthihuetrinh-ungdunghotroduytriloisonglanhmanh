import 'dart:math';
import 'package:flutter/material.dart';

class FloatingLeaves extends StatefulWidget {
  const FloatingLeaves({super.key});

  @override
  State<FloatingLeaves> createState() => _FloatingLeavesState();
}

class _FloatingLeavesState extends State<FloatingLeaves>
    with TickerProviderStateMixin {
  final List<_LeafData> _leaves = [];
  final Random _random = Random();

  final List<String> _leafEmojis = ['🍃', '🌿', '🍀', '🌱'];

  @override
  void initState() {
    super.initState();
    // Tạo 6 chiếc lá với vị trí và tốc độ ngẫu nhiên
    for (int i = 0; i < 6; i++) {
      _leaves.add(_createLeaf(i * 0.3));
    }
  }

  _LeafData _createLeaf(double initialDelay) {
    final controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 6 + _random.nextInt(5)),
    );

    final startX = _random.nextDouble();
    final driftX = (_random.nextDouble() - 0.5) * 0.3;
    final rotations = (_random.nextDouble() - 0.5) * 4;
    final size = 16.0 + _random.nextDouble() * 14;
    final emoji = _leafEmojis[_random.nextInt(_leafEmojis.length)];

    final leaf = _LeafData(
      controller: controller,
      startX: startX,
      driftX: driftX,
      rotations: rotations,
      size: size,
      emoji: emoji,
    );

    // delay rồi loop
    Future.delayed(Duration(milliseconds: (initialDelay * 2000).toInt()), () {
      if (mounted) {
        controller.repeat();
      }
    });

    return leaf;
  }

  @override
  void dispose() {
    for (final leaf in _leaves) {
      leaf.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: _leaves.map((leaf) {
          return AnimatedBuilder(
            animation: leaf.controller,
            builder: (context, child) {
              final t = leaf.controller.value;
              final screenWidth = MediaQuery.of(context).size.width;
              final screenHeight = MediaQuery.of(context).size.height;

              // Y: từ -10% xuống 110% màn hình
              final y = -0.1 + t * 1.2;
              // X: drift nhẹ theo sin
              final x = leaf.startX + leaf.driftX * sin(t * pi * 2);
              // Xoay
              final rotation = t * leaf.rotations * pi;
              // Fade in/out ở đầu và cuối
              final opacity = t < 0.1
                  ? t / 0.1
                  : t > 0.9
                      ? (1 - t) / 0.1
                      : 1.0;

              return Positioned(
                left: x * screenWidth,
                top: y * screenHeight,
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Transform.rotate(
                    angle: rotation,
                    child: Text(
                      leaf.emoji,
                      style: TextStyle(fontSize: leaf.size),
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

class _LeafData {
  final AnimationController controller;
  final double startX;
  final double driftX;
  final double rotations;
  final double size;
  final String emoji;

  _LeafData({
    required this.controller,
    required this.startX,
    required this.driftX,
    required this.rotations,
    required this.size,
    required this.emoji,
  });
}
