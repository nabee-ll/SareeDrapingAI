import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette - Rich Burgundy
  static const Color primary = Color(0xFF8B2252); // Rich Burgundy
  static const Color primaryLight = Color(0xFFA94068); // Soft Burgundy
  static const Color primaryDark = Color(0xFF5C0A2D); // Deep Burgundy

  // Secondary - Black
  static const Color secondary = Color(0xFF121212); // Rich Black
  static const Color secondaryLight = Color(0xFF1E1E1E); // Card Black
  static const Color secondaryDark = Color(0xFF0A0A0A); // Deep Black

  // Gold accent for premium highlights
  static const Color gold = Color(0xFFC9A84C); // Muted Gold
  static const Color goldLight = Color(0xFFE8D08C); // Light Gold

  // Neutrals — dark mode tones
  static const Color background = Color(0xFF0E0E0E); // Near Black Background
  static const Color surface = Color(0xFF1A1A1A); // Dark Surface
  static const Color surfaceVariant = Color(0xFF2A2025); // Dark Rose Tint
  static const Color textPrimary = Color(0xFFF5F0F2); // Off White
  static const Color textSecondary = Color(0xFFB0A3A8); // Muted Rose Grey
  static const Color textHint = Color(0xFF6B5D63); // Dark Hint
  static const Color divider = Color(0xFF2D2528); // Dark Divider

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF42A5F5);

  // Subscription tier colors
  static const Color freeTier = Color(0xFF78909C);
  static const Color basicTier = Color(0xFF42A5F5);
  static const Color premiumTier = Color(0xFFC9A84C); // Gold
  static const Color annualTier = Color(0xFF8B2252); // Burgundy
}
