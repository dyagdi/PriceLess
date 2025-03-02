import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:frontend/models/cart_model.dart';

class SavedCartPage extends StatelessWidget {
  final List<dynamic> products;

  SavedCartPage({required this.products});

  double _getPrice(dynamic price) {
    // Convert string price to double
    return double.tryParse(price.toString()) ?? 0.0;
  }

  String _fixTurkishChars(String text) {
    final Map<String, String> charMap = {
      'Ã¼': 'ü',
      'Ã¶': 'ö',
      'Ä±': 'ı',
      'Å': 'ş',
      'Ã§': 'ç',
      'Ä': 'ğ',
      'Ã': 'İ',
    };

    String fixedText = text;
    charMap.forEach((key, value) {
      fixedText = fixedText.replaceAll(key, value);
    });
    return fixedText;
  }

  void _addToCurrentCart(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    for (var product in products) {
      final cartItem = CartItem(
        name: _fixTurkishChars(product['name']),
        price: _getPrice(product['price']),
        image: product['image'],
        quantity: product['quantity'],
      );
      cartProvider.addItem(cartItem);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Ürünler güncel sepete eklendi")),
    );

    Navigator.pop(context); // Return to previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kayıtlı Sepetim"),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
      ),
      body: SingleChildScrollView( // Wrap with SingleChildScrollView to fix overflow
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true, // Add this
              physics: NeverScrollableScrollPhysics(), // Add this
              itemCount: products.length,
              itemBuilder: (context, index) {
                final item = products[index];
                final price = _getPrice(item['price']);
                final quantity = item['quantity'] ?? 1;
                
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: Image.network(
                      item['image'] ?? '',
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset("images/default.png");
                      },
                    ),
                    title: Text(
                      _fixTurkishChars(item['name'] ?? ''),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "₺${(price * quantity).toStringAsFixed(2)}",
                    ),
                    trailing: Text(
                      "Adet: $quantity",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Toplam: ₺${products.fold(0.0, (sum, item) => sum + (_getPrice(item['price']) * (item['quantity'] ?? 1))).toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _addToCurrentCart(context),
                    child: Text("Güncel Sepete Ekle"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}