// lib/services/pdf_service.dart

import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../models/transaction_model.dart';

class PdfService {
  static Future<Uint8List> generatePdf(TransactionModel trx) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER
              pw.Text(
                "INVOICE PEMBAYARAN",
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),

              // INFORMASI TRANSAKSI
              _row("ID Transaksi", trx.id),
              _row("Produk", trx.productName),
              _row("Tanggal", trx.dateTime),
              _row("Metode Pembayaran", trx.paymentMethod),
              _row("Lokasi Pembayaran", trx.location),

              // Alamat pengiriman
              _row("Alamat Pengiriman",
                  trx.shippingAddress ?? "Tidak ada alamat"),

              _row(
                "Total Pembayaran",
                "${trx.currency} ${trx.amount.toStringAsFixed(2)}",
                bold: true,
              ),

              pw.SizedBox(height: 20),

              // FOOTER
              pw.Divider(),
              pw.Center(
                child: pw.Text(
                  "Terima kasih telah berbelanja di GlobeMart!",
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _row(String key, String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              key,
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            flex: 5,
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight:
                    bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
