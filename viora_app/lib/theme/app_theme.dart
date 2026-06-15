import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
export 'app_colors.dart';
import 'app_colors.dart';
import 'app_typography.dart';

// Re-export AppColors for backward compatibility if needed, or import directly
class AppColorsCompat {
  static const primary = AppColors.primary;
  static const primaryDark = AppColors.primaryDark;
  static const primaryDarker = AppColors.primaryDark;
  static const primaryLight = AppColors.primaryLight;
  static const primarySurface = AppColors.primaryLight;
  static const primarySurfaceLight = AppColors.primaryLight;

  static const background = AppColors.background;
  static const surface = AppColors.surface;
  static const surfaceVariant = AppColors.background;

  static const textPrimary = AppColors.textPrimary;
  static const textSecondary = AppColors.textSecondary;
  static const textHint = Color(0xFFAAAAAA);

  static const error = AppColors.error;
  static const errorSurface = Color(0xFFFFF0F0);
  static const success = AppColors.success;
  static const warning = AppColors.warning;

  // Dark mode
  static const darkBackground = AppColors.darkBackground;
  static const darkSurface = AppColors.darkSurface;
  static const darkSurfaceVariant = Color(0xFF24352E);
  static const darkCard = Color(0xFF1E2E28);
}

// Global theme notifier
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: AppTypography.fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryDark,
        fontFamily: AppTypography.fontFamily,
      ),
      iconTheme: IconThemeData(color: AppColors.primary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Color(0xFF9CA3AF),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, fontFamily: AppTypography.fontFamily),
      unselectedLabelStyle: TextStyle(fontSize: 11, fontFamily: AppTypography.fontFamily),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: AppTypography.fontFamily),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF9FAF8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14, fontFamily: AppTypography.fontFamily),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: AppTypography.fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      surface: AppColorsCompat.darkSurface,
    ),
    scaffoldBackgroundColor: AppColorsCompat.darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryLight,
        fontFamily: AppTypography.fontFamily,
      ),
      iconTheme: IconThemeData(color: AppColors.primaryLight),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColorsCompat.darkSurface,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: Color(0xFF6B7280),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, fontFamily: AppTypography.fontFamily),
      unselectedLabelStyle: TextStyle(fontSize: 11, fontFamily: AppTypography.fontFamily),
    ),
    cardTheme: CardThemeData(
      color: AppColorsCompat.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: AppTypography.fontFamily),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorsCompat.darkSurfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E433C)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontFamily: AppTypography.fontFamily),
    ),
  );
}

// Keep a backward compatible AppColors class alias or proxy
class AppColorsAlias {
  static const primary = AppColors.primary;
  static const primaryDark = AppColors.primaryDark;
  static const primaryDarker = AppColors.primaryDark;
  static const primaryLight = AppColors.primaryLight;
  static const primarySurface = AppColors.primaryLight;
  static const primarySurfaceLight = AppColors.primaryLight;

  static const background = AppColors.background;
  static const surface = AppColors.surface;
  static const surfaceVariant = AppColors.background;

  static const textPrimary = AppColors.textPrimary;
  static const textSecondary = AppColors.textSecondary;
  static const textHint = Color(0xFFAAAAAA);

  static const error = AppColors.error;
  static const errorSurface = Color(0xFFFFF0F0);
  static const success = AppColors.success;
  static const warning = AppColors.warning;

  // Dark mode
  static const darkBackground = AppColors.darkBackground;
  static const darkSurface = AppColors.darkSurface;
  static const darkSurfaceVariant = Color(0xFF24352E);
  static const darkCard = Color(0xFF1E2E28);
}
