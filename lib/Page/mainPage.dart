import 'package:flutter/material.dart';
import '../Components/searchBar.dart';
import '../Components/searchResult.dart';
import '../Components/tagList.dart';
import '../Components/navigationBar.dart'; // Navigation Bar
import 'package:cookcraft/Page/cameraPage.dart'; // CameraPage
import 'package:cookcraft/Page/bookmarkPage.dart'; // BookmarkPage

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0; // เริ่มต้นที่ "ค้นหา"
  final TextEditingController _searchController = TextEditingController();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cookcraft', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: _buildBody(), // เปลี่ยนหน้าตาม currentIndex
      bottomNavigationBar: RecipeBottomNavigationBar(
        currentIndex: _currentIndex,
        onSearchPressed: () {
          setState(() {
            _currentIndex = 0; // กลับไปหน้า "ค้นหา"
          });
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
          }
        },
        onRecipePressed: () {
          setState(() {
            _currentIndex = 2; // ไปหน้า "สูตรอาหาร"
          });
          // Navigator.push(
          //  context,
          //  MaterialPageRoute(builder: (context) => const BookmarkPage()),
          // );
        },
        onProfilePressed: () {
          setState(() {
            _currentIndex = 3; // ไปหน้า "โปรไฟล์"
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint("เพิ่มสูตรอาหารใหม่");
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_currentIndex == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar Section
          customSearchBar(
            controller: _searchController,
            onSearch: (value) {
              _addSearchTag(value);
            },
          ),
          // Tag List Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TagList(
              tags: _searchTags,
              onRemoveTag: _removeSearchTag,
            ),
          ),
          // Search Result Section
          Expanded(
            child: SearchResult(searchTags: _searchTags),
          ),
        ],
      );
    } else if (_currentIndex == 1) {
      return const Center(child: Text("หน้ากล้อง")); // หน้า "กล้อง"
    } else if (_currentIndex == 2) {
      return const Center(child: Text("สูตรอาหาร")); // หน้า "สูตรอาหาร"
    } else {
      return const Center(child: Text("โปรไฟล์")); // หน้า "โปรไฟล์"
    }
  }
}
