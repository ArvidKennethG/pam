import 'package:flutter/material.dart';
import 'dart:async';
import '../routes/app_routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _ani;

  @override
  void initState() {
    super.initState();
    _ani = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);

    // short delay then go to login (or home if session exists)
    Timer(const Duration(milliseconds: 1800), () {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    });
  }

  @override
  void dispose() {
    _ani.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF130f40), Color(0xFF4f3fff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: Tween(begin: 0.9, end: 1.05).animate(CurvedAnimation(parent: _ani, curve: Curves.easeInOut)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // logo placeholder: circular neon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Color(0xFF4f3fff), Color(0xFFff4ecf)]),
                    boxShadow: [
                      BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 18, spreadRadius: 2),
                    ],
                  ),
                  child: const Center(
                    child: Text('G', style: TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 18),
                const Text('GlobeMart', style: TextStyle(fontSize: 22, letterSpacing: 1.2, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 6),
                Opacity(
                  opacity: 0.9,
                  child: Text('Future Shopping • Futuristic UI', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
