import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/app_snackbar.dart';
import 'login_screen.dart';
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

  int _step = 1; // 1: nhap email, 2: nhap OTP + mat khau moi
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
      AppSnackbar.showError(context, l10n.pleaseEnterEmail);
      return;
    }
    setState(() => isLoading = true);
    await ApiService.forgotPassword(_emailCtrl.text.trim());
    setState(() => isLoading = false);
    if (!mounted) return;
    _email = _emailCtrl.text.trim();
    setState(() => _step = 2);
    AppSnackbar.showSuccess(context, l10n.otpSent);
  }

  Future<void> _resetPassword() async {
    final l10n = AppLocalizations.of(context)!;
    if (_otpCtrl.text.trim().length != 6) {
      AppSnackbar.showError(context, l10n.otpMustBeSixDigits);
      return;
    }
    if (_newPassCtrl.text.length < 8) {
      AppSnackbar.showError(context, l10n.passwordMinEightChars);
      return;
    }
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      AppSnackbar.showError(context, l10n.confirmPasswordMismatch);
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
      AppSnackbar.showSuccess(context, l10n.resetPasswordSuccess);
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } else {
      AppSnackbar.showError(context, res["message"] ?? l10n.failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.forgotPasswordTitle,
          style: const TextStyle(
              color: Color(0xFF1B5E20),
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step indicator
            Row(
              children: [
                _buildStep(1, l10n.stepEmail),
                Expanded(
                  child: Container(
                    height: 2,
                    color: _step >= 2
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFE0E0E0),
                  ),
                ),
                _buildStep(2, l10n.stepConfirm),
              ],
            ),

            const SizedBox(height: 32),

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
            color: isActive ? const Color(0xFF4CAF50) : const Color(0xFFE0E0E0),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              "$step",
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: isActive ? const Color(0xFF4CAF50) : Colors.grey)),
      ],
    );
  }

  List<Widget> _buildStep1() {
    final l10n = AppLocalizations.of(context)!;
    return [
      Text(
        l10n.enterYourEmail,
        style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20)),
      ),
      const SizedBox(height: 8),
      Text(
        l10n.weWillSendOtp,
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
      const SizedBox(height: 28),
      TextField(
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        decoration: _inputDeco(l10n.enterYourEmail, Icons.email_outlined),
      ),
      const SizedBox(height: 24),
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
                  style:
                      const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ),
    ];
  }

  List<Widget> _buildStep2() {
    final l10n = AppLocalizations.of(context)!;
    return [
      Text(
        l10n.resetPassword,
        style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20)),
      ),
      const SizedBox(height: 8),
      Text(
        l10n.enterOtpSentTo(_email),
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
      const SizedBox(height: 28),

      // OTP input
      TextField(
        controller: _otpCtrl,
        keyboardType: TextInputType.number,
        maxLength: 6,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
            color: Color(0xFF1B5E20)),
        decoration: InputDecoration(
          hintText: "000000",
          hintStyle: const TextStyle(
              color: Colors.grey, letterSpacing: 8, fontSize: 24),
          counterText: "",
          filled: true,
          fillColor: const Color(0xFFF1F8E9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4CAF50)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFC8E6C9)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF4CAF50), width: 2),
          ),
        ),
      ),
      const SizedBox(height: 20),

      // New password
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
                color: Colors.grey,
                size: 20),
            onPressed: () => setState(() => obscureNew = !obscureNew),
          ),
        ),
      ),
      const SizedBox(height: 16),

      // Confirm password
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
                color: Colors.grey,
                size: 20),
            onPressed: () =>
                setState(() => obscureConfirm = !obscureConfirm),
          ),
        ),
      ),
      const SizedBox(height: 24),

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
                  style:
                      const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ),
      const SizedBox(height: 16),
      Center(
        child: TextButton(
          onPressed: () => setState(() => _step = 1),
          child: Text(l10n.resendOtp,
              style: const TextStyle(color: Color(0xFF4CAF50))),
        ),
      ),
    ];
  }

  InputDecoration _inputDeco(String hint, IconData icon, {Widget? suffix}) {
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

  ButtonStyle _btnStyle() => ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      );
}
