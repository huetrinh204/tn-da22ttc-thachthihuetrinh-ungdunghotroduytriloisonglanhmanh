import 'dart:ui' as ui;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageDotPainter extends FlDotPainter {
  final ui.Image? image;
  final double size;

  ImageDotPainter({
    this.image,
    this.size = 20,
  });

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offsetInCanvas) {
    if (image == null) {
      // Fallback to circle if image not loaded
      final paint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.fill;
      canvas.drawCircle(offsetInCanvas, size / 2, paint);
      return;
    }

    // Draw image centered at the dot position
    final srcRect = Rect.fromLTWH(
      0,
      0,
      image!.width.toDouble(),
      image!.height.toDouble(),
    );
    
    final dstRect = Rect.fromCenter(
      center: offsetInCanvas,
      width: size,
      height: size,
    );

    canvas.drawImageRect(image!, srcRect, dstRect, Paint());
  }

  @override
  Size getSize(FlSpot spot) {
    return Size(size, size);
  }

  @override
  Color get mainColor => Colors.green;

  @override
  List<Object?> get props => [image, size];

  @override
  FlDotPainter lerp(FlDotPainter a, FlDotPainter b, double t) {
    return this;
  }

  // Static method to load image from assets
  static Future<ui.Image> loadImageFromAssets(String path) async {
    final ByteData data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 40, // Pre-scale for performance
      targetHeight: 40,
    );
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}
