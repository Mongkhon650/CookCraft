import 'package:flutter/material.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<Map<String, dynamic>> predictions;
  final double imageWidth;
  final double imageHeight;

  BoundingBoxPainter({
    required this.predictions,
    required this.imageWidth,
    required this.imageHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final scaleX = size.width / imageWidth;
    final scaleY = size.height / imageHeight;

    for (var prediction in predictions) {
      final x = (prediction["x"] as double) * scaleX;
      final y = (prediction["y"] as double) * scaleY;
      final width = (prediction["width"] as double) * scaleX;
      final height = (prediction["height"] as double) * scaleY;

      final rect = Rect.fromLTWH(
        x - width / 2,
        y - height / 2,
        width,
        height,
      );

      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
