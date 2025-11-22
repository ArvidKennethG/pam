// lib/pages/profile_page.dart
// Profile page - PREMIUM UI (Option 3, fixed colors for dark mode)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/hive_service.dart';
import '../services/location_service.dart';
import '../services/currency_service.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  UserModel? user;
  File? avatarFile;

  String lastCity = '-';
  double totalSpentUsd = 0.0;
  double totalSpentIdr = 0.0;

  double currentRate = 15500;
  double previousRate = 15500;
  DateTime? lastUpdated;

  int totalTrx = 0;

  bool isRefreshing = false;
  final ImagePicker _picker = ImagePicker();

  late final AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _loadUser();
    _loadStats(initial: true);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void safeSet(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  Future<void> _loadUser() async {
    final users = HiveService.userDataBox.values.toList();
    if (users.isNotEmpty) {
      user = users.first;
      if (user!.profileImagePath != null && user!.profileImagePath!.isNotEmpty) {
        avatarFile = File(user!.profileImagePath!);
      }
    }
    safeSet(() {});
  }

  Future<void> _loadStats({bool initial = false}) async {
    final trxs = HiveService.getAllTransactions();

    totalTrx = trxs.length;
    totalSpentUsd = HiveService.getTotalSpentByUser(user?.username);

    if (trxs.isNotEmpty) lastCity = trxs.last.location;

    if (!initial) {
      try {
        final rates = await CurrencyService.fetchRates();
        if (rates.containsKey('IDR')) {
          previousRate = currentRate;
          currentRate = rates['IDR']!;
          lastUpdated = DateTime.now();
        }
      } catch (_) {}
    }

    totalSpentIdr = await _computeIdr(totalSpentUsd);

    safeSet(() {});
  }

  Future<double> _computeIdr(double usd) async {
    try {
      final converted = await CurrencyService.convertFromUSD(usd, 'IDR');
      return converted;
    } catch (_) {
      return usd * currentRate;
    }
  }

  String formatRupiahNoDecimals(double value) {
    final intPart = value.round();
    String s = intPart.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buffer.write(s[i]);
      count++;
      if (count % 3 == 0 && i != 0) buffer.write('.');
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  String formatRupiahDelta(double value) {
    final intPart = value.round();
    String s = intPart.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buffer.write(s[i]);
      count++;
      if (count % 3 == 0 && i != 0) buffer.write('.');
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;

    if (user != null) {
      await HiveService.updateUserProfileImage(user!.id, file.path);
      avatarFile = File(file.path);
      user = HiveService.userDataBox.get(user!.id);
    }

    safeSet(() {});
  }

  Future<void> _refreshAll() async {
    if (isRefreshing) return;
    safeSet(() => isRefreshing = true);

    try {
      final loc = await LocationService.getFriendlyLocation();
      lastCity = loc;
    } catch (_) {}

    try {
      final rates = await CurrencyService.fetchRates();
      if (rates.containsKey('IDR')) {
        previousRate = currentRate;
        currentRate = rates['IDR']!;
        lastUpdated = DateTime.now();
      }
    } catch (_) {}

    final newIdr = await _computeIdr(totalSpentUsd);

    _animCtrl.forward(from: 0);

    safeSet(() {
      totalSpentIdr = newIdr;
    });

    await Future.delayed(const Duration(milliseconds: 350));
    safeSet(() => isRefreshing = false);
  }

  Future<void> _logout() async {
    HiveService.clearSession();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  Widget _buildDeltaWidget() {
    final diffRate = currentRate - previousRate;
    final increased = diffRate > 0;
    final deltaIdr = (totalSpentUsd * (currentRate - previousRate)).abs();
    final deltaText = formatRupiahDelta(deltaIdr);

    if (currentRate == previousRate) return const SizedBox.shrink();

    return Row(
      children: [
        Icon(increased ? Icons.arrow_upward : Icons.arrow_downward,
            size: 14, color: increased ? Colors.greenAccent : Colors.redAccent),
        const SizedBox(width: 6),
        Text(
          '${increased ? "↑" : "↓"} $deltaText',
          style: TextStyle(
            color: increased ? Colors.greenAccent : Colors.redAccent,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        const Text('(since last update)', style: TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }

  String _lastUpdatedText() {
    if (lastUpdated == null) return '-';
    final t = lastUpdated!;
    return "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final username = user?.username ?? '-';
    final name = user?.name ?? '-';

    return Scaffold(
      backgroundColor: const Color(0xFF090928),
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4F3FFF),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        color: const Color(0xFF4F3FFF),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 58,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 55,
                    backgroundImage: avatarFile != null
                        ? FileImage(avatarFile!)
                        : const AssetImage('assets/profile.png') as ImageProvider,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),
            Center(child: Text(name, style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold))),
            Center(child: Text("@$username", style: const TextStyle(color: Colors.white70))),
            const SizedBox(height: 20),

            //----------------------------------------------------------------
            // CARD MAIN
            //----------------------------------------------------------------
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1448),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 14)]
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TOTAL TRANSACTION
                  Row(
                    children: const [
                      Icon(Icons.lock, color: Colors.white),
                      SizedBox(width: 10),
                      Text('Total Transactions', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$totalTrx',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  // TOTAL PEMBELANJAAN
                  const Text("Total Pembelanjaan", style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Text(
                      formatRupiahNoDecimals(totalSpentIdr),
                      key: ValueKey(totalSpentIdr),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Kurs + updated
                  Row(
                    children: [
                      const Icon(Icons.attach_money, color: Colors.white70, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        "Kurs: 1 USD = Rp ${currentRate.toStringAsFixed(0)}",
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Updated: ${_lastUpdatedText()}",
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),
                  _buildDeltaWidget(),

                  const SizedBox(height: 20),

                  // LOCATION
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Last Transaction Location",
                              style: TextStyle(color: Colors.white70)),
                          Text(lastCity,
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            //----------------------------------------------------------------
            // BUTTONS
            //----------------------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isRefreshing ? null : _refreshAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F3FFF),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: isRefreshing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.sync),
                    label: Text(
                      isRefreshing ? 'Updating…' : 'Refresh Data (Lokasi + Kurs)',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text("Logout", style: TextStyle(color: Colors.red)),
                )
              ],
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tips", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text("• Tarik ke bawah (pull-to-refresh) untuk update lokasi & kurs cepat.",
                      style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 4),
                  Text("• Kurs diambil dari exchangerate-api dan disimpan sementara (cache).",
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
