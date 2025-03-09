import 'dart:convert';
import 'package:frontend/models/comparable_product.dart';
import 'package:http/http.dart' as http;

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
