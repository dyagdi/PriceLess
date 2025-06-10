import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/constants/colors.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/cart_provider.dart';
import 'package:frontend/providers/theme_provider.dart';
import 'package:frontend/models/cart_model.dart';

class ChatMessageWidget extends StatefulWidget {
  final String message;
  final bool isUser;

  const ChatMessageWidget({
    Key? key,
    required this.message,
    required this.isUser,
  }) : super(key: key);

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> {
  final Map<String, bool> _addedToCart = {};

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: widget.isUser ? _buildUserMessage() : _buildBotMessage(context),
      ),
    );
  }

  Widget _buildUserMessage() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.mainGreen,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        widget.message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildBotMessage(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: _parseAndDisplayMessage(context),
    );
  }

  Widget _parseAndDisplayMessage(BuildContext context) {
    // Check if message contains product information (prices, TL, etc.)
    if (_isProductMessage()) {
      return _buildStructuredProductMessage(context);
    } else {
      return _buildPlainTextMessage(context);
    }
  }

  bool _isProductMessage() {
    return widget.message.contains('TL') ||
        widget.message.contains('fiyat') ||
        widget.message.contains('Ürüne git') ||
        widget.message.contains('https://');
  }

  Widget _buildPlainTextMessage(BuildContext context) {
    return Text(
      widget.message,
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color,
        fontSize: 15,
        height: 1.4,
      ),
    );
  }

  Widget _buildStructuredProductMessage(BuildContext context) {
    // Parse products from the message
    final products = _parseProducts();

    if (products.isEmpty) {
      return _buildPlainTextMessage(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_hasIntroText()) ...[
          Text(
            _getIntroText(),
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 15,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
        ],
        ...products
            .map((product) => _buildProductCard(product, context))
            .toList(),
      ],
    );
  }

  bool _hasIntroText() {
    return widget.message.contains('fiyatlar') ||
        widget.message.contains('şöyle:') ||
        widget.message.contains('mevcut');
  }

  String _getIntroText() {
    final lines = widget.message.split('\n');
    final firstLine = lines.first.trim();

    if (firstLine.contains('*') || firstLine.contains('TL')) {
      return 'Aradığınız ürünler:';
    }

    return firstLine;
  }

  List<ProductInfo> _parseProducts() {
    final products = <ProductInfo>[];
    final lines = widget.message.split('\n');

    for (final line in lines) {
      // Look for lines that start with * and contain ** around product names
      if (line.trim().startsWith('*') &&
          line.contains('**') &&
          line.contains('TL')) {
        final product = _parseProductLine(line);
        if (product != null) {
          products.add(product);
        }
      }
    }

    return products;
  }

  ProductInfo? _parseProductLine(String line) {
    try {
      // Handle the new format with product names in **
      final nameMatch = RegExp(r'\*\*(.*?)\*\*').firstMatch(line);
      if (nameMatch == null) return null;

      String name = nameMatch.group(1)?.trim() ?? '';

      // Find the price pattern (number + TL)
      final pricePattern = RegExp(r'(\d+[,.]?\d*)\s*TL');
      final priceMatch = pricePattern.firstMatch(line);
      if (priceMatch == null) return null;

      final priceStr = priceMatch.group(1)!.replaceAll(',', '.');
      final price = double.tryParse(priceStr);
      if (price == null) return null;

      // Extract URL if present
      String? url;
      if (line.contains('[Ürüne git]')) {
        final urlMatch = RegExp(r'\[Ürüne git\]\((.*?)\)').firstMatch(line);
        if (urlMatch != null) {
          url = urlMatch.group(1);
        }
      }

      // Extract market name from format: **Product** - Market - Price TL
      String? marketName;
      String? imageUrl;

      // Use regex to match the entire pattern and extract market name and image URL
      final fullPattern = RegExp(
          r'\*\*(.*?)\*\*\s*-\s*(.*?)\s*-\s*(\d+[,.]?\d*)\s*TL\s*(?:\[image:(.*?)\])?');
      final fullMatch = fullPattern.firstMatch(line);
      if (fullMatch != null && fullMatch.groupCount >= 2) {
        marketName = fullMatch.group(2)?.trim();
        if (fullMatch.groupCount >= 4) {
          imageUrl = fullMatch.group(4)?.trim();
        }
      }

      return ProductInfo(
        name: name,
        marketName: marketName,
        price: price,
        url: url,
        imageUrl: imageUrl,
      );
    } catch (e) {
      print('Error parsing product line: $e');
      return null;
    }
  }

  void _showElegantNotification(BuildContext context, String productName) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => ElegantToast(
        message: '$productName sepete eklendi!',
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  Widget _buildProductCard(ProductInfo product, BuildContext context) {
    final isAdded = _addedToCart[product.name] ?? false;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            InkWell(
              onTap: () async {
                if (product.url != null) {
                  try {
                    // Try the newer API first (works on simulator)
                    final uri = Uri.parse(product.url!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    } else {
                      // Fallback to older API (works on real devices)
                      if (await canLaunch(product.url!)) {
                        await launch(product.url!);
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Bu bağlantı açılamadı')),
                          );
                        }
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Bağlantı hatası: $e')),
                      );
                    }
                  }
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  // Product Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.mainGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.shopping_basket_outlined,
                      color: AppColors.mainGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Product Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              product.marketName ?? '',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${product.price.toStringAsFixed(2)} TL',
                              style: TextStyle(
                                color: AppColors.mainGreen,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
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
            const SizedBox(height: 8),
            // Add to Cart Button with elegant feedback
            SizedBox(
              width: double.infinity,
              child: Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: ElevatedButton.icon(
                      onPressed: isAdded
                          ? null
                          : () async {
                              final cartItem = CartItem(
                                name: product.name,
                                price: product.price,
                                image: product.imageUrl ?? '',
                              );

                              cartProvider.addItem(cartItem);

                              // Update button state
                              setState(() {
                                _addedToCart[product.name] = true;
                              });

                              // Show elegant notification
                              _showElegantNotification(context, product.name);

                              // Reset button state after 3 seconds
                              Future.delayed(const Duration(seconds: 3), () {
                                if (mounted) {
                                  setState(() {
                                    _addedToCart[product.name] = false;
                                  });
                                }
                              });
                            },
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          isAdded
                              ? Icons.check_circle
                              : Icons.add_shopping_cart,
                          size: 16,
                          key: ValueKey(isAdded),
                        ),
                      ),
                      label: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          isAdded ? 'Eklendi!' : 'Sepete Ekle',
                          key: ValueKey(isAdded),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isAdded ? Colors.green : AppColors.mainGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: isAdded ? 0 : 2,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ElegantToast extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;

  const ElegantToast({
    Key? key,
    required this.message,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<ElegantToast> createState() => _ElegantToastState();
}

class _ElegantToastState extends State<ElegantToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -100,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    // Auto dismiss animation
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.mainGreen,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _controller.reverse().then((_) => widget.onDismiss());
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProductInfo {
  final String name;
  final String? marketName;
  final double price;
  final String? url;
  final String? imageUrl;

  ProductInfo({
    required this.name,
    this.marketName,
    required this.price,
    this.url,
    this.imageUrl,
  });
}
