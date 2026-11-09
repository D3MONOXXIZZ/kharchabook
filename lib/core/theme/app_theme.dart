import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// Application theme configurations supporting dual modes:
/// 1. [dark]: Monex & Redlio dark neo-fintech with Electric Volt accents.
/// 2. [light]: Modern Editorial Pastel with bold ink typography and character illustrations.
class AppTheme {
  AppTheme._();

  /// Theme A: OLED Dark Neo-Fintech
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.neonLime,
      scaffoldBackgroundColor: AppColors.darkCanvas,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonLime,
        onPrimary: AppColors.darkCanvas,
        secondary: AppColors.neonLime,
        onSecondary: AppColors.darkCanvas,
        error: AppColors.expense,
        onError: Colors.white,
        surface: AppColors.darkCard,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkCanvas,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: AppColors.darkBorder,
            width: 1.0,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: const TextStyle(
          color: AppColors.textTertiary,
          fontSize: 15,
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.neonLime, width: 1.5),
        ),
      ),
    );
  }

  /// Theme B: Editorial Pastel (Modeled after modern illustrated education & finance apps)
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.inkBlack,
      scaffoldBackgroundColor: AppColors.pastelCanvas,
      colorScheme: const ColorScheme.light(
        primary: AppColors.inkBlack,
        onPrimary: Colors.white,
        secondary: AppColors.pastelLavenderDark,
        onSecondary: AppColors.inkBlack,
        error: AppColors.expense,
        onError: Colors.white,
        surface: AppColors.pastelCard,
        onSurface: AppColors.inkBlack,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.pastelCanvas,
        foregroundColor: AppColors.inkBlack,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: AppColors.inkBlack,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.pastelCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(
            color: AppColors.pastelBorder,
            width: 1.0,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: const TextStyle(
          color: AppColors.slateLight,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: AppColors.slateMuted,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.pastelBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.pastelBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.inkBlack, width: 1.5),
        ),
      ),
    );
  }
}
