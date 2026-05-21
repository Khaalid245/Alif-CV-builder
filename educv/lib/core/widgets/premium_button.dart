import 'package:flutter/material.dart';
import 'dart:ui';

import '../theme/premium_dark_colors.dart';

class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? width;
  final double? height;

  const PremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.width,
    this.height,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.isFullWidth ? double.infinity : widget.width,
      height: widget.height ?? 56,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: widget.onPressed != null && !widget.isLoading
                  ? _onTapDown
                  : null,
              onTapUp: widget.onPressed != null && !widget.isLoading
                  ? _onTapUp
                  : null,
              onTapCancel: _onTapCancel,
              onTap: widget.onPressed != null && !widget.isLoading
                  ? widget.onPressed
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: widget.onPressed != null && !widget.isLoading
                      ? PremiumDarkColors.buttonGradient
                      : LinearGradient(
                          colors: [
                            PremiumDarkColors.primaryGradientStart
                                .withOpacity(0.5),
                            PremiumDarkColors.primaryGradientEnd
                                .withOpacity(0.5),
                          ],
                        ),
                  boxShadow: [
                    if (widget.onPressed != null && !widget.isLoading) ...[
                      BoxShadow(
                        color: PremiumDarkColors.blueGlow,
                        blurRadius: 20 + (10 * _glowAnimation.value),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: PremiumDarkColors.purpleGlow,
                        blurRadius: 15 + (8 * _glowAnimation.value),
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: _buildContent(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            PremiumDarkColors.textPrimary,
          ),
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.icon,
            size: 18,
            color: PremiumDarkColors.textPrimary,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              widget.text,
              style: const TextStyle(
                color: PremiumDarkColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: const TextStyle(
        color: PremiumDarkColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}