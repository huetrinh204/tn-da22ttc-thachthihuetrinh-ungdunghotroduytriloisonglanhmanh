import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");

    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Viora Home 🌱"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => handleLogout(context),
            tooltip: "Đăng xuất",
          ),
        ],
      ),
      body: const Center(
        child: Text(
          "Chào mừng bạn đến Viora 🎉",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}