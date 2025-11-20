// lib/models/transaction_model.dart

import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 2)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String id;

  // productName will be a readable summary (single product or multi-line cart summary)
  @HiveField(1)
  String productName;

  @HiveField(2)
  double amount; // total amount in currency (or USD)

  @HiveField(3)
  String currency;

  @HiveField(4)
  String dateTime;

  @HiveField(5)
  String location;

  @HiveField(6)
  String paymentMethod;

  TransactionModel({
    required this.id,
    required this.productName,
    required this.amount,
    required this.currency,
    required this.dateTime,
    required this.location,
    required this.paymentMethod,
  });
}
