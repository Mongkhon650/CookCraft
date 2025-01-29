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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.account_circle,
              size: 100,
              color: Colors.black,
            ),
            SizedBox(height: 16),
            Text(
              'คุณยังไม่ได้เข้าสู่ระบบ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'กรุณาเข้าสู่ระบบ',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
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
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ProfilePage()));
        },
      ),
      floatingActionButton: CustomFloatingButton(
        onPressed: _handleFloatingButtonPress,
      ),
    );
  }
}
