import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTypography {
  // Display headings - weight 800, letter-spacing -0.02em, line-height 1.18
  static TextStyle get display => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.02 * 32, // -0.02em converted to pixels
        height: 1.18,
        color: AppColors.textPrimary,
      );

  // H1 headings - weight 700, letter-spacing -0.02em, line-height 1.18
  static TextStyle get h1 => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 28, // -0.02em converted to pixels
        height: 1.18,
        color: AppColors.textPrimary,
      );

  // H2 headings - weight 600, letter-spacing -0.01em, line-height 1.22
  static TextStyle get h2 => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.01 * 22, // -0.01em converted to pixels
        height: 1.22,
        color: AppColors.textPrimary,
      );

  // H3 headings - weight 600, letter-spacing -0.01em, line-height 1.25
  static TextStyle get h3 => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.01 * 18, // -0.01em converted to pixels
        height: 1.25,
        color: AppColors.textPrimary,
      );

  // Body text - weight 400, no letter-spacing, line-height 1.6
  static TextStyle get body => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.6,
        color: AppColors.textSecondary,
      );

  // Captions - weight 400, no letter-spacing, line-height 1.5
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.5,
        color: AppColors.textHint,
      );

  // Button text - weight 600, letter-spacing 0.01em, line-height 1.0
  static TextStyle get button => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.01 * 16, // 0.01em converted to pixels
        height: 1.0,
        color: AppColors.white,
      );

  // Labels - weight 500, no letter-spacing, line-height 1.5
  static TextStyle get label => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        height: 1.5,
        color: AppColors.textPrimary,
      );

  // Uppercase labels - weight 500, letter-spacing 0.07em, line-height 1.5
  static TextStyle get uppercase => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.07 * 11, // 0.07em converted to pixels
        height: 1.5,
        color: AppColors.textHint,
      );
}
