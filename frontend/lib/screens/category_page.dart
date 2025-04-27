import 'package:flutter/material.dart';
import 'package:frontend/screens/category_detail_page.dart';
import 'package:frontend/widgets/bottom_navigation.dart';

class CategoryPage extends StatelessWidget {
  final Map<String, List<dynamic>> categorizedProducts;

  const CategoryPage({super.key, required this.categorizedProducts});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> categoryImages = {
      'Meyve ve Sebze': 'images/meyve_sebze.jpeg',
      'Et, Balık, Tavuk': 'images/et_tavuk_balik.jpeg',
      'Süt Ürünleri': 'images/sut_kahvaltilik.jpeg',
    };

    final categories = categorizedProducts.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Kategoriler",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        automaticallyImplyLeading: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final imagePath = categoryImages[category] ?? 'images/default.jpg';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryDetailPage(
                      category: category,
                      products: categorizedProducts[category] ?? [],
                      categorizedProducts: categorizedProducts,
                    ),
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Row(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        image: DecorationImage(
                          image: AssetImage(imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    bottomNavigationBar: BottomNavigation(
      currentIndex: 1,
      categorizedProducts: categorizedProducts,
    ),
    );
  }
}