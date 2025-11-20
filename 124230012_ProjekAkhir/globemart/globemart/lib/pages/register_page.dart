import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../services/hive_service.dart';
import '../utils/password_utils.dart';
import '../routes/app_routes.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final nameController = TextEditingController();
  final passController = TextEditingController();
  final pass2Controller = TextEditingController();

  final formKey = GlobalKey<FormState>();

  void registerUser() async {
    if (!formKey.currentState!.validate()) return;

    final existing =
        HiveService.getUserByUsername(usernameController.text.trim());
    if (existing != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Username sudah dipakai")));
      return;
    }

    final user = UserModel(
      id: const Uuid().v4(),
      username: usernameController.text.trim(),
      name: nameController.text.trim(),
      passwordHash: PasswordUtils.hashPassword(passController.text),
    );

    await HiveService.saveUser(user);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Registrasi berhasil")));

    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrasi")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: "Username"),
                validator: (v) =>
                    v!.isEmpty ? "Username wajib diisi" : null,
              ),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nama Lengkap"),
                validator: (v) => v!.isEmpty ? "Nama wajib diisi" : null,
              ),
              TextFormField(
                controller: passController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
                validator: (v) =>
                    v!.length < 6 ? "Minimal 6 karakter" : null,
              ),
              TextFormField(
                controller: pass2Controller,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Konfirmasi Password"),
                validator: (v) =>
                    v != passController.text ? "Password tidak sama" : null,
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: registerUser,
                child: const Text("DAFTAR"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
