class ProductSearchResult {
  // final int id; // Removed id
  final String name;
  final double price;
  final String imageUrl;
  final String marketName;
  final String productLink;
  final String mainCategory; // Added
  final String subCategory; // Added
  final String lowestCategory; // Added
  final double? highPrice; // Added (nullable)

  ProductSearchResult({
    // required this.id, // Removed id
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.marketName,
    required this.productLink,
    required this.mainCategory, // Added
    required this.subCategory, // Added
    required this.lowestCategory, // Added
    this.highPrice, // Added (nullable)
  });

  factory ProductSearchResult.fromJson(Map<String, dynamic> json) {
    // Helper to safely convert to double, returning null if input is null
    double? tryParseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return ProductSearchResult(
      // id: json['id'], // Removed id
      name: json['name'] ?? 'Unknown Name', // Added null check
      price:
          tryParseDouble(json['price']) ?? 0.0, // Use helper, provide default
      imageUrl: json['image_url'] ?? '', // Added null check
      marketName: json['market_name'] ?? 'Unknown Market', // Added null check
      productLink: json['product_link'] ?? '', // Added null check
      mainCategory: json['main_category'] ?? 'Unknown Category', // Added
      subCategory: json['sub_category'] ?? 'Unknown Category', // Added
      lowestCategory: json['lowest_category'] ?? 'Unknown Category', // Added
      highPrice: tryParseDouble(json['high_price']), // Added, handle null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id, // Removed id
      'name': name,
      'price': price,
      'image_url': imageUrl,
      'market_name': marketName,
      'product_link': productLink,
      'main_category': mainCategory, // Added
      'sub_category': subCategory, // Added
      'lowest_category': lowestCategory, // Added
      'high_price': highPrice, // Added
    };
  }
}
