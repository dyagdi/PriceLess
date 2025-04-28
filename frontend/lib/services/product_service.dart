import 'dart:convert';
import 'package:frontend/models/cheapest_pc.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/models/product_search_result.dart';
import 'package:frontend/config/api_config.dart';

Future<List<ProductSearchResult>> searchProducts(String query) async {
  final response = await http.get(Uri.parse(
      'https://d66e-176-233-26-194.ngrok-free.app/api/search/?q=$query'));

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(response.body);

    // Map the json response to a list of ProductSearchResult objects
    return jsonData.map((data) => ProductSearchResult.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load search results');
  }
}

Future<List<CheapestProductPc>> fetchCheapestProductsPerCategory() async {
  final url = Uri.parse(
      'https://d66e-176-233-26-194.ngrok-free.app/api/cheapest-products-per-category/');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return cheapestProductPcFromJson(response.body);
  } else {
    throw Exception('Failed to load products');
  }
}

Future<List<CheapestProductPc>> fetchCheapestProductsByCategories() async {
  final url = Uri.parse(
      'https://d66e-176-233-26-194.ngrok-free.app/api/cheapest-products-by-categories/');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return cheapestProductPcFromJson(response.body);
  } else {
    throw Exception('Failed to load category products');
  }
}

Future<List<Product>> fetchDiscountedProducts() async {
  try {
    final response = await http.get(
      Uri.parse(
          'https://d66e-176-233-26-194.ngrok-free.app/api/discounted-products/'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> productsJson =
          json.decode(utf8.decode(response.bodyBytes));
      print('API Response: ${response.body}'); // Debug print
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } else {
      print('HTTP Error: ${response.statusCode}');
      print('Error Response: ${response.body}'); // Debug print
      throw Exception('Failed to load discounted products');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Failed to connect to the server');
  }
}

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String mainCategory;
  final String subCategory;
  final String lowestCategory;
  final String marketName;
  final double? highPrice;
  final String productLink;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.mainCategory,
    required this.subCategory,
    required this.lowestCategory,
    required this.marketName,
    this.highPrice,
    required this.productLink,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      imageUrl: json['image'] ?? json['image_url'] ?? '',
      mainCategory: json['category'] ?? json['main_category'] ?? '',
      subCategory: json['sub_category'] ?? '',
      lowestCategory: json['lowest_category'] ?? '',
      marketName: json['market_name'] ?? '',
      highPrice: json['high_price']?.toDouble(),
      productLink: json['product_link'] ?? '',
    );
  }
}
