import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../accessibility/accessibility_foundation.dart';
import '../accessibility/accessible_inputs.dart';

enum ValidationState { initial, validating, valid, invalid }

class EnterpriseValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? successMessage;
  final ValidationState state;

  const EnterpriseValidationResult({
    required this.isValid,
    this.errorMessage,
    this.successMessage,
    this.state = ValidationState.initial,
  });

  factory EnterpriseValidationResult.initial() {
    return const EnterpriseValidationResult(
      isValid: true,
      state: ValidationState.initial,
    );
  }

  factory EnterpriseValidationResult.validating() {
    return const EnterpriseValidationResult(
      isValid: false,
      state: ValidationState.validating,
    );
  }

  factory EnterpriseValidationResult.valid([String? successMessage]) {
    return EnterpriseValidationResult(
      isValid: true,
      successMessage: successMessage,
      state: ValidationState.valid,
    );
  }

  factory EnterpriseValidationResult.invalid(String errorMessage) {
    return EnterpriseValidationResult(
      isValid: false,
      errorMessage: errorMessage,
      state: ValidationState.invalid,
    );
  }
}

class EnterpriseValidators {
  // Enhanced email validation with real-time feedback
  static EnterpriseValidationResult email(String? value) {
    if (value == null || value.isEmpty) {
      return EnterpriseValidationResult.invalid('Email is required');
    }

    if (value.length < 3) {
      return EnterpriseValidationResult.invalid('Email too short');
    }

    if (!value.contains('@')) {
      return EnterpriseValidationResult.invalid('Email must contain @');
    }

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return EnterpriseValidationResult.invalid(
          'Please enter a valid email address');
    }

    return EnterpriseValidationResult.valid('Valid email address');
  }

  // Enhanced password validation with strength indicator
  static EnterpriseValidationResult password(String? value) {
    if (value == null || value.isEmpty) {
      return EnterpriseValidationResult.invalid('Password is required');
    }

    if (value.length < 8) {
      return EnterpriseValidationResult.invalid(
          'Password must be at least 8 characters');
    }

    final hasLower = RegExp(r'[a-z]').hasMatch(value);
    final hasUpper = RegExp(r'[A-Z]').hasMatch(value);
    final hasDigit = RegExp(r'\d').hasMatch(value);
    final hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);

    if (!hasLower) {
      return EnterpriseValidationResult.invalid(
          'Password needs a lowercase letter');
    }
    if (!hasUpper) {
      return EnterpriseValidationResult.invalid(
          'Password needs an uppercase letter');
    }
    if (!hasDigit) {
      return EnterpriseValidationResult.invalid('Password needs a number');
    }

    if (hasLower && hasUpper && hasDigit && hasSpecial) {
      return EnterpriseValidationResult.valid('Strong password');
    } else if (hasLower && hasUpper && hasDigit) {
      return EnterpriseValidationResult.valid('Good password');
    } else {
      return EnterpriseValidationResult.invalid('Password needs improvement');
    }
  }

  // Enhanced name validation
  static EnterpriseValidationResult name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return EnterpriseValidationResult.invalid('Name is required');
    }

    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return EnterpriseValidationResult.invalid(
          'Name must be at least 2 characters');
    }

    if (trimmed.length > 100) {
      return EnterpriseValidationResult.invalid(
          'Name must not exceed 100 characters');
    }

    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!nameRegex.hasMatch(trimmed)) {
      return EnterpriseValidationResult.invalid(
          'Name contains invalid characters');
    }

    return EnterpriseValidationResult.valid();
  }

  // Enhanced phone validation
  static EnterpriseValidationResult phone(String? value) {
    if (value == null || value.isEmpty) {
      return EnterpriseValidationResult.invalid('Phone number is required');
    }

    // Remove all non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < 10) {
      return EnterpriseValidationResult.invalid('Phone number too short');
    }

    if (digitsOnly.length > 15) {
      return EnterpriseValidationResult.invalid('Phone number too long');
    }

    return EnterpriseValidationResult.valid();
  }

  // Required field validation
  static EnterpriseValidationResult required(String? value,
      [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return EnterpriseValidationResult.invalid(
          '${fieldName ?? 'This field'} is required');
    }
    return EnterpriseValidationResult.valid();
  }

  // URL validation
  static EnterpriseValidationResult url(String? value,
      {bool required = false}) {
    if (value == null || value.isEmpty) {
      if (required) {
        return EnterpriseValidationResult.invalid('URL is required');
      }
      return EnterpriseValidationResult.valid();
    }

    final urlRegex = RegExp(r'^https?:\/\/[^\s/$.?#].[^\s]*$');
    if (!urlRegex.hasMatch(value)) {
      return EnterpriseValidationResult.invalid('Please enter a valid URL');
    }

    return EnterpriseValidationResult.valid();
  }

  // Date validation
  static EnterpriseValidationResult date(String? value) {
    if (value == null || value.isEmpty) {
      return EnterpriseValidationResult.invalid('Date is required');
    }

    try {
      final date = DateTime.parse(value);
      final now = DateTime.now();

      // Check if date is not in the future (for birth dates, etc.)
      if (date.isAfter(now)) {
        return EnterpriseValidationResult.invalid(
            'Date cannot be in the future');
      }

      return EnterpriseValidationResult.valid();
    } catch (e) {
      return EnterpriseValidationResult.invalid('Please enter a valid date');
    }
  }

  // Confirm password validation
  static EnterpriseValidationResult confirmPassword(
      String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return EnterpriseValidationResult.invalid('Please confirm your password');
    }

    if (value != originalPassword) {
      return EnterpriseValidationResult.invalid('Passwords do not match');
    }

    return EnterpriseValidationResult.valid('Passwords match');
  }

  // Length validation
  static EnterpriseValidationResult maxLength(String? value, int maxLength,
      [String? fieldName]) {
    if (value != null && value.length > maxLength) {
      return EnterpriseValidationResult.invalid(
          '${fieldName ?? 'This field'} must not exceed $maxLength characters');
    }
    return EnterpriseValidationResult.valid();
  }

  // Minimum length validation
  static EnterpriseValidationResult minLength(String? value, int minLength,
      [String? fieldName]) {
    if (value != null && value.isNotEmpty && value.length < minLength) {
      return EnterpriseValidationResult.invalid(
          '${fieldName ?? 'This field'} must be at least $minLength characters');
    }
    return EnterpriseValidationResult.valid();
  }

  // Combine multiple validators
  static EnterpriseValidationResult combine(
      List<EnterpriseValidationResult> results) {
    for (final result in results) {
      if (!result.isValid) {
        return result;
      }
    }

    // Return the last valid result (might have success message)
    return results.isNotEmpty
        ? results.last
        : EnterpriseValidationResult.valid();
  }
}

