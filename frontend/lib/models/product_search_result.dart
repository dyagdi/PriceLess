class ProductSearchResult {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final String marketName;
  final String productLink;

  ProductSearchResult({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.marketName,
    required this.productLink,
  });

  factory ProductSearchResult.fromJson(Map<String, dynamic> json) {
    return ProductSearchResult(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      imageUrl: json['image_url'],
      marketName: json['market_name'],
      productLink: json['product_link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image_url': imageUrl,
      'market_name': marketName,
      'product_link': productLink,
    };
  }
}
