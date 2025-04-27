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
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/config/api_config.dart';

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

  // Helper function to truncate long product names
  String _truncateName(String name) {
    if (name.length > 18) {
      return name.substring(0, 18) + "...";
    }
    return name;
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

  // Helper function to truncate long product names
  String _truncateName(String name) {
    if (name.length > 18) {
      return name.substring(0, 18) + "...";
    }
    return name;
  }

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
                width: 180,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ProductCard(
                    name: _truncateName(product.name),
                    price: product.price,
                    highPrice: product.highPrice,
                    imageUrl: product.imageUrl,
                    category: product.mainCategory,
                    marketName: product.marketName,
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
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => ProductDetailSheet(
          name: product.name,
          price: product.price,
          image: product.imageUrl,
          highPrice: product.highPrice,
          category: product.mainCategory,
          marketName: product.marketName,
          scrollController: scrollController,
          id: product.id,
          productLink: product.productLink,
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

    // Use a truncated name for the snackbar message if it's too long
    final displayName = _truncateName(product.name);

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

class ProductDetailSheet extends StatelessWidget {
  final String name;
  final double price;
  final String image;
  final double? highPrice;
  final String? category;
  final String? marketName;
  final ScrollController scrollController;
  final String? id;
  final String? productLink;

  const ProductDetailSheet({
    super.key,
    required this.name,
    required this.price,
    required this.image,
    required this.scrollController,
    this.highPrice,
    this.category,
    this.marketName,
    this.id,
    this.productLink,
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
      child: SafeArea(
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
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.zero,
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
                        // Category badge and market name
                        Row(
                          children: [
                            if (category != null && category!.isNotEmpty)
                              CategoryBadge(category: category!),
                            if (category != null &&
                                category!.isNotEmpty &&
                                marketName != null &&
                                marketName!.isNotEmpty)
                              const SizedBox(width: 8),
                            if (marketName != null && marketName!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusS),
                                  border: Border.all(
                                      color: Colors.blue.withOpacity(0.3)),
                                ),
                                child: Text(
                                  marketName!,
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Product name
                        Text(
                          name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
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

                        // Product description
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

                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),

                        // Comparison section
                        Text(
                          'Diğer Marketlerdeki Fiyatlar',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _buildComparisonSection(context),

                        // Add extra bottom padding for a better look and to make room for the button
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom fixed button - always visible at the bottom
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
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
            ),
          ],
        ),
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
                marketName: marketName,
                highPrice: highPrice,
                productLink: productLink,
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

  Widget _buildComparisonSection(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _fetchSimilarProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green[400]!),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Fiyat karşılaştırması yüklenirken bir hata oluştu',
              style: TextStyle(color: Colors.red[400]),
            ),
          );
        }

        final similarProducts = snapshot.data ?? [];

        if (similarProducts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Diğer marketlerde benzer ürün bulunamadı',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: similarProducts.map<Widget>((product) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    // Product image
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: product['imageUrl'].isNotEmpty
                          ? Image.network(
                              product['imageUrl'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.broken_image,
                                  size: 24,
                                  color: Colors.grey[400],
                                );
                              },
                            )
                          : Icon(
                              Icons.image_not_supported,
                              size: 24,
                              color: Colors.grey[400],
                            ),
                    ),
                    const SizedBox(width: 12),
                    // Product details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  product['marketName'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₺${product['price'].toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (product['highPrice'] != null)
                                    Text(
                                      '₺${product['highPrice'].toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<List<dynamic>> _fetchSimilarProducts() async {
    try {
      final Uri uri = Uri.parse('${ApiConfig.baseUrl}/search').replace(
        queryParameters: {
          'query': name,
          'collection': 'SupermarketProducts',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data
            .where((product) =>
                product['product_link'] != productLink &&
                product['market_name'] != marketName)
            .map((product) => {
                  'name': product['name'] ?? '',
                  'price': (product['price'] ?? 0.0).toDouble(),
                  'imageUrl': product['image_url'] ?? '',
                  'marketName': product['market_name'] ?? '',
                  'highPrice': product['high_price']?.toDouble(),
                  'productLink': product['product_link'] ?? '',
                })
            .take(3)
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching similar products: $e');
      return [];
    }
  }
}
