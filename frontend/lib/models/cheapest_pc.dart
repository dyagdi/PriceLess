// To parse this JSON data, do
//
//     final cheapestProductPc = cheapestProductPcFromJson(jsonString);

import 'dart:convert';

List<CheapestProductPc> cheapestProductPcFromJson(String str) =>
    List<CheapestProductPc>.from(
        json.decode(str).map((x) => CheapestProductPc.fromJson(x)));

String cheapestProductPcToJson(List<CheapestProductPc> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CheapestProductPc {
  final String? id;
  final String name;
  final double price;
  final String? image;
  final String? category;
  final String? marketName;
  final double? highPrice;
  final String? productLink;

  CheapestProductPc({
    this.id,
    required this.name,
    required this.price,
    this.image,
    this.category,
    this.marketName,
    this.highPrice,
    this.productLink,
  });

  factory CheapestProductPc.fromJson(Map<String, dynamic> json) {
    return CheapestProductPc(
      id: json['id'],
      name: json['name'] ?? 'Ürün Adı',
      price: (json['price'] ?? 0.0).toDouble(),
      image: json['image'],
      category: json['category'],
      marketName: json['market_name'],
      highPrice: json['high_price']?.toDouble(),
      productLink: json['product_link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'category': category,
      'market_name': marketName,
      'high_price': highPrice,
      'product_link': productLink,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheapestProductPc &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
