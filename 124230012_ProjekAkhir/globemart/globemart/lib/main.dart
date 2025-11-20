import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'routes/app_routes.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await HiveService.initHive();

  // Notification init (harus di mobile)
  try {
    await NotificationService.init();
  } catch (_) {}

  runApp(const GlobeMartApp());
}

class GlobeMartApp extends StatelessWidget {
  const GlobeMartApp({super.key});

  // color tokens for cyberpunk theme
  static const Color deepPurple = Color(0xFF130f40);
  static const Color neonPink = Color(0xFFff4ecf);
  static const Color neonBlue = Color(0xFF4f3fff);

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'GlobeMart',
        debugShowCheckedModeBanner: false,
        theme: base.copyWith(
          scaffoldBackgroundColor: deepPurple,
          primaryColor: neonBlue,
          colorScheme: base.colorScheme.copyWith(
            primary: neonBlue,
            secondary: neonPink,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.transparent,
            centerTitle: true,
            foregroundColor: Colors.white,
          ),
          textTheme: base.textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: neonPink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
            ),
          ),
        ),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.generate,
      ),
    );
  }
}
