import 'package:flutter/material.dart';

class RecipeBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final VoidCallback onSearchPressed;
  final VoidCallback onCameraPressed;
  final VoidCallback onRecipePressed;
  final VoidCallback onProfilePressed;

  const RecipeBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onSearchPressed,
    required this.onCameraPressed,
    required this.onRecipePressed,
    required this.onProfilePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black54,
      backgroundColor: Colors.blue,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'ค้นหา',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt),
          label: 'กล้อง',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'สูตรอาหาร',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'โปรไฟล์',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            onSearchPressed();
            break;
          case 1:
            onCameraPressed();
            break;
          case 2:
            onRecipePressed();
            break;
          case 3:
            onProfilePressed();
            break;
        }
      },
    );
  }
}
