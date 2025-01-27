import 'dart:convert';
import 'package:frontend/models/cheapest_pc.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/models/product_search_result.dart';

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

Future<List<ProductSearchResult>> searchProducts(String query) async {
  final response = await http.get(Uri.parse('http://localhost:8000/api/search/?q=$query'));

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(response.body);

    // Map the json response to a list of ProductSearchResult objects
    return jsonData.map((data) => ProductSearchResult.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load search results');
  }
}
