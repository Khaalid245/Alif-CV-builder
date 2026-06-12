import 'package:flutter/material.dart';

class ModernSaaSDashboardTheme {
  // Background colors - inspired by Notion/Stripe/Vercel
  static const Color background = Color(0xFFFAFBFC);
  static const Color surfaceBackground = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text colors with perfect contrast ratios
  static const Color primaryText = Color(0xFF0F172A);
  static const Color secondaryText = Color(0xFF475569);
  static const Color tertiaryText = Color(0xFF64748B);
  static const Color mutedText = Color(0xFF94A3B8);

  // Purple accent system (primary brand color)
  static const Color accentPurple = Color(0xFF7C3AED);
  static const Color accentPurpleLight = Color(0xFF8B5CF6);
  static const Color accentPurpleDark = Color(0xFF6D28D9);
  static const Color accentPurpleSubtle = Color(0xFFF3F4F6);

  // Semantic colors
  static const Color success = Color(0xFF059669);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF0284C7);
  static const Color infoLight = Color(0xFFE0F2FE);

  // Border and divider colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color borderSubtle = Color(0xFFF8FAFC);

  // Interactive states
  static const Color hover = Color(0xFFF8FAFC);
  static const Color pressed = Color(0xFFF1F5F9);
  static const Color focus = Color(0xFF7C3AED);
  static const Color disabled = Color(0xFFF1F5F9);
  static const Color disabledText = Color(0xFFCBD5E1);

  // Shadows - soft and modern
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 8,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x04000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> elevatedCardShadow = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 12,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x06000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> floatingShadow = [
    BoxShadow(
      color: Color(0x0C000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
  ];

  // Typography system
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: primaryText,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: primaryText,
    letterSpacing: -0.25,
    height: 1.25,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: primaryText,
    letterSpacing: -0.25,
    height: 1.3,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: primaryText,
    height: 1.4,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: primaryText,
    height: 1.4,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: primaryText,
    height: 1.5,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: primaryText,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: secondaryText,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: tertiaryText,
    height: 1.4,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: primaryText,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: secondaryText,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: tertiaryText,
    height: 1.3,
  );

  // Spacing system
  static const double spacing2xs = 4;
  static const double spacingXs = 8;
  static const double spacingSm = 12;
  static const double spacingMd = 16;
  static const double spacingLg = 20;
  static const double spacingXl = 24;
  static const double spacing2xl = 32;
  static const double spacing3xl = 40;
  static const double spacing4xl = 48;
  static const double spacing5xl = 64;

  // Border radius system
  static const double radiusXs = 4;
  static const double radiusSm = 6;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;
  static const double radius2xl = 20;
  static const double radius3xl = 24;

  // Icon sizes
  static const double iconXs = 12;
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;

  // Component heights
  static const double buttonHeightSm = 32;
  static const double buttonHeightMd = 40;
  static const double buttonHeightLg = 48;
  static const double inputHeight = 44;
  static const double appBarHeight = 64;
  static const double sidebarWidth = 280;
  static const double sidebarCollapsedWidth = 80;

  // Grid system
  static const double gridGutterXs = 8;
  static const double gridGutterSm = 12;
  static const double gridGutterMd = 16;
  static const double gridGutterLg = 24;
  static const double gridGutterXl = 32;
}

// Extension for easy theme access
extension ModernSaaSDashboardThemeExtension on BuildContext {
  ModernSaaSDashboardTheme get theme => ModernSaaSDashboardTheme();
}

// Predefined component styles
class ModernComponentStyles {
  static BoxDecoration get card => BoxDecoration(
        color: ModernSaaSDashboardTheme.cardBackground,
        borderRadius: BorderRadius.circular(ModernSaaSDashboardTheme.radiusLg),
        boxShadow: ModernSaaSDashboardTheme.cardShadow,
        border: Border.all(
          color: ModernSaaSDashboardTheme.borderLight,
          width: 0.5,
        ),
      );

  static BoxDecoration get elevatedCard => BoxDecoration(
        color: ModernSaaSDashboardTheme.cardBackground,
        borderRadius: BorderRadius.circular(ModernSaaSDashboardTheme.radiusLg),
        boxShadow: ModernSaaSDashboardTheme.elevatedCardShadow,
        border: Border.all(
          color: ModernSaaSDashboardTheme.borderLight,
          width: 0.5,
        ),
      );

  static BoxDecoration get floatingCard => BoxDecoration(
        color: ModernSaaSDashboardTheme.cardBackground,
        borderRadius: BorderRadius.circular(ModernSaaSDashboardTheme.radiusXl),
        boxShadow: ModernSaaSDashboardTheme.floatingShadow,
      );

  static InputDecoration get textField => InputDecoration(
        filled: true,
        fillColor: ModernSaaSDashboardTheme.surfaceBackground,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(ModernSaaSDashboardTheme.radiusMd),
          borderSide: const BorderSide(
            color: ModernSaaSDashboardTheme.border,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(ModernSaaSDashboardTheme.radiusMd),
          borderSide: const BorderSide(
            color: ModernSaaSDashboardTheme.border,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(ModernSaaSDashboardTheme.radiusMd),
          borderSide: const BorderSide(
            color: ModernSaaSDashboardTheme.accentPurple,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(ModernSaaSDashboardTheme.radiusMd),
          borderSide: const BorderSide(
            color: ModernSaaSDashboardTheme.error,
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ModernSaaSDashboardTheme.spacingMd,
          vertical: ModernSaaSDashboardTheme.spacingSm,
        ),
      );
}
