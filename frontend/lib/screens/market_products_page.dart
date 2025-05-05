import 'package:flutter/material.dart';
import 'package:frontend/models/market_products.dart';
import 'package:frontend/models/cheapest_pc.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/screens/discounted_product_page.dart'
    show ProductDetailSheet;
import 'package:provider/provider.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:frontend/models/cart_model.dart';
import 'package:frontend/providers/recently_viewed_provider.dart';

class MarketProductsPage extends StatefulWidget {
  final MarketProducts marketData;

  const MarketProductsPage({
    Key? key,
    required this.marketData,
  }) : super(key: key);

  @override
  _MarketProductsPageState createState() => _MarketProductsPageState();
}

class _MarketProductsPageState extends State<MarketProductsPage> {
  Map<String, List<CheapestProductPc>> _categorizedProducts = {};

  @override
  void initState() {
    super.initState();
    _categorizeProducts();
  }

  void _categorizeProducts() {
    setState(() {
      _categorizedProducts = {};
      for (var product in widget.marketData.products) {
        String category = product.category ?? "Diğer";
        if (!_categorizedProducts.containsKey(category)) {
          _categorizedProducts[category] = [];
        }
        _categorizedProducts[category]?.add(product);
      }
    });
  }

  void _showProductDetail(BuildContext context, CheapestProductPc product) {
    try {
      context.read<RecentlyViewedProvider>().addItem(product);
    } catch (e) {
      // Provider might not be available, ignore
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => ProductDetailSheet(
          name: product.name ?? '',
          price: product.price ?? 0.0,
          image: product.image ?? '',
          category: product.category,
          marketName: product.marketName,
          scrollController: scrollController,
          id: product.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
                image: DecorationImage(
                  image: AssetImage(
                    _getMarketImage(widget.marketData.marketName),
                  ),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.marketData.marketName,
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '${widget.marketData.products.length} ürün',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          ),
          ..._categorizedProducts.entries.map((entry) {
            return SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      entry.key,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: entry.value.length,
                    itemBuilder: (context, index) {
                      final product = entry.value[index];
                      return Consumer<CartProvider>(
                        builder: (context, cartProvider, child) {
                          return GestureDetector(
                            onTap: () => _showProductDetail(context, product),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusL),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                          top:
                                              Radius.circular(AppTheme.radiusL),
                                        ),
                                        child: SizedBox(
                                          height: 120,
                                          width: double.infinity,
                                          child: product.image != null &&
                                                  product.image!
                                                      .startsWith('http')
                                              ? Image.network(
                                                  product.image!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      color: Colors.grey[200],
                                                      child: Center(
                                                        child: Icon(
                                                          Icons
                                                              .image_not_supported_outlined,
                                                          color:
                                                              Colors.grey[400],
                                                          size: 32,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                )
                                              : Container(
                                                  color: Colors.grey[200],
                                                  child: Center(
                                                    child: Icon(
                                                      Icons
                                                          .image_not_supported_outlined,
                                                      color: Colors.grey[400],
                                                      size: 32,
                                                    ),
                                                  ),
                                                ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            borderRadius: BorderRadius.circular(
                                                AppTheme.radiusM),
                                          ),
                                          child: Text(
                                            "₺${product.price?.toStringAsFixed(2) ?? "0.00"}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            product.name ?? "Ürün Adı Yok",
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const Spacer(),
                                          SizedBox(
                                            width: double.infinity,
                                            height: 30,
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                final cartItem = CartItem(
                                                  name: product.name ??
                                                      "Ürün Adı Yok",
                                                  price: product.price ?? 0.0,
                                                  image: product.image ?? "",
                                                );
                                                cartProvider.addItem(cartItem);

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        '${product.name} sepete eklendi!'),
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    action: SnackBarAction(
                                                      label: 'Geri Al',
                                                      onPressed: () {
                                                        cartProvider.removeItem(
                                                            cartItem);
                                                      },
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(
                                                  Icons.add_shopping_cart,
                                                  size: 14),
                                              label: const Text('Sepete Ekle',
                                                  style:
                                                      TextStyle(fontSize: 11)),
                                              style: ElevatedButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                minimumSize: const Size(0, 30),
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .primaryColor,
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _getMarketImage(String marketName) {
    marketName = marketName.toLowerCase();
    if (marketName.contains('a101')) return 'images/a101.png';
    if (marketName.contains('bim')) return 'images/bim.png';
    if (marketName.contains('carrefour')) return 'images/carrefour.png';
    if (marketName.contains('migros')) return 'images/migros.png';
    if (marketName.contains('şok')) return 'images/şok.png';
    return 'images/default.png';
  }
}
