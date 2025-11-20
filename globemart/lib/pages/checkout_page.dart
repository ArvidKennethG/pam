// lib/pages/checkout_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';
import '../models/address_model.dart';
import '../services/hive_service.dart';

class CheckoutPage extends StatefulWidget {
  final ProductModel? product;
  final int? singleQty;
  final int? qty;
  final List<dynamic>? cart;
  final bool? isSingle;

  const CheckoutPage({
    super.key,
    this.product,
    this.singleQty,
    this.qty,
    this.cart,
    this.isSingle,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String currency = "USD";
  double rate = 1.0;
  double totalUsd = 0;
  bool loadingRate = false;

  AddressModel? selectedAddress;

  static const exchangeUrl =
      "https://v6.exchangerate-api.com/v6/9ee514d7374850d1999c8c1a/latest/USD";

  @override
  void initState() {
    super.initState();
    computeTotal();
  }

  void safeSet(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  bool get _isSingleContext {
    if (widget.isSingle != null) return widget.isSingle!;
    if (widget.product != null &&
        (widget.cart == null || widget.cart!.isEmpty)) return true;
    return false;
  }

  int get _quantity => widget.singleQty ?? widget.qty ?? 1;

  void computeTotal() {
    double sum = 0;

    if (_isSingleContext && widget.product != null) {
      sum = widget.product!.price * _quantity;
    } else if (widget.cart != null) {
      for (var item in widget.cart!) {
        final double p = (item['price'] as num).toDouble();
        final int q = (item['qty'] as num).toInt();
        sum += p * q;
      }
    }

    safeSet(() => totalUsd = sum);
  }

  Future<void> fetchRate() async {
    safeSet(() => loadingRate = true);

    try {
      final res = await http.get(Uri.parse(exchangeUrl));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['conversion_rates'][currency] != null) {
          rate = (json['conversion_rates'][currency] as num).toDouble();
        } else {
          rate = fallbackRate(currency);
        }
      } else {
        rate = fallbackRate(currency);
      }
    } catch (_) {
      rate = fallbackRate(currency);
    }

    safeSet(() => loadingRate = false);
  }

  double fallbackRate(String c) {
    switch (c) {
      case "IDR":
        return 15500;
      case "EUR":
        return 0.92;
      case "JPY":
        return 150;
      case "GBP":
        return 0.79;
      default:
        return 1.0;
    }
  }

  double convert(double usd) => usd * rate;

  @override
  Widget build(BuildContext context) {
    final isSingle = _isSingleContext;
    final cart = widget.cart;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
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
            padding: const EdgeInsets.all(18),
            children: [
              // ============================
              // 🔥 ALAMAT PENGIRIMAN
              // ============================
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF23103f),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Alamat Pengiriman",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),

                    // Jika sudah memilih alamat
                    if (selectedAddress != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedAddress!.label,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedAddress!.fullAddress,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),

                    ElevatedButton(
                      onPressed: () async {
                        final a = await Navigator.pushNamed(
                          context,
                          '/address',
                        );

                        if (a is AddressModel) {
                          setState(() => selectedAddress = a);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFff4ecf),
                      ),
                      child: Text(selectedAddress == null
                          ? "Pilih Alamat"
                          : "Ganti Alamat"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ============================
              // 🔥 BARANG
              // ============================
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF23103f),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Barang:",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),

                    if (isSingle && widget.product != null)
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.product!.thumbnail,
                              height: 60,
                              width: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "${widget.product!.title} x$_quantity",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      )
                    else if (cart != null && cart.isNotEmpty)
                      Column(
                        children: [
                          for (var item in cart)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item['thumbnail'],
                                      height: 48,
                                      width: 48,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "${item['title']} x${item['qty']}",
                                      style: const TextStyle(
                                          color: Colors.white),
                                    ),
                                  ),
                                  Text(
                                    "USD ${( (item['price'] as num).toDouble() * (item['qty'] as num).toInt()).toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Color(0xFFff4ecf),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      )
                    else
                      const Text(
                        "Tidak ada item",
                        style: TextStyle(color: Colors.white54),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ============================
              // 🔥 KONVERSI MATA UANG
              // ============================
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF23103f),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Konversi Mata Uang",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 12),

                    DropdownButtonFormField(
                      initialValue: currency,
                      dropdownColor: const Color(0xFF23103f),
                      items: ["USD", "IDR", "EUR", "JPY", "GBP"]
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c,
                                  style:
                                      const TextStyle(color: Colors.white)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        currency = v!;
                        fetchRate();
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black26,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),

                    const SizedBox(height: 14),

                    loadingRate
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Colors.white),
                          )
                        : Text(
                            currency == 'USD'
                                ? "Total: USD ${totalUsd.toStringAsFixed(2)}"
                                : "Total: $currency ${convert(totalUsd).toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Color(0xFFff4ecf),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ============================
              // 🔥 BUTTON LANJUT PEMBAYARAN
              // ============================
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/payment',
                    arguments: {
                      'isSingle': isSingle,
                      'product': widget.product,
                      'qty': _quantity,
                      'cart': widget.cart,
                      'totalUsd': totalUsd,
                      'currency': currency,

                      // ⭐ kirim alamat
                      'address': selectedAddress,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFff4ecf),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Lanjut ke Pembayaran",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
