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
      // คำนวณตำแหน่งและขนาดของกรอบ Bounding Box
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

      // Debug: ตรวจสอบค่ากรอบ
      print("Drawing Box: x=$x, y=$y, width=$width, height=$height");

      // วาดกรอบ Bounding Box
      canvas.drawRect(rect, paint);

      // แสดง Confidence Score และชื่อวัตถุดิบ
      final confidence = (prediction["confidence"] as double) * 100; // เปลี่ยนความมั่นใจเป็นเปอร์เซ็นต์
      final className = prediction["class"]; // ชื่อของวัตถุดิบ
      final textPainter = TextPainter(
        text: TextSpan(
          text: "$className (${confidence.toStringAsFixed(1)}%)", // ชื่อ + ความมั่นใจ
          style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      // วาดข้อความที่ด้านบนของกรอบ
      textPainter.paint(canvas, Offset(x - width / 2, y - height / 2 - 16));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
