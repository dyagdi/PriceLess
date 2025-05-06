import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_navigation.dart';
import 'cart_page.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:frontend/services/market_comparison_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/constants/constants_url.dart';
import 'package:google_fonts/google_fonts.dart';

class WalkingPage extends StatefulWidget {
  const WalkingPage({super.key});

  @override
  State<WalkingPage> createState() => _WalkingPageState();
}

class _WalkingPageState extends State<WalkingPage> {
  double _currentValue = 3.0;
  bool _isLoading = true;
  String _error = '';
  List<Map<String, dynamic>> _marketComparisons = [];
  List<Map<String, dynamic>> _nearbyMarkets = [];
  double _userLatitude = 0.0;
  double _userLongitude = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Get user's location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      setState(() {
        _userLatitude = position.latitude;
        _userLongitude = position.longitude;
      });

      // Get market comparisons
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final comparisons = await MarketComparisonService.compareProducts(
        cartProvider.cartItems
      );

      // Get nearby markets with prices
      final response = await http.get(
        Uri.parse('${baseUrl}nearby-markets/?latitude=$_userLatitude&longitude=$_userLongitude&radius=6500')
      );

      if (response.statusCode == 200) {
        final List<dynamic> marketsData = json.decode(response.body);
        
        setState(() {
          _marketComparisons = comparisons;
          _nearbyMarkets = List<Map<String, dynamic>>.from(marketsData);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load nearby markets');
      }
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _error = 'Veriler yüklenirken bir hata oluştu.';
        _isLoading = false;
      });
    }
  }

  double _calculateMarketScore(Map<String, dynamic> market) {
    // Find matching market in nearby markets
    final marketName = market['marketName'].toLowerCase();
    final nearbyMarket = _nearbyMarkets.firstWhere(
      (m) {
        final name = m['name'].toLowerCase();
        // Check for various market name variations
        return name.contains(marketName) || 
               marketName.contains(name) ||
               (marketName == 'mopas' && name.contains('mopaş')) ||
               (marketName == 'migros' && name.contains('migros')) ||
               (marketName == 'sokmarket' && name.contains('şok')) ||
               (marketName == 'marketpaketi' && name.contains('market paketi')) ||
               (marketName == 'carrefour' && name.contains('carrefour'));
      },
      orElse: () => {
        'distance': 5.0,
        'total_price': null,
        'has_price_data': false
      }
    );

    final distance = nearbyMarket['distance'] as double;
    final price = market['totalPrice'] as double;
    final hasPriceData = market['totalPrice'] != null;  // Use price data from market comparison instead

    // Normalize values
    final maxDistance = 5.0; // Maximum distance we consider
    final maxPrice = _marketComparisons.isNotEmpty 
        ? _marketComparisons[0]['totalPrice'] * 1.5 // Use 1.5x the cheapest price as max
        : 1000.0;

    final normalizedDistance = distance / maxDistance;
    final normalizedPrice = price / maxPrice;

    // Calculate weights based on user preference
    final distanceWeight = 1.0 - (_currentValue / 4.0); // 0 to 1
    final priceWeight = _currentValue / 4.0; // 0 to 1

    // Calculate score (lower is better)
    double score = (normalizedDistance * distanceWeight) + (normalizedPrice * priceWeight);
    
    // Penalize markets without price data
    if (!hasPriceData) {
      score *= 1.5;
    }

    return score;
  }

  List<Map<String, dynamic>> _getRecommendations() {
    if (_marketComparisons.isEmpty) return [];

    return List<Map<String, dynamic>>.from(_marketComparisons)
      ..sort((a, b) {
        final scoreA = _calculateMarketScore(a);
        final scoreB = _calculateMarketScore(b);
        return scoreA.compareTo(scoreB);
      });
  }

  @override
  Widget build(BuildContext context) {
    final recommendations = _getRecommendations();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kendim Alacağım',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ne kadar uzağa gitmek istersiniz?',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Stack(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: Theme.of(context).primaryColor,
                                inactiveTrackColor: Theme.of(context).primaryColor.withOpacity(0.3),
                                thumbColor: Theme.of(context).primaryColor,
                                overlayColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                trackHeight: 4.0,
                                trackShape: const RectangularSliderTrackShape(),
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                              ),
                              child: Slider(
                                value: _currentValue,
                                min: 0,
                                max: 4,
                                divisions: 4,
                                onChanged: (value) {
                                  setState(() {
                                    _currentValue = value;
                                  });
                                },
                              ),
                            ),
                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(5, (index) {
                                    return Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _currentValue >= index 
                                            ? Theme.of(context).primaryColor 
                                            : Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Mesafe Önemli',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Fiyat Önemli',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          'Önerilen Marketler',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...recommendations.map((market) {
                          final marketName = market['marketName'];
                          final nearbyMarket = _nearbyMarkets.firstWhere(
                            (m) {
                              final name = m['name'].toLowerCase();
                              final marketNameLower = marketName.toLowerCase();
                              return name.contains(marketNameLower) || 
                                     marketNameLower.contains(name) ||
                                     (marketNameLower == 'mopas' && name.contains('mopaş')) ||
                                     (marketNameLower == 'migros' && name.contains('migros')) ||
                                     (marketNameLower == 'sokmarket' && name.contains('şok')) ||
                                     (marketNameLower == 'marketpaketi' && name.contains('market paketi')) ||
                                     (marketNameLower == 'carrefour' && name.contains('carrefour'));
                            },
                            orElse: () => {
                              'distance': 5.0,
                              'has_price_data': false,
                              'total_price': null
                            }
                          );
                          final distance = nearbyMarket['distance'] as double;
                          final price = market['totalPrice'] as double;
                          final isComplete = market['isComplete'] as bool;
                          final hasPriceData = market['totalPrice'] != null;  // Use price data from market comparison

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              marketName,
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${distance.toStringAsFixed(1)} km uzaklıkta',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isComplete 
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.orange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          isComplete ? 'Tüm ürünler mevcut' : 'Bazı ürünler eksik',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: isComplete ? Colors.green : Colors.orange,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Toplam Tutar:',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        hasPriceData 
                                            ? '${price.toStringAsFixed(2)} TL'
                                            : 'Fiyat bilgisi yok',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: hasPriceData 
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 0),
    );
  }
} 