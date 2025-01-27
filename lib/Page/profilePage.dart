import 'package:cookcraft/Page/bookmarkPage.dart';
import 'package:flutter/material.dart';
import '../Components/navigationBar.dart'; // Import Navigation Bar
import 'cameraPage.dart'; // ใช้ Camera Page
import 'mainPage.dart'; // Import Main Page

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 3;
  final List<String> _searchTags = []; // รายการแท็กที่ใช้ร่วมกันในหน้า

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
            Navigator.pop(context); // กลับไปหน้าก่อนหน้า
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
          Navigator.popUntil(context, (route) => route.isFirst); // กลับไปหน้า MainPage
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
              _addSearchTag(tag); // เพิ่มแท็กจาก CameraPage
            }
            // หลังเพิ่มแท็กเสร็จ กลับไปหน้า "ค้นหา"
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => MainPage(searchTags: _searchTags),
              ),
                  (route) => false, // ลบหน้าเก่าทั้งหมด
            );
          }
        },
        onRecipePressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => BookmarkPage()));
        },
        onProfilePressed: () {
          setState(() {
            _currentIndex = 3;
          });
        },
      ),
    );
  }
}
