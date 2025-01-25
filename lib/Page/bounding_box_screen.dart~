import 'dart:io';
import 'package:flutter/material.dart';
import '/Components/bounding_box_painter.dart';

class BoundingBoxScreen extends StatelessWidget {
  final String imagePath;
  final List<Map<String, dynamic>> predictions;
  final double imageWidth;
  final double imageHeight;

  const BoundingBoxScreen({
    Key? key,
    required this.imagePath,
    required this.predictions,
    required this.imageWidth,
    required this.imageHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ผลลัพธ์การตรวจจับวัตถุดิบ')),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final displayWidth = constraints.maxWidth;
            final displayHeight = constraints.maxHeight;

            // คำนวณ Scale
            final scale = (displayWidth / imageWidth < displayHeight / imageHeight)
                ? displayWidth / imageWidth
                : displayHeight / imageHeight;

            final scaledWidth = imageWidth * scale;
            final scaledHeight = imageHeight * scale;

            return Center(
              child: Stack(
                children: [
                  SizedBox(
                    width: scaledWidth,
                    height: scaledHeight,
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(
                    width: scaledWidth,
                    height: scaledHeight,
                    child: CustomPaint(
                      painter: BoundingBoxPainter(
                        predictions: predictions,
                        imageWidth: imageWidth,
                        imageHeight: imageHeight,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
