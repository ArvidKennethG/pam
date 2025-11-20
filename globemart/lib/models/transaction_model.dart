// lib/models/transaction_model.dart  (modified)

import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 2)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String productName;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String currency;

  @HiveField(4)
  String dateTime;

  @HiveField(5)
  String location;

  @HiveField(6)
  String paymentMethod;

  // NEW: shipping address stored as a single string (human readable)
  @HiveField(7)
  String? shippingAddress;

  TransactionModel({
    required this.id,
    required this.productName,
    required this.amount,
    required this.currency,
    required this.dateTime,
    required this.location,
    required this.paymentMethod,
    this.shippingAddress,
  });
}
