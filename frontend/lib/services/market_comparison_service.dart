import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/constants/constants_url.dart';
import 'package:frontend/models/cart_model.dart';

class MarketComparisonService {
  static Future<List<Map<String, dynamic>>> compareProducts(
      List<CartItem> cartItems) async {
    final List<Map<String, dynamic>> marketComparisons = [];
    final List<Map<String, dynamic>> incompleteMarketComparisons = [];

    try {
      // Fetch products from all markets
      final response = await http.get(Uri.parse('${baseUrl}markets-products/'));

      if (response.statusCode == 200) {
        final List<dynamic> marketsData = json.decode(response.body);
        print('Markets data: $marketsData'); // Debug log

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
            final marketData = {
              'marketName': marketName,
              'totalPrice': totalPrice,
              'products': availableProducts,
              'isComplete': availableProducts.length == cartItems.length,
            };

            // Separate complete and incomplete baskets
            if (availableProducts.length == cartItems.length) {
              marketComparisons.add(marketData);
            } else {
              incompleteMarketComparisons.add(marketData);
            }
          }
        }

        // Sort complete baskets by total price
        marketComparisons.sort((a, b) => 
          (a['totalPrice'] as double).compareTo(b['totalPrice'] as double));

        // Sort incomplete baskets by total price
        incompleteMarketComparisons.sort((a, b) => 
          (a['totalPrice'] as double).compareTo(b['totalPrice'] as double));

        // Combine the lists with complete baskets first
        return [...marketComparisons, ...incompleteMarketComparisons];
      }
    } catch (e) {
      print('Error comparing products: $e');
    }

    return marketComparisons;
  }

  static String _normalizeProductName(String name) {
    return name.toLowerCase().trim();
  }
}
