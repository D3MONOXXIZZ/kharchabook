import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Clean typographic hierarchy adhering to neo-fintech standards.
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Roboto';

  // Display / Large Numeric metrics (Balance, Hero card)
  static TextStyle heroAmount(bool isDark) => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.75,
    color: AppColors.textPrimary,
    height: 1.15,
  );

  static TextStyle headingLarge(bool isDark) => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  static TextStyle headingMedium(bool isDark) => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle bodyRegular(bool isDark) => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  static TextStyle bodyMedium(bool isDark) => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  static TextStyle caption(bool isDark) => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
    height: 1.35,
  );

  static TextStyle labelUppercase(bool isDark) => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: AppColors.textTertiary,
    height: 1.2,
  );

  static TextStyle button(bool isDark) => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    color: AppColors.darkCanvas,
    height: 1.2,
  );
}
