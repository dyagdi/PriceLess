import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/constants/constants_url.dart';
import 'package:frontend/models/cart_model.dart';

class MarketComparisonService {
  static Future<Map<String, List<Map<String, dynamic>>>> compareProducts(
      List<CartItem> cartItems) async {
    final Map<String, List<Map<String, dynamic>>> marketProducts = {};

    try {
      // Fetch products from all markets
      final response = await http.get(Uri.parse('${baseUrl}markets-products/'));

      if (response.statusCode == 200) {
        final List<dynamic> marketsData = json.decode(response.body);
        print('Markets data: $marketsData'); // Debug log

        // Process each product in the cart
        for (final cartItem in cartItems) {
          final List<Map<String, dynamic>> productPrices = [];

          // Search for the product in each market
          for (final market in marketsData) {
            final marketName = market['marketName'];
            final products = market['products'] as List;
            print('Market products: $products'); // Debug log

            // Find matching product in this market
            final matchingProduct = products.firstWhere(
              (product) =>
                  _normalizeProductName(product['name']) ==
                  _normalizeProductName(cartItem.name),
              orElse: () => null,
            );

            if (matchingProduct != null) {
              print('Matching product: $matchingProduct'); // Debug log
              productPrices.add({
                'marketName': marketName,
                'price': matchingProduct['price'],
                'image': matchingProduct['image'],
                'category': matchingProduct['category'],
              });
            }
          }

          // Sort by price
          productPrices.sort(
              (a, b) => (a['price'] as double).compareTo(b['price'] as double));

          // Add to results
          marketProducts[cartItem.name] = productPrices;
        }
      }
    } catch (e) {
      print('Error comparing products: $e');
    }

    return marketProducts;
  }

  static String _normalizeProductName(String name) {
    return name.toLowerCase().trim();
  }
}
