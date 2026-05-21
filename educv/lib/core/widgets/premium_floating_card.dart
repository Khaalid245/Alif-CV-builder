import 'package:flutter/material.dart';
import '../theme/premium_portfolio_colors.dart';

class PremiumFloatingCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool enableHover;
  final VoidCallback? onTap;

  const PremiumFloatingCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 24.0,
    this.enableHover = true,
    this.onTap,
  });

  @override
  State<PremiumFloatingCard> createState() => _PremiumFloatingCardState();
}

class _PremiumFloatingCardState extends State<PremiumFloatingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _elevationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    if (!widget.enableHover) return;
    
    setState(() {
      _isHovered = isHovered;
    });
    
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: widget.margin,
            child: MouseRegion(
              onEnter: (_) => _onHover(true),
              onExit: (_) => _onHover(false),
              child: GestureDetector(
                onTap: widget.onTap,
                child: Container(
                  padding: widget.padding ?? const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: PremiumPortfolioColors.cardBackground,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: Border.all(
                      color: PremiumPortfolioColors.borderLight,
                      width: 1,
                    ),
                    boxShadow: _isHovered
                        ? PremiumPortfolioColors.floatingCardShadow
                        : PremiumPortfolioColors.cardShadow,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}