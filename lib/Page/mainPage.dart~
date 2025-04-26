import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Components/searchBar.dart';
import '../Components/searchResult.dart';
import '../Components/tagList.dart';
import '../Components/navigationBar.dart';
import '../Components/button/customFloatingButton.dart';
import 'cameraPage.dart';
import 'bookmarkPage.dart';
import 'profilePage.dart';
import 'addReciepPage.dart';
import 'auth/login.dart';

class MainPage extends StatefulWidget {
  final List<String>? searchTags;

  const MainPage({Key? key, this.searchTags}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  late List<String> _searchTags;

  @override
  void initState() {
    super.initState();
    _searchTags = widget.searchTags ?? [];
  }

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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()), // ถ้าไม่ล็อกอินให้พาไปหน้า Login
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddRecipePage()), // ถ้าล็อกอินแล้วให้พาไปเพิ่มสูตรอาหาร
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cookcraft', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar: RecipeBottomNavigationBar(
        currentIndex: _currentIndex,
        onSearchPressed: () {
          setState(() {
            _currentIndex = 0;
          });
        },
        onCameraPressed: () async {
          final List<String>? newTags = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CameraPage()),
          );
          if (newTags != null) {
            for (var tag in newTags) {
              _addSearchTag(tag);
            }
          }
        },
        onRecipePressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BookmarkPage()),
          );
        },
        onProfilePressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        },
      ),
      floatingActionButton: CustomFloatingButton(
        onPressed: _handleFloatingButtonPress, // ใช้เงื่อนไขเช็กการล็อกอินก่อนกดปุ่ม
      ),
    );
  }

  Widget _buildBody() {
    if (_currentIndex == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customSearchBar(
            controller: TextEditingController(),
            onSearch: (value) {
              _addSearchTag(value);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TagList(
              tags: _searchTags,
              onRemoveTag: _removeSearchTag,
            ),
          ),
          Expanded(
            child: SearchResult(searchTags: _searchTags),
          ),
        ],
      );
    } else if (_currentIndex == 1) {
      return const Center(child: Text("หน้ากล้อง"));
    } else if (_currentIndex == 2) {
      return const Center(child: Text("สูตรอาหาร"));
    } else {
      return const Center(child: Text("โปรไฟล์"));
    }
  }
}
