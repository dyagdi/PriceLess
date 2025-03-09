import 'dart:convert';

List<ComparableProduct> comparableProductsFromJson(String str) =>
    List<ComparableProduct>.from(
        json.decode(str).map((x) => ComparableProduct.fromJson(x)));

class ComparableProduct {
  final String id;
  final String name;
  final String? normalizedName;
  final String? canonicalName;
  final double price;
  final String image;
  final String marketName;
  final String? productLink;
  final int availableMarkets;
  final PriceRange priceRange;

  ComparableProduct({
    required this.id,
    required this.name,
    this.normalizedName,
    this.canonicalName,
    required this.price,
    required this.image,
    required this.marketName,
    this.productLink,
    required this.availableMarkets,
    required this.priceRange,
  });

  factory ComparableProduct.fromJson(Map<String, dynamic> json) {
    // Handle price safely
    double parsePrice(dynamic value) {
      if (value == null) return 0.0;
      try {
        if (value is num) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? 0.0;
        return 0.0;
      } catch (e) {
        print('Error parsing price: $e');
        return 0.0;
      }
    }

    // Handle price range safely
    PriceRange parsePriceRange(dynamic value) {
      if (value == null) {
        return PriceRange(min: 0.0, max: 0.0, diffPercent: 0.0);
      }
      try {
        return PriceRange.fromJson(value);
      } catch (e) {
        print('Error parsing price range: $e');
        return PriceRange(min: 0.0, max: 0.0, diffPercent: 0.0);
      }
    }

    return ComparableProduct(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      normalizedName: json['normalized_name'],
      canonicalName: json['canonical_name'],
      price: parsePrice(json['price']),
      image: json['image'] ?? '',
      marketName: json['market_name'] ?? '',
      productLink: json['product_link'],
      availableMarkets: json['available_markets'] ?? 0,
      priceRange: parsePriceRange(json['price_range']),
    );
  }
}

class PriceRange {
  final double min;
  final double max;
  final double diffPercent;

  PriceRange({
    required this.min,
    required this.max,
    required this.diffPercent,
  });

  factory PriceRange.fromJson(Map<String, dynamic> json) {
    // Handle numeric values safely
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      try {
        if (value is num) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? 0.0;
        return 0.0;
      } catch (e) {
        print('Error parsing double: $e');
        return 0.0;
      }
    }

    return PriceRange(
      min: parseDouble(json['min']),
      max: parseDouble(json['max']),
      diffPercent: parseDouble(json['diff_percent']),
    );
  }
}
