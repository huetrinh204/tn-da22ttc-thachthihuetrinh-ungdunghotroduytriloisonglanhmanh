import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'onboarding_screen.dart';

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

    setState(() {
      isLoading = true;
      message = "";
    });

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
      setState(() => message = res["message"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tạo tài khoản",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Bắt đầu hành trình sống lành mạnh của bạn 🌱",
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 36),

                // NAME
                _buildLabel("Họ và tên"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDecoration("Nhập họ và tên", Icons.person_outline),
                  validator: (v) {
                    if (v!.trim().isEmpty) return "Vui lòng nhập tên";
                    if (v.trim().length < 2) return "Tên phải có ít nhất 2 ký tự";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // EMAIL
                _buildLabel("Email"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration("Nhập email", Icons.email_outlined),
                  validator: (v) {
                    if (v!.trim().isEmpty) return "Vui lòng nhập email";
                    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
                    if (!emailRegex.hasMatch(v.trim())) return "Email không đúng định dạng";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // PASSWORD
                _buildLabel("Mật khẩu"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  onChanged: (_) {
                    // re-validate confirm khi password thay đổi
                    _formKey.currentState?.validate();
                  },
                  decoration: _inputDecoration(
                    "Tối thiểu 8 ký tự",
                    Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                        obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => obscurePassword = !obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v!.isEmpty) return "Vui lòng nhập mật khẩu";
                    if (v.length < 8) return "Mật khẩu tối thiểu 8 ký tự";
                    if (!RegExp(r'[A-Z]').hasMatch(v)) return "Mật khẩu phải có ít nhất 1 chữ hoa";
                    if (!RegExp(r'[0-9]').hasMatch(v)) return "Mật khẩu phải có ít nhất 1 chữ số";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

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
                        obscureConfirm ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => obscureConfirm = !obscureConfirm),
                    ),
                  ),
                  validator: (v) {
                    if (v!.isEmpty) return "Vui lòng xác nhận mật khẩu";
                    if (v != passwordController.text) return "Mật khẩu không khớp";
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // ERROR MESSAGE
                if (message.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(message,
                              style: const TextStyle(color: Colors.red, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),

                // REGISTER BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,
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
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            "Tạo tài khoản",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // BACK TO LOGIN
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Đã có tài khoản? ",
                          style: TextStyle(color: Colors.grey)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          "Đăng nhập",
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
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
