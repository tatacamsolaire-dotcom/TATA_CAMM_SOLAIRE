
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/sale.dart';

class DashboardScreen extends StatefulWidget {
  final List<Product> products;
  final List<Sale> sales;
  final VoidCallback onGoProducts;
  final VoidCallback onGoSales;
  final VoidCallback onGoHistory;
  final VoidCallback onGoSettings;
  const DashboardScreen({
    super.key,
    required this.products,
    required this.sales,
    required this.onGoProducts,
    required this.onGoSales,
    required this.onGoHistory,
    required this.onGoSettings,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool byValue = false;

  @override
  Widget build(BuildContext context) {
    final totalProducts = widget.products.length;
    final stockTotal = widget.products.fold<int>(0, (p, e) => p + e.quantity);
    final stockValue = widget.products.fold<double>(0, (p, e) => p + (e.sellPrice * e.quantity));

    final revenue = widget.sales.fold<double>(0, (p, s) => p + s.totalPrice);
    final profit = widget.sales.fold<double>(0, (p, s) => p + (s.totalPrice - (s.quantity * _buyPrice(s.productId))));

    final barGroups = widget.products.asMap().entries.map((entry) {
      final idx = entry.key.toDouble();
      final p = entry.value;
      final y = byValue ? p.sellPrice * p.quantity : p.quantity.toDouble();
      return BarChartGroupData(x: idx.toInt(), barRods: [BarChartRodData(toY: y, width: 12)]);
    }).toList();

    final monthly = <String, double>{};
    for (final s in widget.sales) {
      final k = '${s.date.year}-${s.date.month.toString().padLeft(2,'0')}';
      monthly[k] = (monthly[k] ?? 0) + s.totalPrice;
    }
    final months = monthly.keys.toList()..sort();
    final lineSpots = List.generate(months.length, (i) => FlSpot(i.toDouble(), monthly[months[i]] ?? 0));

    final top = <String, int>{};
    for (final s in widget.sales) {
      top[s.productName] = (top[s.productName] ?? 0) + s.quantity;
    }
    final topList = top.entries.toList()..sort((a,b)=>b.value.compareTo(a.value));
    final top5 = topList.take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: _infoCard('Nombre de produits', '$totalProducts')),
            const SizedBox(width: 12),
            Expanded(child: _infoCard('Stock total', '$stockTotal')),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _infoCard('Valeur du stock (FCFA)', stockValue.toStringAsFixed(0))),
            const SizedBox(width: 12),
            Expanded(child: _infoCard('Chiffre d\'affaires', revenue.toStringAsFixed(0))),
          ]),
          const SizedBox(height: 12),
          _infoCard('Bénéfices nets', profit.toStringAsFixed(0)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: ElevatedButton(onPressed: widget.onGoProducts, child: const Text('Gérer produit'))),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton(onPressed: widget.onGoSales, child: const Text('Vente'))),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton(onPressed: widget.onGoHistory, child: const Text('Historique'))),
            const SizedBox(width: 8),
            IconButton(onPressed: widget.onGoSettings, icon: const Icon(Icons.settings)),
          ]),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Visualisation Stock', style: TextStyle(fontWeight: FontWeight.bold)),
            TextButton(onPressed: () => setState(() => byValue = !byValue), child: const Text('Changer de vue')),
          ]),
          AspectRatio(
            aspectRatio: 1.6,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
              child: BarChart(BarChartData(barGroups: barGroups, titlesData: FlTitlesData(show: false), borderData: FlBorderData(show: false))),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Évolution mensuelle du CA'),
          AspectRatio(
            aspectRatio: 1.8,
            child: LineChart(LineChartData(
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [LineChartBarData(spots: lineSpots)],
            )),
          ),
          const SizedBox(height: 16),
          const Text('Top 5 produits vendus'),
          ...top5.map((e) => ListTile(title: Text(e.key), trailing: Text('x${e.value}'))),
          const SizedBox(height: 24),
          const Center(child: Text('PDG DRAMANE TRAORE', style: TextStyle(color: Colors.black54))),
        ],
      ),
    );
  }

  double _buyPrice(String productId) {
    final p = widget.products.where((e) => e.id == productId);
    if (p.isEmpty) return 0;
    return p.first.buyPrice * 1.0;
  }

  Widget _infoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
