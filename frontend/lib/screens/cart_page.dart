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
import 'package:frontend/theme/app_theme.dart';
import 'walking.dart';
import 'package:frontend/screens/market_comparison_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isHeartFilled = false;

  Future<void> _openWalkingPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WalkingPage()),
    );
  }

  void _showNameCartDialog() {
    final TextEditingController nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sepetinizi İsimlendirin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _isHeartFilled = false;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Sepet adı girin',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final cartProvider = Provider.of<CartProvider>(context, listen: false);
                    final cartItems = cartProvider.cartItems;

                    if (cartItems.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Sepetiniz boş, favorilere eklenemez!")),
                      );
                      Navigator.of(context).pop();
                      setState(() {
                        _isHeartFilled = false;
                      });
                      return;
                    }

                    final products = cartItems
                        .map((item) => {
                              'name': item.name,
                              'price': item.price,
                              'image': item.image,
                              'quantity': item.quantity,
                            })
                        .toList();

                    try {
                      final token = await AuthService.getToken();
                      if (token == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Lütfen önce giriş yapın")),
                        );
                        Navigator.of(context).pop();
                        setState(() {
                          _isHeartFilled = false;
                        });
                        return;
                      }

                      final url = Uri.parse('${url_constants.baseUrl}favorite-carts/');
                      final response = await http.post(
                        url,
                        headers: {
                          "Content-Type": "application/json",
                          "Authorization": "Token $token",
                        },
                        body: jsonEncode({
                          'products': products,
                          'name': nameController.text.trim(),
                        }),
                      );

                      if (response.statusCode == 201) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Sepetiniz favorilere eklendi!")),
                        );
                        Navigator.of(context).pop();
                      } else {
                        print('Error response: ${response.body}');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Sepet favorilere eklenirken bir hata oluştu")),
                        );
                        Navigator.of(context).pop();
                        setState(() {
                          _isHeartFilled = false;
                        });
                      }
                    } catch (e) {
                      print('Error saving cart to favorites: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Bir hata oluştu, lütfen tekrar deneyin")),
                      );
                      Navigator.of(context).pop();
                      setState(() {
                        _isHeartFilled = false;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: const Text('Kaydet'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sepetim",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_walk,
                color: Colors.green,
                size: 20,
              ),
            ),
            onPressed: _openWalkingPage,
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isHeartFilled ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
                size: 20,
              ),
            ),
            onPressed: () {
              setState(() {
                _isHeartFilled = !_isHeartFilled;
              });
              if (_isHeartFilled) {
                _showNameCartDialog();
              }
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final cartItems = cartProvider.cartItems;

          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Sepetiniz Boş",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Alışverişe başlamak için ürün ekleyin",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Product Image
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(AppTheme.radiusL),
                              bottom: Radius.circular(AppTheme.radiusL),
                            ),
                            child: SizedBox(
                              width: 100,
                              height: 100,
                              child: Image.network(
                                item.image,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        color: Colors.grey[400],
                                        size: 32,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          // Product Details
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "₺${(item.price * item.quantity).toStringAsFixed(2)}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Quantity Controls
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                              AppTheme.radiusM),
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove,
                                                  size: 18),
                                              onPressed: () {
                                                cartProvider.removeItem(item);
                                              },
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                            Text(
                                              item.quantity.toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add,
                                                  size: 18),
                                              onPressed: () {
                                                cartProvider.addItem(item);
                                              },
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.red),
                                        onPressed: () {
                                          cartProvider.removeItem(item);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Bottom Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Toplam",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          "₺${cartProvider.cartItems.fold(0.0, (double sum, item) => sum + (item.price * item.quantity)).toStringAsFixed(2)}",
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MarketComparisonPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Marketleri Karşılaştır",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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

    final products = cartItems
        .map((item) => {
              'name': item.name,
              'price': item.price,
              'image': item.image,
              'quantity': item.quantity,
            })
        .toList();

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
          SnackBar(
              content: Text("Sepet favorilere eklenirken bir hata oluştu")),
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
