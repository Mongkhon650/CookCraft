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
  bool isLoading = false;
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

  // เพิ่มฟังก์ชันสำหรับลบสูตรอาหาร
  Future<void> _deleteRecipe() async {
    // แสดง Dialog ยืนยันการลบ
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบสูตรอาหาร'),
        content: const Text('คุณแน่ใจหรือว่าต้องการลบสูตรอาหารนี้? การกระทำนี้ไม่สามารถย้อนกลับได้'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ลบสูตรอาหาร'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmDelete) return;

    setState(() {
      isLoading = true;
    });

    // แสดง Dialog กำลังดำเนินการ
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                const Text(
                  'กำลังลบสูตรอาหาร...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      // 1. ลบส่วนผสมที่เกี่ยวข้อง
      final ingredientsSnapshot = await FirebaseFirestore.instance
          .collection('ingredients')
          .where('recipe_id', isEqualTo: widget.recipeId)
          .get();

      for (var doc in ingredientsSnapshot.docs) {
        await doc.reference.delete();
      }

      // 2. ลบขั้นตอนที่เกี่ยวข้อง
      final stepsSnapshot = await FirebaseFirestore.instance
          .collection('steps')
          .where('recipe_id', isEqualTo: widget.recipeId)
          .get();

      for (var doc in stepsSnapshot.docs) {
        await doc.reference.delete();
      }

      // 3. ลบจากคอลเลกชัน bookmarks ของผู้ใช้ทุกคน
      // (เราไม่สามารถลบจาก bookmarks ของผู้ใช้ทุกคนได้โดยตรง
      // เพราะเราไม่รู้ว่าใครบ้างที่บุ๊กมาร์กสูตรนี้ไว้ แต่เราจะปล่อยให้เป็นการอ้างอิงที่ไม่มีข้อมูล)

      // 4. ลบสูตรอาหารหลัก
      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.recipeId)
          .delete();

      // ปิด Dialog
      Navigator.of(context).pop();

      // แสดงข้อความสำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ลบสูตรอาหารเรียบร้อยแล้ว'),
          backgroundColor: Colors.green,
        ),
      );

      // กลับไปหน้าก่อนหน้า
      Navigator.of(context).pop();
    } catch (e) {
      // ปิด Dialog
      Navigator.of(context).pop();

      print("เกิดข้อผิดพลาดในการลบสูตรอาหาร: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
              _showOptionsMenu(context);
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<DocumentSnapshot>(
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
          final bool isOwner = user != null && userId == user!.uid;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                recipeData['image_url'] != null && recipeData['image_url'].toString().isNotEmpty
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
                          if (!ingredientSnapshot.hasData || ingredientSnapshot.data!.docs.isEmpty) {
                            return const Text("ไม่พบข้อมูลส่วนผสม");
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
                          if (!stepsSnapshot.hasData || stepsSnapshot.data!.docs.isEmpty) {
                            return const Text("ไม่พบข้อมูลขั้นตอน");
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: stepsSnapshot.data!.docs.map((step) {
                              final stepData = step.data() as Map<String, dynamic>;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("ขั้นตอนที่ ${stepData['step_number']}: ${stepData['description']}"),
                                  if (stepData['image_url'] != null && stepData['image_url'].toString().isNotEmpty)
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

  void _showOptionsMenu(BuildContext context) {
    // ตรวจสอบว่าผู้ใช้เป็นเจ้าของสูตรอาหารหรือไม่
    FirebaseFirestore.instance
        .collection('recipes')
        .doc(widget.recipeId)
        .get()
        .then((recipeDoc) {
      if (recipeDoc.exists) {
        final recipeData = recipeDoc.data() as Map<String, dynamic>;
        final String recipeUserId = recipeData['user_id'] ?? '';
        final bool isOwner = user != null && recipeUserId == user!.uid;

        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Wrap(
              children: [
                // ถ้าเป็นเจ้าของสูตรอาหาร แสดงตัวเลือกลบสูตรอาหาร
                if (isOwner)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('ลบสูตรอาหาร'),
                    onTap: () {
                      Navigator.pop(context); // ปิด bottom sheet
                      _deleteRecipe(); // เรียกฟังก์ชันลบสูตรอาหาร
                    },
                  ),
                // แสดงตัวเลือกรายงานสูตรอาหารสำหรับทุกคน
                ListTile(
                  leading: const Icon(Icons.report, color: Colors.red),
                  title: const Text('รายงานสูตรอาหาร'),
                  onTap: () {
                    Navigator.pop(context);
                    _reportRecipe();
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }

  void _reportRecipe() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('รายงานสูตรอาหาร'),
        content: const Text('คุณต้องการรายงานสูตรอาหารนี้ด้วยเหตุผลใด?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              // บันทึกการรายงาน
              if (user != null) {
                FirebaseFirestore.instance.collection('reports').add({
                  'recipe_id': widget.recipeId,
                  'reporter_id': user!.uid,
                  'reason': 'ไม่เหมาะสม', // สามารถเพิ่มเหตุผลเพิ่มเติมได้
                  'timestamp': FieldValue.serverTimestamp(),
                });
              }
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ขอบคุณสำหรับการรายงาน')),
              );
            },
            child: const Text('รายงาน'),
          ),
        ],
      ),
    );
  }
}