import 'package:flutter/material.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<Map<String, dynamic>> predictions;

  BoundingBoxPainter(this.predictions);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (var prediction in predictions) {
      final x = prediction["x"];
      final y = prediction["y"];
      final width = prediction["width"];
      final height = prediction["height"];

      final rect = Rect.fromLTWH(
        x - width / 2,
        y - height / 2,
        width,
        height,
      );

      canvas.drawRect(rect, paint);

      final textPainter = TextPainter(
        text: TextSpan(
          text:
          '${prediction["class"]} ${(prediction["confidence"] * 100).toStringAsFixed(2)}%',
          style: TextStyle(
            color: Colors.white,
            backgroundColor: Colors.red,
            fontSize: 12,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - width / 2, y - height / 2 - 15));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
