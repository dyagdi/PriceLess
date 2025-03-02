import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/constants/constants_url.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/screens/saved_cart_page.dart';

class FavoriteCartsPage extends StatefulWidget {
  @override
  _FavoriteCartsPageState createState() => _FavoriteCartsPageState();
}

class _FavoriteCartsPageState extends State<FavoriteCartsPage> {
  List<dynamic> favoriteCarts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFavoriteCarts();
  }

  Future<void> fetchFavoriteCarts() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lütfen önce giriş yapın")),
        );
        return;
      }

      final response = await http.get(
        Uri.parse('${baseUrl}favorite-carts/'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        },
      );

      if (response.statusCode == 200) {
        print("Response body: ${response.body}"); // Debug print
        final decodedData = jsonDecode(response.body);
        setState(() {
          favoriteCarts = decodedData;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load favorite carts');
      }
    } catch (e) {
      print("Error: $e"); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Favori sepetler yüklenirken hata oluştu")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favori Sepetlerim'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: isLoading 
        ? Center(child: CircularProgressIndicator())
        : favoriteCarts.isEmpty 
          ? Center(
              child: Text('Henüz favori sepetiniz bulunmamaktadır',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: favoriteCarts.length,
              itemBuilder: (context, index) {
                final cart = favoriteCarts[index];
                final products = cart['products'] ?? [];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text('Sepetim ${index + 1}'),
                    trailing: Icon(Icons.shopping_cart),
                    onTap: () {
                      if (products.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SavedCartPage(
                              products: products,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Bu sepette ürün bulunmamaktadır")),
                        );
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}