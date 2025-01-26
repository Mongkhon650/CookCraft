import 'dart:convert';
import 'package:flutter/services.dart';

class JsonLoader {
  /// ฟังก์ชันสำหรับโหลดไฟล์ foodDictionary.json
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

  /// ฟังก์ชันสำหรับโหลดไฟล์ ingredient_units.json
  static Future<Map<String, dynamic>> loadIngredientUnits() async {
    final String jsonString =
    await rootBundle.loadString('assets/ingredient_units.json');
    return json.decode(jsonString);
  }

  /// ฟังก์ชันสำหรับดึงข้อมูลหน่วย (weight/count) จาก ingredient_units.json
  static Future<String?> getUnit(String ingredient, String type) async {
    final ingredientUnits = await loadIngredientUnits();
    return ingredientUnits[ingredient]?["unit"]?[type];
  }

  /// ฟังก์ชันสำหรับดึงสิ่งที่ต้องคำนวณ (weight/count) จาก ingredient_units.json
  static Future<List<String>> getCalculations(String ingredient) async {
    final ingredientUnits = await loadIngredientUnits();
    return List<String>.from(ingredientUnits[ingredient]?["calculate"] ?? []);
  }
}
