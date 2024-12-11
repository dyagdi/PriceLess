import 'dart:convert';
import 'package:frontend/models/cheapest_pc.dart';
import 'package:http/http.dart' as http;

Future<List<CheapestProductPc>> fetchCheapestProductsPerCategory() async {
  final url =
      Uri.parse('http://127.0.0.1:8000/api/cheapest-products-per-category/');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return cheapestProductPcFromJson(response.body);
  } else {
    throw Exception('Failed to load products');
  }
}
