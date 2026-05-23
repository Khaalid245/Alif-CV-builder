import 'package:flutter/material.dart';
import '../../../../core/theme/premium_portfolio_colors.dart';

class PremiumFloatingCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool enableHover;

  const PremiumFloatingCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(32),
    this.borderRadius = 24,
    this.enableHover = true,
  });

  @override
  State<PremiumFloatingCard> createState() => _PremiumFloatingCardState();
}

class _PremiumFloatingCardState extends State<PremiumFloatingCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: widget.enableHover ? (_) => setState(() => _isHovered = true) : null,
      onExit: widget.enableHover ? (_) => setState(() => _isHovered = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -8.0 : 0.0),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: PremiumPortfolioColors.cardBackground,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: _isHovered 
                ? PremiumPortfolioColors.accentPurple.withValues(alpha: 0.2)
                : PremiumPortfolioColors.borderLight,
            width: 1,
          ),
          boxShadow: _isHovered
              ? PremiumPortfolioColors.floatingCardShadow
              : PremiumPortfolioColors.cardShadow,
        ),
        child: widget.child,
      ),
    );
  }
}