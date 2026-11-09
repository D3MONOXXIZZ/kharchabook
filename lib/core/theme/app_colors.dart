import 'package:flutter/material.dart';

/// Neo-fintech palette directly modeled after Monex & Redlio dark mode references,
/// combined with the Editorial Pastel palette modeled after modern illustrated education & finance apps.
class AppColors {
  AppColors._();

  // ==========================================
  // THEME A: DARK CANVAS & SURFACES (Monex/Redlio)
  // ==========================================
  static const Color darkCanvas = Color(0xFF0C0E14); // Pure dark matte obsidian
  static const Color darkCard = Color(0xFF151821);   // Elevated dark gunmetal card
  static const Color darkCardElevated = Color(0xFF1C202C); // Floating card
  static const Color darkBorder = Color(0xFF232836); // Subtle edge border
  static const Color darkDivider = Color(0xFF1A1D27);

  // Hero Neon Accents (From Monex & Redlio designs)
  static const Color neonLime = Color(0xFFD4F938);   // Signature electric volt / lime
  static const Color neonLimeDark = Color(0xFFB5D826);
  static const Color neonLimeSoft = Color(0x26D4F938); // 15% opacity

  // Semantic Financial Colors
  static const Color income = Color(0xFF10B981);     // Emerald green
  static const Color incomeSoft = Color(0x2610B981);
  static const Color expense = Color(0xFFFF5C5C);    // Vibrant coral rose
  static const Color expenseSoft = Color(0x26FF5C5C);
  static const Color warning = Color(0xFFFBBF24);    // Amber
  static const Color warningSoft = Color(0x26FBBF24);

  // Dark Palette Accents for Charts & Category Badges
  static const Color accentLavender = Color(0xFFA5B4FC); // Periwinkle / lavender
  static const Color accentCyan = Color(0xFF38BDF8);     // Sky cyan
  static const Color accentCoral = Color(0xFFFF7A59);    // Coral orange
  static const Color accentPurple = Color(0xFFC084FC);   // Violet

  // High-Contrast Typography (Dark)
  static const Color textPrimary = Color(0xFFF8FAFC);   // Pure crisp white-slate
  static const Color textSecondary = Color(0xFF8E95A5); // Cool muted silver
  static const Color textTertiary = Color(0xFF565D6D);  // Subtle placeholder slate

  // ==========================================
  // THEME B: EDITORIAL PASTEL DESIGN SYSTEM
  // ==========================================
  static const Color pastelCanvas = Color(0xFFF6F7FB);     // Soft porcelain grey-white
  static const Color pastelCard = Color(0xFFFFFFFF);       // Clean white card
  static const Color pastelCardElevated = Color(0xFFFFFFFF);
  static const Color pastelBorder = Color(0xFFE5E7EB);     // Subtle slate outline
  static const Color pastelDivider = Color(0xFFF3F4F6);

  // Editorial Pastel Blocks (from reference illustration cards)
  static const Color pastelYellow = Color(0xFFFEF08A);     // Warm buttercup yellow hero card
  static const Color pastelYellowDark = Color(0xFFFDE047); // Darker accent yellow
  static const Color pastelLavender = Color(0xFFDDD6FE);   // Soft lilac / lavender hero card
  static const Color pastelLavenderDark = Color(0xFFC4B5FD);
  static const Color pastelMint = Color(0xFFD1FAE5);       // Soft mint sage card
  static const Color pastelMintDark = Color(0xFFA7F3D0);
  static const Color pastelCoral = Color(0xFFFCE7F3);      // Soft blush rose card
  static const Color pastelCoralDark = Color(0xFFFECDD3);
  static const Color pastelBlue = Color(0xFFE0F2FE);       // Ice blue card
  static const Color pastelBlueDark = Color(0xFFBAE6FD);

  // Editorial Ink & Slate Typography
  static const Color inkBlack = Color(0xFF111827);         // Ultra-bold high-contrast black
  static const Color inkBlackSoft = Color(0xFF1F2937);
  static const Color slateMuted = Color(0xFF6B7280);       // Secondary muted text
  static const Color slateLight = Color(0xFF9CA3AF);       // Tertiary light text
  static const Color pillDark = Color(0xFF18181B);         // High-contrast solid pill selector

  // Light Mode Fallback
  static const Color lightBackground = pastelCanvas;
  static const Color lightSurface = pastelCard;
  static const Color lightCard = pastelCard;
  static const Color lightBorder = pastelBorder;
  static const Color textPrimaryLight = inkBlack;
  static const Color textSecondaryLight = slateMuted;
}
