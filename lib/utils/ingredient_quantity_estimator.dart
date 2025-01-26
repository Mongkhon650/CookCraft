import 'dart:convert';
import 'package:flutter/services.dart';

class IngredientQuantityEstimator {
  // โหลดข้อมูลหน่วยและประเภทการคำนวณจาก JSON
  Future<Map<String, dynamic>> loadIngredientUnits() async {
    final jsonString =
    await rootBundle.loadString('assets/ingredient_units.json');
    return jsonDecode(jsonString);
  }

  // คำนวณน้ำหนักวัตถุดิบโดยประมาณ
  double calculateWeight(double area, double density) {
    return area * density; // น้ำหนัก = พื้นที่ x ความหนาแน่น
  }

  // คำนวณจำนวนวัตถุดิบ เช่น ไข่
  int estimateCount(List<Map<String, dynamic>> predictions, String className) {
    return predictions.where((p) => p["class"] == className).length;
  }

  // คำนวณผลลัพธ์ทั้งหมด เช่น น้ำหนักและจำนวน
  Future<Map<String, dynamic>> estimateQuantities(
      List<Map<String, dynamic>> predictions,
      Map<String, double> densityMapping,
      ) async {
    final ingredientUnits = await loadIngredientUnits(); // โหลด JSON
    final quantities = <String, dynamic>{};

    for (var prediction in predictions) {
      final className = prediction["class"] ?? "";
      final width = prediction["width"] as double;
      final height = prediction["height"] as double;
      final area = width * height;

      if (ingredientUnits.containsKey(className)) {
        final calculate = List<String>.from(ingredientUnits[className]["calculate"] ?? []);
        final weightUnit = ingredientUnits[className]["unit"]?["weight"];
        final countUnit = ingredientUnits[className]["unit"]?["count"];

        // คำนวณน้ำหนักถ้าต้องการ
        double? weight;
        if (calculate.contains("weight") && densityMapping.containsKey(className)) {
          final density = densityMapping[className]!;
          weight = calculateWeight(area, density);
        }

        // คำนวณจำนวนถ้าต้องการ
        int? count;
        if (calculate.contains("count")) {
          count = estimateCount(predictions, className);
        }

        // เก็บผลลัพธ์ใน Map
        quantities[className] = {
          if (weight != null) "weight": {"value": weight, "unit": weightUnit},
          if (count != null) "count": {"value": count, "unit": countUnit},
        };
      }
    }
    return quantities;
  }
}
