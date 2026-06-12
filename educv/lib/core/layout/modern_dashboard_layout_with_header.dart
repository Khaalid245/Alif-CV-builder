import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/modern_saas_theme.dart';
import 'responsive_layout.dart';
import '../widgets/responsive_sidebar_wrapper.dart';
import '../widgets/modern_dashboard_header.dart';

class ModernDashboardLayoutWithHeader extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final Function(int)? onNavigationChanged;
  final String? userName;
  final String? userEmail;
  final String? userAvatar;
  final VoidCallback? onProfileTap;
  final VoidCallback? onUpgradeTap;
  final VoidCallback? onNotificationTap;
  final Function(String)? onSearch;
  final bool showPremiumCard;
  final bool showSearch;
  final int notificationCount;
  final List<Widget>? headerActions;

  const ModernDashboardLayoutWithHeader({
    super.key,
    required this.child,
    this.currentIndex = 0,
    this.onNavigationChanged,
    this.userName,
    this.userEmail,
    this.userAvatar,
    this.onProfileTap,
    this.onUpgradeTap,
    this.onNotificationTap,
    this.onSearch,
    this.showPremiumCard = true,
    this.showSearch = true,
    this.notificationCount = 0,
    this.headerActions,
  });

  @override
  State<ModernDashboardLayoutWithHeader> createState() => _ModernDashboardLayoutWithHeaderState();
}

class _ModernDashboardLayoutWithHeaderState extends State<ModernDashboardLayoutWithHeader> {
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
              // Modern header
              ModernDashboardHeader(
                userName: widget.userName,
                userEmail: widget.userEmail,
                userAvatar: widget.userAvatar,
                onProfileTap: widget.onProfileTap,
                onNotificationTap: widget.onNotificationTap,
                onMenuTap: deviceType.isMobile || deviceType.isTablet
                    ? () => _sidebarKey.currentState?.toggleTabletSidebar()
                    : null,
                onSearch: widget.onSearch,
                notificationCount: widget.notificationCount,
                showSearch: widget.showSearch && deviceType.isDesktop,
                additionalActions: widget.headerActions,
              ),
              
              // Main content
              Expanded(
                child: Container(
                  color: ModernSaaSDashboardTheme.background,
                  child: widget.child,
                ),
              ),
              
              // Bottom navigation for mobile
              if (deviceType.isMobile)
                _buildMobileBottomNavigation(),
            ],
          ),
        );
      },
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
      case 0: return 0; // Dashboard
      case 1: return 1; // My CV
      case 6: return 2; // AI Assistant
      case 5: return 3; // Downloads
      default: return 0;
    }
  }

  void _handleMobileNavigation(int index) {
    // Map mobile bottom nav index to sidebar index
    int sidebarIndex;
    switch (index) {
      case 0: sidebarIndex = 0; break; // Dashboard
      case 1: sidebarIndex = 1; break; // My CV
      case 2: sidebarIndex = 6; break; // AI Assistant
      case 3: sidebarIndex = 5; break; // Downloads
      default: sidebarIndex = 0;
    }
    widget.onNavigationChanged?.call(sidebarIndex);
  }
}

// Enhanced content wrapper that works with the new header
class ModernDashboardContentWithHeader extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final bool showBackground;
  final String? sectionTitle;
  final String? sectionSubtitle;
  final List<Widget>? sectionActions;

  const ModernDashboardContentWithHeader({
    super.key,
    required this.children,
    this.padding,
    this.showBackground = true,
    this.sectionTitle,
    this.sectionSubtitle,
    this.sectionActions,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        return Container(
          color: showBackground ? ModernSaaSDashboardTheme.background : null,
          child: Column(
            children: [
              // Optional section header
              if (sectionTitle != null)
                DashboardSectionHeader(
                  title: sectionTitle!,
                  subtitle: sectionSubtitle,
                  actions: sectionActions,
                ),
              
              // Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: padding ?? _getDefaultPadding(deviceType),
                  child: _buildContent(context, deviceType),
                ),
              ),
            ],
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
          padding: const EdgeInsets.only(bottom: ModernSaaSDashboardTheme.spacingMd),
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
        rowChildren.add(const SizedBox(width: ModernSaaSDashboardTheme.spacingXl));
        rowChildren.add(Expanded(child: children[i + 1]));
      }
      
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: ModernSaaSDashboardTheme.spacingXl),
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

// Floating search widget for mobile
class MobileSearchWidget extends StatefulWidget {
  final Function(String)? onSearch;
  final VoidCallback? onClose;

  const MobileSearchWidget({
    super.key,
    this.onSearch,
    this.onClose,
  });

  @override
  State<MobileSearchWidget> createState() => _MobileSearchWidgetState();
}

class _MobileSearchWidgetState extends State<MobileSearchWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    
    // Auto-focus when opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: ModernSaaSDashboardTheme.surfaceBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: ModernSaaSDashboardTheme.elevatedCardShadow,
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.search,
                  color: ModernSaaSDashboardTheme.accentPurple,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    onChanged: widget.onSearch,
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: ModernSaaSDashboardTheme.mutedText,
                      ),
                    ),
                    style: ModernSaaSDashboardTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(
                    LucideIcons.x,
                    color: ModernSaaSDashboardTheme.tertiaryText,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Quick action button for mobile FAB
class MobileQuickActionFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String tooltip;

  const MobileQuickActionFAB({
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
          elevation: 8,
          child: Icon(icon),
        );
      },
    );
  }
}