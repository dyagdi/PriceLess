import 'package:flutter/material.dart';
import 'package:frontend/models/cheapest_pc.dart';
import 'package:frontend/services/product_service.dart';
import 'package:frontend/screens/category_detail_page.dart';
import 'package:frontend/widgets/bottom_navigation.dart';
import 'package:frontend/constants/colors.dart';

class CategoryPage extends StatefulWidget {
  final Map<String, List<dynamic>> categorizedProducts;

  const CategoryPage({super.key, required this.categorizedProducts});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late Future<List<CheapestProductPc>> _categoryProductsFuture;
  bool isLoading = true;
  Map<String, List<dynamic>> specificCategorizedProducts = {};

  @override
  void initState() {
    super.initState();
    // Load products from specific categories for each market
    _categoryProductsFuture = fetchCheapestProductsByCategories();
    _loadSpecificCategoryProducts();
  }

  Future<void> _loadSpecificCategoryProducts() async {
    try {
      final fetchedProducts = await _categoryProductsFuture;
      setState(() {
        // Clear and rebuild the categorized products map
        specificCategorizedProducts = {};

        for (var product in fetchedProducts) {
          String category = product.category ?? "Uncategorized";
          if (!specificCategorizedProducts.containsKey(category)) {
            specificCategorizedProducts[category] = [];
          }
          specificCategorizedProducts[category]?.add(product);
        }
        isLoading = false;
      });
    } catch (e) {
      print('Error loading specific category products: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define normalized category data with appropriate images and colors
    final Map<String, Map<String, dynamic>> categoryData = {
      'Meyve ve Sebze': {
        'image': 'images/meyve_sebze.jpeg',
        'color': Theme.of(context).colorScheme.primary,
        'icon': Icons.eco,
      },
      'İçecekler': {
        'image': 'images/default.jpg',
        'color': Theme.of(context).colorScheme.secondary,
        'icon': Icons.local_drink,
      },
      'Et, Tavuk ve Balık': {
        'image': 'images/et_tavuk_balik.jpeg',
        'color': Theme.of(context).colorScheme.error,
        'icon': Icons.restaurant_menu,
      },
      'Temel Gıda': {
        'image': 'images/default.jpg',
        'color': Theme.of(context).colorScheme.secondaryContainer,
        'icon': Icons.grain,
      },
      'Dondurulmuş Gıda': {
        'image': 'images/default.jpg',
        'color': Theme.of(context).colorScheme.secondary,
        'icon': Icons.ac_unit,
      },
      // Fallback for any category that might not be normalized
      'Uncategorized': {
        'image': 'images/default.jpg',
        'color': Theme.of(context).colorScheme.outline,
        'icon': Icons.category,
      },
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Kategoriler",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        automaticallyImplyLeading: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : specificCategorizedProducts.isEmpty
              ? const Center(child: Text('Kategorilere göre ürün bulunamadı.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: specificCategorizedProducts.keys.length,
                  itemBuilder: (context, index) {
                    final categories =
                        specificCategorizedProducts.keys.toList();
                    categories.sort(); // Sort categories alphabetically
                    final category = categories[index];

                    // Get image and color from our mapping, or use defaults
                    final categoryInfo = categoryData[category] ??
                        categoryData['Uncategorized']!;

                    final imagePath = categoryInfo['image'];
                    final Color categoryColor = categoryInfo['color'];
                    final IconData categoryIcon = categoryInfo['icon'];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryDetailPage(
                                category: category,
                                products:
                                    specificCategorizedProducts[category] ?? [],
                                categorizedProducts:
                                    specificCategorizedProducts,
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
                              // Category image container
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
                                // Overlay with icon for better visibility
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: categoryColor.withOpacity(0.3),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      categoryIcon,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Category name
                              Expanded(
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              // Product count badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: categoryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${specificCategorizedProducts[category]?.length ?? 0}',
                                  style: TextStyle(
                                    color: categoryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Color indicator
                              Container(
                                width: 12,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: categoryColor.withOpacity(0.2),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
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
        categorizedProducts: widget.categorizedProducts,
      ),
    );
  }
}
