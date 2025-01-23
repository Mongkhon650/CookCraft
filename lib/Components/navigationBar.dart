import 'package:flutter/material.dart';
import '../Page/cameraPage.dart';

class RecipeBottomNavigationBar extends StatelessWidget {
  final VoidCallback onCameraPressed;

  const RecipeBottomNavigationBar({
    Key? key,
    required this.onCameraPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.pink,
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      onTap: (index) {
        if (index == 1) {
          onCameraPressed(); // เรียกฟังก์ชันเมื่อกดปุ่มกล้อง
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
          icon: Icon(Icons.favorite),
          label: "โปรด",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "โปรไฟล์",
        ),
      ],
    );
  }
}
