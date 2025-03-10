import 'package:flutter/material.dart';
import 'package:frontend/models/cart_model.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:frontend/services/product_service.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/widgets/category_badge.dart';
import 'package:frontend/widgets/product_card.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:frontend/providers/favorites_provider.dart';
import 'package:frontend/models/cheapest_pc.dart';

class DiscountedProductPage extends StatefulWidget {
  @override
  _DiscountedProductPageState createState() => _DiscountedProductPageState();
}

class _DiscountedProductPageState extends State<DiscountedProductPage> {
  late Future<List<Product>> _discountedProducts;

  @override
  void initState() {
    super.initState();
    _discountedProducts = fetchDiscountedProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İndirimli Ürünler'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(
                'PriceLess uygulamasında harika indirimler var! Hemen indir ve tasarruf et!',
                subject: 'İndirimli Ürünler',
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _discountedProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          } else if (snapshot.hasError) {
            return _buildErrorState();
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final products = snapshot.data!;
          final groupedProducts = _groupByCategory(products);

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Günün İndirimleri',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'En iyi fiyatlarla alışveriş yapın ve tasarruf edin',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              ...groupedProducts.entries.map((entry) {
                return SliverToBoxAdapter(
                  child: CategorySection(
                    category: entry.key,
                    products: entry.value,
                  ),
                );
              }).toList(),
              // Add some bottom padding
              SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'İndirimli ürünler yükleniyor...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Bir hata oluştu',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Lütfen daha sonra tekrar deneyin',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _discountedProducts = fetchDiscountedProducts();
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'İndirimli ürün bulunamadı',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Daha sonra tekrar kontrol edin',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Map<String, List<Product>> _groupByCategory(List<Product> products) {
    final Map<String, List<Product>> groupedProducts = {};
    for (final product in products) {
      if (groupedProducts.containsKey(product.mainCategory)) {
        groupedProducts[product.mainCategory]!.add(product);
      } else {
        groupedProducts[product.mainCategory] = [product];
      }
    }
    return groupedProducts;
  }
}

class CategorySection extends StatelessWidget {
  final String category;
  final List<Product> products;

  const CategorySection({
    Key? key,
    required this.category,
    required this.products,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  category,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to category detail page
                },
                child: const Text('Tümünü Gör'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return SizedBox(
                width: 160,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ProductCard(
                    name: product.name,
                    price: product.price,
                    highPrice: product.highPrice,
                    imageUrl: product.imageUrl,
                    category: product.mainCategory,
                    onTap: () => _showProductDetail(context, product),
                    onAddToCart: () => _addToCart(context, product),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showProductDetail(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => ProductDetailSheet(
          name: product.name,
          price: product.price,
          image: product.imageUrl,
          highPrice: product.highPrice,
          category: product.mainCategory,
          scrollController: scrollController,
          id: product.id,
        ),
      ),
    );
  }

  void _addToCart(BuildContext context, Product product) {
    final cartItem = CartItem(
      name: product.name,
      price: product.price,
      image: product.imageUrl,
    );

    Provider.of<CartProvider>(context, listen: false).addItem(cartItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} sepete eklendi!'),
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

class ProductDetailSheet extends StatelessWidget {
  final String name;
  final double price;
  final String image;
  final double? highPrice;
  final String? category;
  final ScrollController scrollController;
  final String? id;

  const ProductDetailSheet({
    super.key,
    required this.name,
    required this.price,
    required this.image,
    required this.scrollController,
    this.highPrice,
    this.category,
    this.id,
  });

  @override
  Widget build(BuildContext context) {
    final discountPercentage = highPrice != null
        ? ((highPrice! - price) / highPrice! * 100).round()
        : null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: Image.network(
                              image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Colors.grey[400],
                                      size: 48,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        // Favorite button
                        if (id != null)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: _buildFavoriteButton(context),
                          ),
                      ],
                    ),
                  ),

                  // Category badge and product details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category badge
                        if (category != null && category!.isNotEmpty) ...[
                          CategoryBadge(category: category!),
                          const SizedBox(height: 8),
                        ],

                        // Product name and favorite button
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Price information
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Text(
                              "₺${price.toStringAsFixed(2)}",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            if (highPrice != null) ...[
                              Text(
                                "₺${highPrice!.toStringAsFixed(2)}",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                    ),
                              ),
                              if (discountPercentage != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "-%$discountPercentage",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),

                        // Product description (placeholder)
                        Text(
                          'Ürün Açıklaması',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bu ürün hakkında detaylı bilgi bulunmamaktadır. Ürün özellikleri ve içeriği hakkında bilgi almak için lütfen satıcı ile iletişime geçin.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[700],
                                  ),
                        ),

                        const SizedBox(height: 24),

                        // Add to cart button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final cartItem = CartItem(
                                name: name,
                                price: price,
                                image: image,
                              );
                              Provider.of<CartProvider>(context, listen: false)
                                  .addItem(cartItem);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$name sepete eklendi!'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.shopping_cart),
                            label: const Text('Sepete Ekle'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        // Add bottom padding to ensure content doesn't get cut off
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    // Use try-catch to handle the case where FavoritesProvider might not be available
    try {
      return Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          final isFavorite = id != null && favoritesProvider.isFavorite(id);

          return GestureDetector(
            onTap: () {
              if (id == null) return;

              // Create a product object to toggle
              final product = CheapestProductPc(
                id: id,
                name: name,
                price: price,
                image: image,
                category: category,
              );

              favoritesProvider.toggleFavorite(product);

              // Show a snackbar to confirm the action
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFavorite
                        ? '$name favorilerden çıkarıldı'
                        : '$name favorilere eklendi',
                  ),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey,
                size: 24,
              ),
            ),
          );
        },
      );
    } catch (e) {
      // If FavoritesProvider is not available, return an empty container
      return Container();
    }
  }
}
