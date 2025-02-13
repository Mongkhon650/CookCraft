import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecipeDetailPage extends StatefulWidget {
  final String recipeId;

  const RecipeDetailPage({
    Key? key,
    required this.recipeId,
  }) : super(key: key);

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  bool isBookmarked = false;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _checkIfBookmarked();
    _saveToRecentViews(widget.recipeId);
  }

  void _checkIfBookmarked() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('bookmarks')
        .doc(widget.recipeId)
        .get();
    if (doc.exists) {
      setState(() {
        isBookmarked = true;
      });
    }
  }

  void _toggleBookmark() async {
    if (user == null) return;
    final bookmarkRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('bookmarks')
        .doc(widget.recipeId);

    if (isBookmarked) {
      await bookmarkRef.delete();
    } else {
      await bookmarkRef.set({'recipe_id': widget.recipeId});
    }
    setState(() {
      isBookmarked = !isBookmarked;
    });
  }

  void _saveToRecentViews(String recipeId) async {
    if (user == null) return;

    final recentRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('recent_views')
        .doc(recipeId);

    await recentRef.set({
      'recipe_id': recipeId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
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
        actions: [
          IconButton(
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: _toggleBookmark,
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              _showReportMenu(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('recipes').doc(widget.recipeId).get(),
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
          final String userId = recipeData['user_id'] ?? '';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                recipeData['image_url'] != null
                    ? Image.network(recipeData['image_url'], width: double.infinity, height: 200, fit: BoxFit.cover)
                    : Container(
                  color: Colors.grey[300],
                  width: double.infinity,
                  height: 200,
                  child: const Center(child: Text("ไม่มีรูปภาพสูตรอาหาร")),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              recipeData['name'] ?? "ไม่มีชื่อ",
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                            onPressed: _toggleBookmark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return const Text("กำลังโหลดข้อมูลผู้ใช้...");
                          }
                          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                            return const Text("โพสต์โดย: ไม่ระบุ");
                          }
                          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                          final String displayName = userData['display_name'] ?? "ไม่ระบุ";

                          return Row(
                            children: [
                              const Icon(Icons.account_circle, size: 24, color: Colors.black),
                              const SizedBox(width: 8),
                              Text("โพสต์โดย: $displayName"),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 24, color: Colors.black),
                          const SizedBox(width: 8),
                          Text("เวลาในการทำ: ${recipeData['prep_time'] ?? 'N/A'}"),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(Icons.people, size: 24, color: Colors.black),
                          const SizedBox(width: 8),
                          Text("เสิร์ฟ: ${recipeData['serving'] ?? 'ไม่ระบุ'}"),
                        ],
                      ),
                      const SizedBox(height: 16),

                      const Text("ส่วนผสม", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance.collection('ingredients').where('recipe_id', isEqualTo: widget.recipeId).get(),
                        builder: (context, ingredientSnapshot) {
                          if (ingredientSnapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: ingredientSnapshot.data!.docs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return Text("- ${data['name']} ${data['quantity']['amount']} ${data['quantity']['unit']}");
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      const Text("วิธีทำ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance.collection('steps').where('recipe_id', isEqualTo: widget.recipeId).orderBy('step_number').get(),
                        builder: (context, stepsSnapshot) {
                          if (stepsSnapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: stepsSnapshot.data!.docs.map((step) {
                              final stepData = step.data() as Map<String, dynamic>;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("ขั้นตอนที่ ${stepData['step_number']}: ${stepData['description']}"),
                                  if (stepData['image_url'] != null && stepData['image_url'].isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Image.network(stepData['image_url']),
                                    ),
                                ],
                              );
                            }).toList(),
                          );
                        },
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

  void _showReportMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.report, color: Colors.red),
              title: Text('รายงานสูตรอาหาร'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
