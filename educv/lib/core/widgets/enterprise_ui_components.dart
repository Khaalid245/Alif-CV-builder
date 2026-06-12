import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/enterprise_theme.dart';

// Enterprise Card Component
class EnterpriseCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool showHover;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;

  const EnterpriseCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.showHover = true,
    this.backgroundColor,
    this.boxShadow,
  });

  @override
  State<EnterpriseCard> createState() => _EnterpriseCardState();
}

class _EnterpriseCardState extends State<EnterpriseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _elevationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: widget.showHover ? (_) => _controller.forward() : null,
      onExit: widget.showHover ? (_) => _controller.reverse() : null,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: widget.padding ??
                    const EdgeInsets.all(EnterpriseTheme.spacing24),
                decoration: BoxDecoration(
                  color:
                      widget.backgroundColor ?? EnterpriseTheme.cardBackground,
                  borderRadius:
                      BorderRadius.circular(EnterpriseTheme.radius2xl),
                  border:
                      Border.all(color: EnterpriseTheme.cardBorder, width: 0.5),
                  boxShadow: widget.boxShadow ??
                      [
                        BoxShadow(
                          color: EnterpriseTheme.gray900.withOpacity(
                              0.03 + (_elevationAnimation.value * 0.03)),
                          blurRadius: 8 + (_elevationAnimation.value * 16),
                          offset:
                              Offset(0, 2 + (_elevationAnimation.value * 6)),
                        ),
                        if (_elevationAnimation.value > 0)
                          BoxShadow(
                            color: EnterpriseTheme.primaryPurple
                                .withOpacity(_elevationAnimation.value * 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                      ],
                ),
                child: widget.child,
              ),
            );
          },
        ),
      ),
    );
  }
}

// Statistics Card Component
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return EnterpriseCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(EnterpriseTheme.spacing12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(EnterpriseTheme.radiusMd),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              if (onTap != null)
                const Icon(
                  LucideIcons.chevronRight,
                  color: EnterpriseTheme.textTertiary,
                  size: 16,
                ),
            ],
          ),
          const SizedBox(height: EnterpriseTheme.spacing16),
          Text(value, style: EnterpriseTheme.h2.copyWith(color: color)),
          const SizedBox(height: EnterpriseTheme.spacing4),
          Text(title, style: EnterpriseTheme.bodyMedium),
          if (subtitle != null) ...[
            const SizedBox(height: EnterpriseTheme.spacing4),
            Text(subtitle!, style: EnterpriseTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

// Action Card Component
class ActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final Color? accentColor;

  const ActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? EnterpriseTheme.primaryPurple;

    return EnterpriseCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(EnterpriseTheme.radiusLg),
              border: Border.all(color: color.withOpacity(0.2), width: 0.5),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: EnterpriseTheme.spacing20),
          Text(title, style: EnterpriseTheme.h4),
          const SizedBox(height: EnterpriseTheme.spacing8),
          Text(description, style: EnterpriseTheme.bodyMedium),
        ],
      ),
    );
  }
}

// Status Badge Component
class StatusBadge extends StatelessWidget {
  final String text;
  final StatusType type;

  const StatusBadge({
    super.key,
    required this.text,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (type) {
      case StatusType.success:
        backgroundColor = EnterpriseTheme.success.withOpacity(0.08);
        textColor = EnterpriseTheme.success;
        break;
      case StatusType.warning:
        backgroundColor = EnterpriseTheme.warning.withOpacity(0.08);
        textColor = EnterpriseTheme.warning;
        break;
      case StatusType.error:
        backgroundColor = EnterpriseTheme.error.withOpacity(0.08);
        textColor = EnterpriseTheme.error;
        break;
      case StatusType.info:
        backgroundColor = EnterpriseTheme.info.withOpacity(0.08);
        textColor = EnterpriseTheme.info;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: EnterpriseTheme.spacing12,
        vertical: EnterpriseTheme.spacing6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(EnterpriseTheme.radiusSm),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: EnterpriseTheme.labelSmall.copyWith(color: textColor),
      ),
    );
  }
}

