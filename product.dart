
import 'dart:convert';

class Product {
  String id;
  String name;
  String description;
  double buyPrice;
  double sellPrice;
  int quantity;
  String? imagePath;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.buyPrice,
    required this.sellPrice,
    required this.quantity,
    this.imagePath,
  });

  double get stockValue => sellPrice * quantity;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'buyPrice': buyPrice,
        'sellPrice': sellPrice,
        'quantity': quantity,
        'imagePath': imagePath,
      };

  factory Product.fromMap(Map<String, dynamic> map) => Product(
        id: map['id'],
        name: map['name'] ?? '',
        description: map['description'] ?? '',
        buyPrice: (map['buyPrice'] ?? 0).toDouble(),
        sellPrice: (map['sellPrice'] ?? 0).toDouble(),
        quantity: (map['quantity'] ?? 0).toInt(),
        imagePath: map['imagePath'],
      );

  String toJson() => json.encode(toMap());
  factory Product.fromJson(String s) => Product.fromMap(json.decode(s));
}
