import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:frontend/widgets/bottom_navigation.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:frontend/screens/to_do_list_page.dart';
import 'package:frontend/screens/category_page.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/constants/constants_url.dart' as url_constants;
import 'walking.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Future<void> _openWalkingPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WalkingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sepetim"),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_walk,
                color: Colors.white,
                size: 20,
              ),
            ),
            onPressed: _openWalkingPage,
          ),
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () => saveCartToFavorites(context),
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final cartItems = cartProvider.cartItems;

          if (cartItems.isEmpty) {
            return Center(
              child: Text(
                "Listeniz boş",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: Image.network(
                          item.image,
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset("images/default.png");
                          },
                        ),
                        title: Text(
                          item.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            "₺${(item.price * item.quantity).toStringAsFixed(2)}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                cartProvider.removeItem(item);
                              },
                            ),
                            Text(
                              item.quantity.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                cartProvider.addItem(item);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Toplam: ₺${cartProvider.cartItems.fold(0.0, (double sum, item) => sum + (item.price * item.quantity)).toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        // TODO:
                      },
                      child: Text("Marketleri Karşılaştır"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 4,
      ),
    );
  }

  
void saveCartToFavorites(BuildContext context) async {
  final cartProvider = Provider.of<CartProvider>(context, listen: false);
  final cartItems = cartProvider.cartItems;

  if (cartItems.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Sepetiniz boş, favorilere eklenemez!")),
    );
    return;
  }

  final products = cartItems.map((item) => {
    'name': item.name,
    'price': item.price,
    'image': item.image,
    'quantity': item.quantity,
  }).toList();

  try {
    final token = await AuthService.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lütfen önce giriş yapın")),
      );
      return;
    }

    final url = Uri.parse('${url_constants.baseUrl}favorite-carts/');  
    print('Sending request to: $url'); 
    print('Request data: ${jsonEncode({'products': products})}'); 

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Token $token",  
      },
      body: jsonEncode({'products': products}),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sepetiniz favorilere eklendi!")),
      );
    } else {
      print('Error response: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sepet favorilere eklenirken bir hata oluştu")),
      );
    }
  } catch (e) {
    print('Error saving cart to favorites: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Bir hata oluştu, lütfen tekrar deneyin")),
    );
  }
}

}
