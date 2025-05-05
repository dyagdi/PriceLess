import 'package:flutter/material.dart';
import 'package:frontend/models/product_search_result.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/widgets/category_badge.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/favorites_provider.dart';
import 'package:frontend/providers/recently_viewed_provider.dart';
import 'package:frontend/models/cheapest_pc.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final double price;
  final double? highPrice;
  final String imageUrl;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final String? category;
  final String? marketName;
  final String? id;

  const ProductCard({
    required this.name,
    required this.price,
    this.highPrice,
    required this.imageUrl,
    required this.onTap,
    required this.onAddToCart,
    this.category,
    this.marketName,
    this.id,
    Key? key,
  }) : super(key: key);

  void _handleTap(BuildContext context) {
    // Add to recently viewed
    try {
      final product = CheapestProductPc(
        id: id,
        name: name,
        price: price,
        image: imageUrl,
        category: category,
        marketName: marketName,
      );
      final provider = context.read<RecentlyViewedProvider>();
      provider.addItem(product);
      print('Added to recently viewed from ProductCard: $name');
      print('Current items count: ${provider.items.length}');
    } catch (e) {
      print('Error adding to recently viewed: $e');
    }

    // Call the original onTap
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    final discountPercentage = highPrice != null
        ? ((highPrice! - price) / highPrice! * 100).round()
        : null;

    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Container(
        height: 270,
        decoration: BoxDecoration(
          color: Colors.white,
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
            Stack(
              children: [
                Hero(
                  tag: 'product_image_$name',
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppTheme.radiusL),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 120,
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Colors.grey[400],
                                    size: 32,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.grey[400],
                                  size: 32,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                if (discountPercentage != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.mainRed,
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      ),
                      child: Text(
                        '-%$discountPercentage',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Consumer<FavoritesProvider>(
                    builder: (context, favoritesProvider, child) {
                      final isFavorite = favoritesProvider.isFavorite(name);
                      print('Product $name is favorite: $isFavorite');
                      return GestureDetector(
                        onTap: () {
                          print('Tapping favorite button for product: $name');
                          final product = CheapestProductPc(
                            id: id,
                            name: name,
                            price: price,
                            image: imageUrl,
                            category: category,
                            marketName: marketName,
                          );
                          favoritesProvider.toggleFavorite(product);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey[600],
                            size: 18,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      height: (category != null || marketName != null) ? 26 : 0,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (category != null && category!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: CategoryBadge(category: category!),
                              ),
                            if (category != null &&
                                category!.isNotEmpty &&
                                marketName != null &&
                                marketName!.isNotEmpty)
                              const SizedBox(width: 4),
                            if (marketName != null && marketName!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
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
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 40,
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₺${price.toStringAsFixed(2)}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                        ),
                        const SizedBox(width: 4),
                        if (highPrice != null)
                          Expanded(
                            child: Text(
                              '₺${highPrice!.toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey[600],
                                    fontSize: 10,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 30,
                      child: ElevatedButton.icon(
                        onPressed: onAddToCart,
                        icon: const Icon(Icons.add_shopping_cart, size: 14),
                        label: const Text('Sepete Ekle',
                            style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
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
  }
}
