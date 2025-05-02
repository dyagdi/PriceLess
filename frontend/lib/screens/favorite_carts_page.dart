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
        print("Response body: ${response.body}"); 
        final decodedData = jsonDecode(response.body);
        setState(() {
          favoriteCarts = decodedData;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load favorite carts');
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Favori sepetler yüklenirken hata oluştu")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteFavoriteCart(int cartId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lütfen önce giriş yapın")),
        );
        return;
      }

      final response = await http.delete(
        Uri.parse('${baseUrl}favorite-carts/$cartId/'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          favoriteCarts.removeWhere((cart) => cart['id'] == cartId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sepet başarıyla silindi")),
        );
      } else {
        throw Exception('Failed to delete cart');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sepet silinirken hata oluştu")),
      );
    }
  }

  Future<void> showDeleteConfirmation(BuildContext context, int cartId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sepeti Favorilerden Kaldır'),
          content: Text('Bu sepeti favorilerden kaldırmak istediğinizden emin misiniz?'),
          actions: <Widget>[
            TextButton(
              child: Text('İptal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Kaldır'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                deleteFavoriteCart(cartId);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıtlı Sepetlerim'),
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
                    title: Text('Favori Sepetim ${index + 1}'),
                    trailing: Icon(Icons.shopping_cart),
                    onTap: () {
                      if (products.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SavedCartPage(
                              products: products,
                              cartId: cart['id'],
                              onCartDeleted: () {
                                setState(() {
                                  favoriteCarts.removeWhere((c) => c['id'] == cart['id']);
                                });
                              },
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