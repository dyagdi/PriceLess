import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/constants/constants_url.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/widgets/loading_indicator.dart';
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
          "Content-Type": "application/json; charset=utf-8",
          "Authorization": "Token $token",
        },
      );

      if (response.statusCode == 200) {
        print("Response body: ${response.body}");
        final decodedData = jsonDecode(utf8.decode(response.bodyBytes));
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
          "Content-Type": "application/json; charset=utf-8",
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
          content: Text(
              'Bu sepeti favorilerden kaldırmak istediğinizden emin misiniz?'),
          actions: <Widget>[
            TextButton(
              child: Text('İptal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Kaldır'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Kayıtlı Sepetlerim',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: isLoading
          ? const CustomLoadingIndicator(message: "Sepetleriniz yükleniyor...")
          : favoriteCarts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 64,
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz favori sepetiniz bulunmamaktadır',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: favoriteCarts.length,
                  itemBuilder: (context, index) {
                    final cart = favoriteCarts[index];
                    final products = cart['products'] ?? [];
                    final cartName = cart['name']?.toString().isEmpty ?? true 
                        ? 'Favori Sepetim ${index + 1}' 
                        : cart['name'];
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        title: Text(
                          cart['name']?.toString().isEmpty ?? true
                              ? 'Favori Sepetim ${index + 1}'
                              : cart['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          '${products.length} ürün',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        trailing: Icon(
                          Icons.shopping_cart_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
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
                                      favoriteCarts.removeWhere(
                                          (c) => c['id'] == cart['id']);
                                    });
                                  },
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Bu sepette ürün bulunmamaktadır",
                                  style: GoogleFonts.poppins(),
                                ),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusM),
                                ),
                              ),
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
