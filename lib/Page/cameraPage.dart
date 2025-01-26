import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cookcraft/Components/camera/image_handler.dart';
import 'package:cookcraft/Components/camera/image_processor.dart';
import 'package:cookcraft/Components/camera/bounding_box_painter.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImageHandler _imageHandler = ImageHandler();
  final ImageProcessor _imageProcessor = ImageProcessor();

  File? _image;
  bool _isLoading = false;
  List<Map<String, dynamic>> _predictions = [];
  List<String> _tags = [];
  double _imageWidth = 0;
  double _imageHeight = 0;

  Future<void> _captureImage() async {
    final image = await _imageHandler.captureImage();
    if (image != null) {
      setState(() {
        _image = image;
        _resetData();
      });
      await _processImage(image);
    }
  }

  Future<void> _pickImage() async {
    final image = await _imageHandler.pickImageFromGallery();
    if (image != null) {
      setState(() {
        _image = image;
        _resetData();
      });
      await _processImage(image);
    }
  }

  Future<void> _processImage(File image) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final result = await _imageProcessor.processImage(image);
      setState(() {
        _predictions = result["predictions"];
        _imageWidth = result["imageWidth"];
        _imageHeight = result["imageHeight"];
      });

      // แปลชื่อวัตถุดิบ
      final translatedTags = await _imageProcessor.translatePredictions(_predictions);
      setState(() {
        _tags = translatedTags;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetData() {
    _predictions = [];
    _imageWidth = 0;
    _imageHeight = 0;
    _tags = [];
  }

  void _confirmSelection() {
    Navigator.pop(context, _tags);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ถ่ายภาพวัตถุดิบ')),
      body: Column(
        children: [
          if (_image != null)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final displayWidth = constraints.maxWidth;
                  final displayHeight = constraints.maxHeight;

                  if (_imageWidth <= 0 || _imageHeight <= 0) {
                    return const Center(
                      child: Text(
                        "กำลังโหลดภาพ...",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }

                  final aspectRatio = _imageWidth / _imageHeight;
                  double scaledWidth, scaledHeight;

                  if (displayWidth / displayHeight > aspectRatio) {
                    scaledHeight = displayHeight;
                    scaledWidth = scaledHeight * aspectRatio;
                  } else {
                    scaledWidth = displayWidth;
                    scaledHeight = scaledWidth / aspectRatio;
                  }

                  return Center(
                    child: Stack(
                      children: [
                        SizedBox(
                          width: scaledWidth,
                          height: scaledHeight,
                          child: Image.file(_image!, fit: BoxFit.contain),
                        ),
                        if (_predictions.isNotEmpty)
                          CustomPaint(
                            size: Size(scaledWidth, scaledHeight),
                            painter: BoundingBoxPainter(
                              predictions: _predictions,
                              imageWidth: _imageWidth,
                              imageHeight: _imageHeight,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          if (_isLoading) const CircularProgressIndicator(),
          if (_tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "วัตถุดิบ: ${_tags.join(', ')}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(onPressed: _captureImage, child: const Text('ถ่ายภาพ')),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _pickImage, child: const Text('เลือกภาพจากแกลเลอรี่')),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _confirmSelection, child: const Text('ตกลง')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
