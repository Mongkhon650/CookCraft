import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class IngredientsDetect {
  static const String apiUrl = "https://detect.roboflow.com/infer/workflows/cookcraft/ingredients-detect";
  static const String apiKey = "5lWpmu1oPRR9oki4mJof";

  static Future<Map<String, dynamic>> analyzeImage(String imagePath) async {
    try {
      // อ่านไฟล์ภาพ
      final bytes = await File(imagePath).readAsBytes();

      // เริ่มวัดเวลา (สำหรับการ debug)
      final startTime = DateTime.now();

      // แปลงเป็น base64
      final base64Image = base64Encode(bytes);

      print("Image size: ${bytes.length / 1024} KB");

      final requestBody = json.encode({
        "api_key": apiKey,
        "inputs": {
          "image": {"type": "base64", "value": base64Image}
        }
      });

      // ส่งคำขอไปยัง API
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: requestBody,
      );

      // คำนวณเวลาที่ใช้ไป
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print("API request took: ${duration.inMilliseconds} ms");

      if (response.statusCode == 200) {
        return json.decode(response.body)["outputs"][0]["predictions"];
      } else {
        throw Exception("Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("API Error: $e");
    }
  }
}