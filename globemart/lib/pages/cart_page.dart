// lib/pages/cart_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../routes/app_routes.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  String _formatUsd(double v) => 'USD ${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    // tandai bahwa user baru saja melihat cart -> update lastUpdated
    cart.markCartVisited();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
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
          child: cart.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.shopping_cart_outlined,
                          size: 56, color: Colors.white24),
                      SizedBox(height: 12),
                      Text('Keranjang kosong',
                          style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: cart.items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final it = cart.items[i];
                          final subtotal = it.price * it.qty;
                          return Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                Color(0xFF1b0f2b),
                                Color(0xFF32104a)
                              ]),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.purple.withOpacity(0.12),
                                    blurRadius: 8,
                                    offset: const Offset(0, 6))
                              ],
                            ),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  it.thumbnail,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 64,
                                    height: 64,
                                    color: Colors.black26,
                                    child: const Icon(Icons.broken_image,
                                        color: Colors.white70),
                                  ),
                                ),
                              ),
                              title: Text(it.title,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                              subtitle: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Text('Price: ${_formatUsd(it.price)}',
                                      style: const TextStyle(
                                          color: Colors.white70)),
                                  const SizedBox(height: 6),
                                  Text(
                                      'Subtotal: ${_formatUsd(subtotal)}',
                                      style: const TextStyle(
                                          color: Color(0xFFff4ecf),
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              trailing: SizedBox(
                                width: 120,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.white),
                                      onPressed: () {
                                        final newQty = it.qty - 1;
                                        cart.updateQty(
                                            it.productId, newQty);
                                      },
                                    ),
                                    Text('${it.qty}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon: const Icon(
                                          Icons.add_circle_outline,
                                          color: Color(0xFFff4ecf)),
                                      onPressed: () => cart.updateQty(
                                          it.productId, it.qty + 1),
                                    ),
                                  ],
                                ),
                              ),
                              onLongPress: () async {
                                final confirmed =
                                    await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor:
                                        const Color(0xFF120823),
                                    title: const Text('Hapus item?',
                                        style: TextStyle(
                                            color: Colors.white)),
                                    content: Text(
                                        'Hapus "${it.title}" dari keranjang?',
                                        style: const TextStyle(
                                            color: Colors.white70)),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(
                                                  ctx, false),
                                          child: const Text('Batal')),
                                      ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(
                                                  ctx, true),
                                          style: ElevatedButton
                                              .styleFrom(
                                                  backgroundColor:
                                                      const Color(
                                                          0xFFff4ecf)),
                                          child: const Text('Hapus')),
                                    ],
                                  ),
                                );
                                if (confirmed == true) {
                                  cart.removeFromCart(it.productId);
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    // total & checkout panel
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: Color(0xFF120823),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total (USD)',
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w600)),
                              Text(_formatUsd(cart.totalUsd),
                                  style: const TextStyle(
                                      color: Color(0xFFff4ecf),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    final items = cart.items
                                        .map((e) => {
                                              'title': e.title,
                                              'thumbnail': e.thumbnail,
                                              'price': e.price,
                                              'qty': e.qty,
                                            })
                                        .toList();

                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.checkout,
                                      arguments: {
                                        'isSingle': false,
                                        'cart': items,
                                      },
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: Color(0xFF4f3fff)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Checkout',
                                      style: TextStyle(
                                          color: Color(0xFF4f3fff))),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () {
                                  cart.clearCart();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                          content: Text(
                                              'Keranjang dikosongkan')));
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent),
                                child: const Text('Kosongkan'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
