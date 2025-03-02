import 'package:frontend/models/cheapest_pc.dart';

class MarketProducts {
  final String marketName;
  final List<CheapestProductPc> products;

  MarketProducts({
    required this.marketName,
    required this.products,
  });

  factory MarketProducts.fromJson(Map<String, dynamic> json) {
    return MarketProducts(
      marketName: json['marketName'],
      products: (json['products'] as List)
          .map((product) => CheapestProductPc.fromJson(product))
          .toList(),
    );
  }
}