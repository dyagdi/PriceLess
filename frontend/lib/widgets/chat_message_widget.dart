import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/constants/colors.dart';

class ChatMessageWidget extends StatelessWidget {
  final String message;
  final bool isUser;

  const ChatMessageWidget({
    Key? key,
    required this.message,
    required this.isUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: isUser ? _buildUserMessage() : _buildBotMessage(context),
      ),
    );
  }

  Widget _buildUserMessage() {
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildBotMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
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
    return message.contains('TL') || 
           message.contains('fiyat') || 
           message.contains('Ürüne git') ||
           message.contains('https://');
  }

  Widget _buildPlainTextMessage(BuildContext context) {
    return Text(
      message,
      style: TextStyle(
        color: AppTheme.textPrimary,
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
              color: AppTheme.textPrimary,
              fontSize: 15,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
        ],
        ...products.map((product) => _buildProductCard(product)).toList(),
      ],
    );
  }

  bool _hasIntroText() {
    return message.contains('fiyatlar') || 
           message.contains('şöyle:') ||
           message.contains('mevcut');
  }

  String _getIntroText() {
    final lines = message.split('\n');
    final firstLine = lines.first.trim();
    
    if (firstLine.contains('*') || firstLine.contains('TL')) {
      return 'Aradığınız ürünler:';
    }
    
    return firstLine;
  }

  List<ProductInfo> _parseProducts() {
    final products = <ProductInfo>[];
    final lines = message.split('\n');
    
    for (final line in lines) {
      // Look for lines that start with * and contain ** around product names
      if (line.trim().startsWith('*') && line.contains('**') && line.contains('TL')) {
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
      final fullPattern = RegExp(r'\*\*(.*?)\*\*\s*-\s*(.*?)\s*-\s*(\d+[,.]?\d*)\s*TL\s*(?:\[image:(.*?)\])?');
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

  Widget _buildProductCard(ProductInfo product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (product.url != null) {
            launchUrl(Uri.parse(product.url!));
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
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
                        color: AppTheme.textPrimary,
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
                            color: AppTheme.textSecondary,
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