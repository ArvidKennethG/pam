// lib/pages/transaction_detail_page.dart

import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/pdf_service.dart';
import 'package:printing/printing.dart';

class TransactionDetailPage extends StatelessWidget {
  final TransactionModel trx;
  const TransactionDetailPage({super.key, required this.trx});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Transaksi"), backgroundColor: const Color(0xFF4F3FFF)),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF130f40), Color(0xFF1b0f2b)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: ListView(children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFF23103f), borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Informasi Transaksi", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _item("ID Transaksi", trx.id),
              _item("Produk", trx.productName),
              _item("Tanggal", trx.dateTime),
              _item("Metode Pembayaran", trx.paymentMethod),
              _item("Alamat Pengiriman", trx.shippingAddress ?? "-"),
              _item("Lokasi Pembayaran", trx.location),
              _item("Total Pembayaran", "${trx.currency} ${trx.amount.toStringAsFixed(2)}", highlight: true),
            ]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFff4ecf), padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: () async {
              try {
                final bytes = await PdfService.generatePdf(trx);
                await Printing.sharePdf(bytes: bytes, filename: "invoice-${trx.id}.pdf");
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal generate PDF: $e")));
              }
            },
            child: const Text("Download PDF", style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text("Kembali ke Home", style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ]),
      ),
    );
  }

  Widget _item(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(color: highlight ? const Color(0xFFff4ecf) : Colors.white, fontSize: 15, fontWeight: highlight ? FontWeight.bold : FontWeight.normal)),
      ]),
    );
  }
}
