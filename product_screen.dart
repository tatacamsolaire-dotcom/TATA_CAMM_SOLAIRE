
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductScreen extends StatefulWidget {
  final List<Product> products;
  final Future<void> Function(Product) onSave;
  final Future<void> Function() onDeleteAll;
  final VoidCallback onHome;
  final int lowThreshold;
  const ProductScreen({super.key, required this.products, required this.onSave, required this.onDeleteAll, required this.onHome, required this.lowThreshold});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final formKey = GlobalKey<FormState>();
  late Product editing;
  final name = TextEditingController();
  final desc = TextEditingController();
  final buy = TextEditingController(text: '0');
  final sell = TextEditingController(text: '0');
  final qty = TextEditingController(text: '0');
  String? imagePath;

  String query = '';
  String sort = 'date';

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    editing = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '',
      description: '',
      buyPrice: 0,
      sellPrice: 0,
      quantity: 0,
    );
    name.text = '';
    desc.text = '';
    buy.text = '0';
    sell.text = '0';
    qty.text = '0';
    imagePath = null;
    setState(() {});
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      imagePath = result.files.single.path;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.products.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
    if (sort == 'qty') {
      filtered.sort((a,b)=>b.quantity.compareTo(a.quantity));
    } else if (sort == 'profit') {
      filtered.sort((a,b)=>((b.sellPrice-b.buyPrice)).compareTo((a.sellPrice-a.buyPrice)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Ajouter / Modifier produit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Form(
          key: formKey,
          child: Column(children: [
            TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Nom du produit'), validator: (v) => (v==null||v.isEmpty)?'Obligatoire':null),
            const SizedBox(height: 8),
            TextFormField(controller: desc, decoration: const InputDecoration(labelText: 'Description du produit')),
            const SizedBox(height: 8),
            TextFormField(controller: buy, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Prix d\'achat (FCFA)')),
            const SizedBox(height: 8),
            TextFormField(controller: sell, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Prix de vente (FCFA)')),
            const SizedBox(height: 8),
            TextFormField(controller: qty, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantité')),
            const SizedBox(height: 8),
            Row(children: [
              ElevatedButton(onPressed: _pickImage, child: const Text('Choisir un fichier')),
              const SizedBox(width: 12),
              Expanded(child: Text(imagePath ?? 'Aucun fichier choisi', overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final p = Product(
                      id: editing.id,
                      name: name.text,
                      description: desc.text,
                      buyPrice: double.tryParse(buy.text) ?? 0,
                      sellPrice: double.tryParse(sell.text) ?? 0,
                      quantity: int.tryParse(qty.text) ?? 0,
                      imagePath: imagePath,
                    );
                    await widget.onSave(p);
                    _reset();
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produit enregistré.')));
                  }
                },
                child: const Text('Enregistrer produit'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  await widget.onDeleteAll();
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tous les produits ont été supprimés.')));
                },
                child: const Text('Supprimer tous les produits'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: widget.onHome, child: const Text('Accueil')),
            ]),
          ]),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Rechercher un produit'), onChanged: (v)=>setState(()=>query=v))),
          const SizedBox(width: 8),
          DropdownButton<String>(value: sort, items: const [
            DropdownMenuItem(value: 'date', child: Text('Tri: Ajout')),
            DropdownMenuItem(value: 'qty', child: Text('Tri: Quantité')),
            DropdownMenuItem(value: 'profit', child: Text('Tri: Bénéfice')),
          ], onChanged: (v)=>setState(()=>sort=v??'date')),
        ]),
        const SizedBox(height: 8),
        const Text('Liste des produits', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...filtered.map((p) {
          final low = p.quantity <= widget.lowThreshold;
          return Card(
            child: ListTile(
              leading: p.imagePath != null ? Image.file(File(p.imagePath!), width: 40, height: 40, fit: BoxFit.cover) : const Icon(Icons.inventory_2),
              title: Text(p.name),
              subtitle: Text('Qté: ${p.quantity} • PV: ${p.sellPrice.toStringAsFixed(0)} FCFA' + (low ? '  •  ⚠️ Stock faible' : '')),
              trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () {
                editing = p;
                name.text = p.name; desc.text = p.description; buy.text = p.buyPrice.toString(); sell.text = p.sellPrice.toString(); qty.text = p.quantity.toString(); imagePath = p.imagePath;
                setState(() {});
              }),
              textColor: low ? Colors.red : null,
            ),
          );
        }),
      ]),
    );
  }
}
