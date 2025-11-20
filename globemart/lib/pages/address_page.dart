import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/address_model.dart';
import '../services/hive_service.dart';
import '../services/location_service.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  @override
  Widget build(BuildContext context) {
    final list = HiveService.getAddresses();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Alamat Pengiriman"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _openForm(),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final a = list[index];
          return Card(
            child: ListTile(
              title: Text(a.label),
              subtitle: Text(a.fullAddress),
              onTap: () => Navigator.pop(context, a),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await HiveService.deleteAddress(a.id);
                  setState(() {});
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _openForm() {
    final label = TextEditingController();
    final address = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Alamat"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: label,
              decoration: const InputDecoration(labelText: "Label (Rumah, Kantor, dll)"),
            ),
            TextField(
              controller: address,
              decoration: const InputDecoration(labelText: "Alamat lengkap"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final pos = await LocationService.getPosition();

                final newAddress = AddressModel(
                  id: const Uuid().v4(),
                  label: label.text.trim(),
                  fullAddress: address.text.trim(),
                  lat: pos?.latitude,
                  lng: pos?.longitude,
                );

                await HiveService.saveAddress(newAddress);

                Navigator.pop(context);
                setState(() {});
              },
              child: const Text("Simpan"),
            )
          ],
        ),
      ),
    );
  }
}
