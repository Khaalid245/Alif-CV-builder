import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'performance_foundation.dart';

// Performance-optimized enterprise card
class OptimizedEnterpriseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool showBorder;
  final bool showShadow;
  final Color? backgroundColor;
  final bool enableMicroInteractions;

  const OptimizedEnterpriseCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.showBorder = true,
    this.showShadow = false,
    this.backgroundColor,
    this.enableMicroInteractions = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = RepaintBoundary(
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: showBorder ? Border.all(color: AppColors.border) : null,
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );

    if (onTap != null) {
      if (enableMicroInteractions) {
        card = MicroInteractionButton(
          onPressed: onTap,
          child: card,
        );
      } else {
        card = InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: card,
        );
      }
    }

    return card;
  }
}

// Performance-optimized stats card with responsive design
class OptimizedStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final String? subtitle;
  final bool isLoading;
  final VoidCallback? onTap;

  const OptimizedStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints) {
        final cardColor = color ?? AppColors.primary;
        final isCompact = constraints.isMobile;
        
        return PerformantAnimatedWidget(
          fadeIn: true,
          slideIn: true,
          slideOffset: const Offset(0, 0.2),
          child: OptimizedEnterpriseCard(
            backgroundColor: cardColor.withValues(alpha: 0.05),
            showBorder: true,
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isCompact ? AppSpacing.sm : AppSpacing.md),
                      decoration: BoxDecoration(
                        color: cardColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Icon(
                        icon, 
                        color: cardColor, 
                        size: isCompact ? 18 : 20,
                      ),
                    ),
                    const Spacer(),
                    if (isLoading)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(cardColor),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: isCompact ? AppSpacing.sm : AppSpacing.md),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    value,
                    key: ValueKey(value),
                    style: (isCompact ? AppTypography.h4 : AppTypography.h2).copyWith(
                      color: cardColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  title, 
                  style: isCompact ? AppTypography.bodySmall : AppTypography.bodyMedium,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!, 
                    style: AppTypography.caption,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// Performance-optimized responsive grid
class OptimizedResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsets? padding;
  final double? childAspectRatio;

  const OptimizedResponsiveGrid({
    super.key,
    required this.children,
    this.mainAxisSpacing = 16.0,
    this.crossAxisSpacing = 16.0,
    this.padding,
    this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: children.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: constraints.gridColumns,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: childAspectRatio ?? (constraints.isMobile ? 1.2 : 1.5),
          ),
          itemBuilder: (context, index) {
            return PerformantAnimatedWidget(
              fadeIn: true,
              slideIn: true,
              duration: Duration(milliseconds: 300 + (index * 100)),
              child: children[index],
            );
          },
        );
      },
    );
  }
}

// Performance-optimized list item
class OptimizedListItem extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final bool enableMicroInteractions;

  const OptimizedListItem({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.enableMicroInteractions = true,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.isMobile;
        
        Widget listItem = RepaintBoundary(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(isCompact ? AppSpacing.sm : AppSpacing.md),
                child: Row(
                  children: [
                    leading,
                    SizedBox(width: isCompact ? AppSpacing.sm : AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title, 
                            style: (isCompact ? AppTypography.bodyMedium : AppTypography.bodyLarge).copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!, 
                              style: isCompact ? AppTypography.caption : AppTypography.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (trailing != null) ...[
                      SizedBox(width: isCompact ? AppSpacing.xs : AppSpacing.sm),
                      trailing!,
                    ],
                  ],
                ),
              ),
              if (showDivider)
                Container(
                  height: 1,
                  color: AppColors.divider,
                  margin: EdgeInsets.only(left: isCompact ? 60 : 72),
                ),
            ],
          ),
        );

        if (onTap != null) {
          if (enableMicroInteractions) {
            listItem = MicroInteractionButton(
              onPressed: onTap,
              child: listItem,
            );
          } else {
            listItem = InkWell(
              onTap: onTap,
              child: listItem,
            );
          }
        }

        return listItem;
      },
    );
  }
}

// Performance-optimized section header
class OptimizedSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final bool showDivider;

  const OptimizedSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.isMobile;
        
        return RepaintBoundary(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: isCompact ? AppSpacing.sm : AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title, 
                            style: isCompact ? AppTypography.h3 : AppTypography.h2,
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle!, 
                              style: isCompact ? AppTypography.bodySmall : AppTypography.bodyMedium,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (action != null) action!,
                  ],
                ),
              ),
              if (showDivider)
                Container(
                  height: 1,
                  color: AppColors.divider,
                ),
            ],
          ),
        );
      },
    );
  }
}

// Performance-optimized animated container
class OptimizedAnimatedContainer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final bool autoStart;

  const OptimizedAnimatedContainer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
    this.autoStart = true,
  });

  @override
  State<OptimizedAnimatedContainer> createState() => _OptimizedAnimatedContainerState();
}

class _OptimizedAnimatedContainerState extends State<OptimizedAnimatedContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}

// Performance-optimized content wrapper
class OptimizedContentWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool centerContent;

  const OptimizedContentWrapper({
    super.key,
    required this.child,
    this.padding,
    this.centerContent = false,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints) {
        Widget content = Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: constraints.contentMaxWidth,
          ),
          padding: padding ?? constraints.padding,
          child: child,
        );

        if (centerContent && constraints.isDesktop) {
          content = Center(child: content);
        }

        return content;
      },
    );
  }
}