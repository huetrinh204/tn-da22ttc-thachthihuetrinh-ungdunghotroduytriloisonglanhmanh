import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'onboarding_screen.dart';
import '../widgets/floating_leaves.dart';
import '../widgets/app_snackbar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirm = true;
  String message = "";

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    final res = await ApiService.register(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text,
    );
    setState(() => isLoading = false);
    if (res["message"] == "Register success") {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", res["token"]);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else {
      if (!mounted) return;
      AppSnackbar.showError(context, res["message"] ?? "Đăng ký thất bại");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background — giống login
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
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Color(0xFF1B5E20)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // Logo
                  Image.asset('assets/images/logo.png', height: 90),

                  const SizedBox(height: 16),

                  // Quote dưới logo — giống login
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

                  const SizedBox(height: 24),

                  // Form card
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              "Tạo tài khoản",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // NAME
                          _buildLabel("Họ và tên"),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: _inputDecoration(
                                "Nhập họ và tên", Icons.person_outline),
                            validator: (v) {
                              if (v!.trim().isEmpty) return "Vui lòng nhập tên";
                              if (v.trim().length < 2) return "Tên phải có ít nhất 2 ký tự";
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // EMAIL
                          _buildLabel("Email"),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                                "Nhập email của bạn", Icons.email_outlined),
                            validator: (v) {
                              if (v!.trim().isEmpty) return "Vui lòng nhập email";
                              final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
                              if (!emailRegex.hasMatch(v.trim())) return "Email không đúng định dạng";
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // PASSWORD
                          _buildLabel("Mật khẩu"),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            decoration: _inputDecoration(
                              "Tối thiểu 8 ký tự",
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
                            validator: (v) {
                              if (v!.isEmpty) return "Vui lòng nhập mật khẩu";
                              if (v.length < 8) return "Mật khẩu tối thiểu 8 ký tự";
                              if (!RegExp(r'[A-Z]').hasMatch(v)) return "Phải có ít nhất 1 chữ hoa";
                              if (!RegExp(r'[0-9]').hasMatch(v)) return "Phải có ít nhất 1 chữ số";
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // CONFIRM PASSWORD
                          _buildLabel("Xác nhận mật khẩu"),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: obscureConfirm,
                            decoration: _inputDecoration(
                              "Nhập lại mật khẩu",
                              Icons.lock_outline,
                              suffix: IconButton(
                                icon: Icon(
                                  obscureConfirm
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                    () => obscureConfirm = !obscureConfirm),
                              ),
                            ),
                            validator: (v) {
                              if (v!.isEmpty) return "Vui lòng xác nhận mật khẩu";
                              if (v != passwordController.text) return "Mật khẩu không khớp";
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // REGISTER BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : handleRegister,
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
                                      "Tạo tài khoản",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // BACK TO LOGIN
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: RichText(
                                text: const TextSpan(
                                  text: "Đã có tài khoản? ",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                  children: [
                                    TextSpan(
                                      text: "Đăng nhập",
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
