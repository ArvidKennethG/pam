import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/feedback_model.dart';

class HiveService {
  static late Box userBox;
  static late Box<UserModel> userDataBox;
  static late Box<TransactionModel> transactionBox;
  static late Box<FeedbackModel> feedbackBox;
  static late Box cartBox; // dynamic box for cart list

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
    cartBox = await Hive.openBox('cartBox'); // plain box storing List<Map>
  }

  // SESSION ------------------------------------------
  static bool get isLoggedIn => userBox.get('isLoggedIn', defaultValue: false);
  static void setLoginSession(bool value) => userBox.put('isLoggedIn', value);
  static void clearSession() => userBox.clear();

  // USER ----------------------------------------------
  static Future<void> saveUser(UserModel user) async =>
      userDataBox.put(user.id, user);

  static UserModel? getUserByUsername(String username) {
    try {
      return userDataBox.values.firstWhere((u) => u.username == username);
    } catch (_) {
      return null;
    }
  }

  static Future<void> updateUserProfileImage(String userId, String path) async {
    final user = userDataBox.get(userId);
    if (user != null) {
      user.profileImagePath = path;
      await user.save();
    }
  }

  // CART (stored as List<Map>)
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

  static Future<void> clearCart() async {
    await cartBox.delete('cart');
  }

  // TRANSACTION ---------------------------------------
  static Future<void> saveTransaction(TransactionModel trx) async =>
      transactionBox.put(trx.id, trx);

  static List<TransactionModel> getAllTransactions() =>
      transactionBox.values.toList();

  static double getTotalSpentByUser(String? username) {
    if (username == null) return 0.0;
    final list = transactionBox.values.toList();
    double sum = 0;
    for (var t in list) {
      sum += t.amount;
    }
    return sum;
  }

  static int getTotalTransactionCount() {
    return transactionBox.length;
  }

  // FEEDBACK -------------------------------------------
  static Future<void> saveFeedback(FeedbackModel fb) async =>
      feedbackBox.put(fb.id, fb);

  static List<FeedbackModel> getFeedbackList() =>
      feedbackBox.values.toList();
}
