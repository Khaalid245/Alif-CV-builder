import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'accessibility_foundation.dart';

// Accessible app bar with proper navigation
class AccessibleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool showBackButton;
  final String? backButtonSemanticLabel;

  const AccessibleAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.actions,
    this.showBackButton = true,
    this.backButtonSemanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AccessibleColors.cardAccessible,
      elevation: 0,
      leading: showBackButton
          ? Semantics(
              label: backButtonSemanticLabel ?? AccessibilityLabels.backButton,
              button: true,
              child: IconButton(
                icon: Icon(
                  LucideIcons.arrowLeft,
                  color: AccessibleColors.textPrimaryAccessible,
                ),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                focusColor: AccessibleColors.focusIndicatorHigh.withValues(alpha: 0.1),
                hoverColor: AccessibleColors.hoverAccessible,
              ),
            )
          : null,
      title: Semantics(
        header: true,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AccessibleColors.textPrimaryAccessible,
          ),
        ),
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AccessibleColors.borderLightAccessible,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}

// Accessible list item with proper focus and semantics
class AccessibleListItem extends StatefulWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final String? semanticLabel;
  final String? semanticHint;
  final bool enabled;

  const AccessibleListItem({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.semanticLabel,
    this.semanticHint,
    this.enabled = true,
  });

  @override
  State<AccessibleListItem> createState() => _AccessibleListItemState();
}

class _AccessibleListItemState extends State<AccessibleListItem> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _isHovered = false;

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

  void _handleActivation() {
    if (widget.enabled && widget.onTap != null) {
      HapticFeedback.lightImpact();
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel ?? _buildSemanticLabel(),
      hint: widget.semanticHint,
      button: widget.onTap != null,
      enabled: widget.enabled,
      focused: _isFocused,
      child: Column(
        children: [
          MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: KeyboardListener(
              focusNode: _focusNode,
              onKeyEvent: (event) {
                if (event is KeyDownEvent &&
                    KeyboardNavigation.isActivationKey(event.logicalKey)) {
                  _handleActivation();
                }
              },
              child: GestureDetector(
                onTap: widget.enabled ? widget.onTap : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(),
                    border: _isFocused
                        ? Border.all(
                            color: AccessibleColors.focusIndicator,
                            width: 2.0,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        // Leading widget
                        widget.leading,
                        const SizedBox(width: AppSpacing.md),
                        
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: AppTypography.bodyLarge.copyWith(
                                  color: widget.enabled
                                      ? AccessibleColors.textPrimaryAccessible
                                      : AccessibleColors.disabledAccessible,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (widget.subtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  widget.subtitle!,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: widget.enabled
                                        ? AccessibleColors.textSecondaryAccessible
                                        : AccessibleColors.disabledAccessible,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        // Trailing widget
                        if (widget.trailing != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          widget.trailing!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Divider
          if (widget.showDivider)
            Container(
              height: 1,
              color: AccessibleColors.borderLightAccessible,
              margin: const EdgeInsets.only(left: AppSpacing.md + 48),
            ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    if (!widget.enabled) {
      return AccessibleColors.disabledAccessible.withValues(alpha: 0.05);
    }
    if (_isFocused) {
      return AccessibleColors.focusIndicatorHigh.withValues(alpha: 0.05);
    }
    if (_isHovered) {
      return AccessibleColors.hoverAccessible;
    }
    return Colors.transparent;
  }

  String _buildSemanticLabel() {
    final parts = <String>[widget.title];
    if (widget.subtitle != null) parts.add(widget.subtitle!);
    if (widget.onTap != null) parts.add('button');
    return parts.join(', ');
  }
}

// Accessible card with proper focus and semantics
class AccessibleCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final String? semanticLabel;
  final String? semanticHint;
  final bool showBorder;
  final bool showShadow;

  const AccessibleCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.semanticLabel,
    this.semanticHint,
    this.showBorder = true,
    this.showShadow = false,
  });

  @override
  State<AccessibleCard> createState() => _AccessibleCardState();
}

class _AccessibleCardState extends State<AccessibleCard> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _isHovered = false;

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
    Widget card = Container(
      padding: widget.padding ?? const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AccessibleColors.cardAccessible,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: widget.showBorder || _isFocused
            ? Border.all(
                color: _isFocused
                    ? AccessibleColors.focusIndicator
                    : AccessibleColors.borderLightAccessible,
                width: _isFocused ? 3.0 : 1.0,
              )
            : null,
        boxShadow: widget.showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: widget.child,
    );

    if (widget.onTap != null) {
      card = Semantics(
        label: widget.semanticLabel,
        hint: widget.semanticHint,
        button: true,
        focused: _isFocused,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: KeyboardListener(
            focusNode: _focusNode,
            onKeyEvent: (event) {
              if (event is KeyDownEvent &&
                  KeyboardNavigation.isActivationKey(event.logicalKey)) {
                KeyboardNavigation.handleActivation(widget.onTap);
              }
            },
            child: GestureDetector(
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                transform: Matrix4.identity()
                  ..scale(_isHovered && !_isFocused ? 1.02 : 1.0),
                child: card,
              ),
            ),
          ),
        ),
      );
    } else {
      card = Semantics(
        label: widget.semanticLabel,
        hint: widget.semanticHint,
        container: true,
        child: card,
      );
    }

    return card;
  }
}

// Accessible navigation rail for larger screens
class AccessibleNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final List<NavigationRailDestination> destinations;
  final Widget? leading;
  final Widget? trailing;

  const AccessibleNavigationRail({
    super.key,
    required this.selectedIndex,
    this.onDestinationSelected,
    required this.destinations,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Navigation menu',
      child: NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          onDestinationSelected?.call(index);
          AccessibilityAnnouncements.announceNavigation(
            context,
            destinations[index].label is Widget ? (destinations[index].label as Widget).toString() : destinations[index].label.toString(),
          );
        },
        destinations: destinations.map((dest) {
          return NavigationRailDestination(
            icon: Semantics(
              excludeSemantics: true,
              child: dest.icon,
            ),
            selectedIcon: Semantics(
              excludeSemantics: true,
              child: dest.selectedIcon ?? dest.icon,
            ),
            label: Text(
              dest.label is Widget ? (dest.label as Widget).toString() : dest.label.toString(),
              style: TextStyle(
                color: AccessibleColors.textPrimaryAccessible,
              ),
            ),
          );
        }).toList(),
        leading: leading,
        trailing: trailing,
        backgroundColor: AccessibleColors.surfaceAccessible,
        selectedIconTheme: IconThemeData(
          color: AccessibleColors.focusIndicator,
          size: 24,
        ),
        unselectedIconTheme: IconThemeData(
          color: AccessibleColors.textSecondaryAccessible,
          size: 24,
        ),
        selectedLabelTextStyle: TextStyle(
          color: AccessibleColors.focusIndicator,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: AccessibleColors.textSecondaryAccessible,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// Accessible bottom navigation bar
class AccessibleBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final List<BottomNavigationBarItem> items;

  const AccessibleBottomNavigationBar({
    super.key,
    required this.currentIndex,
    this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Bottom navigation',
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          onTap?.call(index);
          AccessibilityAnnouncements.announceNavigation(
            context,
            items[index].label ?? 'Tab ${index + 1}',
          );
        },
        items: items,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AccessibleColors.cardAccessible,
        selectedItemColor: AccessibleColors.focusIndicator,
        unselectedItemColor: AccessibleColors.textSecondaryAccessible,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}