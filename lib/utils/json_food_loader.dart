import 'dart:convert';
import 'package:flutter/services.dart';

class JsonLoader {
  /// ฟังก์ชันสำหรับโหลดไฟล์ JSON
  static Future<Map<String, String>> loadTranslations() async {
    final String jsonString =
    await rootBundle.loadString('assets/foodDictionary.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((key, value) => MapEntry(key, value.toString()));
  }
}
