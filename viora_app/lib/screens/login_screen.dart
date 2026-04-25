import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../widgets/floating_leaves.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        "971894407814-sdhs1msoj8v96c13cc7jle7coq95dfcd.apps.googleusercontent.com",
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

  void handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() => message = "Vui lòng nhập đầy đủ thông tin");
      return;
    }
    setState(() { isLoading = true; message = ""; });
    final res = await ApiService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );
    setState(() => isLoading = false);
    if (res["message"] == "Login success") {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", res["token"]);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() => message = res["message"]);
    }
  }

  Future<void> handleGoogleLogin() async {
    try {
      await _googleSignIn.signOut();
      final user = await _googleSignIn.signIn();
      if (user == null) return;
      final auth = await user.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        setState(() => message = "Google login thất bại");
        return;
      }
      setState(() { isLoading = true; message = ""; });
      final res = await ApiService.googleLogin(idToken);
      setState(() => isLoading = false);
      if (res["message"] == "Login success") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", res["token"]);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        setState(() => message = res["message"]);
      }
    } catch (e) {
      setState(() => message = "Lỗi Google login: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background phủ toàn màn hình
          Image.asset(
            'assets/images/dangnhap.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),

          // Lá bay
          const FloatingLeaves(),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 48),

                  // Logo only
                  Image.asset('assets/images/logo.png', height: 90),

                  const SizedBox(height: 16),

                  // Quote dưới logo
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '"Sự thay đổi không đến từ điều lớn lao,\nmà từ những thói quen nhỏ được lặp lại mỗi ngày."',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1B5E20),
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Form card
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.88),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            "ĐĂNG NHẬP",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // EMAIL
                        const Text("Email",
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(
                              "Nhập email của bạn", Icons.email_outlined),
                        ),

                        const SizedBox(height: 16),

                        // PASSWORD
                        const Text("Mật khẩu",
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          decoration: _inputDecoration(
                            "Nhập mật khẩu của bạn",
                            Icons.lock_outline,
                            suffix: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                  () => obscurePassword = !obscurePassword),
                            ),
                          ),
                        ),

                        // Quên mật khẩu
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              "Quên mật khẩu?",
                              style: TextStyle(
                                  color: Color(0xFF4CAF50), fontSize: 13),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // LOGIN BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5),
                                  )
                                : const Text(
                                    "Đăng nhập",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // DIVIDER
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text("hoặc",
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 13)),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // GOOGLE + APPLE buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: isLoading ? null : handleGoogleLogin,
                                icon: Image.network(
                                  'https://www.google.com/favicon.ico',
                                  height: 18,
                                  errorBuilder: (_, __, ___) => const Icon(
                                      Icons.login,
                                      size: 18,
                                      color: Colors.black54),
                                ),
                                label: const Text(
                                  "Google",
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.black87),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  side: const BorderSide(
                                      color: Color(0xFFDDDDDD)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.apple,
                                    size: 20, color: Colors.black87),
                                label: const Text(
                                  "Apple",
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.black87),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  side: const BorderSide(
                                      color: Color(0xFFDDDDDD)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (message.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            message,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ],

                        const SizedBox(height: 20),

                        // REGISTER LINK
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const RegisterScreen()),
                            ),
                            child: RichText(
                              text: const TextSpan(
                                text: "Chưa có tài khoản? ",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 13),
                                children: [
                                  TextSpan(
                                    text: "Đăng ký ngay",
                                    style: TextStyle(
                                      color: Color(0xFF4CAF50),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon,
      {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
