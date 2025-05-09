import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cookcraft/Components/camera/image_handler.dart';
import 'package:cookcraft/Components/camera/image_processor.dart';
import 'package:cookcraft/Components/camera/bounding_box_painter.dart';
import 'package:cookcraft/utils/ingredient_quantity_estimator.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImageHandler _imageHandler = ImageHandler();
  final ImageProcessor _imageProcessor = ImageProcessor();
  final IngredientQuantityEstimator _quantityEstimator = IngredientQuantityEstimator();

  File? _image;
  bool _isLoading = false;
  String _loadingMessage = "กำลังประมวลผล..."; // เพิ่มตัวแปรนี้
  List<Map<String, dynamic>> _predictions = [];
  List<String> _tags = [];
  double _imageWidth = 0;
  double _imageHeight = 0;
  Map<String, dynamic> _quantities = {};

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
      _loadingMessage = "กำลังเตรียมรูปภาพ...";  // แสดงสถานะ
    });

    try {
      setState(() {
        _loadingMessage = "กำลังวิเคราะห์รูปภาพ...";
      });

      final result = await _imageProcessor.processImage(image);
      setState(() {
        _predictions = result["predictions"];
        _imageWidth = result["imageWidth"];
        _imageHeight = result["imageHeight"];
      });

      setState(() {
        _loadingMessage = "กำลังแปลผลลัพธ์...";
      });

      // แปลชื่อวัตถุดิบเป็นภาษาไทย
      final translatedTags = await _imageProcessor.translatePredictions(_predictions);
      setState(() {
        _tags = translatedTags;
      });

      // คำนวณปริมาณวัตถุดิบ
      final densityMapping = {
        "Egg": 0.02,
        "Garlic": 0.01,
        "Pork": 0.003,
      };
      final quantities = await _quantityEstimator.estimateQuantities(_predictions, densityMapping);

      // ใช้ `translatePredictions` แปลงคีย์ใน `_quantities` เป็นภาษาไทย
      final translatedKeys = await _imageProcessor.translatePredictions(
          quantities.keys.map((key) => {"class": key}).toList());
      final translatedQuantities = Map.fromIterables(translatedKeys, quantities.values);

      setState(() {
        _quantities = translatedQuantities;
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
    _quantities = {};
  }

  void _confirmSelection() {
    Navigator.pop(context, _tags); // ส่ง Tags กลับไปยัง MainPage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cookcraft', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_image == null) {
      // Step 1: เลือกภาพ
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _captureImage,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("ถ่ายภาพ",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("เลือกภาพจากแกลเลอรี่",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } else if (_isLoading) {
      // Step 2: กำลังประมวลผล
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              _loadingMessage,  // แสดงข้อความสถานะ
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    } else {
      // Step 3: แสดงผลวัตถุดิบและ Bounding Box
      return Column(
        children: [
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  "วัตถุดิบ: ${_tags.join(', ')}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                for (var entry in _quantities.entries)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${entry.key}:", // ชื่อวัตถุดิบที่แปลเป็นภาษาไทย
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (entry.value["weight"] != null)
                        Text(
                          "น้ำหนัก: ${entry.value["weight"]["value"].toStringAsFixed(2)} ${entry.value["weight"]["unit"]}",
                        ),
                      if (entry.value["count"] != null)
                        Text(
                          "จำนวน: ${entry.value["count"]["value"]} ${entry.value["count"]["unit"]}",
                        ),
                    ],
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _confirmSelection,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("ตกลง",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    }
  }
}