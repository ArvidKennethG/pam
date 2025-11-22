// lib/pages/address_list_page.dart

import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../services/hive_service.dart';
import 'add_edit_address_page.dart';

class AddressListPage extends StatefulWidget {
  final bool selectMode; // jika true -> tap akan return AddressModel
  const AddressListPage({super.key, this.selectMode = false});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  List<AddressModel> addresses = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    addresses = HiveService.getAddresses();
    // let default muncul di paling atas
    addresses.sort((a, b) {
      if (a.isDefault && !b.isDefault) return -1;
      if (!a.isDefault && b.isDefault) return 1;
      return 0;
    });
    setState(() {});
  }

  Future<void> _openAddEdit([AddressModel? a]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditAddressPage(address: a)),
    );
    if (result == true) _load();
  }

  Future<void> _confirmDelete(AddressModel a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus alamat?'),
        content: Text('Yakin ingin menghapus alamat "${a.label}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (ok == true) {
      await HiveService.deleteAddress(a.id);
      _load();
    }
  }

  Widget _buildTile(AddressModel a) {
    return Card(
      color: const Color(0xFF1B1030),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: widget.selectMode ? () => Navigator.pop(context, a) : null,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF4F3FFF),
          child: Text(a.label.isNotEmpty ? a.label[0].toUpperCase() : 'A', style: const TextStyle(color: Colors.white)),
        ),
        title: Row(
          children: [
            Expanded(child: Text(a.label, style: const TextStyle(color: Colors.white))),
            if (a.isDefault)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
                child: const Text('Utama', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
          ],
        ),
        subtitle: Text(a.toFriendlyString(), style: const TextStyle(color: Colors.white60)),
        trailing: widget.selectMode
            ? null
            : Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.white70), onPressed: () => _openAddEdit(a)),
                IconButton(icon: const Icon(Icons.delete_forever, color: Colors.redAccent), onPressed: () => _confirmDelete(a)),
              ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF100A25),
      appBar: AppBar(title: Text(widget.selectMode ? 'Pilih Alamat' : 'Alamat Saya'), backgroundColor: const Color(0xFF4F3FFF)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: addresses.isEmpty
                  ? const Center(child: Text('Belum ada alamat.\nTambah alamat untuk melanjutkan.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)))
                  : ListView.builder(itemCount: addresses.length, itemBuilder: (_, i) => _buildTile(addresses[i])),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _openAddEdit(),
              icon: const Icon(Icons.add_location_alt),
              label: const Text('Tambah Alamat'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F3FFF), padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ],
        ),
      ),
    );
  }
}
