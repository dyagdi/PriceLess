import 'dart:convert';
import 'package:frontend/models/cheapest_pc.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/models/product_search_result.dart';
import 'package:frontend/config/api_config.dart';

Future<List<ProductSearchResult>> searchProducts(String query) async {
  final response = await http
      .get(Uri.parse('https://priceless.onrender.com/api/search/?q=$query'));

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
      'https://priceless.onrender.com/api/cheapest-products-per-category/');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return cheapestProductPcFromJson(response.body);
  } else {
    throw Exception('Failed to load products');
  }
}

Future<List<CheapestProductPc>> fetchCheapestProductsByCategories() async {
  final url = Uri.parse(
      'https://priceless.onrender.com/api/cheapest-products-by-categories/');
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
      Uri.parse('https://priceless.onrender.com/api/discounted-products/'),
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

class ProductService {
  static Map<String, dynamic>? _cachedCategorizedProducts;
  static DateTime? _lastFetchTime;
  static const Duration _cacheExpiration = Duration(minutes: 5);

  static Future<Map<String, List<dynamic>>> getCategorizedProducts() async {
    // Check if we have valid cached data
    if (_cachedCategorizedProducts != null && _lastFetchTime != null) {
      final now = DateTime.now();
      if (now.difference(_lastFetchTime!) < _cacheExpiration) {
        return Map<String, List<dynamic>>.from(_cachedCategorizedProducts!);
      }
    }

    Map<String, List<dynamic>> newCategorizedProducts = {};
    
    try {
      final List<CheapestProductPc> fetchedProducts = await fetchProducts();

      final Map<String, String> normalizedCategoryMapping = {
        'Meyve, Sebze': 'Meyve ve Sebze',
        'Meyve & Sebze': 'Meyve ve Sebze',
        'Sebze & Meyve': 'Meyve ve Sebze',
        'Sebzeler': 'Meyve ve Sebze',
        'Meyveler': 'Meyve ve Sebze',
        'İçecek': 'İçecekler',
        'İçecekler': 'İçecekler',
        'Et, Tavuk, Balık': 'Et, Tavuk ve Balık',
        'Et & Tavuk & Şarküteri': 'Et, Tavuk ve Balık',
        'Kırmızı/Beyaz Et': 'Et, Tavuk ve Balık',
        'Et Ürünleri': 'Et, Tavuk ve Balık',
        'Temel Gıda': 'Temel Gıda',
        'Yemeklik Malzemeler': 'Temel Gıda',
        'Gıda & Şekerleme': 'Temel Gıda',
        'GIDA': 'Temel Gıda',
        'Dondurulmuş Gıda': 'Dondurulmuş Gıda',
        'Dondurulmuş Ürünler': 'Dondurulmuş Gıda',
        'Hazır Yemek&Donuk Ürünler': 'Dondurulmuş Gıda',
      };

      // Process products with normalized categories
      for (var product in fetchedProducts) {
        String originalCategory = product.category ?? "Uncategorized";
        String normalizedCategory = normalizedCategoryMapping[originalCategory] ?? originalCategory;

        if (!newCategorizedProducts.containsKey(normalizedCategory)) {
          newCategorizedProducts[normalizedCategory] = [];
        }
        newCategorizedProducts[normalizedCategory]?.add(product);
      }

      // Cache the results
      _cachedCategorizedProducts = Map<String, dynamic>.from(newCategorizedProducts);
      _lastFetchTime = DateTime.now();

      return newCategorizedProducts;
    } catch (e) {
      print('Error fetching categorized products: $e');
      // If there's an error, return cached data if available, otherwise empty map
      return _cachedCategorizedProducts?.cast<String, List<dynamic>>() ?? {};
    }
  }

  static Future<List<CheapestProductPc>> fetchProducts() async {
    try {
      // First try to fetch from our new specific categories endpoint
      final List<CheapestProductPc> specificCategoryProducts = await fetchCheapestProductsByCategories();
      
      if (specificCategoryProducts.isNotEmpty) {
        return specificCategoryProducts;
      }
      
      // If specific categories are empty, fall back to regular categories
      return await fetchCheapestProductsPerCategory();
    } catch (e) {
      print('Error in fetchProducts: $e');
      // If both attempts fail, return empty list rather than null
      return [];
    }
  }
}
