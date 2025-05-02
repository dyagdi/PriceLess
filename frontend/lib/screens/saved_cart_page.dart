import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:frontend/models/cart_model.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/constants/constants_url.dart';
import 'package:frontend/services/auth_service.dart';

class SavedCartPage extends StatefulWidget {
  final List<dynamic> products;
  final int cartId;
  final VoidCallback onCartDeleted;

  const SavedCartPage({
    Key? key,
    required this.products,
    required this.cartId,
    required this.onCartDeleted,
  }) : super(key: key);

  @override
  _SavedCartPageState createState() => _SavedCartPageState();
}

class _SavedCartPageState extends State<SavedCartPage> {
  double _getPrice(dynamic price) {
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
    
    for (var product in widget.products) {
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

    Navigator.pop(context);  
  }

  Future<void> deleteFavoriteCart() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lütfen önce giriş yapın")),
        );
        return;
      }

      final response = await http.delete(
        Uri.parse('${baseUrl}favorite-carts/${widget.cartId}/'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Token $token",
        },
      );

      if (response.statusCode == 200) {
        widget.onCartDeleted();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sepet favorilerden kaldırıldı")),
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

  Future<void> showDeleteConfirmation() async {
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
                deleteFavoriteCart();
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
        title: Text("Kayıtlı Sepetim"),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite, color: Colors.red),
            onPressed: showDeleteConfirmation,
          ),
        ],
      ),
      body: SingleChildScrollView( 
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true, 
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.products.length,
              itemBuilder: (context, index) {
                final item = widget.products[index];
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
                    "Toplam: ₺${widget.products.fold(0.0, (sum, item) => sum + (_getPrice(item['price']) * (item['quantity'] ?? 1))).toStringAsFixed(2)}",
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