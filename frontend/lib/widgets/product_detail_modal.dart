import 'package:flutter/material.dart';
import 'package:frontend/models/cart_model.dart';
import 'package:frontend/models/product_comparison.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:frontend/services/comparison_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:frontend/services/comparison_service.dart'
    show searchProductByName;

class ProductDetailModal extends StatefulWidget {
  final String name;
  final double price;
  final String image;
  final String? canonicalName;

  const ProductDetailModal({
    Key? key,
    required this.name,
    required this.price,
    required this.image,
    this.canonicalName,
  }) : super(key: key);

  @override
  _ProductDetailModalState createState() => _ProductDetailModalState();
}

class _ProductDetailModalState extends State<ProductDetailModal> {
  ProductComparison? _comparison;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComparisonData();
  }

  Future<void> _loadComparisonData() async {
    try {
      print("Loading comparison data for product: ${widget.name}");
      print("Canonical name (if available): ${widget.canonicalName}");

      ProductComparison? comparison;

      // Try using canonical name if available
      if (widget.canonicalName != null && widget.canonicalName!.isNotEmpty) {
        try {
          comparison = await ComparisonService.getProductComparison(
              widget.canonicalName!);
        } catch (e) {
          print('Error loading comparison by canonical name: $e');
        }
      }

      // If that fails, use mock data
      if (comparison == null) {
        comparison =
            await ComparisonService.getMockProductComparison(widget.name);
      }

      setState(() {
        _comparison = comparison;
        _isLoading = false;
      });

      print("Loaded comparison data: ${_comparison?.canonicalName}");
      print("Number of markets: ${_comparison?.numMarkets}");
      print("Market prices: ${_comparison?.marketPrices.length} items");
    } catch (e) {
      print('Error loading comparison data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _launchURL(String? url) async {
    if (url != null && url.isNotEmpty) {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open the link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              // Header with close button, title and share button
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                      iconSize: 24,
                    ),
                    Expanded(
                      child: Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.share),
                      iconSize: 24,
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.grey, thickness: 0.5),

              // Product image
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.network(
                  widget.image,
                  height: 150,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'images/default.png',
                      height: 150,
                    );
                  },
                ),
              ),

              // Price comparison section
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _comparison == null
                        ? const Center(
                            child: Text('No comparison data available'))
                        : _buildComparisonSection(),
              ),

              // Bottom section with price and add to cart button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Divider(color: Colors.grey, thickness: 0.5),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "₺${widget.price.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            final cartItem = CartItem(
                              name: widget.name,
                              price: widget.price,
                              image: widget.image,
                            );

                            Provider.of<CartProvider>(context, listen: false)
                                .addItem(cartItem);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('${widget.name} sepete eklendi!')),
                            );

                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          child: const Text(
                            "Sepete Ekle",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Fiyat Karşılaştırması",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Price comparison summary card
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: Colors.blue, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "Bu ürün ${_comparison!.numMarkets} farklı markette bulundu",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.arrow_downward,
                          color: Colors.green, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "En ucuz: ${_comparison!.cheapestMarket} (₺${_comparison!.minPrice.toStringAsFixed(2)})",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.arrow_upward,
                          color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "En pahalı: ${_comparison!.mostExpensiveMarket} (₺${_comparison!.maxPrice.toStringAsFixed(2)})",
                          style: const TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.compare_arrows,
                          color: Colors.orange, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "Fiyat farkı: %${_comparison!.priceDiffPercent.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (_comparison!.priceDiffPercent > 20)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade100,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.yellow.shade700),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.savings,
                              color: Colors.yellow.shade800, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Bu ürünü ${_comparison!.cheapestMarket}'dan alarak %${_comparison!.priceDiffPercent.toStringAsFixed(2)} tasarruf edebilirsiniz!",
                              style: TextStyle(
                                color: Colors.yellow.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            "Marketlerdeki Fiyatlar",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _comparison!.marketPrices.length,
              itemBuilder: (context, index) {
                final marketPrice = _comparison!.marketPrices[index];
                final bool isCheapest =
                    marketPrice.market == _comparison!.cheapestMarket;
                final bool isMostExpensive =
                    marketPrice.market == _comparison!.mostExpensiveMarket;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 8),
                  color: isCheapest ? Colors.green.shade50 : null,
                  child: ListTile(
                    leading: _getMarketLogo(marketPrice.market),
                    title: Text(
                      marketPrice.market,
                      style: TextStyle(
                        fontWeight:
                            isCheapest ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: marketPrice.productLink != null
                        ? GestureDetector(
                            onTap: () => _launchURL(marketPrice.productLink),
                            child: const Text(
                              "Ürün sayfasına git",
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          )
                        : null,
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "₺${marketPrice.price.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isCheapest
                                ? Colors.green
                                : isMostExpensive
                                    ? Colors.red
                                    : null,
                          ),
                        ),
                        if (isCheapest)
                          const Text(
                            "En ucuz",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                            ),
                          ),
                        if (isMostExpensive)
                          const Text(
                            "En pahalı",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _getMarketLogo(String marketName) {
    // Market colors and first letters for the avatar
    final Map<String, Map<String, dynamic>> marketInfo = {
      'migros': {
        'color': Colors.orange,
        'letter': 'M',
        'icon': Icons.shopping_cart,
      },
      'carrefour': {
        'color': Colors.blue,
        'letter': 'C',
        'icon': Icons.shopping_basket,
      },
      'a101': {
        'color': Colors.blue.shade900,
        'letter': 'A',
        'icon': Icons.store,
      },
      'şok': {
        'color': Colors.yellow.shade700,
        'letter': 'Ş',
        'icon': Icons.local_grocery_store,
      },
      'sok': {
        'color': Colors.yellow.shade700,
        'letter': 'S',
        'icon': Icons.local_grocery_store,
      },
      'bim': {
        'color': Colors.red,
        'letter': 'B',
        'icon': Icons.storefront,
      },
      'mopas': {
        'color': Colors.purple,
        'letter': 'M',
        'icon': Icons.shopping_bag,
      },
      'marketpaketi': {
        'color': Colors.green,
        'letter': 'M',
        'icon': Icons.shopping_bag,
      },
    };

    final marketKey = marketName.toLowerCase();
    final info = marketInfo[marketKey] ??
        {
          'color': Colors.grey,
          'letter': marketName.isNotEmpty
              ? marketName.substring(0, 1).toUpperCase()
              : '?',
          'icon': Icons.store,
        };

    return CircleAvatar(
      backgroundColor: info['color'],
      child: Icon(
        info['icon'],
        color: Colors.white,
        size: 18,
      ),
    );
  }
}
