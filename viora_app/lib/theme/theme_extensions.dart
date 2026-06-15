import 'package:flutter/material.dart';

extension ThemeContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // Card/surface colors
  Color get cardColor => isDark ? const Color(0xFF1E2E28) : Colors.white;
  Color get surfaceColor => isDark ? const Color(0xFF1A2E27) : const Color(0xFFEAF7F2);
  Color get infoBoxColor => isDark ? const Color(0xFF1A2E27) : const Color(0xFFEAF7F2);
  Color get infoBoxBorder => isDark ? const Color(0xFF2E433C) : const Color(0xFFB1E5CD);

  // Text colors
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF1F2937);
  Color get textSecondary => isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
  Color get textGreen => isDark ? const Color(0xFF34D399) : const Color(0xFF006B4E);
  Color get textGreenLight => isDark ? const Color(0xFF34D399) : const Color(0xFF00543D);

  // Input fill
  Color get inputFill => isDark ? const Color(0xFF24352E) : const Color(0xFFF7F9F8);
}
