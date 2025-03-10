import 'dart:convert';
import 'package:frontend/models/cheapest_pc.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/models/product_search_result.dart';

Future<List<ProductSearchResult>> searchProducts(String query) async {
  final response =
      await http.get(Uri.parse('http://localhost:8000/api/search/?q=$query'));

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(response.body);

    // Map the json response to a list of ProductSearchResult objects
    return jsonData.map((data) => ProductSearchResult.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load search results');
  }
}

Future<List<CheapestProductPc>> fetchCheapestProductsPerCategory() async {
  final url =
      Uri.parse('http://localhost:8000/api/cheapest-products-per-category/');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return cheapestProductPcFromJson(response.body);
  } else {
    throw Exception('Failed to load products');
  }
}

Future<List<Product>> fetchDiscountedProducts() async {
  try {
    final response = await http.get(
      Uri.parse(
          'http://127.0.0.1:8000/api/discounted-products/'), // IP adresinizi yazın
    );

    if (response.statusCode == 200) {
      final List<dynamic> productsJson =
          json.decode(utf8.decode(response.bodyBytes));
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } else {
      print('HTTP Error: ${response.statusCode}');
      throw Exception('Failed to load discounted products');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Failed to connect to the server');
  }
}

class Product {
  final String? id;
  final String name;
  final double price;
  final double? highPrice;
  final String imageUrl;
  final String mainCategory;

  Product({
    this.id,
    required this.name,
    required this.price,
    this.highPrice,
    required this.imageUrl,
    required this.mainCategory,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString(),
      name: json['name'] ?? 'Bilinmeyen Ürün',
      price: (json['price'] ?? 0).toDouble(),
      highPrice:
          json['high_price'] != null ? json['high_price'].toDouble() : null,
      imageUrl: json['image_url'] ?? '',
      mainCategory: json['main_category'] ?? 'Genel',
    );
  }
}
