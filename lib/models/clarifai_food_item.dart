import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/json_food_loader.dart'; // นำเข้า JsonLoader

class FoodItemRecognition {
  static const String _apiKey = 'ffdd303949ff4cce9b135afd01ee3b82'; // ใส่ API Key ของคุณ
  static const String _url = 'https://api.clarifai.com/v2/models/food-item-recognition/outputs';

  static Future<List<Map<String, dynamic>>> analyzeImage(String base64Image) async {
    try {
      // โหลดคำแปลจาก JSON
      final translations = await JsonLoader.loadTranslations();

      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Authorization': 'Key $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "inputs": [
            {
              "data": {
                "image": {"base64": base64Image},
              },
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final concepts = data['outputs'][0]['data']['concepts'];
        return concepts.map<Map<String, dynamic>>((c) {
          final name = c['name'];
          final translatedName = translations[name] ?? name; // แปลชื่อวัตถุดิบ
          return {
            'name': translatedName,
            'confidence': (c['value'] * 100).toStringAsFixed(2)
          };
        }).toList();
      } else {
        throw Exception('Failed to analyze image: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }
}
