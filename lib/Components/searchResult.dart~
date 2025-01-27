import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchResult extends StatelessWidget {
  final List<String> searchTags;

  const SearchResult({
    Key? key,
    required this.searchTags,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Receipt').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("ไม่มีข้อมูลที่ตรงกับคำค้นหา", style: TextStyle(color: Colors.grey)),
          );
        }

        final allRecipes = snapshot.data!.docs;
        final filteredRecipes = allRecipes.where((recipe) {
          final ingredients = List<String>.from(recipe['ingredients']);
          final name = recipe['name'].toString();

          // ตรวจสอบว่า tags ทั้งหมดอยู่ใน ingredients หรือไม่
          return searchTags.every((tag) {
            final regex = RegExp(tag, caseSensitive: false);
            return ingredients.any((ingredient) => regex.hasMatch(ingredient));
          }) || searchTags.any((tag) {
            final regex = RegExp(tag, caseSensitive: false);
            return regex.hasMatch(name);
          });
        }).toList();

        if (filteredRecipes.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("ไม่มีข้อมูลที่ตรงกับคำค้นหา", style: TextStyle(color: Colors.grey)),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
            childAspectRatio: 16 / 9,
          ),
          itemCount: filteredRecipes.length,
          itemBuilder: (context, index) {
            final recipe = filteredRecipes[index];
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: NetworkImage(recipe['image_url']),
                  fit: BoxFit.cover,
                ),
              ),
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black.withOpacity(0.6),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    recipe['name'],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
