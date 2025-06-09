import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:frontend/config/api_config.dart';

class PriceHistoryProvider with ChangeNotifier {
  final Map<String, List<Map<String, dynamic>>> _cache = {};
  final Map<String, DateTime> _lastFetchTime = {};
  static const Duration _cacheDuration = Duration(hours: 1);
  static const int _maxRetries = 3;
  static const Duration _timeoutDuration = Duration(seconds: 30);

  List<Map<String, dynamic>>? getPriceHistory(String productName) {
    final now = DateTime.now();
    final lastFetch = _lastFetchTime[productName];

    if (lastFetch != null && now.difference(lastFetch) < _cacheDuration) {
      return _cache[productName];
    }
    return null;
  }

  void setPriceHistory(String productName, List<Map<String, dynamic>> history) {
    // Validate and process the history data
    final processedHistory = history.map((item) {
      // Ensure price is a number
      final price = item['price'];
      if (price is String) {
        item['price'] = double.tryParse(price) ?? 0.0;
      } else if (price is num) {
        item['price'] = price.toDouble();
      } else {
        item['price'] = 0.0;
      }

      // Ensure date is in the correct format
      if (item['date'] is String) {
        try {
          final date = DateTime.parse(item['date']);
          item['date'] = date.toIso8601String();
        } catch (e) {
          print('Error parsing date: ${item['date']}');
          item['date'] = DateTime.now().toIso8601String();
        }
      }

      return item;
    }).toList();

    // Sort by date
    processedHistory.sort((a, b) =>
        DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));

    _cache[productName] = processedHistory;
    _lastFetchTime[productName] = DateTime.now();
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> _makeRequest(String productName) async {
    final url = Uri.parse(
        '${ApiConfig.baseUrl}/price-history?name=${Uri.encodeComponent(productName)}');

    final response = await http.get(url).timeout(
      _timeoutDuration,
      onTimeout: () {
        throw TimeoutException('The request timed out');
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      if (data.isEmpty) {
        return [];
      }
      return List<Map<String, dynamic>>.from(data);
    } else {
      print('Error fetching price history: ${response.statusCode}');
      throw Exception('Failed to load price history: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchPriceHistory(
      String productName) async {
    try {
      // Check cache first
      final cachedData = getPriceHistory(productName);
      if (cachedData != null) {
        return cachedData;
      }

      // Retry logic
      int retryCount = 0;
      while (retryCount < _maxRetries) {
        try {
          final history = await _makeRequest(productName);
          setPriceHistory(productName, history);
          return history;
        } catch (e) {
          retryCount++;
          if (retryCount == _maxRetries) {
            print(
                'Failed to fetch price history after $_maxRetries attempts: $e');
            rethrow;
          }
          // Wait before retrying (exponential backoff)
          await Future.delayed(Duration(seconds: retryCount * 2));
          print(
              'Retrying price history fetch (attempt ${retryCount + 1}/$_maxRetries)');
        }
      }
      throw Exception(
          'Failed to fetch price history after $_maxRetries attempts');
    } catch (e) {
      print('Error in fetchPriceHistory: $e');
      throw Exception('Failed to load price history: $e');
    }
  }

  void clearCache() {
    _cache.clear();
    _lastFetchTime.clear();
    notifyListeners();
  }
}
