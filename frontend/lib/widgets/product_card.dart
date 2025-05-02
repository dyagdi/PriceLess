import 'package:flutter/material.dart';
import 'package:frontend/models/product_search_result.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/widgets/category_badge.dart';
import 'package:frontend/theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final double price;
  final double? highPrice;
  final String imageUrl;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final String? category;
  final String? marketName;

  const ProductCard({
    required this.name,
    required this.price,
    this.highPrice,
    required this.imageUrl,
    required this.onTap,
    required this.onAddToCart,
    this.category,
    this.marketName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final discountPercentage = highPrice != null
        ? ((highPrice! - price) / highPrice! * 100).round()
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 270, // Fixed height to prevent overflow
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
            // Product image with discount badge and favorite icon
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
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      color: Colors.grey[600],
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            // Product details section with better spacing
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Category and market badges with constrained height
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

                    // Product name with fixed height
                    SizedBox(
                      height: 40, // Fixed height for name
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),

                    // Price section
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

                    // Spacer to push button to the bottom
                    const Spacer(),

                    // Add to cart button always at the bottom
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
