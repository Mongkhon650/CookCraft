import 'package:flutter/material.dart';
import '../Components/searchBar.dart'; // ดึง SearchBar มาใช้
import '../Components/searchResult.dart'; // ดึง SearchResults มาใช้
import '../Components/tagList.dart';
import '../Components/navigationBar.dart';
import 'package:cookcraft/Page/cameraPage.dart';
import 'package:cookcraft/models/roboflow_api.dart';


class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
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
        title: const Text('สูตรอาหาร', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pink,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customSearchBar(
            controller: _searchController,
            onSearch: _addSearchTag,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TagList(
              tags: _searchTags,
              onRemoveTag: _removeSearchTag,
            ),
          ),
          Expanded(
            child: SearchResult(searchTags: _searchTags),
          ),
        ],
      ),
      bottomNavigationBar: RecipeBottomNavigationBar(
        onCameraPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CameraPage(),
            ),
          );
        },
      ),
    );
  }
}