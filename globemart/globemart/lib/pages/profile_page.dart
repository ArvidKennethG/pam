import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/hive_service.dart';
import '../models/user_model.dart';
import '../services/location_service.dart';

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

  void _loadUser() {
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
      lastCity = trxs.last.location;
    }
    safeSetState(() {});
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;

    if (user != null) {
      await HiveService.updateUserProfileImage(user!.id, file.path);
      avatarFile = File(file.path);
    }

    safeSetState(() {});
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
                  gradient: const LinearGradient(colors: [
                    Color(0xFF4F3FFF),
                    Color(0xFF7A71FF),
                  ]),
                  borderRadius: BorderRadius.circular(80),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white,
                  // IMPORTANT: handle null-safety correctly here
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
                        Text('Rp ${totalSpent.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
              final loc = await LocationService.getFriendlyLocation();
              safeSetState(() {
                lastCity = loc;
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F3FFF)),
            child: const Text('Refresh Location'),
          ),

          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              HiveService.clearSession();
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          )
        ],
      ),
    );
  }
}
