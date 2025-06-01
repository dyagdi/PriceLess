import 'package:flutter/material.dart';
import 'package:frontend/models/market_products.dart';
import 'package:frontend/models/cheapest_pc.dart';
import 'package:frontend/services/market_service.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:frontend/models/cart_model.dart';
import 'package:frontend/widgets/bottom_navigation.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/screens/discounted_product_page.dart'
    show ProductDetailSheet;
import 'package:frontend/providers/recently_viewed_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/screens/market_products_page.dart';
import 'package:frontend/screens/home_page.dart';

class MarketsPage extends StatefulWidget {
  final Map<String, List<dynamic>> categorizedProducts;

  const MarketsPage({super.key, this.categorizedProducts = const {}});

  @override
  _MarketsPageState createState() => _MarketsPageState();
}

class _MarketsPageState extends State<MarketsPage> {
  List<MarketProducts> marketProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMarketProducts();
  }

  Future<void> loadMarketProducts() async {
    try {
      final fetchedMarketProducts = await fetchMarketProducts();
      setState(() {
        marketProducts = fetchedMarketProducts;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false,
            );
          },
        ),
        title: Text(
          'Marketler',
          style: GoogleFonts.poppins(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(8.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final marketData = marketProducts[index];
                        return MarketSection(marketData: marketData);
                      },
                      childCount: marketProducts.length,
                    ),
                  ),
                ),
                // Add some bottom padding
                SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 3,
        categorizedProducts: widget.categorizedProducts,
      ),
    );
  }
}

class MarketSection extends StatelessWidget {
  final MarketProducts marketData;

  const MarketSection({
    super.key,
    required this.marketData,
  });

  @override
  Widget build(BuildContext context) {
    // Market image mapping
    final Map<String, String> marketImages = {
      "Carrefour": "images/carrefour.png",
      "A101": "images/a101.png",
      "Şok": "images/şok.png",
      "Migros": "images/migros.png",
    };

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Market header
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusL),
                topRight: Radius.circular(AppTheme.radiusL),
              ),
            ),
            child: Row(
              children: [
                // Market logo as an image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
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
                        marketImages[marketData.marketName] ??
                            'images/default.png',
                      ),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        marketData.marketName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${marketData.products.length} ürün",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Products horizontal list
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Ürünler",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: marketData.products.length,
                    itemBuilder: (context, index) {
                      final product = marketData.products[index];
                      return SizedBox(
                        width: 160,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: MarketProductCard(
                            product: product,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // View all button
          if (marketData.products.length > 5)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MarketProductsPage(
                          marketData: marketData,
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                  ),
                  child: Text(
                    "Tüm Ürünleri Gör",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MarketProductCard extends StatelessWidget {
  final CheapestProductPc product;

  const MarketProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return GestureDetector(
          onTap: () => _showProductDetail(context, product),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
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
                // Product image
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppTheme.radiusL),
                      ),
                      child: SizedBox(
                        height: 120,
                        width: double.infinity,
                        child: product.image != null &&
                                product.image!.startsWith('http')
                            ? Image.network(
                                product.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    child: Center(
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        size: 32,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Theme.of(context).colorScheme.surface,
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    size: 32,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    // Price tag
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
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

                // Product details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Product name
                        Text(
                          product.name ?? "Ürün Adı Yok",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const Spacer(),

                        // Add to cart button
                        SizedBox(
                          width: double.infinity,
                          height: 30,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final cartItem = CartItem(
                                name: product.name ?? "Ürün Adı Yok",
                                price: product.price ?? 0.0,
                                image: product.image ?? "",
                              );
                              cartProvider.addItem(cartItem);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('${product.name} sepete eklendi!'),
                                  behavior: SnackBarBehavior.floating,
                                  action: SnackBarAction(
                                    label: 'Geri Al',
                                    onPressed: () {
                                      cartProvider.removeItem(cartItem);
                                    },
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_shopping_cart, size: 14),
                            label: const Text('Sepete Ekle',
                                style: TextStyle(fontSize: 11)),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 30),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: Theme.of(context).primaryColor,
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
  }

  void _showProductDetail(BuildContext context, CheapestProductPc product) {
    // Add to recently viewed if provider exists
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
}