enum StatusType { success, warning, error, info }

// Progress Indicator Component
class ProgressIndicator extends StatelessWidget {
  final double progress;
  final String label;
  final Color? color;

  const ProgressIndicator({
    super.key,
    required this.progress,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progressColor = color ?? EnterpriseTheme.primaryPurple;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: EnterpriseTheme.spacing16,
        vertical: EnterpriseTheme.spacing12,
      ),
      decoration: BoxDecoration(
        color: progressColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(EnterpriseTheme.radiusMd),
        border: Border.all(color: progressColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            progress >= 0.8 ? LucideIcons.checkCircle2 : LucideIcons.clock,
            color: progressColor,
            size: 16,
          ),
          const SizedBox(width: EnterpriseTheme.spacing8),
          Text(
            label,
            style: EnterpriseTheme.labelMedium.copyWith(color: progressColor),
          ),
        ],
      ),
    );
  }
}

// Enterprise Button Component
class EnterpriseButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;

  const EnterpriseButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
  });

  @override
  State<EnterpriseButton> createState() => _EnterpriseButtonState();
}

class _EnterpriseButtonState extends State<EnterpriseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: widget.size.height,
              padding: EdgeInsets.symmetric(horizontal: widget.size.padding),
              decoration: BoxDecoration(
                gradient: widget.type.gradient,
                borderRadius: BorderRadius.circular(EnterpriseTheme.radiusMd),
                boxShadow: EnterpriseTheme.shadowSm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.type.textColor,
                        ),
                      ),
                    )
                  else if (widget.icon != null)
                    Icon(
                      widget.icon,
                      color: widget.type.textColor,
                      size: widget.size.iconSize,
                    ),
                  if ((widget.icon != null || widget.isLoading) &&
                      widget.text.isNotEmpty)
                    const SizedBox(width: EnterpriseTheme.spacing8),
                  if (widget.text.isNotEmpty)
                    Text(
                      widget.text,
                      style: widget.size.textStyle.copyWith(
                        color: widget.type.textColor,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

enum ButtonType { primary, secondary, outline }

extension ButtonTypeExtension on ButtonType {
  LinearGradient get gradient {
    switch (this) {
      case ButtonType.primary:
        return EnterpriseTheme.primaryGradient;
      case ButtonType.secondary:
        return const LinearGradient(
          colors: [EnterpriseTheme.gray100, EnterpriseTheme.gray200],
        );
      case ButtonType.outline:
        return const LinearGradient(
          colors: [Colors.transparent, Colors.transparent],
        );
    }
  }

  Color get textColor {
    switch (this) {
      case ButtonType.primary:
        return EnterpriseTheme.white;
      case ButtonType.secondary:
        return EnterpriseTheme.textPrimary;
      case ButtonType.outline:
        return EnterpriseTheme.primaryPurple;
    }
  }
}

enum ButtonSize { small, medium, large }

extension ButtonSizeExtension on ButtonSize {
  double get height {
    switch (this) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 44;
      case ButtonSize.large:
        return 52;
    }
  }

  double get padding {
    switch (this) {
      case ButtonSize.small:
        return EnterpriseTheme.spacing16;
      case ButtonSize.medium:
        return EnterpriseTheme.spacing20;
      case ButtonSize.large:
        return EnterpriseTheme.spacing24;
    }
  }

  double get iconSize {
    switch (this) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 18;
      case ButtonSize.large:
        return 20;
    }
  }

  TextStyle get textStyle {
    switch (this) {
      case ButtonSize.small:
        return EnterpriseTheme.labelMedium;
      case ButtonSize.medium:
        return EnterpriseTheme.labelLarge;
      case ButtonSize.large:
        return EnterpriseTheme.bodyLarge;
    }
  }
}
