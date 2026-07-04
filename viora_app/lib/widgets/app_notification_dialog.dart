import 'package:flutter/material.dart';
import '../constants/app_icons.dart';
import '../theme/app_colors.dart';
import '../theme/theme_extensions.dart';
import '../l10n/app_localizations.dart';

enum NotificationType { success, error, warning, info }

class AppNotificationDialog extends StatelessWidget {
  final NotificationType type;
  final String title;
  final String? content;
  final String? buttonText;
  final VoidCallback? onDismiss;

  const AppNotificationDialog({
    super.key,
    required this.type,
    required this.title,
    this.content,
    this.buttonText,
    this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required NotificationType type,
    required String title,
    String? content,
    String? buttonText,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AppNotificationDialog(
        type: type,
        title: title,
        content: content,
        buttonText: buttonText,
      ),
    );
  }

  IconData get _icon {
    switch (type) {
      case NotificationType.success:
        return AppIcons.checkCircle;
      case NotificationType.error:
        return AppIcons.error;
      case NotificationType.warning:
        return AppIcons.warning;
      case NotificationType.info:
        return AppIcons.infoCircle;
    }
  }

  Color get _iconColor {
    switch (type) {
      case NotificationType.success:
        return AppColors.success;
      case NotificationType.error:
        return AppColors.error;
      case NotificationType.warning:
        return AppColors.warning;
      case NotificationType.info:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: context.cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, color: _iconColor, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            if (content != null) ...[
              const SizedBox(height: 12),
              Text(
                content!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  onDismiss?.call();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  buttonText ?? l10n.close,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
