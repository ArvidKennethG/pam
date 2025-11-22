import 'package:flutter/material.dart';
import '../services/hive_service.dart';

class CartItem {
  int productId;
  String title;
  String thumbnail;
  double price; // price in USD
  int qty;

  CartItem({
    required this.productId,
    required this.title,
    required this.thumbnail,
    required this.price,
    required this.qty,
  });

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'title': title,
        'thumbnail': thumbnail,
        'price': price,
        'qty': qty,
      };

  static CartItem fromMap(Map<String, dynamic> m) {
    return CartItem(
      productId: (m['productId'] as num).toInt(),
      title: m['title'].toString(),
      thumbnail: m['thumbnail'].toString(),
      price: (m['price'] as num).toDouble(),
      qty: (m['qty'] as num).toInt(),
    );
  }
}

class CartProvider extends ChangeNotifier {
  List<CartItem> items = [];

  CartProvider() {
    _loadFromHive();
  }

  void _loadFromHive() {
    final raw = HiveService.getCartList();
    items = raw.map((m) => CartItem.fromMap(m)).toList();
    notifyListeners();
  }

  Future<void> _saveToHive() async {
    final list = items.map((e) => e.toMap()).toList();
    await HiveService.saveCartList(list);
  }

  void _touchCart() {
    // update timestamp setiap cart berubah
    HiveService.setCartLastUpdated(DateTime.now());
  }

  /// dipanggil ketika user membuka halaman cart (untuk abandoned reminder)
  void markCartVisited() {
    HiveService.setCartLastUpdated(DateTime.now());
  }

  void addToCart(CartItem item) {
    final idx = items.indexWhere((i) => i.productId == item.productId);
    if (idx >= 0) {
      items[idx].qty += item.qty;
    } else {
      items.add(item);
    }
    _touchCart();
    _saveToHive();
    notifyListeners();
  }

  void removeFromCart(int productId) {
    items.removeWhere((i) => i.productId == productId);
    _touchCart();
    _saveToHive();
    notifyListeners();
  }

  void updateQty(int productId, int qty) {
    final idx = items.indexWhere((i) => i.productId == productId);
    if (idx >= 0) {
      items[idx].qty = qty;
      if (items[idx].qty <= 0) items.removeAt(idx);
      _touchCart();
      _saveToHive();
      notifyListeners();
    }
  }

  double get totalUsd {
    double s = 0;
    for (var it in items) {
      s += it.price * it.qty;
    }
    return s;
  }

  int get totalItems {
    int c = 0;
    for (var it in items) c += it.qty;
    return c;
  }

  Future<void> clearCart() async {
    items.clear();
    await HiveService.clearCart();
    // boleh update timestamp juga, tapi notifikasi tidak akan muncul karena cart kosong
    HiveService.setCartLastUpdated(DateTime.now());
    notifyListeners();
  }
}
