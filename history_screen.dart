
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../models/sale.dart';
import '../services/app_repository.dart';
import '../services/pdf_service.dart';

class HistoryScreen extends StatefulWidget {
  final AppRepository repo;
  final VoidCallback onHome;
  const HistoryScreen({super.key, required this.repo, required this.onHome});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String query = '';
  DateTime? from;
  DateTime? to;
  final df = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    final list = [...widget.repo.sales]..sort((a,b)=>b.date.compareTo(a.date));
    final filtered = list.where((s) {
      final q = query.toLowerCase();
      final hit = s.productName.toLowerCase().contains(q) || s.clientName.toLowerCase().contains(q) || s.clientCity.toLowerCase().contains(q);
      final inFrom = from == null || !s.date.isBefore(from!);
      final inTo = to == null || !s.date.isAfter(to!);
      return hit && inFrom && inTo;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Historique des ventes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Recherche (produit, client, ville)'), onChanged: (v)=>setState(()=>query=v))),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () async {
            final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
            if (d!=null) setState(()=>from = d);
          }, child: Text('De: ${from==null?'--':df.format(from!)}'))),
          const SizedBox(width: 8),
          Expanded(child: OutlinedButton(onPressed: () async {
            final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
            if (d!=null) setState(()=>to = d);
          }, child: Text('À: ${to==null?'--':df.format(to!)}'))),
        ]),
        const SizedBox(height: 8),
        if (filtered.isEmpty) Container(height: 200, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12))),
        ...filtered.map((s) => Card(
          child: ListTile(
            title: Text('${s.productName} x${s.quantity} • ${s.totalPrice.toStringAsFixed(0)} FCFA'),
            subtitle: Text('${df.format(s.date)} — ${s.clientName} (${s.clientCity})'),
          ),
        )),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          OutlinedButton(onPressed: widget.onHome, child: const Text('Accueil')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await widget.repo.clearHistory();
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Historique supprimé.')));
              setState(() {});
            },
            child: const Text('Effacer tout'),
          ),
          ElevatedButton(
            onPressed: () async {
              final file = await PdfService().generateHistory(filtered);
              await OpenFilex.open(file.path);
            },
            child: const Text('Exporter en PDF'),
          ),
          ElevatedButton(
            onPressed: () async {
              final f = await widget.repo.exportJson();
              await Share.shareXFiles([XFile(f.path)], text: 'Sauvegarde GESTION DE VENTE ULTRA');
            },
            child: const Text('Exporter données (.json)'),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
              if (result != null && result.files.isNotEmpty) {
                await widget.repo.importJson(File(result.files.single.path!));
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Import réussi. Redémarrez l\'app pour voir les données.')));
              }
            },
            child: const Text('Importer données (.json)'),
          ),
        ]),
      ]),
    );
  }
}
