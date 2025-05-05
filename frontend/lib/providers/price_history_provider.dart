import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/config/api_config.dart';

class PriceHistoryProvider with ChangeNotifier {
  final Map<String, List<Map<String, dynamic>>> _cache = {};
  final Map<String, DateTime> _lastFetchTime = {};
  static const Duration _cacheDuration = Duration(hours: 1);

  List<Map<String, dynamic>>? getPriceHistory(String productName) {
    final now = DateTime.now();
    final lastFetch = _lastFetchTime[productName];

    if (lastFetch != null && now.difference(lastFetch) < _cacheDuration) {
      return _cache[productName];
    }
    return null;
  }

  void setPriceHistory(String productName, List<Map<String, dynamic>> history) {
    _cache[productName] = history;
    _lastFetchTime[productName] = DateTime.now();
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> fetchPriceHistory(
      String productName) async {
    // Check cache first
    final cachedData = getPriceHistory(productName);
    if (cachedData != null) {
      return cachedData;
    }

    // If not in cache or expired, fetch from API
    final url = Uri.parse(
        '${ApiConfig.baseUrl}/price-history?name=${Uri.encodeComponent(productName)}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      final history = List<Map<String, dynamic>>.from(data);

      // Cache the result
      setPriceHistory(productName, history);
      return history;
    } else {
      return [];
    }
  }

  void clearCache() {
    _cache.clear();
    _lastFetchTime.clear();
    notifyListeners();
  }
}
