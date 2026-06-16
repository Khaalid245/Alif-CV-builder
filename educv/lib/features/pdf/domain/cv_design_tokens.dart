/// cv_design_tokens.dart — EduCV CV Design System
/// Phase 2: Template Quality & Design System
///
/// This file centralizes every visual constant used when rendering
/// CV template preview cards inside the Flutter app.
///
/// The values mirror the CSS custom properties in base_cv.html.
/// Any change here is reflected across ALL template preview widgets.
///
/// USAGE:
///   import 'package:educv/features/pdf/domain/cv_design_tokens.dart';
///   color: CvDesignTokens.classicPrimary
///   fontSize: CvDesignTokens.fontSizeName
///
/// PDF-side equivalents are in:
///   cvbuilder-backend/templates/cv_templates/base_cv.html
library cv_design_tokens;

import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════════════════════
// CV TEMPLATE COLOR PALETTES
// One palette per template. A single const change recolors all previews.
// ════════════════════════════════════════════════════════════════════════════

/// Professional Blue — Classic template
class CvColorClassic {
  static const Color primary    = Color(0xFF1A3A5C); // Deep navy
  static const Color accent     = Color(0xFF2A5298); // Mid-blue
  static const Color text       = Color(0xFF0F0F0F);
  static const Color muted      = Color(0xFF5A6272);
  static const Color rule       = Color(0xFFC8D4E0);
  static const Color bgSubtle   = Color(0xFFF5F7FA);
  static const Color headerBg   = Color(0xFF1A3A5C);
  static const Color headerText = Color(0xFFFFFFFF);
}

/// Corporate Gray — Modern template
class CvColorModern {
  static const Color primary    = Color(0xFF1C1C1C); // Near-black
  static const Color accent     = Color(0xFF444444);
  static const Color text       = Color(0xFF111111);
  static const Color muted      = Color(0xFF666666);
  static const Color rule       = Color(0xFFD0D0D0);
  static const Color bgSubtle   = Color(0xFFF8F8F8);
  static const Color headerBg   = Color(0xFF1C1C1C);
  static const Color headerText = Color(0xFFFFFFFF);
}

/// Minimal Black — Academic template
class CvColorAcademic {
  static const Color primary    = Color(0xFF2C2C2C); // Dark charcoal
  static const Color accent     = Color(0xFF3A3A3A);
  static const Color text       = Color(0xFF111111);
  static const Color muted      = Color(0xFF666666);
  static const Color rule       = Color(0xFF999999);
  static const Color bgSubtle   = Color(0xFFFAFAFA);
  static const Color headerBg   = Color(0xFF2C2C2C);
  static const Color headerText = Color(0xFFFFFFFF);
}

// ════════════════════════════════════════════════════════════════════════════
// CV TYPOGRAPHY SCALE
// Mirrors Phase 2 standard. Values are for UI preview, not PDF pt values.
// ════════════════════════════════════════════════════════════════════════════

class CvTypography {
  // Candidate name — 28–34px range
  static const double fontSizeName        = 30.0;

  // Section titles — 18–22px range (UPPERCASE, tracked)
  static const double fontSizeSection     = 19.0;

  // Entry title (job title, degree) — 15–16px range
  static const double fontSizeEntryTitle  = 15.5;

  // Company / institution — 15–16px range
  static const double fontSizeCompany     = 15.0;

  // Body / bullets — 11–12px range
  static const double fontSizeBody        = 12.0;

  // Metadata (dates, levels) — 10–11px range
  static const double fontSizeMeta        = 10.5;

  // Summary paragraph
  static const double fontSizeSummary     = 13.0;

  // Line heights
  static const double lineHeightBody      = 1.55;
  static const double lineHeightTitle     = 1.3;
  static const double lineHeightMeta      = 1.2;

  // Font weight constants
  static const FontWeight weightBody      = FontWeight.w400;
  static const FontWeight weightMedium    = FontWeight.w500;
  static const FontWeight weightSemiBold  = FontWeight.w600;
  static const FontWeight weightBold      = FontWeight.w700;
  static const FontWeight weightExtraBold = FontWeight.w800;
}

