import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/product_comparison.dart';
import 'package:frontend/models/comparable_product.dart';

class ComparisonService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Fetch comparison data for a specific product by canonical name
  static Future<ProductComparison?> getProductComparison(
      String canonicalName) async {
    try {
      print(
          "Making API request to: $baseUrl/products/comparison/$canonicalName/");
      final response = await http.get(
        Uri.parse('$baseUrl/products/comparison/$canonicalName/'),
      );

      print("API response status code: ${response.statusCode}");
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print("API response body: $jsonData");
        return ProductComparison.fromJson(jsonData);
      } else {
        print('Failed to load product comparison: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching product comparison: $e');
      return null;
    }
  }

  // Search for similar products by name
  static Future<ProductComparison?> searchSimilarProducts(
      String productName) async {
    try {
      // Encode the product name for URL
      final encodedName = Uri.encodeComponent(productName);
      print("Making API request to: $baseUrl/products/search/$encodedName/");

      final response = await http.get(
        Uri.parse('$baseUrl/products/search/$encodedName/'),
      );

      print("API response status code: ${response.statusCode}");
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print("API response body: $jsonData");
        return ProductComparison.fromJson(jsonData);
      } else {
        print('Failed to search similar products: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error searching similar products: $e');
      return null;
    }
  }

  // Get product comparison data, trying multiple methods
  static Future<ProductComparison?> getProductComparisonData(
      String? canonicalName, String productName) async {
    // First try using canonical name if available
    if (canonicalName != null && canonicalName.isNotEmpty) {
      final comparison = await getProductComparison(canonicalName);
      if (comparison != null) {
        return comparison;
      }
    }

    // If canonical name doesn't work, try searching by product name
    final searchResult = await searchSimilarProducts(productName);
    if (searchResult != null) {
      return searchResult;
    }

    // If all else fails, return mock data
    return getMockProductComparison(productName);
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

  Future<List<ComparableProduct>> fetchProductsInMultipleMarkets() async {
    try {
      // Try the new endpoint first
      final url = Uri.parse('http://127.0.0.1:8000/api/similar-products/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print('Successfully loaded similar products');
        return comparableProductsFromJson(response.body);
      } else {
        print('Failed to load similar products: ${response.statusCode}');
        print('Response body: ${response.body}');

        // Fall back to the old endpoint
        return _fetchProductsWithCanonicalNames();
      }
    } catch (e) {
      print('Error fetching similar products: $e');
      // Fall back to the old endpoint
      return _fetchProductsWithCanonicalNames();
    }
  }

  // Fallback method using canonical names
  Future<List<ComparableProduct>> _fetchProductsWithCanonicalNames() async {
    try {
      final url =
          Uri.parse('http://127.0.0.1:8000/api/products-in-multiple-markets/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print('Successfully loaded products with canonical names');
        return comparableProductsFromJson(response.body);
      } else {
        print(
            'Failed to load products with canonical names: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching products with canonical names: $e');
      return [];
    }
  }

  // Search for similar products by name
  Future<ProductComparison?> searchProductByName(String productName) async {
    try {
      // Encode the product name for URL
      final encodedName = Uri.encodeComponent(productName);
      print(
          "Making API request to: http://127.0.0.1:8000/api/products/search/$encodedName/");

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/products/search/$encodedName/'),
      );

      print("API response status code: ${response.statusCode}");
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print("API response body: $jsonData");
        return ProductComparison.fromJson(jsonData);
      } else {
        print('Failed to search similar products: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error searching similar products: $e');
      return null;
    }
  }
}
