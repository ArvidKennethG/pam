// lib/services/pdf_service.dart

import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../models/transaction_model.dart';

class PdfService {
  /// Generate PDF bytes for a transaction (portrait A4)
  static Future<Uint8List> generatePdf(TransactionModel trx) async {
    final pdf = pw.Document();

    // load logo from assets
    Uint8List logoBytes = Uint8List(0);
    try {
      final logoData = await rootBundle.load('assets/logo.png');
      logoBytes = logoData.buffer.asUint8List();
    } catch (e) {
      // ignore if asset not found; PDF will be created without logo
    }

    // Header widget (solid color box to avoid color conversion issues)
    final header = pw.Container(
      color: PdfColors.blue, // using PdfColors for compatibility
      padding: const pw.EdgeInsets.all(12),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(children: [
            if (logoBytes.isNotEmpty) pw.Image(pw.MemoryImage(logoBytes), width: 48, height: 48),
            pw.SizedBox(width: 10),
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('GlobeMart', style: pw.TextStyle(color: PdfColors.white, fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text('Transaction Invoice', style: pw.TextStyle(color: PdfColors.white, fontSize: 10)),
            ])
          ]),
          pw.Text(trx.id, style: pw.TextStyle(color: PdfColors.white, fontSize: 9)),
        ],
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(18),
        build: (pw.Context context) {
          return [
            header,
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('Product: ${trx.productName}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text('Amount: ${trx.amount.toStringAsFixed(2)} ${trx.currency}'),
                pw.SizedBox(height: 6),
                pw.Text('Payment Method: ${trx.paymentMethod}'),
                pw.SizedBox(height: 6),
                pw.Text('Location: ${trx.location}'),
                pw.SizedBox(height: 6),
                pw.Text('Date/Time: ${trx.dateTime}'),
                pw.SizedBox(height: 6),
                pw.Text('Transaction ID: ${trx.id}'),
              ]),
            ),
            pw.Spacer(),
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('Thank you for shopping with GlobeMart', style: pw.TextStyle(fontSize: 10)),
              pw.Text('Signature: __________________', style: pw.TextStyle(fontSize: 10)),
            ])
          ];
        },
      ),
    );

    return pdf.save();
  }
}
