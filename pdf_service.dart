
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/sale.dart';

class PdfService {
  final df = DateFormat('dd/MM/yyyy HH:mm');

  Future<File> generateInvoice(Sale sale) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('GESTION DE VENTE ULTRA', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.Text('Tata CAMM Solaire  —  "La sécurité sans limites"'),
                pw.SizedBox(height: 16),
                pw.Text('FACTURE', style: pw.TextStyle(fontSize: 18)),
                pw.SizedBox(height: 8),
                pw.Text('Date : ${df.format(sale.date)}'),
                pw.SizedBox(height: 16),
                pw.Text('Client : ${sale.clientName}'),
                pw.Text('Ville  : ${sale.clientCity}'),
                pw.Text('Téléphone : ${sale.clientPhone}'),
                pw.SizedBox(height: 16),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Produit')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Qté')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('PU (FCFA)')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Total')),
                    ]),
                    pw.TableRow(children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(sale.productName)),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${sale.quantity}')),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(sale.unitPrice.toStringAsFixed(0))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(sale.totalPrice.toStringAsFixed(0))),
                    ]),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text('Total à payer : ${sale.totalPrice.toStringAsFixed(0)} FCFA', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ),
                pw.Spacer(),
                pw.Divider(),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text('PDG DRAMANE TRAORE'),
                )
              ],
            ),
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/facture_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<File> generateHistory(List<Sale> sales) async {
    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        pw.Text('Historique des ventes', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            pw.TableRow(children: [
              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Date')),
              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Client')),
              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Produit')),
              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Qté')),
              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Total')),
            ]),
            ...sales.map((s) => pw.TableRow(children: [
              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(df.format(s.date))),
              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(s.clientName)),
              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(s.productName)),
              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${s.quantity}')),
              pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(s.totalPrice.toStringAsFixed(0))),
            ])),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('PDG DRAMANE TRAORE')),
      ],
    ));

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/historique_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
