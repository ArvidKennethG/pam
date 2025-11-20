import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/feedback_model.dart';
import '../services/hive_service.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final nameCtrl = TextEditingController();
  final msgCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    msgCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = nameCtrl.text.trim();
    final msg = msgCtrl.text.trim();
    if (msg.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Isi pesan dulu")));
      return;
    }

    final fb = FeedbackModel(
      id: const Uuid().v4(),
      name: name.isEmpty ? 'Anonymous' : name,
      message: msg,
      dateTime: DateTime.now().toIso8601String(),
    );

    HiveService.saveFeedback(fb);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Terima kasih atas pesanmu!")));

    nameCtrl.clear();
    msgCtrl.clear();

    setState(() {}); // refresh if you display list in same page
  }

  @override
  Widget build(BuildContext context) {
    final list = HiveService.getFeedbackList().reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Saran & Kesan"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),

          const Text("Nama Kamu", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 8),

          TextField(
            controller: nameCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: "Masukkan nama",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            ),
          ),

          const SizedBox(height: 24),
          const Text("Saran / Kesan", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 8),

          TextField(
            controller: msgCtrl,
            minLines: 5,
            maxLines: 8,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              hintText: "Tulis pesan kamu...",
              hintStyle: TextStyle(color: Colors.white54),
            ),
          ),

          const SizedBox(height: 28),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFff4ecf),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _submit,
            child: const Text("Kirim", style: TextStyle(fontSize: 16)),
          ),

          const SizedBox(height: 30),

          const Text("Riwayat Saran", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          if (list.isEmpty)
            const Text("Belum ada saran", style: TextStyle(color: Colors.white54))
          else
            ...list.map((fb) {
              return Card(
                color: const Color(0xFF1b1130),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(fb.name, style: const TextStyle(color: Colors.white)),
                  subtitle: Text("${fb.message}\n${fb.dateTime}", style: const TextStyle(color: Colors.white70)),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
