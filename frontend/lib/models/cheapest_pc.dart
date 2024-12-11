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
  String? name;
  double? price;
  String? image;
  String? category;

  CheapestProductPc({
    this.name,
    this.price,
    this.image,
    this.category,
  });

  factory CheapestProductPc.fromJson(Map<String, dynamic> json) =>
      CheapestProductPc(
        name: json["name"],
        price: json["price"]?.toDouble(),
        image: json["image"],
        category: json["category"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "price": price,
        "image": image,
        "category": category,
      };
}
