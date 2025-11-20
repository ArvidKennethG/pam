// lib/pages/transaction_detail_page.dart

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../models/transaction_model.dart';
import '../services/pdf_service.dart';

class TransactionDetailPage extends StatelessWidget {
  final TransactionModel trx;
  const TransactionDetailPage({super.key, required this.trx});

  @override
  Widget build(BuildContext context) {
    final items = trx.productName.split('\n'); // list item dari summary string

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Transaksi"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF130f40), Color(0xFF1b0f2b)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF23103f),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Detail Transaksi",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ID TRANSAKSI
                    Text("ID Transaksi:",
                        style: TextStyle(color: Colors.white.withOpacity(0.7))),
                    Text(trx.id,
                        style: const TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 16),

                    // DAFTAR ITEM
                    Text("Barang:",
                        style: TextStyle(color: Colors.white.withOpacity(0.7))),
                    const SizedBox(height: 8),
                    ...items.map((i) => Text(
                          "• $i",
                          style: const TextStyle(color: Colors.white),
                        )),
                    const SizedBox(height: 16),

                    // TOTAL
                    Text("Total Pembayaran:",
                        style: TextStyle(color: Colors.white.withOpacity(0.7))),
                    Text(
                      "${trx.currency} ${trx.amount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Color(0xFFff4ecf),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // WAKTU
                    Text("Waktu Transaksi:",
                        style: TextStyle(color: Colors.white.withOpacity(0.7))),
                    Text(
                      trx.dateTime,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),

                    // LOKASI
                    Text("Lokasi:",
                        style: TextStyle(color: Colors.white.withOpacity(0.7))),
                    Text(
                      trx.location,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),

                    // METODE PEMBAYARAN
                    Text("Metode Pembayaran:",
                        style: TextStyle(color: Colors.white.withOpacity(0.7))),
                    Text(
                      trx.paymentMethod,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // DOWNLOAD PDF
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFff4ecf),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  final bytes = await PdfService.generatePdf(trx);
                  await Printing.sharePdf(
                    bytes: bytes,
                    filename: 'invoice-${trx.id}.pdf',
                  );
                },
                child: const Text(
                  "Download / Share PDF",
                  style: TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 12),

              // KEMBALI
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFff4ecf)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Kembali",
                  style: TextStyle(color: Color(0xFFff4ecf)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
