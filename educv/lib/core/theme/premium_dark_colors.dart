import 'package:flutter/material.dart';

class PremiumDarkColors {
  // Background gradients
  static const Color backgroundStart = Color(0xFF0A0A0F);
  static const Color backgroundEnd = Color(0xFF111827);
  static const Color background = backgroundStart;
  static const Color backgroundSecondary = Color(0xFF1F2937);
  
  // Glass surface
  static const Color glassSurface = Color(0x40111827);
  static const Color glassBorder = Color(0x14FFFFFF);
  static const Color glassBackground = Color(0x20111827);
  static const Color glassHover = Color(0x30111827);
  
  // Primary gradient
  static const Color primaryGradientStart = Color(0xFF4F46E5);
  static const Color primaryGradientEnd = Color(0xFF7C3AED);
  static const Color primary = primaryGradientStart;
  static const Color primaryLight = Color(0xFF6366F1);
  static const Color gradientStart = primaryGradientStart;
  static const Color gradientEnd = primaryGradientEnd;
  
  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textHint = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF6B7280);
  
  // Input fields
  static const Color inputBackground = Color(0x20FFFFFF);
  static const Color inputBorder = Color(0x20FFFFFF);
  static const Color inputFocusBorder = Color(0xFF4F46E5);
  
  // Accent colors
  static const Color accent = Color(0xFF4F46E5);
  static const Color accentLight = Color(0xFF6366F1);
  
  // Glow effects
  static const Color blueGlow = Color(0x404F46E5);
  static const Color purpleGlow = Color(0x407C3AED);
  static const Color glow = blueGlow;
  
  // Surface colors
  static const Color surface = Color(0xFF1F2937);
  static const Color card = Color(0xFF374151);
  
  // Border colors
  static const Color border = Color(0x20FFFFFF);
  static const Color borderLight = Color(0x30FFFFFF);
  
  // Avatar colors
  static const List<Color> avatarColors = [
    Color(0xFF4F46E5),
    Color(0xFF7C3AED),
    Color(0xFF059669),
    Color(0xFFDC2626),
  ];
  
  // Success (keeping from original)
  static const Color success = Color(0xFF10B981);
  
  // Error
  static const Color error = Color(0xFFEF4444);
  
  // Transparent
  static const Color transparent = Color(0x00000000);
  
  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundStart, backgroundEnd],
  );
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryGradientStart, primaryGradientEnd],
  );
  
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGradientStart, primaryGradientEnd],
  );
}