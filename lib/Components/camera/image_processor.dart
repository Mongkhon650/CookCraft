import 'dart:io';
import 'package:cookcraft/utils/json_food_loader.dart';
import 'package:cookcraft/models/ingredients_detect.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ImageProcessor {
  Future<Map<String, dynamic>> processImage(File imageFile) async {
    try {
      // ประมวลผลภาพด้วย API
      final analysisResult = await IngredientsDetect.analyzeImage(imageFile.path);

      // ใช้ข้อมูลจากภาพต้นฉบับหาก API ไม่ได้ส่งขนาดมา
      final decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
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
