// lib/routes/app_routes.dart

import 'package:flutter/material.dart';

import '../pages/splash_page.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../pages/main_navigation.dart';
import '../pages/profile_page.dart';
import '../pages/product_detail_page.dart';
import '../pages/cart_page.dart';
import '../pages/checkout_page.dart';
import '../pages/payment_page.dart';
import '../pages/transaction_detail_page.dart';
import '../pages/transaction_history_page.dart';
import '../pages/feedback_page.dart';
import '../pages/address_list_page.dart'; // <- new

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const main = '/main';
  static const home = '/home';
  static const profile = '/profile';
  static const productDetail = '/product-detail';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const payment = '/payment';
  static const transactionDetail = '/transaction-detail';
  static const transactionHistory = '/transaction-history';
  static const feedback = '/feedback';
  static const address = '/address'; // <- new

  static Route<dynamic> generate(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case main:
      case home:
        return MaterialPageRoute(builder: (_) => const MainNavigation());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case cart:
        return MaterialPageRoute(builder: (_) => const CartPage());
      case feedback:
        return MaterialPageRoute(builder: (_) => const FeedbackPage());
      case productDetail: {
        final map = args as Map<String, dynamic>?;
        final product = map != null ? map['product'] as dynamic : null;
        if (product == null) {
          return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Product not provided'))));
        }
        return MaterialPageRoute(builder: (_) => ProductDetailPage(product: product));
      }
      case checkout: {
        final map = args as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CheckoutPage(
            product: map != null ? map['product'] as dynamic : null,
            singleQty: map != null ? map['singleQty'] as int? : null,
            qty: map != null ? map['qty'] as int? : null,
            cart: map != null ? map['cart'] as List<dynamic>? : null,
            isSingle: map != null ? map['isSingle'] as bool? : null,
          ),
        );
      }
      case payment: {
        return MaterialPageRoute(builder: (_) => const PaymentPage(), settings: settings);
      }
      case transactionDetail: {
        final map = args as Map<String, dynamic>?;
        final trx = map != null ? map['trx'] : null;
        if (trx == null) {
          return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Transaction not provided'))));
        }
        return MaterialPageRoute(builder: (_) => TransactionDetailPage(trx: trx));
      }
      case transactionHistory:
        return MaterialPageRoute(builder: (_) => const TransactionHistoryPage());
      case address:
        // support select mode via arguments: { 'selectMode': true/false }
        final map = args as Map<String, dynamic>?;
        final selectMode = map != null ? (map['selectMode'] as bool? ?? false) : false;
        return MaterialPageRoute(builder: (_) => AddressListPage(selectMode: selectMode));
      default:
        return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Route not found'))));
    }
  }

  static Map<String, WidgetBuilder> get routes => {
        splash: (c) => const SplashPage(),
        login: (c) => const LoginPage(),
        register: (c) => const RegisterPage(),
        main: (c) => const MainNavigation(),
      };
}
