import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/onboarding_gate.dart';
import '../services/fcm_service.dart';
import 'onboarding_screen.dart';
import 'policies_screen.dart';
import '../widgets/floating_leaves.dart';
import '../widgets/app_notification_dialog.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../l10n/app_localizations.dart';
import '../widgets/language_flag_toggle.dart';
import '../theme/theme_extensions.dart';

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
  bool acceptedPrivacy = false;
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
    if (!acceptedPrivacy) {
      AppNotificationDialog.show(
        context,
        type: NotificationType.warning,
        title: l10n.pleaseAgreePrivacy,
      );
      return;
    }
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
      await FcmService.resyncToken();
      await OnboardingGate.prepareNewAccount();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else {
      if (!mounted) return;
      AppNotificationDialog.show(context, type: NotificationType.error, title: res["message"] ?? l10n.registerFailed);
    }
  }

  void _showPoliciesScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PoliciesScreen()),
    );
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios,
                          color: context.textGreen),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

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

                  const SizedBox(height: AppSpacing.xxl),

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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              l10n.registerTitle,
                              style: AppTypography.headingMedium.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xxl),

                          _buildLabel(l10n.fullName),
                          const SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            controller: nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: _inputDecoration(
                                l10n.enterFullName, Icons.person_outline),
                            validator: (v) {
                              if (v!.trim().isEmpty) return l10n.pleaseEnterName;
                              if (v.trim().length < 2) return l10n.nameTooShort;
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          _buildLabel(l10n.email),
                          const SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                                l10n.enterEmail, Icons.email_outlined),
                            validator: (v) {
                              if (v!.trim().isEmpty) return l10n.pleaseEnterEmail;
                              final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                              if (!emailRegex.hasMatch(v.trim())) return l10n.invalidEmailFormat;
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          _buildLabel(l10n.password),
                          const SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            decoration: _inputDecoration(
                              l10n.minEightChars,
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
                            validator: (v) {
                              if (v!.isEmpty) return l10n.pleaseEnterPassword;
                              if (v.length < 8) return l10n.passwordMinEightChars;
                              if (!RegExp(r'[A-Z]').hasMatch(v)) return l10n.passwordNeedsUppercase;
                              if (!RegExp(r'[0-9]').hasMatch(v)) return l10n.passwordNeedsNumber;
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          _buildLabel(l10n.confirmPasswordLabel),
                          const SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: obscureConfirm,
                            decoration: _inputDecoration(
                              l10n.enterPasswordAgain,
                              Icons.lock_outline,
                              suffix: IconButton(
                                icon: Icon(
                                  obscureConfirm
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: context.textSecondary,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                    () => obscureConfirm = !obscureConfirm),
                              ),
                            ),
                            validator: (v) {
                              if (v!.isEmpty) return l10n.pleaseConfirmPassword;
                              if (v != passwordController.text) return l10n.passwordsDoNotMatch;
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: acceptedPrivacy,
                                  onChanged: (v) => setState(() => acceptedPrivacy = v ?? false),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _showPoliciesScreen,
                                  child: Text(
                                    l10n.agreePrivacyPolicy,
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.xxl),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : handleRegister,
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
                                      l10n.register,
                                      style: AppTypography.title.copyWith(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: RichText(
                                text: TextSpan(
                                  text: l10n.haveAccount,
                                  style: AppTypography.bodySecondary.copyWith(
                                    fontSize: 13,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: l10n.loginNow,
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTypography.captionBold.copyWith(
        color: context.textPrimary,
        fontSize: 13,
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
