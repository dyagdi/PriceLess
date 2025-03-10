import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/market_products.dart';
import 'package:frontend/constants/constants_url.dart';

Future<List<MarketProducts>> fetchMarketProducts() async {
  try {
    final response = await http.get(Uri.parse('${baseUrl}markets-products/'));
    
    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      List<dynamic> marketsJson = json.decode(response.body);
      return marketsJson.map((json) => MarketProducts.fromJson(json)).toList();
    } else {
      print('Error status code: ${response.statusCode}');
      throw Exception('Failed to load market products: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching market products: $e');
    throw Exception('Failed to load market products: $e');
  }
}