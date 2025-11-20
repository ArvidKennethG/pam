// lib/pages/profile_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/hive_service.dart';
import '../services/location_service.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? user;
  File? avatarFile;
  String lastCity = '-';
  double totalSpent = 0.0;
  int totalTrx = 0;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadStats();
  }

  void safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  Future<void> _loadUser() async {
    // Ambil first user dari userDataBox (sesuai implementasi HiveService sebelumnya)
    final users = HiveService.userDataBox.values.toList();
    if (users.isNotEmpty) {
      user = users.first;
      if (user!.profileImagePath != null && user!.profileImagePath!.isNotEmpty) {
        avatarFile = File(user!.profileImagePath!);
      }
    }
    safeSetState(() {});
  }

  Future<void> _loadStats() async {
    final trxs = HiveService.getAllTransactions();
    totalTrx = trxs.length;
    totalSpent = HiveService.getTotalSpentByUser(user?.username);
    if (trxs.isNotEmpty) {
      // gunakan transaksi terakhir jika tersedia
      lastCity = trxs.last.location;
    }
    safeSetState(() {});
  }

  // Format rupiah: 1.234.567,89
  String formatRupiah(double value) {
    final intPart = value.truncate();
    final decimals = ((value - intPart) * 100).round();

    String s = intPart.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buffer.write(s[i]);
      count++;
      if (count % 3 == 0 && i != 0) buffer.write('.');
    }
    final reversed = buffer.toString().split('').reversed.join();

    if (decimals > 0) {
      return 'Rp $reversed,${decimals.toString().padLeft(2, '0')}';
    } else {
      return 'Rp $reversed';
    }
  }

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;

    // Simpan path ke Hive via service yang sudah tersedia
    if (user != null) {
      await HiveService.updateUserProfileImage(user!.id, file.path);
      avatarFile = File(file.path);
      // reload user object from box to reflect changes
      user = HiveService.userDataBox.get(user!.id);
    }

    safeSetState(() {});
  }

  Future<void> _refreshLocation() async {
    final loc = await LocationService.getFriendlyLocation();
    // tidak ada method saveLastLocation di HiveService original; kita hanya tampilkan saja
    lastCity = loc;
    safeSetState(() {});
  }

  Future<void> _logout() async {
    HiveService.clearSession();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final username = user?.username ?? '-';
    final name = user?.name ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFF4F3FFF),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4F3FFF),
                      Color(0xFF7A71FF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(80),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white,
                  backgroundImage: avatarFile != null
                      ? FileImage(avatarFile!) as ImageProvider<Object>
                      : const AssetImage('assets/profile.png'),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          const SizedBox(height: 6),
          Center(child: Text('@$username')),
          const SizedBox(height: 20),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shopping_bag),
                      const SizedBox(width: 8),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Total Transactions'),
                        Text('$totalTrx', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ])
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.paid),
                      const SizedBox(width: 8),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Total Spent'),
                        Text(formatRupiah(totalSpent), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ])
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on),
                      const SizedBox(width: 8),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Last Transaction Location'),
                        Text(lastCity, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ])
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await _refreshLocation();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F3FFF)),
            child: const Text('Refresh Location'),
          ),

          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          )
        ],
      ),
    );
  }
}
