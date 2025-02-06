import 'package:flutter/material.dart';

class FavoriteCartsPage extends StatelessWidget {
  final List<String> favoriteCarts = [
    "Sepet 1",
    "Sepet 2",
    "Sepet 3",
  ]; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favori Sepetlerim'),
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
                  //sepetin içeriğini görüntülesinler
                },
              ),
          ],
        ),
      ),
    );
  }
}