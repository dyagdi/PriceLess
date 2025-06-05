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
    return await ProductService.getCategorizedProducts();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItemCount = cartProvider.cartItems.length;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
          child: BottomNavigationBar(
          currentIndex: currentIndex,
            onTap: (index) async {
            // Prevent multiple taps while navigating
            if (cartProvider.isNavigating) return;
            
            // Prevent navigating to the same screen
            if (currentIndex == index) return;

                cartProvider.isNavigating = true;
            try {
              Widget nextScreen;
                switch (index) {
                  case 0:
                  nextScreen = HomePage();
                    break;
                  case 1:
                    final products = await _getCategorizedProducts();
                  nextScreen = CategoryPage(categorizedProducts: products);
                    break;
                  case 2:
                  nextScreen = ToDoListPage();
                    break;
                  case 3:
                    final products = await _getCategorizedProducts();
                  nextScreen = MarketsPage(categorizedProducts: products);
                    break;
                  case 4:
                  nextScreen = CartPage();
                    break;
                default:
                  nextScreen = HomePage();
              }

              // Use pushReplacement instead of pushAndRemoveUntil to maintain proper navigation
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) => nextScreen,
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            } finally {
              cartProvider.isNavigating = false;
              }
            },
            items: [
              _buildNavItem(Icons.home_outlined, Icons.home, 'Anasayfa', 0),
            _buildNavItem(Icons.category_outlined, Icons.category, 'Kategoriler', 1),
            _buildNavItem(Icons.list_alt_outlined, Icons.list_alt, 'Ortak Liste', 2),
              _buildNavItem(Icons.store_outlined, Icons.store, 'Marketler', 3),
              _buildNavItem(
                Icons.shopping_cart_outlined,
                Icons.shopping_cart,
                'Sepetim',
                4,
                badgeCount: cartItemCount,
              ),
            ],
            selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            elevation: 0,
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      IconData unselectedIcon, IconData selectedIcon, String label, int index,
      {int badgeCount = 0}) {
    return BottomNavigationBarItem(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(unselectedIcon),
          if (badgeCount > 0)
            Positioned(
              right: -8,
              top: -8,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: badgeCount > 99 ? 4 : badgeCount > 9 ? 4 : 6,
                  vertical: 2,
                ),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      activeIcon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(selectedIcon),
          if (badgeCount > 0)
            Positioned(
              right: -8,
              top: -8,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: badgeCount > 99 ? 4 : badgeCount > 9 ? 4 : 6,
                  vertical: 2,
                ),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      label: label,
    );
  }
}
