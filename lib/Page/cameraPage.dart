import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/clarifai_food_item.dart'; // ดึง FoodItemRecognition มาใช้

class CameraPage extends StatefulWidget {
  final Function(String) onAddTag; // รับฟังก์ชันจาก MainPage

  const CameraPage({Key? key, required this.onAddTag}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File? _image;
  List<Map<String, dynamic>>? _concepts;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _concepts = null;
      });
      await _processImage(pickedFile.path);
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _concepts = null;
      });
      await _processImage(pickedFile.path);
    }
  }

  Future<void> _processImage(String imagePath) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final imageBytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // ใช้ FoodItemRecognition API
      final concepts = await FoodItemRecognition.analyzeImage(base64Image);

      // คัดเฉพาะวัตถุดิบที่มั่นใจ > 70%
      final highConfidenceConcepts = concepts.where((c) {
        return double.parse(c['confidence']) > 70.0; // ตั้งเงื่อนไขความมั่นใจ
      }).toList();

      if (highConfidenceConcepts.isNotEmpty) {
        // ส่งชื่อวัตถุดิบที่มั่นใจที่สุดไปยัง MainPage
        widget.onAddTag(highConfidenceConcepts[0]['name']);

        // กลับไปยัง MainPage
        Navigator.pop(context);
      } else {
        // หากไม่เจอวัตถุดิบที่มั่นใจ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No confident ingredients detected!')),
        );
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('กล้องและแกลเลอรี่'),
        backgroundColor: Colors.pink,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_image != null) Image.file(_image!, height: 200),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _pickImageFromCamera,
                child: const Text('ถ่ายภาพ'),
              ),
              ElevatedButton(
                onPressed: _pickImageFromGallery,
                child: const Text('เลือกจากแกลเลอรี่'),
              ),
            ],
          ),
          if (_isLoading) const CircularProgressIndicator(),
          if (_concepts != null)
            Expanded(
              child: ListView.builder(
                itemCount: _concepts!.length,
                itemBuilder: (context, index) {
                  final concept = _concepts![index];
                  return Card(
                    child: ListTile(
                      title: Text(concept['name']), // แสดงชื่อวัตถุดิบที่แปลแล้ว
                      subtitle: Text('Confidence: ${concept['confidence']}%'),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
