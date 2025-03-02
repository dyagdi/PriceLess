import 'package:flutter/material.dart';
import 'package:frontend/screens/category_page.dart';
import 'package:frontend/screens/home_page.dart';
import 'package:frontend/screens/cart_page.dart';
import 'package:frontend/screens/to_do_list_page.dart';
import 'package:frontend/screens/markets_page.dart';
import 'package:frontend/services/product_service.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Map<String, List<dynamic>> categorizedProducts;

  const BottomNavigation({
    Key? key,
    required this.currentIndex,
    this.categorizedProducts = const {},
  }) : super(key: key);

  Future<Map<String, List<dynamic>>> _getCategorizedProducts() async {
    if (categorizedProducts.isNotEmpty) {
      return categorizedProducts;
    }
    
    final fetchedProducts = await fetchCheapestProductsPerCategory();
    final Map<String, List<dynamic>> newCategorizedProducts = {};
    
    for (var product in fetchedProducts) {
      String category = product.category ?? "Uncategorized";
      if (!newCategorizedProducts.containsKey(category)) {
        newCategorizedProducts[category] = [];
      }
      newCategorizedProducts[category]?.add(product);
    }
    
    return newCategorizedProducts;
  }

  @override
  Widget build(BuildContext context) {
    // If currentIndex is -1, default to first item but don't highlight any
    final effectiveIndex = currentIndex < 0 ? 0 : currentIndex;

    return BottomNavigationBar(
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
                MaterialPageRoute(builder: (context) => CategoryPage(categorizedProducts: products)),
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
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Anasayfa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'Kategoriler',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Alışveriş Listesi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store),
          label: 'Marketler',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Sepetim',
        ),
      ],
      selectedItemColor: currentIndex < 0 ? Colors.grey : Colors.black,  // Grey out all items if currentIndex is -1
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    );
  }
}