
import 'dart:io';

import 'package:uuid/uuid.dart';

import '../models/product.dart';
import '../models/sale.dart';
import 'storage_service.dart';

class AppRepository {
  final storage = StorageService();
  final _uuid = const Uuid();

  List<Product> products = [];
  List<Sale> sales = [];

  Future<void> load() async {
    final data = await storage.readAll();
    products = (data['products'] as List).map((e) => Product.fromMap(e)).toList();
    sales = (data['sales'] as List).map((e) => Sale.fromMap(e)).toList();
  }

  Future<void> _persist() async {
    await storage.writeAll({
      'products': products.map((e) => e.toMap()).toList(),
      'sales': sales.map((e) => e.toMap()).toList(),
    });
  }

  // Products
  Future<void> addOrUpdateProduct(Product p) async {
    final idx = products.indexWhere((e) => e.id == p.id);
    if (idx == -1) {
      products.add(p);
    } else {
      products[idx] = p;
    }
    await _persist();
  }

  Future<void> deleteAllProducts() async {
    products.clear();
    await _persist();
  }

  Product newProduct() => Product(
        id: _uuid.v4(),
        name: '',
        description: '',
        buyPrice: 0,
        sellPrice: 0,
        quantity: 0,
      );

  // Sales
  Future<Sale> createSale({
    required Product product,
    required int quantity,
    required String city,
    required String clientName,
    required String clientPhone,
    required DateTime date,
  }) async {
    final total = product.sellPrice * quantity;
    final sale = Sale(
      id: _uuid.v4(),
      productId: product.id,
      productName: product.name,
      quantity: quantity,
      unitPrice: product.sellPrice,
      totalPrice: total,
      clientCity: city,
      clientName: clientName,
      clientPhone: clientPhone,
      date: date,
    );
    sales.add(sale);
    product.quantity -= quantity;
    await _persist();
    return sale;
  }

  Future<void> clearHistory() async {
    sales.clear();
    await _persist();
  }

  Future<File> exportJson() => storage.exportJson();
  Future<void> importJson(File file) => storage.importJson(file);
}
