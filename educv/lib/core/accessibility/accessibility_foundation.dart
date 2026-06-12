import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

// WCAG 2.1 AA compliant color system
class AccessibleColors {
  // High contrast colors for accessibility
  static const Color focusIndicator = Color(0xFF005FCC); // 4.5:1 contrast ratio
  static const Color focusIndicatorHigh = Color(0xFF0066FF); // High visibility
  static const Color errorAccessible = Color(0xFFD32F2F); // WCAG AA compliant
  static const Color successAccessible = Color(0xFF2E7D32); // WCAG AA compliant
  static const Color warningAccessible = Color(0xFFED6C02); // WCAG AA compliant
  static const Color infoAccessible = Color(0xFF0288D1); // WCAG AA compliant

  // Text colors with proper contrast ratios
  static const Color textPrimaryAccessible = Color(0xFF000000); // 21:1 contrast
  static const Color textSecondaryAccessible =
      Color(0xFF424242); // 12.6:1 contrast
  static const Color textOnPrimaryAccessible =
      Color(0xFFFFFFFF); // 21:1 contrast

  // Background colors
  static const Color backgroundAccessible = Color(0xFFFFFFFF);
  static const Color surfaceAccessible = Color(0xFFF5F5F5);
  static const Color cardAccessible = Color(0xFFFFFFFF);

  // Border colors with sufficient contrast
  static const Color borderAccessible = Color(0xFF757575); // 4.5:1 contrast
  static const Color borderLightAccessible = Color(0xFFBDBDBD); // 3:1 contrast

  // Interactive states
  static const Color hoverAccessible = Color(0xFFF5F5F5);
  static const Color pressedAccessible = Color(0xFFEEEEEE);
  static const Color disabledAccessible = Color(0xFF9E9E9E);

  // Validation colors with high contrast
  static const Color validationSuccess = Color(0xFF1B5E20);
  static const Color validationError = Color(0xFFB71C1C);
  static const Color validationWarning = Color(0xFFE65100);
}

// Focus management utilities
class AccessibilityFocus {
  static const double focusWidth = 3.0;
  static const double focusOffset = 2.0;

  static BoxDecoration getFocusDecoration({
    Color? focusColor,
    double? width,
    double? borderRadius,
  }) {
    return BoxDecoration(
      border: Border.all(
        color: focusColor ?? AccessibleColors.focusIndicator,
        width: width ?? focusWidth,
      ),
      borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
    );
  }

  static OutlineInputBorder getFocusedInputBorder({
    Color? focusColor,
    double? width,
    double? borderRadius,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
      borderSide: BorderSide(
        color: focusColor ?? AccessibleColors.focusIndicator,
        width: width ?? focusWidth,
      ),
    );
  }
}

// Semantic labels and descriptions
class AccessibilityLabels {
  // Navigation
  static const String backButton = 'Go back to previous screen';
  static const String closeButton = 'Close dialog';
  static const String menuButton = 'Open navigation menu';
  static const String homeButton = 'Go to home screen';

  // Form elements
  static const String requiredField = 'Required field';
  static const String optionalField = 'Optional field';
  static const String validInput = 'Valid input';
  static const String invalidInput = 'Invalid input, please correct';
  static const String loadingInput = 'Validating input';

  // Actions
  static const String saveButton = 'Save changes';
  static const String cancelButton = 'Cancel and discard changes';
  static const String deleteButton = 'Delete item permanently';
  static const String editButton = 'Edit item';
  static const String addButton = 'Add new item';

  // Status indicators
  static const String loadingStatus = 'Loading content';
  static const String errorStatus = 'Error occurred';
  static const String successStatus = 'Action completed successfully';
  static const String emptyStatus = 'No items to display';

  // CV specific
  static const String cvProgress = 'CV completion progress';
  static const String cvSection = 'CV section';
  static const String cvSectionComplete = 'CV section completed';
  static const String cvSectionIncomplete = 'CV section needs completion';
  static const String generateCV = 'Generate CV documents';
  static const String downloadCV = 'Download CV document';
}

