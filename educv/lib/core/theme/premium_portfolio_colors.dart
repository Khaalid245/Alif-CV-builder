import 'package:flutter/material.dart';

class PremiumPortfolioColors {
  // Background
  static const Color background = Color(0xFFF5F7FB);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Text
  static const Color primaryText = Color(0xFF1E293B);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color lightText = Color(0xFF94A3B8);
  
  // Accents
  static const Color accentPurple = Color(0xFF7C3AED);
  static const Color accentNavy = Color(0xFF334155);
  static const Color accentBlue = Color(0xFF3B82F6);
  
  // Grid and overlays
  static const Color gridOverlay = Color(0x14949FB8);
  static const Color borderLight = Color(0xFFE2E8F0);
  
  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  
  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 40,
      offset: Offset(0, 8),
    ),
  ];
  
  static const List<BoxShadow> floatingCardShadow = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 30,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 60,
      offset: Offset(0, 16),
    ),
  ];
}