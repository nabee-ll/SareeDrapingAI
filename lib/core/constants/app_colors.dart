import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Web-aligned brand palette
  static const Color primary = Color(0xFFC9257C);
  static const Color primaryLight = Color(0xFFE84393);
  static const Color primaryDark = Color(0xFFA01858);

  // Accent and neutral helpers
  static const Color secondary = Color(0xFFD4AF37);
  static const Color secondaryLight = Color(0xFFFDF7FB);
  static const Color secondaryDark = Color(0xFFB8942C);

  // Gold accent for highlights
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF4D03F);

  // Light surfaces and text colors (matching web)
  static const Color background = Color(0xFFFAF6F1);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF7EEF4);
  static const Color textPrimary = Color(0xFF2D2D3A);
  static const Color textSecondary = Color(0xFF6B6B7B);
  static const Color textHint = Color(0xFF9A93A3);
  static const Color divider = Color(0xFFE8E3DC);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF0A9396);

  // Subscription tier colors
  static const Color freeTier = Color(0xFF78909C);
  static const Color basicTier = Color(0xFF42A5F5);
  static const Color premiumTier = Color(0xFFC9A84C); // Gold
  static const Color annualTier = Color(0xFF8B2252); // Burgundy
}
