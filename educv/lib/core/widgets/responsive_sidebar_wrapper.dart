import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/modern_saas_theme.dart';
import 'responsive_layout.dart';
import 'modern_saas_sidebar.dart';

class ResponsiveSidebarWrapper extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final Function(int)? onNavigationChanged;
  final String? userName;
  final String? userEmail;
  final String? userAvatar;
  final VoidCallback? onProfileTap;
  final VoidCallback? onUpgradeTap;
  final bool showPremiumCard;

  const ResponsiveSidebarWrapper({
    super.key,
    required this.child,
    required this.currentIndex,
    this.onNavigationChanged,
    this.userName,
    this.userEmail,
    this.userAvatar,
    this.onProfileTap,
    this.onUpgradeTap,
    this.showPremiumCard = true,
  });

  @override
  State<ResponsiveSidebarWrapper> createState() =>
      ResponsiveSidebarWrapperState();
}

class ResponsiveSidebarWrapperState extends State<ResponsiveSidebarWrapper>
    with TickerProviderStateMixin {
  bool _isTabletSidebarOpen = false;
  late AnimationController _overlayController;
  late Animation<double> _overlayAnimation;

  @override
  void initState() {
    super.initState();
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _overlayAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _overlayController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _overlayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        switch (deviceType) {
          case DeviceType.mobile:
            return _buildMobileLayout();
          case DeviceType.tablet:
            return _buildTabletLayout();
          case DeviceType.desktop:
            return _buildDesktopLayout();
        }
      },
    );
  }

  Widget _buildMobileLayout() {
    // Mobile: No sidebar, content takes full width
    return Scaffold(
      backgroundColor: ModernSaaSDashboardTheme.background,
      body: widget.child,
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      backgroundColor: ModernSaaSDashboardTheme.background,
      body: Stack(
        children: [
          // Main content
          Row(
            children: [
              // Spacer for sidebar when open
              if (_isTabletSidebarOpen)
                const SizedBox(width: ModernSaaSDashboardTheme.sidebarWidth),
              Expanded(child: widget.child),
            ],
          ),

          // Overlay
          if (_isTabletSidebarOpen)
            AnimatedBuilder(
              animation: _overlayAnimation,
              builder: (context, child) {
                return GestureDetector(
                  onTap: _closeTabletSidebar,
                  child: Container(
                    color: Colors.black.withOpacity(_overlayAnimation.value),
                  ),
                );
              },
            ),

          // Collapsible sidebar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _isTabletSidebarOpen
                ? 0
                : -ModernSaaSDashboardTheme.sidebarWidth,
            top: 0,
            bottom: 0,
            width: ModernSaaSDashboardTheme.sidebarWidth,
            child: ModernSaaSSidebar(
              currentIndex: widget.currentIndex,
              onNavigationChanged: (index) {
                widget.onNavigationChanged?.call(index);
                _closeTabletSidebar();
              },
              isCollapsed: false,
              userName: widget.userName,
              userEmail: widget.userEmail,
              userAvatar: widget.userAvatar,
              onProfileTap: widget.onProfileTap,
              onUpgradeTap: widget.onUpgradeTap,
              showPremiumCard: widget.showPremiumCard,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: ModernSaaSDashboardTheme.background,
      body: Row(
        children: [
          // Fixed sidebar
          ModernSaaSSidebar(
            currentIndex: widget.currentIndex,
            onNavigationChanged: widget.onNavigationChanged,
            isCollapsed: false,
            userName: widget.userName,
            userEmail: widget.userEmail,
            userAvatar: widget.userAvatar,
            onProfileTap: widget.onProfileTap,
            onUpgradeTap: widget.onUpgradeTap,
            showPremiumCard: widget.showPremiumCard,
          ),

          // Main content
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  void _openTabletSidebar() {
    setState(() {
      _isTabletSidebarOpen = true;
    });
    _overlayController.forward();
  }

  void _closeTabletSidebar() {
    setState(() {
      _isTabletSidebarOpen = false;
    });
    _overlayController.reverse();
  }

  void toggleTabletSidebar() {
    if (_isTabletSidebarOpen) {
      _closeTabletSidebar();
    } else {
      _openTabletSidebar();
    }
  }
}

class ResponsiveAppBarWithSidebar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onMenuPressed;

  const ResponsiveAppBarWithSidebar({
    super.key,
    required this.title,
    this.actions,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        return Container(
          height: preferredSize.height,
          decoration: const BoxDecoration(
            color: ModernSaaSDashboardTheme.surfaceBackground,
            border: Border(
              bottom: BorderSide(
                color: ModernSaaSDashboardTheme.borderLight,
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: deviceType.isMobile ? 16 : 24,
              ),
              child: Row(
                children: [
                  // Menu button for mobile and tablet
                  if (deviceType.isMobile || deviceType.isTablet)
                    IconButton(
                      onPressed: onMenuPressed,
                      icon: const Icon(
                        LucideIcons.menu,
                        color: ModernSaaSDashboardTheme.primaryText,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: ModernSaaSDashboardTheme.hover,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                  if (deviceType.isMobile || deviceType.isTablet)
                    const SizedBox(width: 16),

                  // Title
                  Text(
                    title,
                    style: deviceType.isDesktop
                        ? ModernSaaSDashboardTheme.displaySmall
                        : deviceType.isTablet
                            ? ModernSaaSDashboardTheme.headlineLarge
                            : ModernSaaSDashboardTheme.headlineMedium,
                  ),

                  const Spacer(),

                  // Actions
                  if (actions != null) ...actions!,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}

// Extension to access sidebar controls from child widgets
extension SidebarContext on BuildContext {
  void openSidebar() {
    final wrapper = findAncestorStateOfType<_ResponsiveSidebarWrapperState>();
    wrapper?.toggleTabletSidebar();
  }
}

// Sidebar toggle button widget for easy integration
class SidebarToggleButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const SidebarToggleButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        if (deviceType.isDesktop) {
          return const SizedBox.shrink(); // No toggle needed on desktop
        }

        return IconButton(
          onPressed: onPressed ?? () => context.openSidebar(),
          icon: const Icon(
            LucideIcons.menu,
            color: ModernSaaSDashboardTheme.primaryText,
          ),
          style: IconButton.styleFrom(
            backgroundColor: ModernSaaSDashboardTheme.hover,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }
}

// Sidebar item widget for external use
class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final String? badge;
  final Color? badgeColor;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.badge,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? ModernSaaSDashboardTheme.accentPurple.withOpacity(0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: ModernSaaSDashboardTheme.accentPurple
                          .withOpacity(0.2),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? ModernSaaSDashboardTheme.accentPurple
                      : ModernSaaSDashboardTheme.tertiaryText,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: ModernSaaSDashboardTheme.bodyMedium.copyWith(
                      color: isSelected
                          ? ModernSaaSDashboardTheme.accentPurple
                          : ModernSaaSDashboardTheme.primaryText,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                          badgeColor ?? ModernSaaSDashboardTheme.accentPurple,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge!,
                      style: ModernSaaSDashboardTheme.labelSmall.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
