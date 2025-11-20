import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../utils/password_utils.dart';
import '../routes/app_routes.dart';
import '../models/user_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  void loginUser() {
    if (!formKey.currentState!.validate()) return;

    final UserModel? user =
        HiveService.getUserByUsername(usernameController.text.trim());

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Username tidak ditemukan")));
      return;
    }

    final correct = PasswordUtils.verifyPassword(
        passController.text, user.passwordHash);

    if (!correct) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Password salah")));
      return;
    }

    HiveService.setLoginSession(true);

    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: "Username"),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              TextFormField(
                controller: passController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loginUser,
                child: const Text("LOGIN"),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                child: const Text("Belum punya akun? Daftar"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
