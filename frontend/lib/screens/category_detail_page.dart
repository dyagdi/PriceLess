import 'package:flutter/material.dart';
import 'package:frontend/models/cart_model.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:frontend/widgets/app_button.dart';
import 'package:provider/provider.dart';

class CategoryDetailPage extends StatelessWidget {
  final String category;
  final List<dynamic> products;
  final Map<String, List<dynamic>> categorizedProducts;

  const CategoryDetailPage({
    super.key,
    required this.category,
    required this.products,
    required this.categorizedProducts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          category,
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
              title: Text(product.name ?? "Ürün Adı Yok"),
              subtitle: Text("₺${product.price?.toStringAsFixed(2) ?? "0.00"}"),
              leading: product.image != null
                  ? Image.network(product.image!)
                  : Image.asset('images/default.png'),
              trailing: AppButton(
                backgroundColor: Colors.green,
                buttonText: "Sepete Ekle",
                buttonTextColor: Colors.white,
                height: 36,
                width: 120,
                onTap: () {
                  // Add to cart logic
                  final cartItem = CartItem(
                    name: product.name,
                    price: product.price,
                    image: product.image,
                  );

                  Provider.of<CartProvider>(context, listen: false)
                      .addItem(cartItem);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product.name} sepete eklendi!')),
                  );
                },
              ),
            ),
          );
        },
      ),
      
    );
  }
}