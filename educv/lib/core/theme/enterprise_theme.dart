import 'package:flutter/material.dart';

class EnterpriseTheme {
  // Primary Colors - Indigo
  static const Color primaryPurple = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryPurpleLight = Color(0xFF6366F1); // Indigo 500
  static const Color primaryPurpleDark = Color(0xFF4338CA); // Indigo 700

  // Accent Colors
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentRose = Color(0xFFF43F5E);

  // Neutral Colors - Slate
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFF8FAFC); // Slate 50
  static const Color gray100 = Color(0xFFF1F5F9); // Slate 100
  static const Color gray200 = Color(0xFFE2E8F0); // Slate 200
  static const Color gray300 = Color(0xFFCBD5E1); // Slate 300
  static const Color gray400 = Color(0xFF94A3B8); // Slate 400
  static const Color gray500 = Color(0xFF64748B); // Slate 500
  static const Color gray600 = Color(0xFF475569); // Slate 600
  static const Color gray700 = Color(0xFF334155); // Slate 700
  static const Color gray800 = Color(0xFF1E293B); // Slate 800
  static const Color gray900 = Color(0xFF0F172A); // Slate 900

  // Semantic Colors
  static const Color success = accentGreen;
  static const Color warning = accentOrange;
  static const Color error = accentRed;
  static const Color info = accentBlue;

  // Background Colors
  static const Color backgroundPrimary = white;
  static const Color backgroundSecondary = gray50;
  static const Color backgroundTertiary = gray100;

  // Card Colors
  static const Color cardBackground = white;
  static const Color cardBorder = gray200;

  // Text Colors
  static const Color textPrimary = gray900;
  static const Color textSecondary = gray600;
  static const Color textTertiary = gray400;

  // Spacing System
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing6 = 6.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;

  // Border Radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radius2xl = 24.0;

  // Shadows
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: gray900.withOpacity(0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: gray900.withOpacity(0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: primaryPurple.withOpacity(0.02),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: gray900.withOpacity(0.05),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: primaryPurple.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  // Glassmorphism Effect
  static BoxDecoration get glassmorphism => BoxDecoration(
        color: white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(radius2xl),
        border: Border.all(color: white.withOpacity(0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.03),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      );

  // Gradients
  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)], // Indigo to Violet
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get accentGradient => const LinearGradient(
        colors: [accentBlue, accentTeal],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // Typography
  static TextStyle get h1 => const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle get h2 => const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.3,
        letterSpacing: -0.3,
      );

  static TextStyle get h3 => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
        letterSpacing: -0.2,
      );

  static TextStyle get h4 => const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
        letterSpacing: -0.1,
      );

  static TextStyle get bodyLarge => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.5,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textTertiary,
        height: 1.4,
      );

  static TextStyle get labelLarge => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      );

  static TextStyle get labelMedium => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        height: 1.4,
      );

  static TextStyle get labelSmall => const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: textTertiary,
        height: 1.4,
        letterSpacing: 0.5,
      );
}
