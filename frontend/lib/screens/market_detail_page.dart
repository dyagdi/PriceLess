import 'package:flutter/material.dart';
import 'package:frontend/widgets/bottom_navigation.dart';
class MarketDetailPage extends StatelessWidget {
  final String marketName;
  final Map<String, List<dynamic>> categorizedProducts;

  const MarketDetailPage({
    super.key, 
    required this.marketName,
    this.categorizedProducts = const {},
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> products = [
      {'name': 'Product 1', 'price': '10.00', 'image': 'images/product1.jpg'},
      {'name': 'Product 2', 'price': '20.00', 'image': 'images/product2.jpg'},
      {'name': 'Product 3', 'price': '30.00', 'image': 'images/product3.jpg'},
    ]; // Sample products for the selected market

    return Scaffold(
      appBar: AppBar(
        title: Text(
          marketName,
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: Image.asset(product['image']!, width: 50, height: 50),
              title: Text(product['name']!),
              subtitle: Text("₺${product['price']}"),
              trailing: IconButton(
                icon: const Icon(Icons.add_shopping_cart),
                onPressed: () {
                  // Add to cart logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('${product['name']} sepete eklendi!')),
                  );
                },
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 3,
        categorizedProducts: categorizedProducts,
      ),
    );
  }
}