// lib/pages/add_edit_address_page.dart

import 'package:flutter/material.dart';
import '../models/address_model.dart';
import '../services/hive_service.dart';

class AddEditAddressPage extends StatefulWidget {
  final AddressModel? address;
  const AddEditAddressPage({super.key, this.address});

  @override
  State<AddEditAddressPage> createState() => _AddEditAddressPageState();
}

class _AddEditAddressPageState extends State<AddEditAddressPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController labelCtrl;
  late TextEditingController recipientCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController addressCtrl;
  late TextEditingController rtCtrl;
  late TextEditingController rwCtrl;
  late TextEditingController kelCtrl;
  late TextEditingController kecCtrl;
  late TextEditingController cityCtrl;
  late TextEditingController provinceCtrl;
  late TextEditingController postalCtrl;

  bool isDefault = false;

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    labelCtrl = TextEditingController(text: a?.label ?? '');
    recipientCtrl = TextEditingController(text: a?.recipientName ?? '');
    phoneCtrl = TextEditingController(text: a?.phone ?? '');
    addressCtrl = TextEditingController(text: a?.fullAddress ?? '');
    rtCtrl = TextEditingController(text: a?.rt ?? '');
    rwCtrl = TextEditingController(text: a?.rw ?? '');
    kelCtrl = TextEditingController(text: a?.kelurahan ?? '');
    kecCtrl = TextEditingController(text: a?.kecamatan ?? '');
    cityCtrl = TextEditingController(text: a?.city ?? '');
    provinceCtrl = TextEditingController(text: a?.province ?? '');
    postalCtrl = TextEditingController(text: a?.postalCode ?? '');
    isDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    labelCtrl.dispose();
    recipientCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    rtCtrl.dispose();
    rwCtrl.dispose();
    kelCtrl.dispose();
    kecCtrl.dispose();
    cityCtrl.dispose();
    provinceCtrl.dispose();
    postalCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final model = AddressModel(
      id: widget.address?.id,
      label: labelCtrl.text.trim(),
      recipientName: recipientCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      fullAddress: addressCtrl.text.trim(),
      rt: rtCtrl.text.trim(),
      rw: rwCtrl.text.trim(),
      kelurahan: kelCtrl.text.trim(),
      kecamatan: kecCtrl.text.trim(),
      city: cityCtrl.text.trim(),
      province: provinceCtrl.text.trim(),
      postalCode: postalCtrl.text.trim(),
      isDefault: isDefault,
      lat: widget.address?.lat,
      lng: widget.address?.lng,
    );

    // Simpan
    await HiveService.saveAddress(model);

    // Jika model.isDefault true, pastikan nonaktifkan default lain
    if (model.isDefault) {
      final all = HiveService.getAddresses();
      for (var a in all) {
        if (a.id != model.id && a.isDefault) {
          await HiveService.saveAddress(a.copyWith(isDefault: false));
        }
      }
    }

    Navigator.pop(context, true);
  }

  Widget _field(TextEditingController c, String label, {bool required = false, TextInputType? keyboardType}) {
    return TextFormField(
      controller: c,
      keyboardType: keyboardType ?? TextInputType.text,
      validator: required ? (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24)),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blueAccent)),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.address != null;
    return Scaffold(
      backgroundColor: const Color(0xFF100A25),
      appBar: AppBar(title: Text(isEdit ? 'Edit Alamat' : 'Tambah Alamat'), backgroundColor: const Color(0xFF4F3FFF)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                _field(labelCtrl, 'Label (Rumah/Kantor/Kost)', required: true),
                const SizedBox(height: 10),
                _field(recipientCtrl, 'Nama Penerima'),
                const SizedBox(height: 10),
                _field(phoneCtrl, 'Nomor Telepon', required: true, keyboardType: TextInputType.phone),
                const SizedBox(height: 10),
                _field(addressCtrl, 'Alamat Lengkap', required: true),
                const SizedBox(height: 10),
                Row(children: [Expanded(child: _field(rtCtrl, 'RT')), const SizedBox(width: 10), Expanded(child: _field(rwCtrl, 'RW'))]),
                const SizedBox(height: 10),
                _field(kelCtrl, 'Kelurahan'),
                const SizedBox(height: 10),
                _field(kecCtrl, 'Kecamatan', required: true),
                const SizedBox(height: 10),
                _field(cityCtrl, 'Kota / Kabupaten', required: true),
                const SizedBox(height: 10),
                _field(provinceCtrl, 'Provinsi'),
                const SizedBox(height: 10),
                _field(postalCtrl, 'Kode Pos', keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                Row(children: [Checkbox(value: isDefault, onChanged: (v) => setState(() => isDefault = v ?? false)), const SizedBox(width: 8), const Text('Jadikan alamat utama', style: TextStyle(color: Colors.white))]),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: _save, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F3FFF), padding: const EdgeInsets.symmetric(vertical: 14)), child: Text(isEdit ? 'Simpan Perubahan' : 'Simpan Alamat')),
              ],
            ),
          )
        ],
      ),
    );
  }
}
