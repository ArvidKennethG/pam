// lib/pages/payment_page.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/product_model.dart';
import '../models/transaction_model.dart';
import '../services/hive_service.dart';
import '../services/location_service.dart';
import '../services/world_time_service.dart';
import '../services/notification_service.dart';
import '../services/pdf_service.dart';
import 'transaction_detail_page.dart';
import 'package:printing/printing.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};

    final bool isSingle = args['isSingle'] as bool? ?? false;
    final ProductModel? product = args['product'] as ProductModel?;
    final int qty = (args['qty'] as int?) ?? 1;
    final List<dynamic>? cart = args['cart'] as List<dynamic>?;
    final double totalUsd = (args['totalUsd'] as num?)?.toDouble() ?? 0.0;
    final String currency = args['currency'] as String? ?? 'USD';

    Future<void> completePayment(BuildContext ctx, String method) async {
      final id = const Uuid().v4();

      final pos = await LocationService.getPosition();
      String location = 'Unknown Location';
      if (pos != null) {
        try {
          location = await LocationService.reverseGeocode(pos);
        } catch (_) {
          location = '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
        }
      }

      // prepare product summary string
      String productSummary = '';
      if (!isSingle && cart != null) {
        final lines = cart.map((m) {
          final title = m['title'];
          final p = (m['price'] as num).toDouble();
          final q = (m['qty'] as num).toInt();
          return '$title x$q - USD ${(p * q).toStringAsFixed(2)}';
        }).toList();
        productSummary = lines.join('\n');
      } else if (isSingle && product != null) {
        productSummary = '${product.title} x$qty - USD ${(product.price * qty).toStringAsFixed(2)}';
      } else {
        productSummary = 'No items';
      }

      // use WorldTimeService to get timestamp (fallback to local ISO if fails)
      String dateTime = DateTime.now().toIso8601String();
      try {
        dateTime = await WorldTimeService.getTime("Asia/Jakarta");
      } catch (_) {}

      final trx = TransactionModel(
        id: id,
        productName: productSummary,
        amount: totalUsd,
        currency: currency,
        dateTime: dateTime,
        location: location,
        paymentMethod: method,
      );

      await HiveService.saveTransaction(trx);

      try {
        await NotificationService.showSuccessNotification(title: "Pembayaran Berhasil", body: "Nota transaksi sudah dibuat");
      } catch (_) {
        // ignore if running on web/emulator without notifications
      }

      // show bottom sheet
      showModalBottomSheet(
        context: ctx,
        backgroundColor: Colors.transparent,
        builder: (_) {
          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFff4ecf), Color(0xFF4f3fff)]),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16),
            child: Wrap(
              children: [
                const ListTile(
                  title: Text('Pembayaran Berhasil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('Nota siap dilihat dan diunduh', style: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(ctx, MaterialPageRoute(builder: (_) => TransactionDetailPage(trx: trx)));
                  },
                  child: const Text('Lihat Nota', style: TextStyle(color: Colors.black)),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      final bytes = await PdfService.generatePdf(trx);
                      await Printing.sharePdf(bytes: bytes, filename: 'invoice-${trx.id}.pdf');
                    } catch (e) {
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Gagal generate PDF: $e')));
                    }
                  },
                  child: const Text('Download PDF', style: TextStyle(color: Colors.black)),
                ),
                const SizedBox(height: 8),
                TextButton(
                    onPressed: () {
                      Navigator.popUntil(ctx, (route) => route.isFirst);
                    },
                    child: const Text('Kembali ke Home', style: TextStyle(color: Colors.white70))),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Metode Pembayaran'), backgroundColor: Colors.transparent, elevation: 0),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF130f40), Color(0xFF1b0f2b)]),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              _paymentOptionTile(context, 'Virtual Wallet', Icons.account_balance_wallet, () => completePayment(context, 'Virtual Wallet')),
              _paymentOptionTile(context, 'Bank Transfer', Icons.account_balance, () => completePayment(context, 'Bank Transfer')),
              _paymentOptionTile(context, 'Cash on Delivery', Icons.delivery_dining, () => completePayment(context, 'Cash on Delivery')),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFF23103f), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ringkasan Pembayaran', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text('Items summary', style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('Total: USD ${totalUsd.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFFff4ecf), fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentOptionTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF1b0f2b), Color(0xFF23103f)]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16))),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
