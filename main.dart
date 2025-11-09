
import 'package:flutter/material.dart';
import 'models/product.dart';
import 'models/sale.dart';
import 'services/app_repository.dart';
import 'services/settings_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/product_screen.dart';
import 'screens/sale_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/lock_screen.dart';
import 'widgets/app_header.dart';

void main() {
  runApp(const UltraApp());
}

class UltraApp extends StatefulWidget {
  const UltraApp({super.key});
  @override
  State<UltraApp> createState() => _UltraAppState();
}

class _UltraAppState extends State<UltraApp> {
  final repo = AppRepository();
  final settings = SettingsService();
  int tab = 0;
  bool ready = false;
  bool unlocked = true;
  bool dark = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await repo.load();
    dark = await settings.getDarkMode();
    final pin = await settings.getPin();
    unlocked = pin == null || pin.isEmpty;
    setState(() { ready = true; });
  }

  ThemeData _theme(bool darkMode) => ThemeData(
    brightness: darkMode ? Brightness.dark : Brightness.light,
    primaryColor: const Color(0xFFFF8C00),
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF8C00), brightness: darkMode ? Brightness.dark : Brightness.light),
    useMaterial3: true,
    inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
  );

  @override
  Widget build(BuildContext context) {
    if (!ready) return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _theme(dark),
      home: FutureBuilder<String?>(
        future: settings.getPin(),
        builder: (context, snap) {
          final pin = snap.data ?? '';
          if (!unlocked && pin.isNotEmpty) {
            return LockScreen(pin: pin, onUnlocked: () => setState(() => unlocked = true));
          }
          return Scaffold(
            appBar: AppHeader(title: _titleForTab(tab)),
            body: _buildBody(),
            bottomNavigationBar: NavigationBar(
              selectedIndex: tab,
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home), label: 'Accueil'),
                NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Gérer produit'),
                NavigationDestination(icon: Icon(Icons.point_of_sale), label: 'Vente'),
                NavigationDestination(icon: Icon(Icons.history), label: 'Historique'),
                NavigationDestination(icon: Icon(Icons.settings), label: 'Paramètres'),
              ],
              onDestinationSelected: (i) => setState(() => tab = i),
            ),
          );
        }
      ),
    );
  }

  String _titleForTab(int t) => switch (t) {
    0 => 'Tableau de bord',
    1 => 'Gestion des produits',
    2 => 'Vente & Facturation',
    3 => 'Historique des ventes',
    _ => 'Paramètres',
  };

  Widget _buildBody() {
    switch (tab) {
      case 0:
        return DashboardScreen(
          products: repo.products,
          sales: repo.sales,
          onGoProducts: () => setState(() => tab = 1),
          onGoSales: () => setState(() => tab = 2),
          onGoHistory: () => setState(() => tab = 3),
          onGoSettings: () => setState(() => tab = 4),
        );
      case 1:
        return FutureBuilder<int>(
          future: settings.getThreshold(),
          builder: (context, snap) => ProductScreen(
            products: repo.products,
            lowThreshold: snap.data ?? 5,
            onSave: (p) async { await repo.addOrUpdateProduct(p); setState(() {}); },
            onDeleteAll: () async { await repo.deleteAllProducts(); setState(() {}); },
            onHome: () => setState(() => tab = 0),
          ),
        );
      case 2:
        return SaleScreen(repo: repo, onHome: () => setState(() => tab = 0));
      case 3:
        return HistoryScreen(repo: repo, onHome: () => setState(() => tab = 0));
      case 4:
      default:
        return SettingsScreen(settings: settings, onApplied: () async {
          dark = await settings.getDarkMode();
          setState(() {});
        });
    }
  }
}
