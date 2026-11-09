import 'package:flutter/material.dart';

/// Predictable 8pt grid spacing and dimensional constants.
class AppDimensions {
  AppDimensions._();

  // Spacing Units
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;

  // Screen Padding
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets dialogPadding = EdgeInsets.all(20.0);

  // Border Radii (Subtle, non-bubble)
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusFull = 999.0;

  static final BorderRadius borderRadiusSmall = BorderRadius.circular(radiusSmall);
  static final BorderRadius borderRadiusMedium = BorderRadius.circular(radiusMedium);
  static final BorderRadius borderRadiusLarge = BorderRadius.circular(radiusLarge);
  static final BorderRadius borderRadiusFull = BorderRadius.circular(radiusFull);

  // Hairline border width
  static const double borderWidth = 1.0;

  // Touch Target Minimums
  static const double minTouchTarget = 48.0;
  static const double buttonHeight = 50.0;
  static const double inputHeight = 52.0;
}
