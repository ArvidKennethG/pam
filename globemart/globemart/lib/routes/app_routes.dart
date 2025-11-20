// lib/routes/app_routes.dart

import 'package:flutter/material.dart';

import '../pages/splash_page.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../pages/main_navigation.dart';
import '../pages/checkout_page.dart';
import '../pages/payment_page.dart';
import '../pages/transaction_detail_page.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const checkout = '/checkout';
  static const payment = '/payment';
  static const invoice = '/invoice';

  // Use onGenerateRoute-like mapping here for safety
  static Route<dynamic>? generate(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case home:
        return MaterialPageRoute(builder: (_) => const MainNavigation());
      case checkout:
        final map = args as Map<String, dynamic>?;
        return MaterialPageRoute(
            builder: (_) => CheckoutPage(
                  product: map != null ? map['product'] : null,
                  singleQty: map != null ? map['qty'] : null,
                  cart: map != null ? map['cart'] : null,
                ));
      case payment:
        return MaterialPageRoute(builder: (_) => const PaymentPage(), settings: settings);
      case invoice:
        final map = args as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => TransactionDetailPage(trx: map != null ? map['trx'] : null),
        );
      default:
        return null;
    }
  }

  // Helper to provide a ready routes map if you used routes: {} earlier (not required)
  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (c) => const SplashPage(),
      login: (c) => const LoginPage(),
      register: (c) => const RegisterPage(),
      home: (c) => const MainNavigation(),
      // checkout & payment & invoice are handled via generate() so we can pass args safely
    };
  }
}
