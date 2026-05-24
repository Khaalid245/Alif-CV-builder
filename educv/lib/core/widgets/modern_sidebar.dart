import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/enterprise_theme.dart';
import '../widgets/enterprise_ui_components.dart';

class ModernSidebar extends StatefulWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;
  final String currentRoute;
  final Function(String) onNavigate;

  const ModernSidebar({
    super.key,
    required this.isCollapsed,
    required this.onToggle,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  State<ModernSidebar> createState() => _ModernSidebarState();
}

class _ModernSidebarState extends State<ModernSidebar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _widthAnimation = Tween<double>(
      begin: 280,
      end: 80,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isCollapsed) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ModernSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCollapsed != oldWidget.isCollapsed) {
      if (widget.isCollapsed) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: _widthAnimation.value,
          height: double.infinity,
          decoration: BoxDecoration(
            color: EnterpriseTheme.cardBackground,
            border: Border(
              right: BorderSide(color: EnterpriseTheme.cardBorder),
            ),
            boxShadow: EnterpriseTheme.shadowSm,
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildNavigation()),
              _buildFooter(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(EnterpriseTheme.spacing20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: EnterpriseTheme.primaryGradient,
              borderRadius: BorderRadius.circular(EnterpriseTheme.radiusMd),
            ),
            child: const Icon(
              LucideIcons.fileText,
              color: EnterpriseTheme.white,
              size: 20,
            ),
          ),
          if (!widget.isCollapsed) ...[
            const SizedBox(width: EnterpriseTheme.spacing12),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI CV Builder',
                    style: EnterpriseTheme.h4.copyWith(
                      color: EnterpriseTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Enterprise Edition',
                    style: EnterpriseTheme.bodySmall.copyWith(
                      color: EnterpriseTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          IconButton(
            onPressed: widget.onToggle,
            icon: Icon(
              widget.isCollapsed ? LucideIcons.chevronRight : LucideIcons.chevronLeft,
              color: EnterpriseTheme.textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    final navItems = [
      NavItem(
        icon: LucideIcons.layoutDashboard,
        label: 'Dashboard',
        route: '/dashboard',
      ),
      NavItem(
        icon: LucideIcons.fileText,
        label: 'My CV',
        route: '/cv',
      ),
      NavItem(
        icon: LucideIcons.layout,
        label: 'Templates',
        route: '/templates',
      ),
      NavItem(
        icon: LucideIcons.download,
        label: 'Downloads',
        route: '/downloads',
      ),
      NavItem(
        icon: LucideIcons.brain,
        label: 'AI Tools',
        route: '/ai-tools',
      ),
      NavItem(
        icon: LucideIcons.barChart3,
        label: 'Analytics',
        route: '/analytics',
      ),
      NavItem(
        icon: LucideIcons.settings,
        label: 'Settings',
        route: '/settings',
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: EnterpriseTheme.spacing8),
      itemCount: navItems.length,
      itemBuilder: (context, index) {
        final item = navItems[index];
        final isActive = widget.currentRoute == item.route;
        
        return _buildNavItem(item, isActive);
      },
    );
  }

  Widget _buildNavItem(NavItem item, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: EnterpriseTheme.spacing12,
        vertical: EnterpriseTheme.spacing2,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onNavigate(item.route),
          borderRadius: BorderRadius.circular(EnterpriseTheme.radiusMd),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: EnterpriseTheme.spacing16,
              vertical: EnterpriseTheme.spacing12,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? EnterpriseTheme.primaryPurple.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(EnterpriseTheme.radiusMd),
              border: isActive
                  ? Border.all(
                      color: EnterpriseTheme.primaryPurple.withOpacity(0.2),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  color: isActive
                      ? EnterpriseTheme.primaryPurple
                      : EnterpriseTheme.textSecondary,
                  size: 20,
                ),
                if (!widget.isCollapsed) ...[
                  const SizedBox(width: EnterpriseTheme.spacing12),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Expanded(
                      child: Text(
                        item.label,
                        style: EnterpriseTheme.labelLarge.copyWith(
                          color: isActive
                              ? EnterpriseTheme.primaryPurple
                              : EnterpriseTheme.textPrimary,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(EnterpriseTheme.spacing20),
      child: Column(
        children: [
          if (!widget.isCollapsed) ...[
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.all(EnterpriseTheme.spacing16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      EnterpriseTheme.primaryPurple.withOpacity(0.1),
                      EnterpriseTheme.accentBlue.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(EnterpriseTheme.radiusMd),
                  border: Border.all(
                    color: EnterpriseTheme.primaryPurple.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.sparkles,
                          color: EnterpriseTheme.primaryPurple,
                          size: 16,
                        ),
                        const SizedBox(width: EnterpriseTheme.spacing8),
                        Text(
                          'AI Assistant',
                          style: EnterpriseTheme.labelMedium.copyWith(
                            color: EnterpriseTheme.primaryPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: EnterpriseTheme.spacing8),
                    Text(
                      'Get AI-powered suggestions to improve your CV',
                      style: EnterpriseTheme.bodySmall,
                    ),
                    const SizedBox(height: EnterpriseTheme.spacing12),
                    EnterpriseButton(
                      text: 'Try AI Tools',
                      onPressed: () => widget.onNavigate('/ai-tools'),
                      size: ButtonSize.small,
                      icon: LucideIcons.arrowRight,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: EnterpriseTheme.spacing16),
          ],
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: EnterpriseTheme.primaryPurple,
                child: Text(
                  'W',
                  style: EnterpriseTheme.labelMedium.copyWith(
                    color: EnterpriseTheme.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (!widget.isCollapsed) ...[
                const SizedBox(width: EnterpriseTheme.spacing12),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'William Chen',
                          style: EnterpriseTheme.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Premium Plan',
                          style: EnterpriseTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;
  final String route;

  NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}