// ════════════════════════════════════════════════════════════════════════════
// CV SPACING — 8-Point Grid
// Mirrors the --sp-* CSS variables in base_cv.html exactly.
// ════════════════════════════════════════════════════════════════════════════

class CvSpacing {
  /// sp-1 · 4pt — tight: icon-to-text, within-line gaps
  static const double sp1 = 4.0;

  /// sp-2 · 8pt — near: subtitle-to-description, label-to-value
  static const double sp2 = 8.0;

  /// sp-3 · 12pt — entry: between individual entries
  static const double sp3 = 12.0;

  /// sp-4 · 16pt — section: between sections
  static const double sp4 = 16.0;

  /// sp-5 · 24pt — major: header-to-body
  static const double sp5 = 24.0;

  /// sp-6 · 32pt — spacious: breathing room
  static const double sp6 = 32.0;
}

// ════════════════════════════════════════════════════════════════════════════
// CV DESIGN TOKENS — MASTER CLASS
// Convenience accessors for the most common tokens.
// ════════════════════════════════════════════════════════════════════════════

class CvDesignTokens {
  // ── Colors by palette name ───────────────────────────────────────────────
  static const Color classicPrimary    = CvColorClassic.primary;
  static const Color modernPrimary     = CvColorModern.primary;
  static const Color academicPrimary   = CvColorAcademic.primary;

  // ── Section rule colors ──────────────────────────────────────────────────
  static const Color classicRule       = CvColorClassic.rule;
  static const Color modernRule        = CvColorModern.rule;
  static const Color academicRule      = CvColorAcademic.rule;

  // ── Background panels ────────────────────────────────────────────────────
  static const Color classicBgSubtle   = CvColorClassic.bgSubtle;
  static const Color modernBgSubtle    = CvColorModern.bgSubtle;
  static const Color academicBgSubtle  = CvColorAcademic.bgSubtle;

  // ── Typography shortcuts ─────────────────────────────────────────────────
  static const double fontSizeName     = CvTypography.fontSizeName;
  static const double fontSizeSection  = CvTypography.fontSizeSection;
  static const double fontSizeBody     = CvTypography.fontSizeBody;
  static const double fontSizeMeta     = CvTypography.fontSizeMeta;

  // ── Spacing shortcuts ────────────────────────────────────────────────────
  static const double spacingTight     = CvSpacing.sp1;
  static const double spacingNear      = CvSpacing.sp2;
  static const double spacingEntry     = CvSpacing.sp3;
  static const double spacingSection   = CvSpacing.sp4;
  static const double spacingMajor     = CvSpacing.sp5;

  // ── Border radius ────────────────────────────────────────────────────────
  static const double radiusCard       = 8.0;
  static const double radiusBadge      = 4.0;
  static const double radiusPill       = 20.0;

  // ── Thumbnail dimensions (for CV card previews) ──────────────────────────
  static const double thumbWidth       = 48.0;
  static const double thumbHeight      = 64.0;
  static const double thumbWidthSm     = 36.0;
  static const double thumbHeightSm    = 48.0;

  // ── Helper: get primary color for a given template name ──────────────────
  static Color primaryForTemplate(String template) {
    switch (template.toLowerCase()) {
      case 'classic':  return classicPrimary;
      case 'modern':   return modernPrimary;
      case 'academic': return academicPrimary;
      default:         return classicPrimary;
    }
  }

  /// Returns the background subtle color for a template's preview card.
  static Color bgSubtleForTemplate(String template) {
    switch (template.toLowerCase()) {
      case 'classic':  return classicBgSubtle;
      case 'modern':   return modernBgSubtle;
      case 'academic': return academicBgSubtle;
      default:         return classicBgSubtle;
    }
  }

  /// Returns the rule/divider color for a template.
  static Color ruleForTemplate(String template) {
    switch (template.toLowerCase()) {
      case 'classic':  return classicRule;
      case 'modern':   return modernRule;
      case 'academic': return academicRule;
      default:         return classicRule;
    }
  }
}
