// import 'package:flutter/material.dart';
// import '../Components/tagList.dart';
// import '../Components/searchBar.dart';
// import '../Components/searchResult.dart';
// import 'package:cookcraft/Components/navigationBar.dart';
// import 'package:cookcraft/Page/cameraPage.dart'; // CameraPage
// import 'package:cookcraft/Page/bookmarkPage.dart'; // BookmarkPage
// import 'package:cookcraft/Page/mainPage.dart';
//
// class BookmarkPage extends StatelessWidget {
//   const BookmarkPage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Cookcraft',
//           style: TextStyle(color: Colors.black),
//         ),
//         backgroundColor: Colors.blue,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: const [
//             Icon(
//               Icons.person,
//               size: 100,
//               color: Colors.black,
//             ),
//             SizedBox(height: 16),
//             Text(
//               'คุณยังไม่ได้เข้าสู่ระบบ',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'กรุณาเข้าสู่ระบบ',
//               style: TextStyle(fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: RecipeBottomNavigationBar(
//         currentIndex: _currentIndex,
//         onSearchPressed: () {
//           setState(() {
//             _currentIndex = 0; // กลับไปหน้า "ค้นหา"
//           });
//         },
//         onCameraPressed: () async {
//           // ใช้ฟังก์ชันของคุณตามเดิม
//           final List<String>? newTags = await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const CameraPage(),
//             ),
//           );
//           if (newTags != null) {
//             for (var tag in newTags) {
//               _addSearchTag(tag);
//             }
//           }
//         },
//         onRecipePressed: () {
//           // setState(() {
//           //   _currentIndex = 2; // ไปหน้า "สูตรอาหาร"
//           // });
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const BookmarkPage()),
//           );
//         },
//         onProfilePressed: () {
//           setState(() {
//             _currentIndex = 3; // ไปหน้า "โปรไฟล์"
//           });
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // คุณสามารถเพิ่มฟังก์ชันอื่นได้ที่นี่ เช่น เพิ่ม Bookmark
//           debugPrint("Floating Action Button กดแล้ว");
//         },
//         backgroundColor: Colors.blue,
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
