import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'feedback_page.dart';
import 'cart_page.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int index = 0;

  final pages = const [
    HomePage(),
    ProfilePage(),
    FeedbackPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      body: pages[index],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));
        },
        backgroundColor: const Color(0xFF4F3FFF),
        icon: const Icon(Icons.shopping_cart),
        label: Text('${cart.totalItems}'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: "Saran",
          ),
        ],
      ),
    );
  }
}
