import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/constants/constants_url.dart';
import 'package:frontend/models/cart_model.dart';

class MarketComparisonService {
  static Future<List<Map<String, dynamic>>> compareProducts(
      List<CartItem> cartItems) async {
    final List<Map<String, dynamic>> marketComparisons = [];

    try {
      // Fetch products from all markets
      final response = await http.get(Uri.parse('${baseUrl}markets-products/'));

      if (response.statusCode == 200) {
        final List<dynamic> marketsData = json.decode(response.body);
        print('Markets data: $marketsData'); // Debug log

        // Get total number of unique products in cart
        final totalUniqueProducts = cartItems.length;

        // Process each market
        for (final market in marketsData) {
          final marketName = market['marketName'];
          final products = market['products'] as List;
          double totalPrice = 0;
          List<Map<String, dynamic>> availableProducts = [];

          // Check each product in cart against this market
          for (final cartItem in cartItems) {
            // Find matching product in this market
            final matchingProduct = products.firstWhere(
              (product) =>
                  _normalizeProductName(product['name']) ==
                  _normalizeProductName(cartItem.name),
              orElse: () => null,
            );

            if (matchingProduct != null) {
              totalPrice += matchingProduct['price'];
              availableProducts.add({
                'name': cartItem.name,
                'price': matchingProduct['price'],
                'image': matchingProduct['image'],
                'category': matchingProduct['category'],
              });
            }
          }

          // Only add markets that have at least one product
          if (availableProducts.isNotEmpty) {
            marketComparisons.add({
              'marketName': marketName,
              'totalPrice': totalPrice,
              'availableProducts': availableProducts,
              'totalProducts': totalUniqueProducts,
              'foundProducts': availableProducts.length,
              'isComplete': availableProducts.length == totalUniqueProducts,
            });
          }
        }

        // Sort markets by total price, with complete baskets first
        marketComparisons.sort((a, b) {
          // If one basket is complete and the other isn't, complete basket comes first
          if (a['isComplete'] != b['isComplete']) {
            return a['isComplete'] ? -1 : 1;
          }
          // If both are complete or both are incomplete, sort by total price
          return a['totalPrice'].compareTo(b['totalPrice']);
        });

        return marketComparisons;
      } else {
        print('Error fetching market products: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error in compareProducts: $e');
      return [];
    }
  }

  static String _normalizeProductName(String name) {
    return name.toLowerCase().trim();
  }
}
