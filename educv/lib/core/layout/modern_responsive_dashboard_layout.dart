import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/modern_saas_theme.dart';
import 'responsive_layout.dart';
import '../widgets/responsive_sidebar_wrapper.dart';

class ModernResponsiveDashboardLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;
  final int currentIndex;
  final Function(int)? onNavigationChanged;
  final String? userName;
  final String? userEmail;
  final String? userAvatar;
  final VoidCallback? onProfileTap;
  final VoidCallback? onUpgradeTap;
  final bool showPremiumCard;

  const ModernResponsiveDashboardLayout({
    super.key,
    required this.child,
    required this.title,
    this.actions,
    this.currentIndex = 0,
    this.onNavigationChanged,
    this.userName,
    this.userEmail,
    this.userAvatar,
    this.onProfileTap,
    this.onUpgradeTap,
    this.showPremiumCard = true,
  });

  @override
  State<ModernResponsiveDashboardLayout> createState() =>
      _ModernResponsiveDashboardLayoutState();
}

class _ModernResponsiveDashboardLayoutState
    extends State<ModernResponsiveDashboardLayout> {
  final GlobalKey<ResponsiveSidebarWrapperState> _sidebarKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        return ResponsiveSidebarWrapper(
          key: _sidebarKey,
          currentIndex: widget.currentIndex,
          onNavigationChanged: widget.onNavigationChanged,
          userName: widget.userName,
          userEmail: widget.userEmail,
          userAvatar: widget.userAvatar,
          onProfileTap: widget.onProfileTap,
          onUpgradeTap: widget.onUpgradeTap,
          showPremiumCard: widget.showPremiumCard,
          child: Column(
            children: [
              // App bar for mobile and tablet
              if (deviceType.isMobile || deviceType.isTablet)
                ResponsiveAppBarWithSidebar(
                  title: widget.title,
                  actions: widget.actions,
                  onMenuPressed: () =>
                      _sidebarKey.currentState?.toggleTabletSidebar(),
                ),

              // Desktop top bar
              if (deviceType.isDesktop) _buildDesktopTopBar(),

              // Main content
              Expanded(
                child: widget.child,
              ),

              // Bottom navigation for mobile
              if (deviceType.isMobile) _buildMobileBottomNavigation(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopTopBar() {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: ModernSaaSDashboardTheme.surfaceBackground,
        border: Border(
          bottom: BorderSide(
            color: ModernSaaSDashboardTheme.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          children: [
            Text(
              widget.title,
              style: ModernSaaSDashboardTheme.displaySmall,
            ),
            const Spacer(),
            if (widget.actions != null) ...widget.actions!,
          ],
        ),
      ),
    );
  }

  Widget _buildMobileBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: ModernSaaSDashboardTheme.surfaceBackground,
        border: Border(
          top: BorderSide(
            color: ModernSaaSDashboardTheme.borderLight,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: _getMobileNavIndex(),
          onTap: (index) => _handleMobileNavigation(index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: ModernSaaSDashboardTheme.surfaceBackground,
          selectedItemColor: ModernSaaSDashboardTheme.accentPurple,
          unselectedItemColor: ModernSaaSDashboardTheme.tertiaryText,
          selectedLabelStyle: ModernSaaSDashboardTheme.labelSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: ModernSaaSDashboardTheme.labelSmall,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.home),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.user),
              label: 'My CV',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.bot),
              label: 'AI Assistant',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.download),
              label: 'Downloads',
            ),
          ],
        ),
      ),
    );
  }

  int _getMobileNavIndex() {
    // Map sidebar index to mobile bottom nav index
    switch (widget.currentIndex) {
      case 0:
        return 0; // Dashboard
      case 1:
        return 1; // My CV
      case 6:
        return 2; // AI Assistant
      case 5:
        return 3; // Downloads
      default:
        return 0;
    }
  }

  void _handleMobileNavigation(int index) {
    // Map mobile bottom nav index to sidebar index
    int sidebarIndex;
    switch (index) {
      case 0:
        sidebarIndex = 0;
        break; // Dashboard
      case 1:
        sidebarIndex = 1;
        break; // My CV
      case 2:
        sidebarIndex = 6;
        break; // AI Assistant
      case 3:
        sidebarIndex = 5;
        break; // Downloads
      default:
        sidebarIndex = 0;
    }
    widget.onNavigationChanged?.call(sidebarIndex);
  }
}

// Enhanced content wrapper with proper spacing for the new sidebar
class ModernDashboardContent extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final bool showBackground;

  const ModernDashboardContent({
    super.key,
    required this.children,
    this.padding,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        return Container(
          color: showBackground ? ModernSaaSDashboardTheme.background : null,
          child: SingleChildScrollView(
            padding: padding ?? _getDefaultPadding(deviceType),
            child: _buildContent(context, deviceType),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return _buildMobileContent();
      case DeviceType.tablet:
        return _buildTabletContent();
      case DeviceType.desktop:
        return _buildDesktopContent(context);
    }
  }

  Widget _buildMobileContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((child) {
        return Padding(
          padding:
              const EdgeInsets.only(bottom: ModernSaaSDashboardTheme.spacingMd),
          child: child,
        );
      }).toList(),
    );
  }

  Widget _buildTabletContent() {
    final rows = <Widget>[];
    for (int i = 0; i < children.length; i += 2) {
      final rowChildren = <Widget>[];

      rowChildren.add(Expanded(child: children[i]));

      if (i + 1 < children.length) {
        rowChildren
            .add(const SizedBox(width: ModernSaaSDashboardTheme.spacingXl));
        rowChildren.add(Expanded(child: children[i + 1]));
      }

      rows.add(
        Padding(
          padding:
              const EdgeInsets.only(bottom: ModernSaaSDashboardTheme.spacingXl),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowChildren,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }

  Widget _buildDesktopContent(BuildContext context) {
    return Wrap(
      spacing: ModernSaaSDashboardTheme.spacingXl,
      runSpacing: ModernSaaSDashboardTheme.spacingXl,
      children: children.map((child) {
        return SizedBox(
          width: _calculateDesktopCardWidth(context),
          child: child,
        );
      }).toList(),
    );
  }

  EdgeInsets _getDefaultPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(ModernSaaSDashboardTheme.spacingMd);
      case DeviceType.tablet:
        return const EdgeInsets.all(ModernSaaSDashboardTheme.spacingXl);
      case DeviceType.desktop:
        return const EdgeInsets.all(ModernSaaSDashboardTheme.spacing2xl);
    }
  }

  double _calculateDesktopCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth -
        ModernSaaSDashboardTheme.sidebarWidth -
        (ModernSaaSDashboardTheme.spacing2xl * 2) -
        ModernSaaSDashboardTheme.spacingXl;
    return (availableWidth / 2).clamp(300.0, 500.0);
  }
}

// Quick action floating button for mobile
class MobileQuickActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String tooltip;

  const MobileQuickActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        if (!deviceType.isMobile) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: ModernSaaSDashboardTheme.accentPurple,
          foregroundColor: Colors.white,
          tooltip: tooltip,
          child: Icon(icon),
        );
      },
    );
  }
}
