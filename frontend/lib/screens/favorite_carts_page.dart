import 'package:flutter/material.dart';

class FavoriteCartsPage extends StatelessWidget {
  final List<String> favoriteCarts = [
    "Shopping Cart 1",
    "Shopping Cart 2",
    "Shopping Cart 3",
  ]; // Example favorite shopping carts

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Shopping Carts'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            for (var cart in favoriteCarts)
              ListTile(
                title: Text(cart),
                trailing: Icon(Icons.shopping_cart),
                onTap: () {
                  // Implement cart viewing functionality
                },
              ),
          ],
        ),
      ),
    );
  }
}
