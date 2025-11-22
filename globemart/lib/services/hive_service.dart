import 'package:hive_flutter/hive_flutter.dart';

import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/feedback_model.dart';
import '../models/address_model.dart';

class HiveService {
  static late Box userBox;
  static late Box<UserModel> userDataBox;
  static late Box<TransactionModel> transactionBox;
  static late Box<FeedbackModel> feedbackBox;
  static late Box cartBox; // dynamic box for cart list

  // ⭐ Address storage box
  static late Box addressBox;

  // =====================================================
  // INIT HIVE
  // =====================================================
  static Future<void> initHive() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TransactionModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(FeedbackModelAdapter());
    }

    userBox = await Hive.openBox('userBox');
    userDataBox = await Hive.openBox<UserModel>('userDataBox');
    transactionBox = await Hive.openBox<TransactionModel>('transactionBox');
    feedbackBox = await Hive.openBox<FeedbackModel>('feedbackBox');
    cartBox = await Hive.openBox('cartBox');

    addressBox = await Hive.openBox('addressBox');
  }

  // =====================================================
  // LOGIN SESSION
  // =====================================================
  static bool get isLoggedIn => userBox.get('isLoggedIn', defaultValue: false);

  static void setLoginSession(bool value) => userBox.put('isLoggedIn', value);

  static void clearSession() => userBox.clear();

  // =====================================================
  // USER
  // =====================================================
  static Future<void> saveUser(UserModel user) async =>
      userDataBox.put(user.id, user);

  static UserModel? getUserByUsername(String username) {
    try {
      return userDataBox.values.firstWhere((u) => u.username == username);
    } catch (_) {
      return null;
    }
  }

  static Future<void> updateUserProfileImage(
      String userId, String path) async {
    final user = userDataBox.get(userId);
    if (user != null) {
      user.profileImagePath = path;
      await user.save();
    }
  }

  // =====================================================
  // CART (List<Map>)
  // =====================================================
  static Future<void> saveCartList(List<Map<String, dynamic>> list) async {
    await cartBox.put('cart', list);
  }

  static List<Map<String, dynamic>> getCartList() {
    final v = cartBox.get('cart');
    if (v == null) return [];
    try {
      return List<Map<String, dynamic>>.from(v);
    } catch (_) {
      return [];
    }
  }

  static Future<void> clearCart() async => cartBox.delete('cart');

  // =====================================================
  // CART TIMESTAMP (Abandoned Cart Helper)
  // =====================================================
  static void setCartLastUpdated(DateTime dt) {
    userBox.put('cartLastUpdated', dt.toIso8601String());
  }

  static DateTime? getCartLastUpdated() {
    final raw = userBox.get('cartLastUpdated');
    if (raw is String) {
      try {
        return DateTime.parse(raw);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static bool hasCartItems() {
    final list = getCartList();
    return list.isNotEmpty;
  }

  // =====================================================
  // ADDRESS CRUD
  // =====================================================
  static Future<void> saveAddress(AddressModel a) async {
    await addressBox.put(a.id, a.toMap());
  }

  static List<AddressModel> getAddresses() {
    return addressBox.values
        .map(
          (e) => AddressModel.fromMap(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }

  static Future<void> deleteAddress(String id) async {
    await addressBox.delete(id);
  }

  // =====================================================
  // TRANSACTION
  // =====================================================
  static Future<void> saveTransaction(TransactionModel trx) async =>
      transactionBox.put(trx.id, trx);

  static List<TransactionModel> getAllTransactions() =>
      transactionBox.values.toList();

  static double getTotalSpentByUser(String? username) {
    if (username == null) return 0.0;
    double sum = 0;
    for (var t in transactionBox.values) {
      sum += t.amount;
    }
    return sum;
  }

  static int getTotalTransactionCount() => transactionBox.length;

  // =====================================================
  // FEEDBACK
  // =====================================================
  static Future<void> saveFeedback(FeedbackModel fb) async =>
      feedbackBox.put(fb.id, fb);

  static List<FeedbackModel> getFeedbackList() =>
      feedbackBox.values.toList();
}
