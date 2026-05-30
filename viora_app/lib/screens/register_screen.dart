import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/onboarding_gate.dart';
import 'onboarding_screen.dart';
import '../widgets/floating_leaves.dart';
import '../widgets/app_snackbar.dart';
import '../l10n/app_localizations.dart';
import '../widgets/language_flag_toggle.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
      await OnboardingGate.prepareNewAccount();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else {
      if (!mounted) return;
      AppSnackbar.showError(context, res["message"] ?? l10n.registerFailed);
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

          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 16),
                child: const LanguageFlagToggle(),
              ),
            ),
          ),

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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      AppLocalizations.of(context)!.quote.replaceAll(r'\n', '\n'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1B5E20),
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

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
                          Center(
                            child: Text(
                              AppLocalizations.of(context)!.registerTitle,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // NAME
                          _buildLabel(AppLocalizations.of(context)!.fullName),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: _inputDecoration(
                                AppLocalizations.of(context)!.enterFullName, Icons.person_outline),
                            validator: (v) {
                              if (v!.trim().isEmpty) return AppLocalizations.of(context)!.pleaseEnterName;
                              if (v.trim().length < 2) return AppLocalizations.of(context)!.nameTooShort;
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // EMAIL
                          _buildLabel(AppLocalizations.of(context)!.email),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                                AppLocalizations.of(context)!.enterEmail, Icons.email_outlined),
                            validator: (v) {
                              if (v!.trim().isEmpty) return AppLocalizations.of(context)!.pleaseEnterEmail;
                              final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
                              if (!emailRegex.hasMatch(v.trim())) return AppLocalizations.of(context)!.invalidEmailFormat;
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // PASSWORD
                          _buildLabel(AppLocalizations.of(context)!.password),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            decoration: _inputDecoration(
                              AppLocalizations.of(context)!.minEightChars,
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
                              if (v!.isEmpty) return AppLocalizations.of(context)!.pleaseEnterPassword;
                              if (v.length < 8) return AppLocalizations.of(context)!.passwordMinEightChars;
                              if (!RegExp(r'[A-Z]').hasMatch(v)) return AppLocalizations.of(context)!.passwordNeedsUppercase;
                              if (!RegExp(r'[0-9]').hasMatch(v)) return AppLocalizations.of(context)!.passwordNeedsNumber;
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // CONFIRM PASSWORD
                          _buildLabel(AppLocalizations.of(context)!.confirmPasswordLabel),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: obscureConfirm,
                            decoration: _inputDecoration(
                              AppLocalizations.of(context)!.enterPasswordAgain,
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
                              if (v!.isEmpty) return AppLocalizations.of(context)!.pleaseConfirmPassword;
                              if (v != passwordController.text) return AppLocalizations.of(context)!.passwordsDoNotMatch;
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
                                  : Text(
                                      AppLocalizations.of(context)!.register,
                                      style: const TextStyle(
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
                                text: TextSpan(
                                  text: AppLocalizations.of(context)!.haveAccount,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                  children: [
                                    TextSpan(
                                      text: AppLocalizations.of(context)!.loginNow,
                                      style: const TextStyle(
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
