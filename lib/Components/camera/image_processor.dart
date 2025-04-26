import 'dart:io';
import 'package:cookcraft/utils/json_food_loader.dart';
import 'package:cookcraft/models/ingredients_detect.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as p;

class ImageProcessor {
  // เพิ่มฟังก์ชัน compress รูปภาพ
  Future<File> compressAndResizeImage(File imageFile) async {
    // กำหนดความกว้างและความสูงสูงสุด (640x640 เป็นขนาดที่เหมาะสมสำหรับหลาย model)
    final maxWidth = 640;
    final maxHeight = 640;

    // สร้างไฟล์ปลายทางสำหรับรูปที่บีบอัดแล้ว
    final dir = await path_provider.getTemporaryDirectory();
    final targetPath = p.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');

    // บีบอัดและปรับขนาดรูปภาพ
    final result = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      targetPath,
      quality: 85,       // คุณภาพของการบีบอัด (0-100)
      minWidth: 640,     // ความกว้างขั้นต่ำ
      minHeight: 640,    // ความสูงขั้นต่ำ
    );

    // ตรวจสอบและแปลงผลลัพธ์เป็น File
    return result != null ? File(result.path) : imageFile;
  }

  // ปรับปรุงฟังก์ชัน processImage
  Future<Map<String, dynamic>> processImage(File imageFile) async {
    try {
      // บีบอัดและปรับขนาดรูปภาพก่อนส่งไปยัง API
      final compressedImage = await compressAndResizeImage(imageFile);

      // ประมวลผลภาพด้วย API
      final analysisResult = await IngredientsDetect.analyzeImage(compressedImage.path);

      // ใช้ข้อมูลจากภาพต้นฉบับหาก API ไม่ได้ส่งขนาดมา
      final decodedImage = await decodeImageFromList(compressedImage.readAsBytesSync());
      final realImageWidth = decodedImage.width.toDouble();
      final realImageHeight = decodedImage.height.toDouble();

      final predictions = List<Map<String, dynamic>>.from(analysisResult["predictions"]);
      return {
        "predictions": predictions,
        "imageWidth": analysisResult["imageWidth"]?.toDouble() ?? realImageWidth,
        "imageHeight": analysisResult["imageHeight"]?.toDouble() ?? realImageHeight,
      };
    } catch (e) {
      throw Exception("Error processing image: $e");
    }
  }

  Future<List<String>> translatePredictions(List<Map<String, dynamic>> predictions) async {
    List<String> translatedTags = [];
    for (var prediction in predictions) {
      final detectedClass = prediction["class"] ?? "";
      final translatedClass = await JsonLoader.translateIngredient(detectedClass) ?? detectedClass;
      if (!translatedTags.contains(translatedClass)) {
        translatedTags.add(translatedClass);
      }
    }
    return translatedTags;
  }
}