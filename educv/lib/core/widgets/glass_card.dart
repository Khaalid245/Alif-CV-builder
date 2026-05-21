import 'package:flutter/material.dart';
import 'dart:ui';

import '../theme/premium_dark_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurIntensity;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 32.0,
    this.blurIntensity = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: PremiumDarkColors.glassBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: PremiumDarkColors.blueGlow.withOpacity(0.1),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurIntensity, sigmaY: blurIntensity),
          child: Container(
            decoration: BoxDecoration(
              color: PremiumDarkColors.glassSurface,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}