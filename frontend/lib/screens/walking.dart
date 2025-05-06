import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_navigation.dart';
import 'cart_page.dart';

class WalkingPage extends StatefulWidget {
  const WalkingPage({super.key});

  @override
  State<WalkingPage> createState() => _WalkingPageState();
}

class _WalkingPageState extends State<WalkingPage> {
  double _currentValue = 3.0; 

  
  final Map<String, Map<String, dynamic>> _markets = {
    'Migros': {
      'price': 45.90,
      'distance': 0.5, 
      'color': Colors.blue,
    },
    'Şok': {
      'price': 35.90, 
      'distance': 1.5, 
      'color': Colors.red,
    },
    'A101': {
      'price': 25.90, 
      'distance': 3.0, 
      'color': Colors.orange,
    },
  };

  double _calculateMarketScore(Map<String, dynamic> market) {
   
    final distanceWeight = 1.0 - (_currentValue / 5.0); 
    final priceWeight = _currentValue / 5.0;
    
    
    final normalizedDistance = market['distance'] / 5.0;
    final normalizedPrice = market['price'] / 100.0;
    
    
    return (normalizedDistance * distanceWeight) + (normalizedPrice * priceWeight);
  }

  
  List<String> _getRecommendations() {
    final List<MapEntry<String, Map<String, dynamic>>> sortedMarkets = 
        _markets.entries.toList()
          ..sort((a, b) {
            final scoreA = _calculateMarketScore(a.value);
            final scoreB = _calculateMarketScore(b.value);
            return scoreA.compareTo(scoreB);
          });

    return sortedMarkets.map((e) => e.key).toList();
  }

  @override
  Widget build(BuildContext context) {
    final recommendations = _getRecommendations();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kendim Alacağım'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const Text(
                'Ne kadar uzağa gitmek istersiniz?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Stack(
                children: [
                  
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.green,
                      inactiveTrackColor: Colors.green.withOpacity(0.3),
                      thumbColor: Colors.green,
                      overlayColor: Colors.green.withOpacity(0.1),
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
                  // Dots
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
                              color: _currentValue >= index ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 30),
              const Text(
                'Carrefour Süt 200 Ml',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ..._markets.entries.map((market) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: market.value['color'],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            market.key,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '₺${market.value['price'].toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${market.value['distance']} km)',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Önerilen Market Sıralaması',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...recommendations.asMap().entries.map((entry) {
                      final market = entry.key;
                      final rank = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${market + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              rank,
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(
        currentIndex: 4,
      ),
    );
  }
} 