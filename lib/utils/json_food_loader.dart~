import 'dart:convert';
import 'package:flutter/services.dart';

class JsonLoader {
  /// ฟังก์ชันสำหรับโหลดไฟล์ JSON
  static Future<Map<String, String>> loadTranslations() async {
    final String jsonString =
    await rootBundle.loadString('assets/foodDictionary.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    // เปลี่ยนคีย์ทั้งหมดใน JSON เป็นตัวพิมพ์เล็ก
    return jsonData.map((key, value) => MapEntry(key.toLowerCase(), value.toString()));
  }

  /// ฟังก์ชันสำหรับแปลชื่อวัตถุดิบ
  static Future<String?> translateIngredient(String ingredient) async {
    final translations = await loadTranslations();
    // เปรียบเทียบโดยไม่สนใจตัวพิมพ์ใหญ่พิมพ์เล็ก
    return translations[ingredient.toLowerCase()];
  }
}
