import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/app_notification_dialog.dart';
import 'login_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../l10n/app_localizations.dart';
import '../theme/theme_extensions.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  int _step = 1;
  bool isLoading = false;
  bool obscureNew = true;
  bool obscureConfirm = true;
  String _email = "";

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final l10n = AppLocalizations.of(context)!;
    if (_emailCtrl.text.trim().isEmpty) {
      AppNotificationDialog.show(context, type: NotificationType.error, title: l10n.pleaseEnterEmail);
      return;
    }
    setState(() => isLoading = true);
    await ApiService.forgotPassword(_emailCtrl.text.trim());
    setState(() => isLoading = false);
    if (!mounted) return;
    _email = _emailCtrl.text.trim();
    setState(() => _step = 2);
    AppNotificationDialog.show(context, type: NotificationType.success, title: l10n.otpSent);
  }

  Future<void> _resetPassword() async {
    final l10n = AppLocalizations.of(context)!;
    if (_otpCtrl.text.trim().length != 6) {
      AppNotificationDialog.show(context, type: NotificationType.error, title: l10n.otpMustBeSixDigits);
      return;
    }
    if (_newPassCtrl.text.length < 8) {
      AppNotificationDialog.show(context, type: NotificationType.error, title: l10n.passwordMinEightChars);
      return;
    }
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      AppNotificationDialog.show(context, type: NotificationType.error, title: l10n.confirmPasswordMismatch);
      return;
    }

    setState(() => isLoading = true);
    final res = await ApiService.resetPassword(
      email: _email,
      code: _otpCtrl.text.trim(),
      newPassword: _newPassCtrl.text,
    );
    setState(() => isLoading = false);
    if (!mounted) return;

    if (res["message"] == "Đặt lại mật khẩu thành công" || res["message"] == "Password reset success") {
      AppNotificationDialog.show(context, type: NotificationType.success, title: l10n.resetPasswordSuccess);
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } else {
      AppNotificationDialog.show(context, type: NotificationType.error, title: res["message"] ?? l10n.failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.forgotPasswordTitle,
          style: AppTypography.headingMedium.copyWith(
            color: AppColors.primary,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStep(1, l10n.stepEmail),
                Expanded(
                  child: Container(
                    height: 2,
                    color: _step >= 2
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
                _buildStep(2, l10n.stepConfirm),
              ],
            ),

            const SizedBox(height: AppSpacing.xxxl),

            if (_step == 1) ..._buildStep1(),
            if (_step == 2) ..._buildStep2(),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int step, String label) {
    final isActive = _step >= step;
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.border,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              "$step",
              style: TextStyle(
                color: isActive ? Colors.white : context.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isActive ? AppColors.primary : context.textSecondary,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildStep1() {
    final l10n = AppLocalizations.of(context)!;
    return [
      Text(
        l10n.enterYourEmail,
        style: AppTypography.headingMedium.copyWith(
          color: AppColors.primary,
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      Text(
        l10n.weWillSendOtp,
        style: AppTypography.bodySecondary,
      ),
      const SizedBox(height: 28),
      TextField(
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        decoration: _inputDeco(l10n.enterYourEmail, Icons.email_outlined),
      ),
      const SizedBox(height: AppSpacing.xxl),
      SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: isLoading ? null : _sendOtp,
          style: _btnStyle(),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : Text(l10n.sendOtp,
                  style: AppTypography.title.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  )),
        ),
      ),
    ];
  }

  List<Widget> _buildStep2() {
    final l10n = AppLocalizations.of(context)!;
    return [
      Text(
        l10n.resetPassword,
        style: AppTypography.headingMedium.copyWith(
          color: AppColors.primary,
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      Text(
        l10n.enterOtpSentTo(_email),
        style: AppTypography.bodySecondary,
      ),
      const SizedBox(height: 28),

      TextField(
        controller: _otpCtrl,
        keyboardType: TextInputType.number,
        maxLength: 6,
        textAlign: TextAlign.center,
        style: AppTypography.headingLarge.copyWith(
          color: AppColors.primary,
          letterSpacing: 8,
          fontSize: 24,
        ),
        decoration: InputDecoration(
          hintText: "000000",
          hintStyle: AppTypography.headingLarge.copyWith(
            color: context.textSecondary,
            letterSpacing: 8,
            fontSize: 24,
          ),
          counterText: "",
          filled: true,
          fillColor: AppColors.primaryLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.xl),

      TextField(
        controller: _newPassCtrl,
        obscureText: obscureNew,
        decoration: _inputDeco(
          l10n.newPasswordMinEight,
          Icons.lock_outline,
          suffix: IconButton(
            icon: Icon(
                obscureNew
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: context.textSecondary,
                size: 20),
            onPressed: () => setState(() => obscureNew = !obscureNew),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.lg),

      TextField(
        controller: _confirmPassCtrl,
        obscureText: obscureConfirm,
        decoration: _inputDeco(
          l10n.confirmNewPassword,
          Icons.lock_outline,
          suffix: IconButton(
            icon: Icon(
                obscureConfirm
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: context.textSecondary,
                size: 20),
            onPressed: () =>
                setState(() => obscureConfirm = !obscureConfirm),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.xxl),

      SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: isLoading ? null : _resetPassword,
          style: _btnStyle(),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : Text(l10n.resetPassword,
                  style: AppTypography.title.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  )),
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      Center(
        child: TextButton(
          onPressed: () => setState(() => _step = 1),
          child: Text(
            l10n.resendOtp,
            style: AppTypography.bodySecondary.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    ];
  }

  InputDecoration _inputDeco(String hint, IconData icon, {Widget? suffix}) {
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
          const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
    );
  }

  ButtonStyle _btnStyle() => ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      );
}
