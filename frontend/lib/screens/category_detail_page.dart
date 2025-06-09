import 'package:flutter/material.dart';
import 'package:frontend/models/cart_model.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/cheapest_pc.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/providers/recently_viewed_provider.dart';
import 'package:frontend/screens/discounted_product_page.dart'
    show ProductDetailSheet;
import 'package:frontend/widgets/product_card.dart'; // Import the ProductCard widget

class CategoryDetailPage extends StatefulWidget {
  final String category;
  final List<dynamic> products;
  final Map<String, List<dynamic>> categorizedProducts;

  const CategoryDetailPage({
    super.key,
    required this.category,
    required this.products,
    required this.categorizedProducts,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  // Map products by market name
  late Map<String, List<CheapestProductPc>> marketProducts;
  bool isGroupedByMarket = true; // Default view is grouped by market

  @override
  void initState() {
    super.initState();
    _organizeProductsByMarket();
  }

  void _organizeProductsByMarket() {
    marketProducts = {};

    for (var product in widget.products) {
      if (product is CheapestProductPc) {
        final marketName = product.marketName ?? 'Diğer';
        if (!marketProducts.containsKey(marketName)) {
          marketProducts[marketName] = [];
        }
        marketProducts[marketName]!.add(product);
      }
    }
  }

  // Helper function to truncate long product names
  String _truncateName(String name) {
    if (name.length > 25) {
      return '${name.substring(0, 25)}...';
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        actions: [
          // Toggle button for view type
          IconButton(
            icon: Icon(
              isGroupedByMarket ? Icons.view_list : Icons.grid_view,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              setState(() {
                isGroupedByMarket = !isGroupedByMarket;
              });
            },
            tooltip: isGroupedByMarket
                ? 'Tüm ürünleri göster'
                : 'Market bazında grupla',
          ),
        ],
      ),
      body: widget.products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bu kategoride ürün bulunamadı',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : isGroupedByMarket
              ? _buildGroupedByMarketView()
              : _buildGridView(widget.products),
    );
  }

  Widget _buildGroupedByMarketView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: marketProducts.entries.map((entry) {
          return _buildMarketSection(entry.key, entry.value);
        }).toList(),
      ),
    );
  }

  Widget _buildMarketSection(
      String marketName, List<CheapestProductPc> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Market header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.storefront, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      marketName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${products.length} ürün)',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        // Product grid for this market - Using a height that accommodates the button
        SizedBox(
          height: 280, // Increased height to accommodate the add to cart button
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              // Use the ProductCard directly instead of custom implementation
              return SizedBox(
                width: 170, // Slightly wider to prevent overflow
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ProductCard(
                    name: _truncateName(product.name ?? 'Ürün Adı Yok'),
                    price: product.price ?? 0.0,
                    imageUrl: product.image ?? '',
                    category: product.category,
                    marketName: product.marketName,
                    onTap: () => _showProductDetail(context, product),
                    onAddToCart: () => _addToCart(context, product),
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(height: 16, thickness: 1),
      ],
    );
  }

  Widget _buildGridView(List<dynamic> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(12.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio:
            0.58, // Adjusted ratio to give more height to the card
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index] as CheapestProductPc;

        // Use the ProductCard widget for consistency with HomePage
        return ProductCard(
          name: _truncateName(product.name ?? 'Ürün Adı Yok'),
          price: product.price ?? 0.0,
          imageUrl: product.image ?? '',
          category: product.category,
          marketName: product.marketName,
          onTap: () => _showProductDetail(context, product),
          onAddToCart: () => _addToCart(context, product),
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

  void _addToCart(BuildContext context, CheapestProductPc product) {
    final cartItem = CartItem(
      name: product.name ?? '',
      price: product.price ?? 0.0,
      image: product.image ?? '',
    );

    Provider.of<CartProvider>(context, listen: false).addItem(cartItem);

    // Use a truncated name for the snackbar message if it's too long
    final displayName = _truncateName(product.name ?? '');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$displayName sepete eklendi!'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Geri Al',
          onPressed: () {
            Provider.of<CartProvider>(context, listen: false)
                .removeItem(cartItem);
          },
        ),
      ),
    );
  }
}
