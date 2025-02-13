import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Components/navigationBar.dart';
import 'mainPage.dart';
import 'cameraPage.dart';
import 'bookmarkPage.dart';
import 'auth/login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cookcraft', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.blue,
        elevation: 0,
        automaticallyImplyLeading: false, // ปิดปุ่มย้อนกลับ
      ),
      body: Center(
        child: user != null ? _buildUserProfile(user!) : _buildLoginPrompt(context),
      ),
      bottomNavigationBar: RecipeBottomNavigationBar(
        currentIndex: 3,
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
          if (newTags != null) {}
        },
        onRecipePressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BookmarkPage()),
          );
        },
        onProfilePressed: () {},
      ),
    );
  }

  /// ✅ **ดึงข้อมูลผู้ใช้จาก Firestore**
  Widget _buildUserProfile(User user) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text("ไม่พบข้อมูลผู้ใช้");
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final String displayName = userData['display_name'] ?? "ไม่มีชื่อผู้ใช้";
        final String email = userData['email'] ?? "ไม่ระบุอีเมล";

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 100, color: Colors.black),
            const SizedBox(height: 16),
            Text(displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('@${email.split('@')[0]}', style: const TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30), // ปรับระยะขอบซ้าย-ขวา
              child: Divider(thickness: 2, color: Colors.black), // เส้นแบ่ง
            ),
            const SizedBox(height: 10),
            _buildProfileOption('โปรไฟล์', () {
              print("กดที่: โปรไฟล์");
            }),
            _buildProfileOption('การตั้งค่า', () {
              print("กดที่: การตั้งค่า");
            }),
            _buildProfileOption('คำถามที่พบบ่อย', () {
              print("กดที่: คำถามที่พบบ่อย");
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainPage()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('ออกจากระบบ', style: TextStyle(color: Colors.black),),
            ),
          ],
        );
      },
    );
  }

  /// ✅ **สร้างปุ่มเมนูที่กดได้**
  Widget _buildProfileOption(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap, // รองรับการกด
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
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
