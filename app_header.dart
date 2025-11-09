
import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const AppHeader({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFFF8C00),
      titleSpacing: 0,
      elevation: 2,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('GESTION DE VENTE ULTRA', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('Tata CAMM Solaire — La sécurité sans limites', style: TextStyle(fontSize: 12)),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(24),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}
