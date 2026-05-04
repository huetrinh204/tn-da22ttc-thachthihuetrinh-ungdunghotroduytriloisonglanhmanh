import 'package:flutter/material.dart';

extension ThemeContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // Card/surface colors
  Color get cardColor => isDark ? const Color(0xFF1E2E1E) : Colors.white;
  Color get surfaceColor => isDark ? const Color(0xFF1A2E1A) : const Color(0xFFF1F8E9);
  Color get infoBoxColor => isDark ? const Color(0xFF1A2E1A) : const Color(0xFFE8F5E9);
  Color get infoBoxBorder => isDark ? const Color(0xFF2E4A2E) : const Color(0xFFC8E6C9);

  // Text colors
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF1A1A1A);
  Color get textSecondary => isDark ? const Color(0xFFB0B0B0) : Colors.grey;
  Color get textGreen => isDark ? const Color(0xFF81C784) : const Color(0xFF1B5E20);
  Color get textGreenLight => isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32);

  // Input fill
  Color get inputFill => isDark ? const Color(0xFF243524) : const Color(0xFFF5F5F5);
}
