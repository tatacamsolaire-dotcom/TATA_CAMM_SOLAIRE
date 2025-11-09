
import 'dart:convert';

class Sale {
  String id;
  String productId;
  String productName;
  int quantity;
  double unitPrice;
  double totalPrice;
  String clientCity;
  String clientName;
  String clientPhone;
  DateTime date;

  Sale({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.clientCity,
    required this.clientName,
    required this.clientPhone,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
        'clientCity': clientCity,
        'clientName': clientName,
        'clientPhone': clientPhone,
        'date': date.toIso8601String(),
      };

  factory Sale.fromMap(Map<String, dynamic> map) => Sale(
        id: map['id'],
        productId: map['productId'],
        productName: map['productName'],
        quantity: (map['quantity'] ?? 0).toInt(),
        unitPrice: (map['unitPrice'] ?? 0).toDouble(),
        totalPrice: (map['totalPrice'] ?? 0).toDouble(),
        clientCity: map['clientCity'] ?? '',
        clientName: map['clientName'] ?? '',
        clientPhone: map['clientPhone'] ?? '',
        date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      );

  String get label => '$productName x$quantity';

  String toJson() => json.encode(toMap());
  factory Sale.fromJson(String s) => Sale.fromMap(json.decode(s));
}
