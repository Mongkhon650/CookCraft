import 'package:cookcraft/Page/profilePage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Components/navigationBar.dart';
import '../Components/button/customFloatingButton.dart';
import 'cameraPage.dart';
import 'mainPage.dart';
import 'addReciepPage.dart';
import 'auth/login.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  int _currentIndex = 2;
  final List<String> _searchTags = [];

  void _addSearchTag(String tag) {
    if (tag.isNotEmpty && !_searchTags.contains(tag)) {
      setState(() {
        _searchTags.add(tag);
      });
    }
  }

  void _removeSearchTag(String tag) {
    setState(() {
      _searchTags.remove(tag);
    });
  }

  void _handleFloatingButtonPress() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("🔴 ผู้ใช้ยังไม่ได้ล็อกอิน พาไปหน้า LoginPage");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()), // พาไปหน้า Login ก่อน
      );
    } else {
      debugPrint("🟢 ผู้ใช้ล็อกอินแล้ว พาไปหน้า AddRecipePage");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddRecipePage()), // ถ้าล็อกอินแล้วไปหน้าเพิ่มสูตร
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cookcraft',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: user != null ? _buildBookmarkContent() : _buildLoginPrompt(),
      bottomNavigationBar: RecipeBottomNavigationBar(
        currentIndex: _currentIndex,
        onSearchPressed: () {
          setState(() {
            _currentIndex = 0;
          });
          Navigator.popUntil(context, (route) => route.isFirst);
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
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => MainPage(searchTags: _searchTags),
              ),
                  (route) => false,
            );
          }
        },
        onRecipePressed: () {
          setState(() {
            _currentIndex = 2;
          });
        },
        onProfilePressed: () {
          Navigator.push(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'สูตรอาหารที่ถูกใจ',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),
          const Text('สูตรอาหารที่ถูกใจ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(4, (index) => _buildRecipeCard()),
          ),
          const SizedBox(height: 20),
          const Text('สูตรอาหารที่ล่าสุด', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          _buildRecipeCard(),
        ],
      ),
    );
  }

  Widget _buildRecipeCard() {
    return Container(
      width: 100,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Text(
        'สูตรอาหาร',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_circle,
            size: 100,
            color: Colors.black,
          ),
          const SizedBox(height: 16),
          const Text(
            'คุณยังไม่ได้เข้าสู่ระบบ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'กรุณาเข้าสู่ระบบ',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              ).then((_) {
                setState(() {}); // รีโหลดหน้าเมื่อกลับมาจากล็อกอิน
              });
            },
            child: const Text('เข้าสู่ระบบ'),
          ),
        ],
      ),
    );
  }
}
