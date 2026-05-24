import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'accessibility_foundation.dart';

// Accessible input field with WCAG 2.1 compliance
class AccessibleInput extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool required;
  final String? semanticLabel;
  final String? semanticHint;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;

  const AccessibleInput({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.required = false,
    this.semanticLabel,
    this.semanticHint,
    this.onTap,
    this.onChanged,
    this.onEditingComplete,
  });

  @override
  State<AccessibleInput> createState() => _AccessibleInputState();
}

class _AccessibleInputState extends State<AccessibleInput> {
  final FocusNode _focusNode = FocusNode();
  String? _errorMessage;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    
    // Announce field focus to screen readers
    if (_isFocused) {
      final announcement = widget.required 
          ? '${widget.label}, ${AccessibilityLabels.requiredField}'
          : '${widget.label}, ${AccessibilityLabels.optionalField}';
      AccessibilityAnnouncements.announce(context, announcement);
    }
  }

  void _validateField() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.controller.text);
      setState(() {
        _errorMessage = error;
      });
      
      // Announce validation result to screen readers
      if (error != null) {
        AccessibilityAnnouncements.announce(context, 'Error: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorMessage != null;
    
    return Semantics(
      container: true,
      label: widget.semanticLabel ?? _buildSemanticLabel(),
      hint: widget.semanticHint ?? _buildSemanticHint(),
      textField: true,
      focused: _isFocused,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label with required indicator
          _buildLabel(),
          const SizedBox(height: AppSpacing.sm),
          
          // Input field
          _buildInputField(hasError),
          
          // Error message
          if (hasError) ...[
            const SizedBox(height: AppSpacing.xs),
            _buildErrorMessage(),
          ],
          
          // Character count for limited fields
          if (widget.maxLength != null) ...[
            const SizedBox(height: AppSpacing.xs),
            _buildCharacterCount(),
          ],
        ],
      ),
    );
  }

  Widget _buildLabel() {
    return RichText(
      text: TextSpan(
        style: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
          color: AccessibleColors.textPrimaryAccessible,
        ),
        children: [
          TextSpan(text: widget.label),
          if (widget.required)
            TextSpan(
              text: ' *',
              style: TextStyle(
                color: AccessibleColors.errorAccessible,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField(bool hasError) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      enabled: widget.enabled,
      onTap: widget.onTap,
      onChanged: (value) {
        widget.onChanged?.call(value);
        if (_errorMessage != null) {
          _validateField(); // Real-time validation
        }
      },
      onEditingComplete: () {
        _validateField();
        widget.onEditingComplete?.call();
      },
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon != null 
            ? Icon(
                widget.prefixIcon,
                color: _isFocused 
                    ? AccessibleColors.focusIndicator 
                    : AccessibleColors.textSecondaryAccessible,
                semanticLabel: null, // Prevent duplicate announcements
              )
            : null,
        suffixIcon: _buildSuffixIcon(hasError),
        
        // Accessible border styling
        border: _buildBorder(false, false),
        enabledBorder: _buildBorder(false, hasError),
        focusedBorder: _buildBorder(true, hasError),
        errorBorder: _buildBorder(false, true),
        focusedErrorBorder: _buildBorder(true, true),
        disabledBorder: _buildBorder(false, false, disabled: true),
        
        filled: true,
        fillColor: widget.enabled 
            ? (_isFocused 
                ? AccessibleColors.backgroundAccessible 
                : AccessibleColors.surfaceAccessible)
            : AccessibleColors.disabledAccessible.withValues(alpha: 0.1),
        
        // Remove default counter to use custom one
        counterText: '',
        
        // Error styling
        errorStyle: TextStyle(
          color: AccessibleColors.errorAccessible,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: TextStyle(
        color: widget.enabled 
            ? AccessibleColors.textPrimaryAccessible 
            : AccessibleColors.disabledAccessible,
        fontSize: 16,
      ),
    );
  }

  OutlineInputBorder _buildBorder(bool focused, bool hasError, {bool disabled = false}) {
    Color borderColor;
    double borderWidth;
    
    if (disabled) {
      borderColor = AccessibleColors.disabledAccessible;
      borderWidth = 1.0;
    } else if (hasError) {
      borderColor = AccessibleColors.errorAccessible;
      borderWidth = focused ? 3.0 : 2.0;
    } else if (focused) {
      borderColor = AccessibleColors.focusIndicator;
      borderWidth = 3.0;
    } else {
      borderColor = AccessibleColors.borderAccessible;
      borderWidth = 1.0;
    }
    
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusBtn),
      borderSide: BorderSide(
        color: borderColor,
        width: borderWidth,
      ),
    );
  }

  Widget? _buildSuffixIcon(bool hasError) {
    if (widget.suffixIcon != null) return widget.suffixIcon;
    
    if (hasError) {
      return Semantics(
        label: AccessibilityLabels.invalidInput,
        child: Icon(
          LucideIcons.alertCircle,
          color: AccessibleColors.errorAccessible,
          size: 20,
        ),
      );
    }
    
    return null;
  }

  Widget _buildErrorMessage() {
    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            LucideIcons.alertCircle,
            size: 16,
            color: AccessibleColors.errorAccessible,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: AccessibleColors.errorAccessible,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterCount() {
    final currentLength = widget.controller.text.length;
    final maxLength = widget.maxLength!;
    final isNearLimit = currentLength > (maxLength * 0.8);
    
    return Semantics(
      liveRegion: true,
      label: 'Character count: $currentLength of $maxLength',
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          '$currentLength / $maxLength',
          style: TextStyle(
            color: isNearLimit 
                ? AccessibleColors.warningAccessible 
                : AccessibleColors.textSecondaryAccessible,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _buildSemanticLabel() {
    final parts = <String>[widget.label];
    if (widget.required) parts.add('required');
    if (_errorMessage != null) parts.add('invalid');
    return parts.join(', ');
  }

  String? _buildSemanticHint() {
    final parts = <String>[];
    if (widget.hint != null) parts.add(widget.hint!);
    if (widget.maxLength != null) {
      parts.add('Maximum ${widget.maxLength} characters');
    }
    if (_errorMessage != null) parts.add(_errorMessage!);
    return parts.isNotEmpty ? parts.join('. ') : null;
  }
}

// Accessible dropdown with proper keyboard navigation
class AccessibleDropdown<T> extends StatefulWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final bool required;
  final String? semanticLabel;
  final String? semanticHint;

  const AccessibleDropdown({
    super.key,
    required this.label,
    this.value,
    required this.items,
    this.onChanged,
    this.hint,
    this.required = false,
    this.semanticLabel,
    this.semanticHint,
  });

  @override
  State<AccessibleDropdown<T>> createState() => _AccessibleDropdownState<T>();
}

class _AccessibleDropdownState<T> extends State<AccessibleDropdown<T>> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: widget.semanticLabel ?? _buildSemanticLabel(),
      hint: widget.semanticHint,
      button: true,
      focused: _isFocused,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          RichText(
            text: TextSpan(
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: AccessibleColors.textPrimaryAccessible,
              ),
              children: [
                TextSpan(text: widget.label),
                if (widget.required)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: AccessibleColors.errorAccessible,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          
          // Dropdown
          DropdownButtonFormField<T>(
            value: widget.value,
            items: widget.items,
            onChanged: (value) {
              widget.onChanged?.call(value);
              if (value != null) {
                AccessibilityAnnouncements.announce(
                  context, 
                  'Selected ${value.toString()}'
                );
              }
            },
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: widget.hint,
              border: _buildBorder(false),
              enabledBorder: _buildBorder(false),
              focusedBorder: _buildBorder(true),
              filled: true,
              fillColor: _isFocused 
                  ? AccessibleColors.backgroundAccessible 
                  : AccessibleColors.surfaceAccessible,
            ),
            style: TextStyle(
              color: AccessibleColors.textPrimaryAccessible,
              fontSize: 16,
            ),
            dropdownColor: AccessibleColors.cardAccessible,
            icon: Icon(
              LucideIcons.chevronDown,
              color: _isFocused 
                  ? AccessibleColors.focusIndicator 
                  : AccessibleColors.textSecondaryAccessible,
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _buildBorder(bool focused) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusBtn),
      borderSide: BorderSide(
        color: focused 
            ? AccessibleColors.focusIndicator 
            : AccessibleColors.borderAccessible,
        width: focused ? 3.0 : 1.0,
      ),
    );
  }

  String _buildSemanticLabel() {
    final parts = <String>[widget.label, 'dropdown'];
    if (widget.required) parts.add('required');
    if (widget.value != null) parts.add('selected ${widget.value.toString()}');
    return parts.join(', ');
  }
}