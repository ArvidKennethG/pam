// lib/pages/payment_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/product_model.dart';
import '../models/address_model.dart';
import '../models/transaction_model.dart';

import '../providers/cart_provider.dart';
import '../routes/app_routes.dart';
import '../services/hive_service.dart';
import '../services/location_service.dart';
import '../services/world_time_service.dart';
import '../services/notification_service.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool isPaying = false;
  String paymentMethod = "Bank Transfer";

  Future<void> _completePayment(
    BuildContext context, {
    required bool isSingle,
    ProductModel? product,
    int? qty,
    List<dynamic>? cart,
    required double totalUsd,
    required String currency,
    required AddressModel? address,
  }) async {
    if (isPaying) return;
    setState(() => isPaying = true);

    // ambil posisi (opsional)
    final pos = await LocationService.getPosition();
    final locationString = pos != null ? "${pos.latitude}, ${pos.longitude}" : "Unknown";

    // ambil waktu (pakai Jakarta)
    final now = await WorldTimeService.getTime("Asia/Jakarta");

    final trxId = const Uuid().v4();
    final productName = (isSingle && product != null) ? "${product.title} x$qty" : "Cart (${cart?.length ?? 0} items)";

    final trx = TransactionModel(
      id: trxId,
      productName: productName,
      amount: totalUsd,
      currency: currency,
      dateTime: now,
      location: locationString,
      paymentMethod: paymentMethod,
      shippingAddress: address?.fullAddress ?? "Alamat tidak tersedia",
    );

    // simpan transaksi
    await HiveService.saveTransaction(trx);

    // hapus cart di Hive
    await HiveService.clearCart();

    // update provider jika ada
    try {
      final cartProv = Provider.of<CartProvider>(context, listen: false);
      await cartProv.clearCart();
    } catch (_) {}

    // notifikasi
    try {
      await NotificationService.showSuccessNotification(title: "Pembayaran Berhasil", body: "Transaksi Anda telah berhasil diproses!");
    } catch (_) {}

    setState(() => isPaying = false);
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1b1130),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => _buildSuccessSheet(context, trx),
    );
  }

  Widget _buildSuccessSheet(BuildContext context, TransactionModel trx) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.check_circle, color: Colors.greenAccent, size: 60),
        const SizedBox(height: 16),
        const Text("Pembayaran Berhasil!", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 18),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // tutup sheet
            Navigator.pushNamed(context, AppRoutes.transactionDetail, arguments: {'trx': trx});
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFff4ecf), padding: const EdgeInsets.symmetric(vertical: 14)),
          child: const Text("Lihat Nota"),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 14)),
          child: const Text("Kembali ke Home"),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};

    final bool isSingle = args['isSingle'] as bool? ?? false;
    final ProductModel? product = args['product'] as ProductModel?;
    final int? qty = args['qty'] as int?;
    final List<dynamic>? cart = args['cart'] as List<dynamic>?;
    final double totalUsd = (args['totalUsd'] as num?)?.toDouble() ?? 0.0;
    final String currency = args['currency'] as String? ?? 'USD';
    final AddressModel? address = args['address'] as AddressModel?;

    return Scaffold(
      appBar: AppBar(title: const Text("Pembayaran"), backgroundColor: Colors.transparent, elevation: 0),
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF130f40), Color(0xFF1b0f2b)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: SafeArea(
          child: ListView(padding: const EdgeInsets.all(18), children: [
            _section(title: "Alamat Pengiriman", child: Text(address?.fullAddress ?? "Tidak ada alamat dipilih", style: const TextStyle(color: Colors.white))),
            const SizedBox(height: 22),
            _section(title: "Metode Pembayaran", child: Column(children: [_paymentOption("Bank Transfer"), _paymentOption("QRIS"), _paymentOption("Dana")])),
            const SizedBox(height: 22),
            _section(title: "Total Pembayaran", child: Text("$currency ${totalUsd.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFFff4ecf), fontSize: 22, fontWeight: FontWeight.bold))),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: isPaying ? null : () => _completePayment(context, isSingle: isSingle, product: product, qty: qty, cart: cart, totalUsd: totalUsd, currency: currency, address: address),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFff4ecf), padding: const EdgeInsets.symmetric(vertical: 16)),
              child: isPaying ? const CircularProgressIndicator(color: Colors.white) : const Text("Selesaikan Pembayaran"),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFF23103f), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white70)), const SizedBox(height: 10), child]));
  }

  Widget _paymentOption(String value) {
    return RadioListTile<String>(value: value, groupValue: paymentMethod, onChanged: (v) { if (v == null) return; setState(() => paymentMethod = v); }, activeColor: const Color(0xFFff4ecf), title: Text(value, style: const TextStyle(color: Colors.white)));
  }
}
