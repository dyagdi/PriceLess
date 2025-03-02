import 'package:flutter/material.dart';
import 'package:frontend/models/cart_model.dart';
import 'package:frontend/models/product_comparison.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:frontend/services/comparison_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
    if (widget.canonicalName != null && widget.canonicalName!.isNotEmpty) {
      try {
        // Use the real API when it's ready
        // final comparison = await ComparisonService.getProductComparison(widget.canonicalName!);

        // For now, use mock data
        final comparison =
            await ComparisonService.getMockProductComparison(widget.name);

        setState(() {
          _comparison = comparison;
          _isLoading = false;
        });
      } catch (e) {
        print('Error loading comparison data: $e');
        setState(() {
          _isLoading = false;
        });
      }
    } else {
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
          Text(
            "En ucuz: ${_comparison!.cheapestMarket} (₺${_comparison!.minPrice.toStringAsFixed(2)})",
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "En pahalı: ${_comparison!.mostExpensiveMarket} (₺${_comparison!.maxPrice.toStringAsFixed(2)})",
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
          Text(
            "Fiyat farkı: %${_comparison!.priceDiffPercent.toStringAsFixed(2)}",
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

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 8),
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
                    trailing: Text(
                      "₺${marketPrice.price.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCheapest ? Colors.green : null,
                      ),
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
    // You can replace these with actual market logos
    final Map<String, Color> marketColors = {
      'Migros': Colors.orange,
      'Carrefour': Colors.blue,
      'A101': Colors.blue.shade900,
      'Şok': Colors.yellow.shade700,
      'BİM': Colors.red,
    };

    final color = marketColors[marketName] ?? Colors.grey;

    return CircleAvatar(
      backgroundColor: color,
      child: Text(
        marketName.substring(0, 1),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
