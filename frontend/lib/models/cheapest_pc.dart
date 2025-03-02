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
  final String? name;
  final String? normalizedName;
  final String? canonicalName;
  final double? price;
  final String? image;
  final String? category;
  final String? marketName;

  CheapestProductPc({
    this.id,
    this.name,
    this.normalizedName,
    this.canonicalName,
    this.price,
    this.image,
    this.category,
    this.marketName,
  });

  factory CheapestProductPc.fromJson(Map<String, dynamic> json) {
    return CheapestProductPc(
      id: json['id'],
      name: json['name'],
      normalizedName: json['normalized_name'],
      canonicalName: json['canonical_name'],
      price:
          json['price'] != null ? double.parse(json['price'].toString()) : null,
      image: json['image'],
      category: json['category'],
      marketName: json['market_name'],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "price": price,
        "image": image,
        "category": category,
      };
}
