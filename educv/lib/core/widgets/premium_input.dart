import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';

import '../theme/premium_dark_colors.dart';

class PremiumInput extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onEditingComplete;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const PremiumInput({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.onEditingComplete,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  State<PremiumInput> createState() => _PremiumInputState();
}

class _PremiumInputState extends State<PremiumInput>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _focusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    widget.focusNode?.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChange);
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = widget.focusNode?.hasFocus ?? false;
    });
    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: PremiumDarkColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _focusAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Color.lerp(
                    const Color(0xFFE5E7EB), // Light gray border when not focused
                    const Color(0xFF4F46E5), // Blue border when focused
                    _focusAnimation.value,
                  )!,
                  width: 1.5,
                ),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: PremiumDarkColors.blueGlow,
                          blurRadius: 20,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white, // White background for better contrast
                    ),
                    child: TextFormField(
                      controller: widget.controller,
                      validator: widget.validator,
                      onChanged: widget.onChanged,
                      onEditingComplete: widget.onEditingComplete,
                      keyboardType: widget.keyboardType,
                      textInputAction: widget.textInputAction,
                      obscureText: widget.obscureText,
                      focusNode: widget.focusNode,
                      style: const TextStyle(
                        color: Color(0xFF111827), // Dark text for visibility on white background
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      cursorColor: const Color(0xFF4F46E5),
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        hintStyle: const TextStyle(
                          color: Color(0xFF9CA3AF), // Gray placeholder
                          fontSize: 16,
                        ),
                        prefixIcon: widget.prefixIcon,
                        suffixIcon: widget.suffixIcon,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 18,
                        ),
                        errorStyle: const TextStyle(
                          color: Color(0xFFEF4444), // Red error text
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class PremiumPasswordInput extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onEditingComplete;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;

  const PremiumPasswordInput({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.onChanged,
    this.onEditingComplete,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
  });

  @override
  State<PremiumPasswordInput> createState() => _PremiumPasswordInputState();
}

class _PremiumPasswordInputState extends State<PremiumPasswordInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return PremiumInput(
      label: widget.label,
      hint: widget.hint,
      controller: widget.controller,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onEditingComplete: widget.onEditingComplete,
      textInputAction: widget.textInputAction,
      focusNode: widget.focusNode,
      obscureText: _obscureText,
      prefixIcon: const Icon(
        LucideIcons.lock,
        color: Color(0xFF6B7280), // Gray icon color
        size: 20,
      ),
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? LucideIcons.eye : LucideIcons.eyeOff,
          color: const Color(0xFF4F46E5), // Blue accent for visibility toggle
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
    );
  }
}