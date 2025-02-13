import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cookcraft/Page/recipeDetailPage.dart';

class SearchResult extends StatelessWidget {
  final List<String> searchTags;

  const SearchResult({
    Key? key,
    required this.searchTags,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('recipes').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("ไม่มีข้อมูลสูตรอาหาร", style: TextStyle(color: Colors.grey)),
          );
        }

        final allRecipes = snapshot.data!.docs;

        return FutureBuilder<Map<String, List<String>>>(
          future: _fetchIngredients(),
          builder: (context, ingredientSnapshot) {
            if (ingredientSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!ingredientSnapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text("ไม่สามารถโหลดข้อมูลวัตถุดิบได้", style: TextStyle(color: Colors.grey)),
              );
            }

            final ingredientMap = ingredientSnapshot.data!;

            // กรองข้อมูลที่ตรงกับชื่อหรือวัตถุดิบ
            final filteredRecipes = searchTags.isEmpty
                ? allRecipes
                : allRecipes.where((recipe) {
              final name = recipe['name'].toString().toLowerCase().trim();
              final recipeId = recipe.id;
              final ingredients = ingredientMap[recipeId]?.join(" ") ?? "";
              return searchTags.any((tag) {
                final query = tag.toLowerCase().trim();
                return name.contains(query) || ingredients.contains(query);
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

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailPage(recipeId: recipe.id),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: NetworkImage(recipe['image_url'] ?? ""),
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
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<Map<String, List<String>>> _fetchIngredients() async {
    final ingredientSnapshot = await FirebaseFirestore.instance.collection('ingredients').get();
    final Map<String, List<String>> ingredientMap = {};

    for (var doc in ingredientSnapshot.docs) {
      final recipeId = doc['recipe_id'] as String;
      final name = doc['name'] as String;
      if (!ingredientMap.containsKey(recipeId)) {
        ingredientMap[recipeId] = [];
      }
      ingredientMap[recipeId]!.add(name.toLowerCase());
    }

    return ingredientMap;
  }
}
