import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/product_comparison.dart';

class ComparisonService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Fetch comparison data for a specific product by canonical name
  static Future<ProductComparison?> getProductComparison(
      String canonicalName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/comparison/$canonicalName/'),
      );

      if (response.statusCode == 200) {
        return ProductComparison.fromJson(json.decode(response.body));
      } else {
        print('Failed to load product comparison: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching product comparison: $e');
      return null;
    }
  }

  // For demo purposes, return mock data if the API is not ready
  static Future<ProductComparison> getMockProductComparison(
      String productName) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 800));

    return ProductComparison(
      canonicalName: productName,
      marketPrices: [
        MarketPrice(
            market: 'Migros',
            price: 32.50,
            productLink: 'https://www.migros.com.tr/product'),
        MarketPrice(
            market: 'Carrefour',
            price: 34.99,
            productLink: 'https://www.carrefoursa.com/product'),
        MarketPrice(
            market: 'A101',
            price: 31.90,
            productLink: 'https://www.a101.com.tr/product'),
        MarketPrice(
            market: 'Şok',
            price: 33.75,
            productLink: 'https://www.sokmarket.com.tr/product'),
      ],
      minPrice: 31.90,
      maxPrice: 34.99,
      priceDiffPercent: 9.69,
      cheapestMarket: 'A101',
      mostExpensiveMarket: 'Carrefour',
    );
  }
}
