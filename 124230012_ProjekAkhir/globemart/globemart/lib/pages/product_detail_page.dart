import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../pages/checkout_page.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int qty = 1;
  bool isAdding = false;

  void safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  void _increase() {
    safeSetState(() => qty++);
  }

  void _decrease() {
    if (qty > 1) safeSetState(() => qty--);
  }

  Future<void> _addToCart() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    safeSetState(() => isAdding = true);

    cart.addToCart(
      CartItem(
        productId: widget.product.id,
        title: widget.product.title,
        thumbnail: widget.product.thumbnail,
        price: widget.product.price,
        qty: qty,
      ),
    );

    // small delay for UX then snackbar
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ditambahkan ke keranjang: ${widget.product.title} x$qty')),
    );

    safeSetState(() => isAdding = false);
  }

  void _buyNow() {
    // Navigate to Checkout page with this product + qty
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutPage(product: widget.product, singleQty: qty),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        ],
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
          child: Column(
            children: [
              // IMAGE + HERO
              Hero(
                tag: 'product_${p.id}',
                child: AspectRatio(
                  aspectRatio: 1.3,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(colors: [Color(0xFF1b0f2b), Color(0xFF4f3fff)]),
                      boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.18), blurRadius: 16, offset: Offset(0, 8))],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Image.network(
                      p.thumbnail,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1)
                                : null,
                            color: const Color(0xFFff4ecf),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.black26,
                        child: const Center(child: Icon(Icons.broken_image, color: Colors.white70, size: 48)),
                      ),
                    ),
                  ),
                ),
              ),

              // DETAILS AREA
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF120823),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
                  ),
                  child: ListView(
                    children: [
                      // Title & rating/price row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              p.title,
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('USD ${p.price.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFFff4ecf), fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                                child: Text('⭐ ${p.rating.toStringAsFixed(1)}', style: const TextStyle(color: Colors.white70)),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // description
                      Text(p.description, style: const TextStyle(color: Colors.white70, height: 1.4)),
                      const SizedBox(height: 18),

                      // Quantity stepper
                      Row(
                        children: [
                          const Text('Quantity', style: TextStyle(color: Colors.white70)),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(color: const Color(0xFF23103f), borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: _decrease,
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                                ),
                                Text('$qty', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                IconButton(
                                  onPressed: _increase,
                                  icon: const Icon(Icons.add_circle_outline, color: Color(0xFFff4ecf)),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Subtotal computed in USD
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Subtotal', style: TextStyle(color: Colors.white70)),
                              Text('USD ${(p.price * qty).toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFFff4ecf), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: isAdding ? null : _addToCart,
                              icon: isAdding ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.add_shopping_cart),
                              label: const Text('Tambah ke Keranjang'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFff4ecf),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _buyNow,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF4f3fff)),
                                backgroundColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Beli Sekarang', style: TextStyle(color: Color(0xFF4f3fff))),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // small footnote
                      Center(
                        child: Text('Free shipping over USD 100', style: TextStyle(color: Colors.white.withOpacity(0.6))),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
