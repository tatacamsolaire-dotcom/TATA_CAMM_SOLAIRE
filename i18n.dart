
class I18n {
  final String lang;
  I18n(this.lang);

  static const _fr = {
    'dashboard': 'Tableau de bord',
    'products': 'Gestion des produits',
    'sale': 'Vente & Facturation',
    'history': 'Historique des ventes',
    'settings': 'Paramètres',
    'low_stock': 'Stock faible',
  };
  static const _en = {
    'dashboard': 'Dashboard',
    'products': 'Products',
    'sale': 'Sales & Billing',
    'history': 'Sales History',
    'settings': 'Settings',
    'low_stock': 'Low stock',
  };
  static const _bm = {
    'dashboard': 'Tablo bɔ', // simplifié
    'products': 'Dɛmugow',
    'sale': 'Sanyɔrɔ & Farakolo',
    'history': 'Tariku',
    'settings': 'Tɔrɔfɛnw',
    'low_stock': 'Dɛmɛ bɔra',
  };

  String t(String key) {
    final m = switch (lang) { 'en' => _en, 'bm' => _bm, _ => _fr };
    return m[key] ?? key;
  }
}
