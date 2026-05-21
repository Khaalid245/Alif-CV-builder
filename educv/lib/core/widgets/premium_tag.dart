import 'package:flutter/material.dart';
import '../theme/premium_portfolio_colors.dart';

class PremiumTag extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  const PremiumTag({
    super.key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? PremiumPortfolioColors.accentPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: PremiumPortfolioColors.accentPurple.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: textColor ?? PremiumPortfolioColors.accentPurple,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor ?? PremiumPortfolioColors.accentPurple,
            ),
          ),
        ],
      ),
    );
  }
}