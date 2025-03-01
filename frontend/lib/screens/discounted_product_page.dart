import 'package:flutter/material.dart';
import 'package:frontend/models/cart_model.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:frontend/services/product_service.dart';
import 'package:frontend/widgets/category_badge.dart';
import 'package:frontend/widgets/product_card.dart';
import 'package:provider/provider.dart';
// ignore: unused_import
import 'package:share_plus/share_plus.dart';

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
      ),
      body: FutureBuilder<List<Product>>(
        future: _discountedProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
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
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer_outlined,
                      size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'İndirimli ürün bulunamadı',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          final products = snapshot.data!;
          final groupedProducts = _groupByCategory(products);

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Günün İndirimleri',
                    style: Theme.of(context).textTheme.headlineLarge,
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
            ],
          );
        },
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
          padding: const EdgeInsets.all(16.0),
          child: Text(
            category,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
                  padding: const EdgeInsets.only(right: 16),
                  child: ProductCard(
                    name: product.name,
                    price: product.price,
                    highPrice: product.highPrice,
                    imageUrl: product.imageUrl,
                    onTap: () => _showProductDetail(context, product),
                    onAddToCart: () => _addToCart(context, product),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showProductDetail(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => ProductDetailSheet(
          name: product.name,
          price: product.price,
          image: product.imageUrl,
          highPrice: product.highPrice,
          category: product.mainCategory,
          scrollController: scrollController,
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

  const ProductDetailSheet({
    super.key,
    required this.name,
    required this.price,
    required this.image,
    required this.scrollController,
    this.highPrice,
    this.category,
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
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset("images/default.png");
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (category != null) ...[
                  CategoryBadge(category: category!),
                  const SizedBox(height: 12),
                ],
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      "₺${price.toStringAsFixed(2)}",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (highPrice != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        "₺${highPrice!.toStringAsFixed(2)}",
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).secondaryHeaderColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "-%$discountPercentage",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
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
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Sepete Ekle'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
