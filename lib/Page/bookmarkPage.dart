import 'package:cookcraft/Page/profilePage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Components/navigationBar.dart';
import '../Components/button/customFloatingButton.dart';
import 'cameraPage.dart';
import 'mainPage.dart';
import 'addReciepPage.dart';
import 'auth/login.dart';
import 'recipeDetailPage.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  int _currentIndex = 2;
  final List<String> _searchTags = [];
  final User? user = FirebaseAuth.instance.currentUser;

  void _addSearchTag(String tag) {
    if (tag.isNotEmpty && !_searchTags.contains(tag)) {
      setState(() {
        _searchTags.add(tag);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cookcraft',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
      ),
      body: user != null ? _buildBookmarkContent() : _buildLoginPrompt(),
      bottomNavigationBar: RecipeBottomNavigationBar(
        currentIndex: _currentIndex,
        onSearchPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        },
        onCameraPressed: () async {
          final List<String>? newTags = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CameraPage(),
            ),
          );
          if (newTags != null) {
            for (var tag in newTags) {
              _addSearchTag(tag);
            }
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainPage(searchTags: _searchTags),
              ),
            );
          }
        },
        onRecipePressed: () {
          setState(() {
            _currentIndex = 2;
          });
        },
        onProfilePressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        },
      ),
      floatingActionButton: user != null
          ? CustomFloatingButton(
        onPressed: _handleFloatingButtonPress,
      )
          : null, // ซ่อนปุ่มเพิ่มสูตรหากยังไม่ได้ล็อกอิน
    );
  }

  Widget _buildBookmarkContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'ค้นหาสูตรอาหารที่ถูกใจ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),

            // ✅ แสดง "สูตรอาหารของคุณ"
            const Text('สูตรอาหารของคุณ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildYourRecipes(), // ✅ เพิ่มส่วนนี้

            const SizedBox(height: 20),
            const Text('สูตรอาหารที่ถูกใจ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildBookmarkedRecipes(),

            const SizedBox(height: 20),
            const Text('สูตรอาหารที่ดูล่าสุด', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            _buildRecentRecipes(),
          ],
        ),
      ),
    );
  }

// ✅ เพิ่ม `สูตรอาหารของคุณ`
  Widget _buildYourRecipes() {
    if (user == null) return const Text("กรุณาเข้าสู่ระบบ");

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('my_recipes') // ✅ ใช้ `my_recipes`
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("ยังไม่มีสูตรอาหารของคุณ", style: TextStyle(color: Colors.grey));
        }

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: snapshot.data!.docs.map((doc) {
            final recipeId = doc.id;
            final recipeData = doc.data() as Map<String, dynamic>;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailPage(recipeId: recipeId),
                  ),
                );
              },
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: recipeData['image_url'] != null
                          ? DecorationImage(image: NetworkImage(recipeData['image_url']), fit: BoxFit.cover)
                          : null,
                      color: recipeData['image_url'] == null ? Colors.grey[300] : null,
                    ),
                    alignment: Alignment.center,
                    child: recipeData['image_url'] == null ? const Text("ไม่มีรูป", style: TextStyle(color: Colors.black)) : null,
                  ),
                  const SizedBox(height: 5),
                  Text(recipeData['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }


  /// 📌 **ดึงข้อมูลสูตรที่บันทึกไว้ แล้วให้สามารถกด "โพสต์" ได้**
  Widget _buildYourRecipeItem(String recipeId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('recipes').doc(recipeId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox();
        }

        final recipeData = snapshot.data!.data() as Map<String, dynamic>;
        final String recipeName = recipeData['name'] ?? 'ไม่มีชื่อ';
        final String imageUrl = recipeData['image_url'] ?? '';

        return ListTile(
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: imageUrl.isNotEmpty
                  ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                  : null,
              color: imageUrl.isEmpty ? Colors.grey[300] : null,
            ),
            alignment: Alignment.center,
            child: imageUrl.isEmpty ? const Icon(Icons.no_food, color: Colors.black54) : null,
          ),
          title: Text(recipeName),
          trailing: TextButton(
            child: const Text("โพสต์"),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('recipes').doc(recipeId).update({'published': true});
              await FirebaseFirestore.instance.collection('users').doc(user!.uid)
                  .collection('my_recipes')
                  .doc(recipeId)
                  .delete(); // ✅ ลบออกจาก "สูตรอาหารของคุณ"

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('สูตรอาหารถูกโพสต์แล้ว!')),
              );
            },
          ),
        );
      },
    );
  }


  /// 📌 **ดึง "สูตรอาหารที่ถูกใจ" จาก Firestore**
  Widget _buildBookmarkedRecipes() {
    return _buildRecipeList('bookmarks');
  }

  /// 📌 **ดึง "สูตรอาหารที่ดูล่าสุด" จาก Firestore**
  Widget _buildRecentRecipes() {
    return _buildRecipeList('recent_views', orderByTimestamp: true);
  }

  /// 📌 **ดึงข้อมูลสูตรอาหารจาก Firestore (รองรับทั้ง "ที่ถูกใจ" และ "ดูล่าสุด")**
  Widget _buildRecipeList(String collectionName, {bool orderByTimestamp = false}) {
    if (user == null) return const Text("กรุณาเข้าสู่ระบบ");

    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection(collectionName);

    if (orderByTimestamp) {
      query = query.orderBy('timestamp', descending: true);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("ไม่มีข้อมูล", style: TextStyle(color: Colors.grey));
        }

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: snapshot.data!.docs.map((doc) {
            final recipeId = doc['recipe_id'];
            return _buildRecipeItem(recipeId);
          }).toList(),
        );
      },
    );
  }

  /// 📌 **ดึงข้อมูลสูตรอาหารแต่ละรายการจาก Firestore และแสดงรูปภาพ**
  Widget _buildRecipeItem(String recipeId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('recipes').doc(recipeId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: 120,
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox();
        }

        final recipeData = snapshot.data!.data() as Map<String, dynamic>;
        final String recipeName = recipeData['name'] ?? 'ไม่มีชื่อ';
        final String imageUrl = recipeData['image_url'] ?? '';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetailPage(recipeId: recipeId),
              ),
            );
          },
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: imageUrl.isNotEmpty
                      ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                      : null,
                  color: imageUrl.isEmpty ? Colors.grey[300] : null,
                ),
                alignment: Alignment.center,
                child: imageUrl.isEmpty ? const Text("ไม่มีรูป", style: TextStyle(color: Colors.black)) : null,
              ),
              const SizedBox(height: 5),
              Text(recipeName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }

  /// 🛑 **ปุ่มลอย กดแล้วเพิ่มสูตรอาหารใหม่**
  void _handleFloatingButtonPress() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AddRecipePage()));
    }
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle, size: 100, color: Colors.black),
          const SizedBox(height: 16),
          const Text('คุณยังไม่ได้เข้าสู่ระบบ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
            child: const Text('เข้าสู่ระบบ'),
          ),
        ],
      ),
    );
  }
}
