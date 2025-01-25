import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class RoboflowAPIPage extends StatefulWidget {
  @override
  _RoboflowAPIPageState createState() => _RoboflowAPIPageState();
}

class _RoboflowAPIPageState extends State<RoboflowAPIPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  List<dynamic>? _predictions; // เก็บผลลัพธ์ Bounding Box และข้อมูลวัตถุ
  int _imageWidth = 1; // ความกว้างของภาพที่โหลด
  int _imageHeight = 1; // ความสูงของภาพที่โหลด

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _predictions = null; // รีเซ็ตผลลัพธ์
      });
      await _uploadImage(_image!);
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    const String apiUrl =
        "https://detect.roboflow.com/infer/workflows/cookcraft/custom-workflow-2";
    const String apiKey = "5lWpmu1oPRR9oki4mJof"; // ใส่ API key ของคุณ

    try {
      print("Starting API request...");
      print("File path: ${imageFile.path}");

      // อ่านไฟล์และแปลงเป็น Base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // สร้าง body ของคำร้อง (JSON)
      final requestBody = json.encode({
        "api_key": apiKey,
        "inputs": {
          "image": {"type": "base64", "value": base64Image}
        }
      });

      // ส่งคำร้อง
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // ดึงข้อมูลการทำนาย
        final predictions = jsonResponse["outputs"][0]["predictions"]["predictions"];
        final imageInfo = jsonResponse["outputs"][0]["predictions"]["image"];

        print("Detection Results: $predictions");

        setState(() {
          _predictions = predictions;
          _imageWidth = imageInfo["width"];
          _imageHeight = imageInfo["height"];
        });
      } else {
        print("Error: ${response.statusCode}");
        print("Error response: ${response.body}");
        setState(() {
          _predictions = [
            {"error": "Error: ${response.statusCode} - ${response.body}"}
          ];
        });
      }
    } catch (e) {
      print("Exception: $e");
      setState(() {
        _predictions = [
          {"error": "Exception: $e"}
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Roboflow API"),
      ),
      body: Column(
        children: [
          if (_image != null)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // สัดส่วนของภาพที่แสดงบนหน้าจอ
                  final double displayedImageWidth = constraints.maxWidth;
                  final double displayedImageHeight = constraints.maxHeight;

                  // อัตราส่วนสเกลสำหรับปรับ bounding box
                  final double scaleX = displayedImageWidth / _imageWidth;
                  final double scaleY = displayedImageHeight / _imageHeight;

                  return Stack(
                    children: [
                      Image.file(_image!, fit: BoxFit.contain, width: double.infinity),
                      if (_predictions != null)
                        for (var prediction in _predictions!)
                          Positioned(
                            left: (prediction["x"] - prediction["width"] / 2) * scaleX,
                            top: (prediction["y"] - prediction["height"] / 2) * scaleY,
                            width: prediction["width"] * scaleX,
                            height: prediction["height"] * scaleY,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red, width: 2),
                              ),
                              child: SingleChildScrollView(
                                child: Text(
                                  '${prediction["class"]} ${(prediction["confidence"] * 100).toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    color: Colors.white,
                                    backgroundColor: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ],
                  );
                },
              ),
            ),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text("Select Image"),
          ),
          if (_predictions != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Text(
                  "Detection Results: ${_predictions.toString()}",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
