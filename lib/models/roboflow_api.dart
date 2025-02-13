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
  List<dynamic>? _predictions;
  int _imageWidth = 1; // ความกว้างของภาพที่ได้จาก API
  int _imageHeight = 1; // ความสูงของภาพที่ได้จาก API

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _predictions = null;
      });
      await _uploadImage(_image!);
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    const String apiUrl =
        "https://detect.roboflow.com/infer/workflows/cookcraft/ingredients-detect";
    const String apiKey = "5lWpmu1oPRR9oki4mJof";

    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final requestBody = json.encode({
        "api_key": apiKey,
        "inputs": {
          "image": {"type": "base64", "value": base64Image}
        }
      });

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final predictions = jsonResponse["outputs"][0]["predictions"]["predictions"];
        final imageInfo = jsonResponse["outputs"][0]["predictions"]["image"];

        setState(() {
          _predictions = predictions;
          _imageWidth = imageInfo["width"];
          _imageHeight = imageInfo["height"];
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception: $e");
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
                  // ขนาดที่แสดงผลจริง
                  final double displayedImageWidth = constraints.maxWidth;
                  final double displayedImageHeight = constraints.maxHeight;

                  // คำนวณสัดส่วนของภาพ
                  final double imageAspectRatio = _imageWidth / _imageHeight;
                  final double displayedAspectRatio =
                      displayedImageWidth / displayedImageHeight;

                  double scale = 1.0;
                  double offsetX = 0.0;
                  double offsetY = 0.0;

                  if (displayedAspectRatio > imageAspectRatio) {
                    // ช่องว่างแนวขวาง (ภาพมีขอบดำด้านข้าง)
                    scale = displayedImageHeight / _imageHeight;
                    offsetX = (displayedImageWidth - (_imageWidth * scale)) / 2;
                  } else {
                    // ช่องว่างแนวตั้ง (ภาพมีขอบดำด้านบน/ล่าง)
                    scale = displayedImageWidth / _imageWidth;
                    offsetY = (displayedImageHeight - (_imageHeight * scale)) / 2;
                  }

                  return Stack(
                    children: [
                      Center(
                        child: Image.file(
                          _image!,
                          fit: BoxFit.contain,
                          width: displayedImageWidth,
                          height: displayedImageHeight,
                        ),
                      ),
                      if (_predictions != null)
                        for (var prediction in _predictions!)
                          Positioned(
                            left: offsetX +
                                (prediction["x"] - prediction["width"] / 2) * scale,
                            top: offsetY +
                                (prediction["y"] - prediction["height"] / 2) * scale,
                            width: prediction["width"] * scale,
                            height: prediction["height"] * scale,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red, width: 2),
                              ),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  color: Colors.red,
                                  padding: EdgeInsets.symmetric(horizontal: 2),
                                  child: Text(
                                    '${prediction["class"]} ${(prediction["confidence"] * 100).toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
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
        ],
      ),
    );
  }
}
