import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'premium_dark_colors.dart';

class PremiumDarkTypography {
  // Hero Headlines - Large editorial typography
  static TextStyle get heroDisplay => GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.02,
        height: 1.1,
        color: PremiumDarkColors.textPrimary,
      );

  static TextStyle get heroDisplayMobile => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.02,
        height: 1.15,
        color: PremiumDarkColors.textPrimary,
      );

  // Section Headlines
  static TextStyle get sectionTitle => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.01,
        height: 1.2,
        color: PremiumDarkColors.textPrimary,
      );

  static TextStyle get sectionTitleMobile => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.01,
        height: 1.2,
        color: PremiumDarkColors.textPrimary,
      );

  // Card Titles
  static TextStyle get cardTitle => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.01,
        height: 1.3,
        color: PremiumDarkColors.textPrimary,
      );

  // Body Text
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: PremiumDarkColors.textSecondary,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: PremiumDarkColors.textSecondary,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: PremiumDarkColors.textSecondary,
      );

  // Button Text
  static TextStyle get buttonPrimary => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.01,
        color: Colors.white,
      );

  static TextStyle get buttonSecondary => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.01,
        color: PremiumDarkColors.textPrimary,
      );

  // Labels and Captions
  static TextStyle get label => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: PremiumDarkColors.textPrimary,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: PremiumDarkColors.textSecondary,
      );

  static TextStyle get captionBold => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: PremiumDarkColors.textSecondary,
      );

  // Trust Badge
  static TextStyle get trustBadge => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: PremiumDarkColors.primary,
      );

  // Eyebrow Text
  static TextStyle get eyebrow => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: PremiumDarkColors.primary,
      );
}