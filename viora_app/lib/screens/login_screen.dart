import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'admin_home_screen.dart';
import 'register_screen.dart';
import 'onboarding_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../widgets/floating_leaves.dart';
import '../widgets/app_notification_dialog.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/theme_extensions.dart';
import '../services/onboarding_gate.dart';
import '../services/fcm_service.dart';
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
      AppNotificationDialog.show(context, type: NotificationType.error, title: l10n.pleaseEnterAllInfo);
      return;
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(emailController.text.trim())) {
      AppNotificationDialog.show(context, type: NotificationType.error, title: l10n.invalidEmailFormat);
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
        AppNotificationDialog.show(context, type: NotificationType.error, title: l10n.loginFailedRetry);
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);
      await FcmService.resyncToken();

      // Check if user is admin
      final profileRes = await ApiService.getProfile(token);
      final userRole = profileRes['user']?['role'] as String?;

      if (userRole == 'admin') {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
        );
      } else {
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
      AppNotificationDialog.show(context, type: NotificationType.error, title: res["message"] ?? l10n.loginFailed);
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
        AppNotificationDialog.show(context, type: NotificationType.error, title: l10n.googleLoginFailed);
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
          AppNotificationDialog.show(context, type: NotificationType.error, title: l10n.googleLoginFailed);
          return;
        }
        await prefs.setString("token", token);
        await FcmService.resyncToken();
        final isNewUser = res["isNewUser"] == true;

        final profileRes = await ApiService.getProfile(token);
        final userRole = profileRes['user']?['role'] as String?;

        if (userRole == 'admin') {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
          );
        } else {
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
        AppNotificationDialog.show(context, type: NotificationType.error, title: res["message"] ?? l10n.googleLoginFailed);
      }
    } catch (e) {
      if (!mounted) return;
      AppNotificationDialog.show(context, type: NotificationType.error, title: l10n.googleLoginError(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/dangnhap.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),

          const FloatingLeaves(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 48),

                  Image.asset('assets/images/logo.png', height: 90),

                  const SizedBox(height: AppSpacing.lg),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.quote.replaceAll(r'\n', '\n'),
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySecondary.copyWith(
                        fontSize: 13,
                        color: context.textGreen,
                        fontStyle: FontStyle.italic,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    decoration: BoxDecoration(
                      color: context.cardColor.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
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
                            l10n.loginTitle,
                            style: AppTypography.headingMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        Text(l10n.email,
                            style: AppTypography.captionBold.copyWith(
                              color: context.textPrimary,
                              fontSize: 13,
                            )),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(
                              l10n.enterEmail, Icons.email_outlined),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        Text(l10n.password,
                            style: AppTypography.captionBold.copyWith(
                              color: context.textPrimary,
                              fontSize: 13,
                            )),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          decoration: _inputDecoration(
                            l10n.enterPassword,
                            Icons.lock_outline,
                            suffix: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: context.textSecondary,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                  () => obscurePassword = !obscurePassword),
                            ),
                          ),
                        ),

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
                              l10n.forgotPasswordQuestion,
                              style: AppTypography.bodySecondary.copyWith(
                                color: AppColors.primary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.sm),
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
                                    l10n.login,
                                    style: AppTypography.title.copyWith(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        Row(
                          children: [
                            Expanded(child: Divider(color: AppColors.border)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(l10n.or,
                                  style: AppTypography.caption.copyWith(
                                    color: context.textSecondary,
                                  )),
                            ),
                            Expanded(child: Divider(color: AppColors.border)),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: isLoading ? null : handleGoogleLogin,
                            icon: Image.network(
                              'https://www.google.com/favicon.ico',
                              height: 18,
                              errorBuilder: (_, _, _) => Icon(
                                  Icons.login,
                                  size: 18,
                                  color: context.textSecondary),
                            ),
                            label: Text(
                              l10n.loginWithGoogle,
                              style: AppTypography.body.copyWith(
                                fontSize: 13,
                                color: context.textPrimary,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.sm)),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const RegisterScreen()),
                            ),
                            child: RichText(
                              text: TextSpan(
                                text: l10n.noAccount,
                                style: AppTypography.bodySecondary.copyWith(
                                  fontSize: 13,
                                ),
                                children: [
                                  TextSpan(
                                    text: l10n.registerNow,
                                    style: AppTypography.captionBold.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 13,
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

                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ),

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
      hintStyle: AppTypography.bodySecondary.copyWith(fontSize: 14),
      prefixIcon: Icon(icon, color: context.textSecondary, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: context.inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
