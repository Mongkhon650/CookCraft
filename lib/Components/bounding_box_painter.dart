import 'package:flutter/material.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<dynamic> predictions;
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

    final textStyle = TextStyle(
      color: Colors.white,
      backgroundColor: Colors.red,
      fontSize: 12,
    );

    // คำนวณ Scale และ Offset
    final scaleX = size.width / imageWidth;
    final scaleY = size.height / imageHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    final offsetX = (size.width - (imageWidth * scale)) / 2;
    final offsetY = (size.height - (imageHeight * scale)) / 2;

    for (var prediction in predictions) {
      final x = (prediction["x"] as double) * scale + offsetX;
      final y = (prediction["y"] as double) * scale + offsetY;
      final width = (prediction["width"] as double) * scale;
      final height = (prediction["height"] as double) * scale;

      final rect = Rect.fromLTWH(
        x - width / 2,
        y - height / 2,
        width,
        height,
      );
      canvas.drawRect(rect, paint);

      final textSpan = TextSpan(
        text: '${prediction["class"]} ${(prediction["confidence"] * 100).toStringAsFixed(2)}%',
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(x - width / 2, y - height / 2 - 12));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
