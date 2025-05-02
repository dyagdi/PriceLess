import 'package:flutter/material.dart';

class PopularProductPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Popüler Ürünler"),
      ),
      body: Center(
        child: Text(
          "This is the Popular Products page.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
