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
  Map<String, List<Map<String, dynamic>>> _marketProducts = {};
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
        _marketProducts = comparison;
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
        backgroundColor: Colors.white,
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
              : _marketProducts.isEmpty
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
                      itemCount: _marketProducts.length,
                      itemBuilder: (context, index) {
                        final productName =
                            _marketProducts.keys.elementAt(index);
                        final prices = _marketProducts[productName]!;
                        final productImage =
                            prices.isNotEmpty ? prices[0]['image'] : null;
                        final productCategory =
                            prices.isNotEmpty ? prices[0]['category'] : null;

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
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: productImage != null &&
                                              productImage.isNotEmpty
                                          ? Image.network(
                                              productImage,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Container(
                                                width: 60,
                                                height: 60,
                                                color: Colors.grey[200],
                                                child: Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.grey[400]),
                                              ),
                                            )
                                          : Container(
                                              width: 60,
                                              height: 60,
                                              color: Colors.grey[200],
                                              child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey[400]),
                                            ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(productName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge),
                                          if (productCategory != null)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4.0),
                                              child: Text(productCategory,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                          color: Colors
                                                              .grey[600])),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  separatorBuilder: (context, idx) => Divider(
                                      height: 1, color: Colors.grey[200]),
                                  itemCount: prices.length,
                                  itemBuilder: (context, priceIndex) {
                                    final priceInfo = prices[priceIndex];
                                    final isCheapest = priceIndex == 0;
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: isCheapest
                                          ? Icon(Icons.star,
                                              color: AppTheme.primaryColor)
                                          : Icon(Icons.store,
                                              color: AppTheme.primaryColor
                                                  .withOpacity(0.5)),
                                      title: Text(priceInfo['marketName'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge),
                                      subtitle: Text(
                                        '₺${priceInfo['price'].toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: isCheapest
                                              ? AppTheme.successColor
                                              : AppTheme.textSecondary,
                                          fontWeight: isCheapest
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      trailing: isCheapest
                                          ? Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppTheme.successColor
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text('En Ucuz',
                                                  style: TextStyle(
                                                      color:
                                                          AppTheme.successColor,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            )
                                          : null,
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
