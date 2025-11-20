import 'package:flutter/material.dart';
import '../services/hive_service.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final trxList = HiveService.getAllTransactions();

    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Transaksi")),
      body: ListView.builder(
        itemCount: trxList.length,
        itemBuilder: (_, i) {
          final trx = trxList[i];

          return ListTile(
            title: Text(trx.productName),
            subtitle: Text("${trx.amount} ${trx.currency}"),
            onTap: () {},
          );
        },
      ),
    );
  }
}
