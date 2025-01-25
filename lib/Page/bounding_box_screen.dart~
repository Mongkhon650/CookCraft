import 'dart:io';
import 'package:flutter/material.dart';
import '/Components/bounding_box_painter.dart';

class BoundingBoxScreen extends StatelessWidget {
  final String imagePath;
  final List<dynamic> predictions;
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
            return Stack(
              children: [
                Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                ),
                CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: BoundingBoxPainter(
                    predictions: predictions,
                    imageWidth: imageWidth,
                    imageHeight: imageHeight,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
