import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: "971894407814-sdhs1msoj8v96c13cc7jle7coq95dfcd.apps.googleusercontent.com",
    scopes: ['email', 'profile'],
  );

  String message = "";
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ================= LOGIN EMAIL =================
  void handleLogin() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      setState(() {
        message = "Vui lòng nhập đầy đủ thông tin";
      });
      return;
    }

    setState(() {
      isLoading = true;
      message = "";
    });

    final res = await ApiService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() {
      isLoading = false;
    });

    if (res["message"] == "Login success") {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", res["token"]);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() {
        message = res["message"];
      });
    }
  }

  // ================= LOGIN GOOGLE =================
  Future<void> handleGoogleLogin() async {
    try {
      await _googleSignIn.signOut(); // luôn hiện popup chọn tài khoản
      final user = await _googleSignIn.signIn();

      if (user == null) return;

      final auth = await user.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        setState(() {
          message = "Google login thất bại";
        });
        return;
      }

      setState(() {
        isLoading = true;
        message = "";
      });

      final res = await ApiService.googleLogin(idToken);

      setState(() {
        isLoading = false;
      });

      if (res["message"] == "Login success") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", res["token"]);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        setState(() {
          message = res["message"];
        });
      }
    } catch (e) {
      setState(() {
        message = "Lỗi Google login: $e";
      });
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Viora 🌱",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            // EMAIL
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // PASSWORD
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // LOGIN BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Đăng nhập"),
              ),
            ),

            const SizedBox(height: 15),

            // GOOGLE LOGIN
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : handleGoogleLogin,
                icon: const Icon(Icons.login),
                label: const Text("Đăng nhập bằng Google"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // MESSAGE
            Text(
              message,
              style: const TextStyle(color: Colors.red),
            ),

            const SizedBox(height: 16),

            // REGISTER LINK
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Chưa có tài khoản? ",
                    style: TextStyle(color: Colors.grey)),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: const Text(
                    "Đăng ký",
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}