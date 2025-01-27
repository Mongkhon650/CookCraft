import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeDetailPage extends StatelessWidget {
  final String recipeId; // รับ ID ของสูตรอาหาร

  const RecipeDetailPage({
    Key? key,
    required this.recipeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cookcraft', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('Receipt').doc(recipeId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text("ไม่พบข้อมูลสูตรอาหาร", style: TextStyle(color: Colors.grey, fontSize: 16)),
            );
          }

          final recipeData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // แสดงรูปสูตรอาหาร
                recipeData['image_url'] != null
                    ? Image.network(
                  recipeData['image_url'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                )
                    : Container(
                  color: Colors.grey[300],
                  width: double.infinity,
                  height: 200,
                  child: const Center(child: Text("รูปสูตรอาหาร")),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ชื่อสูตรอาหาร
                      Text(
                        recipeData['name'] ?? "ไม่มีชื่อ",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      // ผู้สร้างสูตรอาหาร
                      Row(
                        children: [
                          const Icon(Icons.account_circle, size: 24, color: Colors.black),
                          const SizedBox(width: 8),
                          Text("ผู้ใช้ 001 @${recipeData['user_id'] ?? 'N/A'}"),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // เวลาที่ใช้ในการทำอาหาร
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 24, color: Colors.black),
                          const SizedBox(width: 8),
                          Text("เวลาในการทำอาหาร: ${recipeData['prep_time'] ?? 'N/A'}"),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // ส่วนผสม
                      const Text("ส่วนผสม", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...List.generate(
                        recipeData['ingredients'].length,
                            (index) => Text(
                          "- ${recipeData['ingredients'][index]}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // ขั้นตอนการทำ
                      const Text("วิธีทำ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...List.generate(
                        recipeData['steps'].length,
                            (index) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ขั้นตอนที่ ${recipeData['steps'][index]['step_number']}:",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              recipeData['steps'][index]['description'],
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
