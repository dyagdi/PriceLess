import 'package:flutter/material.dart';

class DiscountedProductsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("İndirimli Ürünler"),
      ),
      body: Center(
        child: Text(
          "This is the Discounted Products page.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
