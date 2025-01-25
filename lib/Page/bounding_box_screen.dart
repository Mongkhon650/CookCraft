import 'dart:io';
import 'package:flutter/material.dart';
import '../Components/bounding_box_painter.dart';

class BoundingBoxScreen extends StatelessWidget {
  final String imagePath;
  final List<Map<String, dynamic>> predictions;

  const BoundingBoxScreen({Key? key, required this.imagePath, required this.predictions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bounding Box')),
      body: Center(
        child: Stack(
          children: [
            Image.file(File(imagePath)),
            CustomPaint(
              size: Size.infinite,
              painter: BoundingBoxPainter(predictions),
            ),
          ],
        ),
      ),
    );
  }
}