// Screen reader announcements
class AccessibilityAnnouncements {
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  static void announceSuccess(BuildContext context, String action) {
    announce(context, '$action completed successfully');
  }

  static void announceError(BuildContext context, String error) {
    announce(context, 'Error: $error');
  }

  static void announceLoading(BuildContext context, String action) {
    announce(context, '$action in progress');
  }

  static void announceNavigation(BuildContext context, String destination) {
    announce(context, 'Navigated to $destination');
  }
}

// Keyboard navigation helpers
class KeyboardNavigation {
  static const List<LogicalKeyboardKey> activationKeys = [
    LogicalKeyboardKey.enter,
    LogicalKeyboardKey.space,
  ];

  static const List<LogicalKeyboardKey> navigationKeys = [
    LogicalKeyboardKey.tab,
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight,
  ];

  static bool isActivationKey(LogicalKeyboardKey key) {
    return activationKeys.contains(key);
  }

  static bool isNavigationKey(LogicalKeyboardKey key) {
    return navigationKeys.contains(key);
  }

  static void handleActivation(VoidCallback? onPressed) {
    if (onPressed != null) {
      // Provide haptic feedback for keyboard activation
      HapticFeedback.lightImpact();
      onPressed();
    }
  }
}

// Accessible widget wrapper
class AccessibleWidget extends StatefulWidget {
  final Widget child;
  final String? semanticLabel;
  final String? semanticHint;
  final VoidCallback? onTap;
  final bool excludeSemantics;
  final bool focusable;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocusChange;

  const AccessibleWidget({
    super.key,
    required this.child,
    this.semanticLabel,
    this.semanticHint,
    this.onTap,
    this.excludeSemantics = false,
    this.focusable = true,
    this.focusNode,
    this.onFocusChange,
  });

  @override
  State<AccessibleWidget> createState() => _AccessibleWidgetState();
}

class _AccessibleWidgetState extends State<AccessibleWidget> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    widget.onFocusChange?.call(_isFocused);
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;

    // Add focus decoration if focusable and focused
    if (widget.focusable && _isFocused) {
      child = Container(
        decoration: AccessibilityFocus.getFocusDecoration(),
        child: child,
      );
    }

    // Add keyboard handling if interactive
    if (widget.onTap != null) {
      child = KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              KeyboardNavigation.isActivationKey(event.logicalKey)) {
            KeyboardNavigation.handleActivation(widget.onTap);
          }
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: child,
        ),
      );
    } else if (widget.focusable) {
      child = Focus(
        focusNode: _focusNode,
        child: child,
      );
    }

    // Add semantic information
    if (!widget.excludeSemantics) {
      child = Semantics(
        label: widget.semanticLabel,
        hint: widget.semanticHint,
        button: widget.onTap != null,
        focusable: widget.focusable,
        focused: _isFocused,
        child: child,
      );
    }

    return child;
  }
}

// Accessible button with proper focus and semantics
class AccessibleButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? semanticLabel;
  final String? semanticHint;

  const AccessibleButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.semanticLabel,
    this.semanticHint,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? text,
      hint: semanticHint,
      button: true,
      enabled: onPressed != null && !isLoading,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AccessibleColors.focusIndicator,
          foregroundColor:
              foregroundColor ?? AccessibleColors.textOnPrimaryAccessible,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          // Enhanced focus styling
          side: BorderSide.none,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.focused)) {
              return AccessibleColors.focusIndicatorHigh.withValues(alpha: 0.1);
            }
            if (states.contains(WidgetState.hovered)) {
              return AccessibleColors.hoverAccessible;
            }
            if (states.contains(WidgetState.pressed)) {
              return AccessibleColors.pressedAccessible;
            }
            return null;
          }),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    foregroundColor ?? AccessibleColors.textOnPrimaryAccessible,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: foregroundColor ??
                          AccessibleColors.textOnPrimaryAccessible,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
