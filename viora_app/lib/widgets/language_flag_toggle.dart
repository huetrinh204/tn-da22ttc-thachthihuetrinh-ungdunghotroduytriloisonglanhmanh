import 'package:flutter/material.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';

/// Nút chọn ngôn ngữ (🇻🇳 / 🇬🇧) dùng trên màn hình đăng nhập.
class LanguageFlagToggle extends StatelessWidget {
  const LanguageFlagToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = myAppKey.currentState?.localeProvider;
    if (localeProvider == null) return const SizedBox.shrink();

    return ListenableBuilder(
      listenable: localeProvider,
      builder: (context, _) {
        final code = localeProvider.locale.languageCode;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _FlagChip(
                flag: '🇻🇳',
                selected: code == 'vi',
                tooltip: AppLocalizations.of(context)!.vietnamese,
                onTap: () => localeProvider.setLocale(const Locale('vi')),
              ),
              _FlagChip(
                flag: '🇬🇧',
                selected: code == 'en',
                tooltip: AppLocalizations.of(context)!.english,
                onTap: () => localeProvider.setLocale(const Locale('en')),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FlagChip extends StatelessWidget {
  const _FlagChip({
    required this.flag,
    required this.selected,
    required this.tooltip,
    required this.onTap,
  });

  final String flag;
  final bool selected;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: selected
            ? const Color(0xFFE8F5E9)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              flag,
              style: TextStyle(
                fontSize: 22,
                color: selected ? null : Colors.black.withValues(alpha: 0.45),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
