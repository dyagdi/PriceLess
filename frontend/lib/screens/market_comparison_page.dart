import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:frontend/services/market_comparison_service.dart';
import 'package:frontend/widgets/bottom_navigation.dart';
import 'package:frontend/models/cart_model.dart';
import 'package:frontend/theme/app_theme.dart';

class MarketComparisonPage extends StatefulWidget {
  const MarketComparisonPage({super.key});

  @override
  State<MarketComparisonPage> createState() => _MarketComparisonPageState();
}

class _MarketComparisonPageState extends State<MarketComparisonPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _marketComparisons = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadComparison();
  }

  Future<void> _loadComparison() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final comparison =
          await MarketComparisonService.compareProducts(cartProvider.cartItems);

      setState(() {
        _marketComparisons = comparison;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Ürünler karşılaştırılırken bir hata oluştu.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Karşılaştırma'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.primaryColor),
                  const SizedBox(height: 16),
                  Text('Ürünler karşılaştırılıyor...',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            )
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          color: AppTheme.errorColor, size: 48),
                      const SizedBox(height: 12),
                      Text(_error,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                )
              : _marketComparisons.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              color: Colors.grey[400], size: 48),
                          const SizedBox(height: 12),
                          Text('Karşılaştırılacak ürün bulunamadı.',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      separatorBuilder: (context, idx) =>
                          const SizedBox(height: 16),
                      itemCount: _marketComparisons.length,
                      itemBuilder: (context, index) {
                        final market = _marketComparisons[index];
                        final isComplete = market['isComplete'] as bool;
                        final isCheapest = index == 0 && isComplete;

                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusL),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isCheapest ? Icons.star : Icons.store,
                                      color: isCheapest
                                          ? AppTheme.primaryColor
                                          : AppTheme.primaryColor
                                              .withOpacity(0.5),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            market['marketName'],
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          if (!isComplete)
                                            Text(
                                              '${market['foundProducts']}/${market['totalProducts']} ürünler',
                                              style: TextStyle(
                                                color: market['isComplete']
                                                    ? Colors.green
                                                    : Colors.orange,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (isCheapest)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.successColor
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'En Ucuz',
                                          style: TextStyle(
                                            color: AppTheme.successColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Toplam Fiyat: ₺${market['totalPrice'].toStringAsFixed(2)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: isCheapest
                                            ? AppTheme.successColor
                                            : AppTheme.textSecondary,
                                        fontWeight: isCheapest
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 8),
                                Text(
                                  'Ürünler',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  separatorBuilder: (context, idx) =>
                                      const Divider(height: 1),
                                  itemCount: market['availableProducts'].length,
                                  itemBuilder: (context, productIndex) {
                                    final product = market['availableProducts']
                                        [productIndex];
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          product['image'] ?? '',
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            width: 50,
                                            height: 50,
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.image),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        product['name'] ?? 'İsimsiz Ürün',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                      subtitle: Text(
                                        product['category'] ?? 'Kategori Yok',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.grey[600]),
                                      ),
                                      trailing: Text(
                                        '₺${(product['price'] ?? 0.0).toStringAsFixed(2)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      bottomNavigationBar: const BottomNavigation(
        currentIndex: 4,
      ),
    );
  }
}
