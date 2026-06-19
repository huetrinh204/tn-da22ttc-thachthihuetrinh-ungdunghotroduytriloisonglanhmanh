import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'admin_home_screen.dart';
import 'register_screen.dart';
import 'onboarding_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../widgets/floating_leaves.dart';
import '../widgets/app_snackbar.dart';
import '../theme/theme_extensions.dart';
import '../services/onboarding_gate.dart';
import 'forgot_password_screen.dart';
import '../l10n/app_localizations.dart';
import '../widgets/language_flag_toggle.dart';

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
    final l10n = AppLocalizations.of(context)!;
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      AppSnackbar.showError(context, l10n.pleaseEnterAllInfo);
      return;
    }
    setState(() => isLoading = true);
    final res = await ApiService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );
    setState(() => isLoading = false);
    if (res["message"] == "Login success") {
      final token = res["token"];
      if (token == null) {
        if (!mounted) return;
        AppSnackbar.showError(context, l10n.loginFailedRetry);
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);
      
      // Check if user is admin
      final profileRes = await ApiService.getProfile(token);
      final userRole = profileRes['user']?['role'] as String?;
      
      if (userRole == 'admin') {
        // Admin goes to AdminHomeScreen
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
        );
      } else {
        // Regular user goes to normal flow
        final needsOnboarding = await OnboardingGate.needsOnboarding(token);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                needsOnboarding ? const OnboardingScreen() : const HomeScreen(),
          ),
        );
      }
    } else {
      if (!mounted) return;
      AppSnackbar.showError(context, res["message"] ?? l10n.loginFailed);
    }
  }

  Future<void> handleGoogleLogin() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await _googleSignIn.signOut();
      final user = await _googleSignIn.signIn();
      if (user == null) return;
      final auth = await user.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        if (!mounted) return;
        AppSnackbar.showError(context, l10n.googleLoginFailed);
        return;
      }
      setState(() => isLoading = true);
      final res = await ApiService.googleLogin(idToken);
      setState(() => isLoading = false);
      if (res["message"] == "Login success") {
        final prefs = await SharedPreferences.getInstance();
        final token = res["token"] as String?;
        if (token == null) {
          if (!mounted) return;
          AppSnackbar.showError(context, l10n.googleLoginFailed);
          return;
        }
        await prefs.setString("token", token);
        final isNewUser = res["isNewUser"] == true;
        
        // Check if user is admin
        final profileRes = await ApiService.getProfile(token);
        final userRole = profileRes['user']?['role'] as String?;
        
        if (userRole == 'admin') {
          // Admin goes to AdminHomeScreen
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
          );
        } else {
          // Regular user goes to normal flow
          final needsOnboarding = await OnboardingGate.needsOnboarding(
            token,
            isNewUser: isNewUser,
          );
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  needsOnboarding ? const OnboardingScreen() : const HomeScreen(),
            ),
          );
        }
      } else {
        if (!mounted) return;
        AppSnackbar.showError(context, res["message"] ?? l10n.googleLoginFailed);
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(context, l10n.googleLoginError(e.toString()));
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
                        Center(
                          child: Text(
                            AppLocalizations.of(context)!.loginTitle,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // EMAIL
                        Text(AppLocalizations.of(context)!.email,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(
                              AppLocalizations.of(context)!.enterEmail, Icons.email_outlined),
                        ),

                        const SizedBox(height: 16),

                        // PASSWORD
                        Text(AppLocalizations.of(context)!.password,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          decoration: _inputDecoration(
                            AppLocalizations.of(context)!.enterPassword,
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
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const ForgotPasswordScreen()),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.forgotPasswordQuestion,
                              style: const TextStyle(
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
                                : Text(
                                    AppLocalizations.of(context)!.login,
                                    style: const TextStyle(
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
                              child: Text(AppLocalizations.of(context)!.or,
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 13)),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // GOOGLE button
                        SizedBox(
                          width: double.infinity,
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
                            label: Text(
                              AppLocalizations.of(context)!.loginWithGoogle,
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black87),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Color(0xFFDDDDDD)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),

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
                              text: TextSpan(
                                text: AppLocalizations.of(context)!.noAccount,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 13),
                                children: [
                                  TextSpan(
                                    text: AppLocalizations.of(context)!.registerNow,
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

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Flag toggle — để cuối để ở trên cùng (z-index)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 16),
                child: const LanguageFlagToggle(),
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
      prefixIcon: Icon(icon, color: context.textSecondary, size: 20),
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
