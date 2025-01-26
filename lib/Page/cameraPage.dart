import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/ingredients_detect.dart';
import '../utils/json_food_loader.dart';
import 'package:cookcraft/Components/bounding_box_painter.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File? _image;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  final List<String> _tags = [];
  List<Map<String, dynamic>> _predictions = [];
  double _imageWidth = 0;
  double _imageHeight = 0;

  Future<void> _captureImageWithCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);

        // รีเซ็ตค่าที่เกี่ยวข้องกับ Bounding Box
        _predictions = [];
        _imageWidth = 0;
        _imageHeight = 0;
      });
      await _processImage(_image!.path);
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);

        // รีเซ็ตค่าที่เกี่ยวข้องกับ Bounding Box
        _predictions = [];
        _imageWidth = 0;
        _imageHeight = 0;
      });
      await _processImage(_image!.path);
    }
  }


  Future<void> _processImage(String imagePath) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final analysisResult = await IngredientsDetect.analyzeImage(imagePath);

      // ใช้ข้อมูลจากภาพต้นฉบับหาก API ไม่ได้ส่งขนาดมา
      final decodedImage = await decodeImageFromList(File(imagePath).readAsBytesSync());
      final realImageWidth = decodedImage.width.toDouble();
      final realImageHeight = decodedImage.height.toDouble();

      setState(() {
        _predictions = List<Map<String, dynamic>>.from(analysisResult["predictions"]);
        _imageWidth = analysisResult["imageWidth"]?.toDouble() ?? realImageWidth;
        _imageHeight = analysisResult["imageHeight"]?.toDouble() ?? realImageHeight;

        // อัปเดต `_tags` ด้วยชื่อวัตถุดิบ (แปลเป็นภาษาไทย)
        _tags.clear(); // รีเซ็ตก่อนเพิ่มใหม่
      });

      // แปลชื่อวัตถุดิบ
      for (var prediction in _predictions) {
        final detectedClass = prediction["class"] ?? "";
        final translatedClass = await JsonLoader.translateIngredient(detectedClass) ?? detectedClass;

        if (!_tags.contains(translatedClass)) {
          setState(() {
            _tags.add(translatedClass); // เพิ่มชื่อที่แปลแล้วใน `_tags`
          });
        }
      }

      // Debug: ตรวจสอบ `_tags`
      print("Tags: $_tags");
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

  void _confirmSelection() {
    Navigator.pop(context, _tags); // ส่ง Tags กลับไปยัง MainPage
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
                    // หากขนาดภาพยังไม่ได้ตั้งค่า ให้แสดงข้อความหรือเว้นว่างไว้
                    return Center(
                      child: Text(
                        "กำลังโหลดภาพ...",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }

                  // คำนวณสัดส่วนของภาพที่จะแสดงในจอ
                  final aspectRatio = _imageWidth / _imageHeight;
                  double scaledWidth, scaledHeight;

                  if (displayWidth / displayHeight > aspectRatio) {
                    scaledHeight = displayHeight;
                    scaledWidth = scaledHeight * aspectRatio;
                  } else {
                    scaledWidth = displayWidth;
                    scaledHeight = scaledWidth / aspectRatio;
                  }

                  final scaleX = scaledWidth / _imageWidth;
                  final scaleY = scaledHeight / _imageHeight;

                  // Debug: แสดงค่าขนาดและสเกล
                  print("ScaledWidth: $scaledWidth, ScaledHeight: $scaledHeight");
                  print("ScaleX: $scaleX, ScaleY: $scaleY");

                  return Center(
                    child: Stack(
                      children: [
                        SizedBox(
                          width: scaledWidth,
                          height: scaledHeight,
                          child: Image.file(
                            _image!,
                            fit: BoxFit.contain,
                          ),
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
                  ElevatedButton(
                    onPressed: _captureImageWithCamera,
                    child: const Text('ถ่ายภาพ'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _pickImageFromGallery,
                    child: const Text('เลือกภาพจากแกลเลอรี่'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _confirmSelection,
                    child: const Text('ตกลง'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
