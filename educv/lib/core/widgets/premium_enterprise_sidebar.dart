import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/premium_saas_theme.dart';

class PremiumEnterpriseSidebar extends StatefulWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;
  final String currentRoute;
  final Function(String) onNavigate;

  const PremiumEnterpriseSidebar({
    super.key,
    required this.isCollapsed,
    required this.onToggle,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  State<PremiumEnterpriseSidebar> createState() =>
      _PremiumEnterpriseSidebarState();
}

class _PremiumEnterpriseSidebarState extends State<PremiumEnterpriseSidebar>
    with TickerProviderStateMixin {
  late AnimationController _collapseController;
  late AnimationController _glowController;
  late Animation<double> _widthAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _collapseController = AnimationController(
      duration: PremiumSaaSTheme.animationMedium,
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _widthAnimation = Tween<double>(begin: 280, end: 80).animate(
      CurvedAnimation(
          parent: _collapseController, curve: PremiumSaaSTheme.curveDefault),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _collapseController, curve: PremiumSaaSTheme.curveDefault),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    if (widget.isCollapsed) {
      _collapseController.value = 1.0;
    }

    _glowController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(PremiumEnterpriseSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCollapsed != oldWidget.isCollapsed) {
      if (widget.isCollapsed) {
        _collapseController.forward();
      } else {
        _collapseController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _collapseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _collapseController,
      builder: (context, child) {
        return Container(
          width: _widthAnimation.value,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                PremiumSaaSTheme.darkBackground,
                PremiumSaaSTheme.darkSurface,
              ],
            ),
            border: Border(
              right: BorderSide(
                color: PremiumSaaSTheme.darkBorder,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildNavigation()),
              _buildAIAssistant(),
              _buildUserProfile(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(widget.isCollapsed
          ? PremiumSaaSTheme.space4
          : PremiumSaaSTheme.space6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: PremiumSaaSTheme.heroGradient,
              borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusLg),
              boxShadow: PremiumSaaSTheme.shadowGlow,
            ),
            child: const Icon(
              LucideIcons.brain,
              color: PremiumSaaSTheme.textInverse,
              size: 20,
            ),
          ),
          if (!widget.isCollapsed) ...[
            SizedBox(width: PremiumSaaSTheme.space3),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI CV Builder',
                      style: PremiumSaaSTheme.labelLarge.copyWith(
                        color: PremiumSaaSTheme.textInverse,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Enterprise',
                      style: PremiumSaaSTheme.bodySmall.copyWith(
                        color: PremiumSaaSTheme.textInverseSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const Spacer(),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onToggle,
              borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusSm),
              child: Container(
                padding: EdgeInsets.all(PremiumSaaSTheme.space2),
                child: Icon(
                  widget.isCollapsed
                      ? LucideIcons.chevronRight
                      : LucideIcons.chevronLeft,
                  color: PremiumSaaSTheme.textInverseSecondary,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    final navItems = [
      _NavItem(
        icon: LucideIcons.layoutDashboard,
        label: 'Dashboard',
        route: '/dashboard',
        badge: null,
      ),
      _NavItem(
        icon: LucideIcons.fileText,
        label: 'My CV',
        route: '/cv',
        badge: '85%',
      ),
      _NavItem(
        icon: LucideIcons.layout,
        label: 'Templates',
        route: '/templates',
        badge: null,
      ),
      _NavItem(
        icon: LucideIcons.download,
        label: 'Downloads',
        route: '/downloads',
        badge: '8',
      ),
      _NavItem(
        icon: LucideIcons.sparkles,
        label: 'AI Tools',
        route: '/ai-tools',
        badge: 'NEW',
      ),
      _NavItem(
        icon: LucideIcons.barChart3,
        label: 'Analytics',
        route: '/analytics',
        badge: null,
      ),
      _NavItem(
        icon: LucideIcons.settings,
        label: 'Settings',
        route: '/settings',
        badge: null,
      ),
    ];

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: PremiumSaaSTheme.space4),
      itemCount: navItems.length,
      itemBuilder: (context, index) {
        final item = navItems[index];
        final isActive = widget.currentRoute == item.route;

        return _buildNavItem(item, isActive);
      },
    );
  }

  Widget _buildNavItem(_NavItem item, bool isActive) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: PremiumSaaSTheme.space3,
        vertical: PremiumSaaSTheme.space1,
      ),
      child: Material(
        color: Colors.transparent,
        child: Tooltip(
          message: widget.isCollapsed ? item.label : '',
          preferBelow: false,
          child: InkWell(
            onTap: () => widget.onNavigate(item.route),
            borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusLg),
            child: AnimatedContainer(
              duration: PremiumSaaSTheme.animationFast,
              padding: EdgeInsets.symmetric(
                horizontal: PremiumSaaSTheme.space4,
                vertical: PremiumSaaSTheme.space3,
              ),
              decoration: BoxDecoration(
                gradient: isActive
                    ? LinearGradient(
                        colors: [
                          PremiumSaaSTheme.primaryPurple.withOpacity(0.2),
                          PremiumSaaSTheme.primaryPurple.withOpacity(0.1),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusLg),
                border: isActive
                    ? Border.all(
                        color: PremiumSaaSTheme.primaryPurple.withOpacity(0.3),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    child: Icon(
                      item.icon,
                      color: isActive
                          ? PremiumSaaSTheme.primaryPurpleLight
                          : PremiumSaaSTheme.textInverseSecondary,
                      size: 18,
                    ),
                  ),
                  if (!widget.isCollapsed) ...[
                    SizedBox(width: PremiumSaaSTheme.space3),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Expanded(
                        child: Text(
                          item.label,
                          style: PremiumSaaSTheme.labelMedium.copyWith(
                            color: isActive
                                ? PremiumSaaSTheme.textInverse
                                : PremiumSaaSTheme.textInverseSecondary,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    if (item.badge != null) ...[
                      SizedBox(width: PremiumSaaSTheme.space2),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: PremiumSaaSTheme.space2,
                          vertical: PremiumSaaSTheme.space1,
                        ),
                        decoration: BoxDecoration(
                          color: item.badge == 'NEW'
                              ? PremiumSaaSTheme.accentGreen
                              : PremiumSaaSTheme.primaryPurple.withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(PremiumSaaSTheme.radiusSm),
                        ),
                        child: Text(
                          item.badge!,
                          style: PremiumSaaSTheme.labelSmall.copyWith(
                            color: item.badge == 'NEW'
                                ? PremiumSaaSTheme.textInverse
                                : PremiumSaaSTheme.primaryPurpleLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIAssistant() {
    if (widget.isCollapsed) {
      return Container(
        margin: EdgeInsets.all(PremiumSaaSTheme.space3),
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: PremiumSaaSTheme.heroGradient,
                borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: PremiumSaaSTheme.primaryPurple
                        .withOpacity(0.3 + (_glowAnimation.value * 0.2)),
                    blurRadius: 12 + (_glowAnimation.value * 8),
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                LucideIcons.sparkles,
                color: PremiumSaaSTheme.textInverse,
                size: 20,
              ),
            );
          },
        ),
      );
    }

    return Container(
      margin: EdgeInsets.all(PremiumSaaSTheme.space4),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              padding: EdgeInsets.all(PremiumSaaSTheme.space4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    PremiumSaaSTheme.primaryPurple.withOpacity(0.15),
                    PremiumSaaSTheme.accentBlue.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusXl),
                border: Border.all(
                  color: PremiumSaaSTheme.primaryPurple
                      .withOpacity(0.2 + (_glowAnimation.value * 0.1)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: PremiumSaaSTheme.primaryPurple
                        .withOpacity(0.1 + (_glowAnimation.value * 0.1)),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.sparkles,
                        color: PremiumSaaSTheme.primaryPurpleLight,
                        size: 16,
                      ),
                      SizedBox(width: PremiumSaaSTheme.space2),
                      Text(
                        'AI Assistant',
                        style: PremiumSaaSTheme.labelMedium.copyWith(
                          color: PremiumSaaSTheme.textInverse,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: PremiumSaaSTheme.space2),
                  Text(
                    'Get AI-powered suggestions to optimize your CV',
                    style: PremiumSaaSTheme.bodySmall.copyWith(
                      color: PremiumSaaSTheme.textInverseSecondary,
                    ),
                  ),
                  SizedBox(height: PremiumSaaSTheme.space3),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: PremiumSaaSTheme.space2,
                    ),
                    decoration: BoxDecoration(
                      gradient: PremiumSaaSTheme.heroGradient,
                      borderRadius:
                          BorderRadius.circular(PremiumSaaSTheme.radiusMd),
                    ),
                    child: Text(
                      'Try AI Tools',
                      textAlign: TextAlign.center,
                      style: PremiumSaaSTheme.labelSmall.copyWith(
                        color: PremiumSaaSTheme.textInverse,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    return Container(
      padding: EdgeInsets.all(PremiumSaaSTheme.space4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: PremiumSaaSTheme.heroGradient,
              borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusLg),
            ),
            child: Center(
              child: Text(
                'W',
                style: PremiumSaaSTheme.labelLarge.copyWith(
                  color: PremiumSaaSTheme.textInverse,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (!widget.isCollapsed) ...[
            SizedBox(width: PremiumSaaSTheme.space3),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'William Chen',
                      style: PremiumSaaSTheme.labelMedium.copyWith(
                        color: PremiumSaaSTheme.textInverse,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: PremiumSaaSTheme.space2,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: PremiumSaaSTheme.accentGreen.withOpacity(0.2),
                        borderRadius:
                            BorderRadius.circular(PremiumSaaSTheme.radiusXs),
                      ),
                      child: Text(
                        'Premium',
                        style: PremiumSaaSTheme.labelSmall.copyWith(
                          color: PremiumSaaSTheme.accentGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  final String? badge;

  _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    this.badge,
  });
}
