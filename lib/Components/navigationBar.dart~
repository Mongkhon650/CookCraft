import 'package:flutter/material.dart';

class RecipeBottomNavigationBar extends StatelessWidget {
  final VoidCallback onCameraPressed;
  final VoidCallback onRecipePressed;
  final VoidCallback onSearchPressed; // Callback สำหรับ "ค้นหา"
  final VoidCallback onProfilePressed; // Callback สำหรับ "โปรไฟล์"
  final int currentIndex; // รับค่าดัชนีปัจจุบัน

  const RecipeBottomNavigationBar({
    Key? key,
    required this.onCameraPressed,
    required this.onRecipePressed,
    required this.onSearchPressed,
    required this.onProfilePressed,
    required this.currentIndex, // กำหนดค่าเริ่มต้น
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.lightBlueAccent,
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex, // ใช้ currentIndex ที่รับเข้ามา
      onTap: (index) {
        if (index == 0) {
          onSearchPressed(); // ค้นหา
        } else if (index == 1) {
          onCameraPressed(); // กล้อง
        } else if (index == 2) {
          onRecipePressed(); // สูตรอาหาร
        } else if (index == 3) {
          onProfilePressed(); // โปรไฟล์
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: "ค้นหา",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt),
          label: "กล้อง",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt),
          label: "สูตรอาหาร",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "โปรไฟล์",
        ),
      ],
    );
  }
}
