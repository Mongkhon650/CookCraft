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
  bool _isLoading = false;

  // เพิ่มตัวแปรควบคุม Tab
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    print("Current user UID: ${user?.uid}");
  }

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
          : null,
    );
  }

  Widget _buildBookmarkContent() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'ค้นหาสูตรอาหาร',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),

        // แท็บควบคุมประเภทสูตรอาหาร
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: _buildTabButton(0, 'สูตรอาหารของฉัน'),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildTabButton(1, 'ที่ฉันโพสต์แล้ว'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // แสดงเนื้อหาตาม Tab ที่เลือก
        Expanded(
          child: _selectedTabIndex == 0
              ? _buildSavedRecipesTab()
              : _buildPublishedRecipesTab(),
        )
      ],
    );
  }

  // Widget สร้างปุ่ม Tab
  Widget _buildTabButton(int index, String title) {
    bool isSelected = _selectedTabIndex == index;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        elevation: isSelected ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(title),
    );
  }

  // Tab แสดงสูตรอาหารที่บันทึกแต่ยังไม่ได้โพสต์
  Widget _buildSavedRecipesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'สูตรอาหารที่บันทึกไว้',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildYourRecipes(),

          const SizedBox(height: 20),
          const Text(
            'สูตรอาหารที่ถูกใจ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildBookmarkedRecipes(),

          const SizedBox(height: 20),
          const Text(
            'สูตรอาหารที่ดูล่าสุด',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildRecentRecipes(),

          // ระยะห่างด้านล่าง
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // Tab แสดงสูตรอาหารที่โพสต์แล้ว
  Widget _buildPublishedRecipesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('recipes')
          .where('user_id', isEqualTo: user?.uid)
          .where('published', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'คุณยังไม่มีสูตรอาหารที่โพสต์',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'เพิ่มสูตรอาหารแล้วกดโพสต์เพื่อแชร์กับผู้อื่น',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'สูตรอาหารที่คุณโพสต์แล้ว (${snapshot.data!.docs.length})',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // แสดงสูตรอาหารที่โพสต์แล้ว
              GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final data = doc.data() as Map<String, dynamic>;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailPage(recipeId: doc.id),
                        ),
                      );
                    },
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // รูปภาพสูตรอาหาร
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                image: data['image_url'] != null && data['image_url'].toString().isNotEmpty
                                    ? DecorationImage(
                                  image: NetworkImage(data['image_url']),
                                  fit: BoxFit.cover,
                                )
                                    : null,
                                color: data['image_url'] == null || data['image_url'].toString().isEmpty
                                    ? Colors.grey[300]
                                    : null,
                              ),
                              child: data['image_url'] == null || data['image_url'].toString().isEmpty
                                  ? const Center(child: Icon(Icons.image_not_supported, color: Colors.grey))
                                  : null,
                            ),
                          ),

                          // ข้อมูลสูตรอาหาร
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['name'] ?? "ไม่มีชื่อ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'สำหรับ ${data['serving'] ?? "N/A"}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                    Text(
                                      data['prep_time'] ?? "N/A",
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // ระยะห่างด้านล่าง
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  // ✅ ปรับปรุงฟังก์ชัน `_buildYourRecipes`
  Widget _buildYourRecipes() {
    if (user == null) return const Text("กรุณาเข้าสู่ระบบ");

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('my_recipes') // ใช้ `my_recipes`
          .where('published', isEqualTo: false) // เฉพาะที่ยังไม่ได้โพสต์
          .snapshots(),
      builder: (context, snapshot) {
        print("สถานะการโหลด: ${snapshot.connectionState}");
        if (snapshot.hasData) {
          print("จำนวนสูตรที่พบ: ${snapshot.data!.docs.length}");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print("เกิดข้อผิดพลาด: ${snapshot.error}");
          return Text("เกิดข้อผิดพลาด: ${snapshot.error}");
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const Text("ยังไม่มีสูตรอาหารที่บันทึกไว้",
                  style: TextStyle(color: Colors.grey)
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddRecipePage())
                ).then((_) => setState(() {})),
                icon: const Icon(Icons.add),
                label: const Text("เพิ่มสูตรอาหารใหม่"),
              ),
            ],
          );
        }

        return GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final recipeData = doc.data() as Map<String, dynamic>;

            return GestureDetector(
              onTap: () {
                // สูตรที่บันทึกไว้แต่ยังไม่ได้โพสต์ ในส่วนนี้ต้องใช้การเข้าถึงแบบพิเศษ
                // อาจต้องสร้างหน้าแสดงรายละเอียดแยกหรือส่งพารามิเตอร์ว่าเป็นสูตรที่ยังไม่ได้โพสต์
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailPage(
                      recipeId: doc.id,
                      isPrivate: true, // เพิ่มพารามิเตอร์เพื่อบอกว่าเป็นสูตรส่วนตัว
                      collectionPath: 'users/${user!.uid}/my_recipes', // เส้นทางคอลเลกชัน
                    ),
                  ),
                );
              },
              child: Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // รูปภาพสูตรอาหาร
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: recipeData['image_url'] != null && recipeData['image_url'].toString().isNotEmpty
                                  ? DecorationImage(
                                image: NetworkImage(recipeData['image_url']),
                                fit: BoxFit.cover,
                              )
                                  : null,
                              color: recipeData['image_url'] == null || recipeData['image_url'].toString().isEmpty
                                  ? Colors.grey[300]
                                  : null,
                            ),
                            child: recipeData['image_url'] == null || recipeData['image_url'].toString().isEmpty
                                ? const Center(child: Icon(Icons.image_not_supported, color: Colors.grey))
                                : null,
                          ),

                          // แสดงสถานะว่าเป็นสูตรส่วนตัว
                          Positioned(
                            top: 5,
                            right: 5,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.lock, color: Colors.white, size: 12),
                                  SizedBox(width: 2),
                                  Text(
                                    'ส่วนตัว',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ข้อมูลสูตรอาหาร
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipeData['name'] ?? "ไม่มีชื่อ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // ปุ่มโพสต์
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () async {
                                await _publishRecipe(doc.id);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                minimumSize: Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                "โพสต์",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ฟังก์ชันโพสต์สูตรอาหาร
  Future<void> _publishRecipe(String recipeId) async {
    // แสดง Dialog ยืนยันการโพสต์
    bool confirmPublish = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการโพสต์'),
        content: const Text('คุณต้องการโพสต์สูตรอาหารนี้ให้ผู้อื่นเห็นใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('โพสต์เลย'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirmPublish) return;

    setState(() {
      _isLoading = true;
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
                  'กำลังโพสต์สูตรอาหาร...',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                const Text(
                  'กำลังย้ายข้อมูลไปยังพื้นที่สาธารณะ\nโปรดรอสักครู่',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      // 1. ดึงข้อมูลสูตรอาหารจาก my_recipes
      final recipeDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('my_recipes')
          .doc(recipeId)
          .get();

      if (!recipeDoc.exists) {
        // ปิด Dialog
        Navigator.of(context).pop();
        throw Exception("ไม่พบสูตรอาหาร");
      }

      final recipeData = recipeDoc.data() as Map<String, dynamic>;

      // 2. สร้างสูตรใหม่ใน recipes collection
      final newRecipeRef = await FirebaseFirestore.instance.collection('recipes').add({
        'name': recipeData['name'],
        'serving': recipeData['serving'],
        'prep_time': recipeData['prep_time'],
        'image_url': recipeData['image_url'] ?? '',
        'user_id': user!.uid,
        'published': true,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 3. ดึงส่วนผสมจาก my_recipes
      final ingredientsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('my_recipes')
          .doc(recipeId)
          .collection('ingredients')
          .get();

      // 4. เพิ่มส่วนผสมเข้าไปใน ingredients collection
      for (var doc in ingredientsSnapshot.docs) {
        final ingredientData = doc.data();
        await FirebaseFirestore.instance.collection('ingredients').add({
          'name': ingredientData['name'],
          'quantity': ingredientData['quantity'],
          'recipe_id': newRecipeRef.id,
        });
      }

      // 5. ดึงขั้นตอนจาก my_recipes
      final stepsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('my_recipes')
          .doc(recipeId)
          .collection('steps')
          .orderBy('step_number')
          .get();

      // 6. เพิ่มขั้นตอนเข้าไปใน steps collection
      for (var doc in stepsSnapshot.docs) {
        final stepData = doc.data();
        await FirebaseFirestore.instance.collection('steps').add({
          'description': stepData['description'],
          'image_url': stepData['image_url'] ?? '',
          'recipe_id': newRecipeRef.id,
          'step_number': stepData['step_number'],
        });
      }

      // 7. ลบสูตรจาก my_recipes (หรือเปลี่ยนสถานะเป็น published)
      // แทนที่จะลบ เราจะเปลี่ยนสถานะในคอลเลกชัน my_recipes ให้เป็น published = true
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('my_recipes')
          .doc(recipeId)
          .update({
        'published': true,
        'public_recipe_id': newRecipeRef.id, // เก็บ ID ของสูตรสาธารณะไว้อ้างอิง
      });

      // 8. บันทึกไว้ใน bookmarks ด้วย
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('bookmarks')
          .doc(newRecipeRef.id)
          .set({
        'recipe_id': newRecipeRef.id,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // ปิด Dialog
      Navigator.of(context).pop();

      // แสดงข้อความสำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('สูตรอาหารถูกโพสต์เรียบร้อยแล้ว'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // สลับไปที่แท็บสูตรที่โพสต์แล้ว
      setState(() {
        _selectedTabIndex = 1;
      });
    } catch (e) {
      print("เกิดข้อผิดพลาด: $e");

      // ปิด Dialog ถ้ามี
      Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// ดึง "สูตรอาหารที่ถูกใจ" จาก Firestore
  Widget _buildBookmarkedRecipes() {
    return _buildRecipeList('bookmarks');
  }

  /// ดึง "สูตรอาหารที่ดูล่าสุด" จาก Firestore
  Widget _buildRecentRecipes() {
    return _buildRecipeList('recent_views', orderByTimestamp: true);
  }

  /// ดึงข้อมูลสูตรอาหารจาก Firestore (รองรับทั้ง "ที่ถูกใจ" และ "ดูล่าสุด")
  Widget _buildRecipeList(String collectionName, {bool orderByTimestamp = false}) {
    if (user == null) return const Text("กรุณาเข้าสู่ระบบ");

    Query query = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection(collectionName);

    if (orderByTimestamp) {
      query = query.orderBy('timestamp', descending: true).limit(5); // จำกัดจำนวนที่แสดง
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

        return SizedBox(
          height: 160, // กำหนดความสูงคงที่
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final recipeId = doc['recipe_id'];
              return _buildRecipeItem(recipeId);
            },
          ),
        );
      },
    );
  }


  /// ดึงข้อมูลสูตรอาหารแต่ละรายการจาก Firestore และแสดงรูปภาพ
  Widget _buildRecipeItem(String recipeId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('recipes').doc(recipeId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: 120,
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
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
          child: Container(
            width: 120,
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // รูปภาพ
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    image: imageUrl.isNotEmpty
                        ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                        : null,
                    color: imageUrl.isEmpty ? Colors.grey[300] : null,
                  ),
                  alignment: Alignment.center,
                  child: imageUrl.isEmpty
                      ? const Icon(Icons.image_not_supported, color: Colors.black45)
                      : null,
                ),
                // ชื่อสูตร
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      recipeName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ปุ่มลอย กดแล้วเพิ่มสูตรอาหารใหม่
  void _handleFloatingButtonPress() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddRecipePage())
      ).then((_) {
        // รีเฟรชหน้าจอเมื่อกลับมา
        setState(() {});
      });
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