import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/screens/category_page.dart';
import 'package:frontend/screens/home_page.dart';
import 'package:frontend/screens/cart_page.dart';
import 'package:frontend/screens/to_do_list_page.dart';
import 'package:frontend/screens/markets_page.dart';
import 'package:frontend/services/product_service.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'dart:math' as math;

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Map<String, List<dynamic>> categorizedProducts;

  const BottomNavigation({
    Key? key,
    required this.currentIndex,
    this.categorizedProducts = const {},
  }) : super(key: key);

  Future<Map<String, List<dynamic>>> _getCategorizedProducts() async {
    // Always fetch fresh data to avoid caching issues
    print('Fetching fresh product data from backend...');

    try {
      // First try to fetch from our new specific categories endpoint with normalized categories
      final fetchedCategoryProducts = await fetchCheapestProductsByCategories();
      print(
          'Received ${fetchedCategoryProducts.length} products from specific categories backend');

      if (fetchedCategoryProducts.isNotEmpty) {
        // If we have specific category products, use them
        final Map<String, List<dynamic>> specificCategorizedProducts = {};

        for (var product in fetchedCategoryProducts) {
          String category = product.category ?? "Uncategorized";
          // Use the normalized category name from the backend
          if (!specificCategorizedProducts.containsKey(category)) {
            specificCategorizedProducts[category] = [];
          }
          specificCategorizedProducts[category]?.add(product);
        }

        print(
            'Organized products into ${specificCategorizedProducts.keys.length} normalized categories');
        return specificCategorizedProducts;
      }
    } catch (e) {
      print(
          'Error fetching specific category products: $e, falling back to regular categories');
    }

    // If specific categories fetch failed or was empty, fall back to original method
    // with our own category normalization
    final fetchedProducts = await fetchCheapestProductsPerCategory();
    print('Received ${fetchedProducts.length} products from backend');

    final Map<String, List<dynamic>> newCategorizedProducts = {};

    // Define mapping for normalized categories
    final Map<String, String> normalizedCategoryMapping = {
      'Meyve, Sebze': 'Meyve ve Sebze',
      'Meyve & Sebze': 'Meyve ve Sebze',
      'Sebze & Meyve': 'Meyve ve Sebze',
      'Sebzeler': 'Meyve ve Sebze',
      'Meyveler': 'Meyve ve Sebze',
      'İçecek': 'İçecekler',
      'İçecekler': 'İçecekler',
      'Et, Tavuk, Balık': 'Et, Tavuk ve Balık',
      'Et & Tavuk & Şarküteri': 'Et, Tavuk ve Balık',
      'Kırmızı/Beyaz Et': 'Et, Tavuk ve Balık',
      'Et Ürünleri': 'Et, Tavuk ve Balık',
      'Temel Gıda': 'Temel Gıda',
      'Yemeklik Malzemeler': 'Temel Gıda',
      'Gıda & Şekerleme': 'Temel Gıda',
      'GIDA': 'Temel Gıda',
      'Dondurulmuş Gıda': 'Dondurulmuş Gıda',
      'Dondurulmuş Ürünler': 'Dondurulmuş Gıda',
      'Hazır Yemek&Donuk Ürünler': 'Dondurulmuş Gıda',
    };

    // Process products with normalized categories
    for (var product in fetchedProducts) {
      // Get the category from the product, default to "Uncategorized"
      String originalCategory = product.category ?? "Uncategorized";

      // Try to normalize the category
      String normalizedCategory =
          normalizedCategoryMapping[originalCategory] ?? originalCategory;

      // Add the product to the appropriate category
      if (!newCategorizedProducts.containsKey(normalizedCategory)) {
        newCategorizedProducts[normalizedCategory] = [];
      }
      newCategorizedProducts[normalizedCategory]?.add(product);
    }

    return newCategorizedProducts;
  }

  @override
  Widget build(BuildContext context) {
    // If currentIndex is -1, default to first item but don't highlight any
    final effectiveIndex = currentIndex < 0 ? 0 : currentIndex;
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItemCount = cartProvider.cartItems.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: BottomNavigationBar(
            currentIndex: effectiveIndex,
            onTap: (index) async {
              if (currentIndex != index) {
                switch (index) {
                  case 0:
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                      (route) => false,
                    );
                    break;
                  case 1:
                    final products = await _getCategorizedProducts();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CategoryPage(categorizedProducts: products)),
                    );
                    break;
                  case 2:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ToDoListPage()),
                    );
                    break;
                  case 3:
                    final products = await _getCategorizedProducts();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MarketsPage(
                          categorizedProducts: products,
                        ),
                      ),
                    );
                    break;
                  case 4:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartPage()),
                    );
                    break;
                }
              }
            },
            items: [
              _buildNavItem(Icons.home_outlined, Icons.home, 'Anasayfa', 0),
              _buildNavItem(
                  Icons.category_outlined, Icons.category, 'Kategoriler', 1),
              _buildNavItem(
                  Icons.list_alt_outlined, Icons.list_alt, 'Ortak Liste', 2),
              _buildNavItem(Icons.store_outlined, Icons.store, 'Marketler', 3),
              _buildNavItem(
                Icons.shopping_cart_outlined,
                Icons.shopping_cart,
                'Sepetim',
                4,
                badgeCount: cartItemCount,
              ),
            ],
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: Colors.grey[600],
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            elevation: 0,
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      IconData unselectedIcon, IconData selectedIcon, String label, int index,
      {int badgeCount = 0}) {
    final isSelected = currentIndex == index;

    if (badgeCount > 0) {
      return BottomNavigationBarItem(
        icon: Badge(
          label: Text(
            badgeCount.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          child: Icon(isSelected ? selectedIcon : unselectedIcon),
        ),
        activeIcon: Badge(
          label: Text(
            badgeCount.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          child: Icon(selectedIcon),
        ),
        label: label,
      );
    }

    return BottomNavigationBarItem(
      icon: Icon(unselectedIcon),
      activeIcon: Icon(selectedIcon),
      label: label,
    );
  }
}
