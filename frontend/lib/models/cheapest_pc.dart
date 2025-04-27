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
  final double? price;
  final String? image;
  final String? category;

  CheapestProductPc({
    this.id,
    this.name,
    this.price,
    this.image,
    this.category,
  });

  factory CheapestProductPc.fromJson(Map<String, dynamic> json) {
    return CheapestProductPc(
      id: json['_id'] ?? json['id'] ?? DateTime.now().toString(),
      name: json['name'],
      price: json['price']?.toDouble(),
      image: json['image'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "price": price,
        "image": image,
        "category": category,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheapestProductPc &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
