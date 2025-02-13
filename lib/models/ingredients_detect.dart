import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class IngredientsDetect {
  static const String apiUrl = "https://detect.roboflow.com/infer/workflows/cookcraft/ingredients-detect";
  static const String apiKey = "5lWpmu1oPRR9oki4mJof";

  static Future<Map<String, dynamic>> analyzeImage(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(bytes);

      final requestBody = json.encode({
        "api_key": apiKey,
        "inputs": {
          "image": {"type": "base64", "value": base64Image}
        }
      });

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body)["outputs"][0]["predictions"];
      } else {
        throw Exception("Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("API Error: $e");
    }
  }
}
