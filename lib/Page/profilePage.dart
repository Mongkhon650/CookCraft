import 'package:cookcraft/Page/bookmarkPage.dart';
import 'package:cookcraft/Page/cameraPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cookcraft/Page/auth/login.dart';
import '../Components/navigationBar.dart';
import 'mainPage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cookcraft', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Center(
        child: user != null ? _buildUserProfile(user) : _buildLoginPrompt(context),
      ),
      bottomNavigationBar: RecipeBottomNavigationBar(
        currentIndex: 3, // อยู่ที่หน้าโปรไฟล์
        onSearchPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        },
        onCameraPressed: () async {
          final List<String>? newTags = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CameraPage()),
          );
          if (newTags != null) {
            // สามารถใช้ newTags ได้ตามต้องการ
          }
        },
        onRecipePressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BookmarkPage()),
          );
        },
        onProfilePressed: () {
          // หน้าโปรไฟล์อยู่แล้ว ไม่ต้องทำอะไร
        },
      ),
    );
  }

  Widget _buildUserProfile(User user) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.account_circle, size: 100, color: Colors.black),
        const SizedBox(height: 16),
        Text(
          user.displayName ?? 'ไม่มีชื่อผู้ใช้',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          '@${user.email?.split('@')[0] ?? 'ไม่ระบุอีเมล'}',
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 10),
        _buildProfileOption('โปรไฟล์'),
        _buildProfileOption('การตั้งค่า'),
        _buildProfileOption('คำถามที่พบบ่อย'),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            setState(() {}); // รีโหลดหน้าเมื่อออกจากระบบ
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('ออกจากระบบ'),
        ),
      ],
    );
  }

  Widget _buildProfileOption(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.account_circle, size: 100, color: Colors.black),
        const SizedBox(height: 16),
        const Text(
          'คุณยังไม่ได้เข้าสู่ระบบ',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('กรุณาเข้าสู่ระบบ', style: TextStyle(fontSize: 16)),
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
    );
  }
}
