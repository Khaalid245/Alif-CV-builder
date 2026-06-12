import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/modern_saas_theme.dart';
import '../layout/responsive_layout.dart';

class ModernSaaSSidebar extends StatefulWidget {
  final int currentIndex;
  final Function(int)? onNavigationChanged;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;
  final String? userName;
  final String? userEmail;
  final String? userAvatar;
  final VoidCallback? onProfileTap;
  final VoidCallback? onUpgradeTap;
  final bool showPremiumCard;

  const ModernSaaSSidebar({
    super.key,
    required this.currentIndex,
    this.onNavigationChanged,
    this.isCollapsed = false,
    this.onToggleCollapse,
    this.userName,
    this.userEmail,
    this.userAvatar,
    this.onProfileTap,
    this.onUpgradeTap,
    this.showPremiumCard = false,
  });

  @override
  State<ModernSaaSSidebar> createState() => _ModernSaaSSidebarState();
}

class _ModernSaaSSidebarState extends State<ModernSaaSSidebar>
    with TickerProviderStateMixin {
  late AnimationController _collapseController;
  late Animation<double> _collapseAnimation;
  late AnimationController _hoverController;

  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _collapseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _collapseAnimation = Tween<double>(
      begin: ModernSaaSDashboardTheme.sidebarWidth,
      end: ModernSaaSDashboardTheme.sidebarCollapsedWidth,
    ).animate(CurvedAnimation(
      parent: _collapseController,
      curve: Curves.easeInOut,
    ));

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    if (widget.isCollapsed) {
      _collapseController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ModernSaaSSidebar oldWidget) {
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
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        if (deviceType.isMobile) {
          return const SizedBox.shrink(); // Hidden on mobile
        }

        return AnimatedBuilder(
          animation: _collapseAnimation,
          builder: (context, child) {
            final isCollapsed = _collapseController.value > 0.5;

            return Container(
              width: _collapseAnimation.value,
              decoration: const BoxDecoration(
                color: ModernSaaSDashboardTheme.surfaceBackground,
                border: Border(
                  right: BorderSide(
                    color: ModernSaaSDashboardTheme.borderLight,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  _buildSidebarHeader(isCollapsed),
                  Expanded(
                    child: _buildNavigationSection(isCollapsed),
                  ),
                  _buildUserProfile(isCollapsed),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSidebarHeader(bool isCollapsed) {
    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 16 : 24,
        vertical: 16,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  ModernSaaSDashboardTheme.accentPurple,
                  ModernSaaSDashboardTheme.accentPurpleLight,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: ModernSaaSDashboardTheme.accentPurple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              LucideIcons.graduationCap,
              color: Colors.white,
              size: 20,
            ),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'EduCV',
                    style: ModernSaaSDashboardTheme.headlineMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'CV Builder',
                    style: ModernSaaSDashboardTheme.bodySmall.copyWith(
                      color: ModernSaaSDashboardTheme.tertiaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationSection(bool isCollapsed) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 8 : 16,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCollapsed) _buildSectionLabel('Main'),
          ..._getMainNavigationItems().asMap().entries.map((entry) {
            return _buildSidebarItem(
              entry.value,
              entry.key,
              isCollapsed,
            );
          }),
          if (!isCollapsed) ...[
            const SizedBox(height: 24),
            _buildSectionLabel('CV Builder'),
          ] else ...[
            const SizedBox(height: 16),
            _buildSectionDivider(isCollapsed),
          ],
          ..._getCVBuilderItems().asMap().entries.map((entry) {
            final adjustedIndex = entry.key + _getMainNavigationItems().length;
            return _buildSidebarItem(
              entry.value,
              adjustedIndex,
              isCollapsed,
            );
          }),
          if (!isCollapsed) ...[
            const SizedBox(height: 24),
            _buildSectionLabel('Tools'),
          ] else ...[
            const SizedBox(height: 16),
            _buildSectionDivider(isCollapsed),
          ],
          ..._getToolsItems().asMap().entries.map((entry) {
            final adjustedIndex = entry.key +
                _getMainNavigationItems().length +
                _getCVBuilderItems().length;
            return _buildSidebarItem(
              entry.value,
              adjustedIndex,
              isCollapsed,
            );
          }),
          if (!isCollapsed) ...[
            const SizedBox(height: 24),
            _buildSectionLabel('Account'),
          ] else ...[
            const SizedBox(height: 16),
            _buildSectionDivider(isCollapsed),
          ],
          ..._getAccountItems().asMap().entries.map((entry) {
            final adjustedIndex = entry.key +
                _getMainNavigationItems().length +
                _getCVBuilderItems().length +
                _getToolsItems().length;
            return _buildSidebarItem(
              entry.value,
              adjustedIndex,
              isCollapsed,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16,
        bottom: 8,
        top: 8,
      ),
      child: Text(
        label.toUpperCase(),
        style: ModernSaaSDashboardTheme.labelSmall.copyWith(
          color: ModernSaaSDashboardTheme.mutedText,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSectionDivider(bool isCollapsed) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 16 : 24,
        vertical: 4,
      ),
      height: 1,
      decoration: BoxDecoration(
        color: ModernSaaSDashboardTheme.borderLight,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildSidebarItem(SidebarItemData item, int index, bool isCollapsed) {
    final isSelected = widget.currentIndex == index;
    final isHovered = _hoveredIndex == index;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 8 : 8,
        vertical: 2,
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredIndex = index),
        onExit: (_) => setState(() => _hoveredIndex = null),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => widget.onNavigationChanged?.call(index),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: isCollapsed ? 16 : 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ModernSaaSDashboardTheme.accentPurple.withOpacity(0.08)
                      : isHovered
                          ? ModernSaaSDashboardTheme.hover
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
                    Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      child: Icon(
                        item.icon,
                        size: 20,
                        color: isSelected
                            ? ModernSaaSDashboardTheme.accentPurple
                            : isHovered
                                ? ModernSaaSDashboardTheme.primaryText
                                : ModernSaaSDashboardTheme.tertiaryText,
                      ),
                    ),
                    if (!isCollapsed) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.label,
                          style: ModernSaaSDashboardTheme.bodyMedium.copyWith(
                            color: isSelected
                                ? ModernSaaSDashboardTheme.accentPurple
                                : isHovered
                                    ? ModernSaaSDashboardTheme.primaryText
                                    : ModernSaaSDashboardTheme.primaryText,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (item.badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: item.badgeColor ??
                                ModernSaaSDashboardTheme.accentPurple,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            item.badge!,
                            style: ModernSaaSDashboardTheme.labelSmall.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile(bool isCollapsed) {
    return Container(
      padding: EdgeInsets.all(isCollapsed ? 16 : 20),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: ModernSaaSDashboardTheme.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onProfileTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        ModernSaaSDashboardTheme.accentPurple,
                        ModernSaaSDashboardTheme.accentPurpleLight,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: ModernSaaSDashboardTheme.accentPurple
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: widget.userAvatar != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            widget.userAvatar!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Center(
                          child: Text(
                            _getInitials(widget.userName ?? 'User'),
                            style:
                                ModernSaaSDashboardTheme.labelMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.userName ?? 'User',
                          style: ModernSaaSDashboardTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.userEmail != null)
                          Text(
                            widget.userEmail!,
                            style: ModernSaaSDashboardTheme.bodySmall.copyWith(
                              color: ModernSaaSDashboardTheme.tertiaryText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    LucideIcons.moreHorizontal,
                    size: 16,
                    color: ModernSaaSDashboardTheme.tertiaryText,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<SidebarItemData> _getMainNavigationItems() {
    return [
      SidebarItemData(
        icon: LucideIcons.home,
        label: 'Dashboard',
      ),
      SidebarItemData(
        icon: LucideIcons.user,
        label: 'My CV',
      ),
    ];
  }

  List<SidebarItemData> _getCVBuilderItems() {
    return [
      SidebarItemData(
        icon: LucideIcons.fileText,
        label: 'CV Form',
      ),
      SidebarItemData(
        icon: LucideIcons.eye,
        label: 'Preview',
      ),
      SidebarItemData(
        icon: LucideIcons.download,
        label: 'Downloads',
      ),
      SidebarItemData(
        icon: LucideIcons.brain,
        label: 'CV Intelligence',
      ),
    ];
  }

  List<SidebarItemData> _getToolsItems() {
    return [
      SidebarItemData(
        icon: LucideIcons.layout,
        label: 'Templates',
      ),
      SidebarItemData(
        icon: LucideIcons.barChart3,
        label: 'Analytics',
      ),
      SidebarItemData(
        icon: LucideIcons.bell,
        label: 'Notifications',
      ),
      SidebarItemData(
        icon: LucideIcons.history,
        label: 'Version History',
      ),
    ];
  }

  List<SidebarItemData> _getAccountItems() {
    return [
      SidebarItemData(
        icon: LucideIcons.settings,
        label: 'Account Settings',
      ),
      SidebarItemData(
        icon: LucideIcons.key,
        label: 'Change Password',
      ),
    ];
  }

  String _getInitials(String fullName) {
    if (fullName.isEmpty) return 'U';

    final names = fullName.trim().split(' ');
    if (names.length == 1) {
      return names[0][0].toUpperCase();
    }

    final firstInitial =
        names.first.isNotEmpty ? names.first[0].toUpperCase() : '';
    final lastInitial =
        names.last.isNotEmpty ? names.last[0].toUpperCase() : '';

    return '$firstInitial$lastInitial';
  }
}

class SidebarItemData {
  final IconData icon;
  final String label;
  final String? badge;
  final Color? badgeColor;

  const SidebarItemData({
    required this.icon,
    required this.label,
    this.badge,
    this.badgeColor,
  });
}