// Real-time validation mixin for form fields
mixin RealTimeValidation<T extends StatefulWidget> on State<T> {
  final Map<String, EnterpriseValidationResult> _validationResults = {};

  void updateValidation(String fieldName, EnterpriseValidationResult result) {
    setState(() {
      _validationResults[fieldName] = result;
    });
  }

  EnterpriseValidationResult? getValidation(String fieldName) {
    return _validationResults[fieldName];
  }

  bool get isFormValid {
    return _validationResults.values.every((result) => result.isValid);
  }

  void clearValidation(String fieldName) {
    setState(() {
      _validationResults.remove(fieldName);
    });
  }

  void clearAllValidation() {
    setState(() {
      _validationResults.clear();
    });
  }
}

// Enhanced input field with real-time validation and accessibility
class EnterpriseValidatedInput extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final EnterpriseValidationResult Function(String?) validator;
  final Function(EnterpriseValidationResult)? onValidationChanged;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final bool enabled;
  final bool required;

  const EnterpriseValidatedInput({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    required this.validator,
    this.onValidationChanged,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.required = false,
  });

  @override
  State<EnterpriseValidatedInput> createState() =>
      _EnterpriseValidatedInputState();
}

class _EnterpriseValidatedInputState extends State<EnterpriseValidatedInput> {
  EnterpriseValidationResult _validationResult =
      EnterpriseValidationResult.initial();
  bool _hasBeenTouched = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (_hasBeenTouched) {
      _validateField();
    }
  }

  void _validateField() {
    final result = widget.validator(widget.controller.text);
    setState(() {
      _validationResult = result;
    });
    widget.onValidationChanged?.call(result);

    // Announce validation changes to screen readers
    if (result.errorMessage != null) {
      AccessibilityAnnouncements.announceError(context, result.errorMessage!);
    }
  }

  void _onFocusLost() {
    if (!_hasBeenTouched) {
      setState(() {
        _hasBeenTouched = true;
      });
      _validateField();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AccessibleInput(
      label: widget.label,
      hint: widget.hint,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      prefixIcon: widget.prefixIcon,
      suffixIcon: _buildSuffixIcon(),
      maxLines: widget.maxLines,
      enabled: widget.enabled,
      required: widget.required,
      validator:
          _hasBeenTouched ? (value) => _validationResult.errorMessage : null,
      onChanged: (value) => _onTextChanged(),
      onEditingComplete: () => _onFocusLost(),
      semanticLabel: _buildSemanticLabel(),
      semanticHint: _buildSemanticHint(),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.suffixIcon != null) return widget.suffixIcon;

    if (_hasBeenTouched && _validationResult.state != ValidationState.initial) {
      IconData icon;
      Color color;
      String semanticLabel;

      switch (_validationResult.state) {
        case ValidationState.valid:
          icon = Icons.check_circle;
          color = AccessibleColors.successAccessible;
          semanticLabel = AccessibilityLabels.validInput;
          break;
        case ValidationState.invalid:
          icon = Icons.error;
          color = AccessibleColors.errorAccessible;
          semanticLabel = AccessibilityLabels.invalidInput;
          break;
        case ValidationState.validating:
          icon = Icons.hourglass_empty;
          color = AccessibleColors.infoAccessible;
          semanticLabel = AccessibilityLabels.loadingInput;
          break;
        default:
          return null;
      }

      return Semantics(
        label: semanticLabel,
        child: Icon(icon, color: color, size: 20),
      );
    }

    return null;
  }

  String _buildSemanticLabel() {
    final parts = <String>[widget.label];
    if (widget.required) parts.add('required');
    if (_validationResult.state == ValidationState.invalid)
      parts.add('invalid');
    if (_validationResult.state == ValidationState.valid) parts.add('valid');
    return parts.join(', ');
  }

  String? _buildSemanticHint() {
    final parts = <String>[];
    if (widget.hint != null) parts.add(widget.hint!);
    if (_validationResult.errorMessage != null) {
      parts.add(_validationResult.errorMessage!);
    } else if (_validationResult.successMessage != null) {
      parts.add(_validationResult.successMessage!);
    }
    return parts.isNotEmpty ? parts.join('. ') : null;
  }
}
