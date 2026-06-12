import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/premium_saas_theme.dart';

class ImprovedSidebar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onNavigationChanged;
  final String? userName;
  final String? userEmail;
  final VoidCallback? onProfileTap;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;

  const ImprovedSidebar({
    super.key,
    required this.currentIndex,
    required this.onNavigationChanged,
    this.userName,
    this.userEmail,
    this.onProfileTap,
    this.isCollapsed = false,
    this.onToggleCollapse,
  });

  @override
  State<ImprovedSidebar> createState() => _ImprovedSidebarState();
}

class _ImprovedSidebarState extends State<ImprovedSidebar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: widget.isCollapsed ? 80 : 280,
        decoration: BoxDecoration(
          color: PremiumSaaSTheme.lightSurface,
          border: const Border(
            right: BorderSide(
              color: PremiumSaaSTheme.lightBorder,
              width: 1,
            ),
          ),
          boxShadow: PremiumSaaSTheme.shadowSoft,
        ),
        child: Column(
          children: [
            // Header with Logo
            _buildHeader(),

            // Main Navigation
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Start Section
                    _buildSection(
                      title: 'QUICK START',
                      items: [
                        NavigationItem(
                          icon: LucideIcons.layoutDashboard,
                          label: 'Dashboard',
                          index: 0,
                        ),
                        NavigationItem(
                          icon: LucideIcons.fileEdit,
                          label: 'Build CV',
                          index: 2,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // CV Management Section
                    _buildSection(
                      title: 'MY CV',
                      items: [
                        NavigationItem(
                          icon: LucideIcons.eye,
                          label: 'Preview CV',
                          index: 3,
                        ),
                        NavigationItem(
                          icon: LucideIcons.download,
                          label: 'Downloads',
                          index: 4,
                        ),
                        NavigationItem(
                          icon: LucideIcons.sparkles,
                          label: 'AI Suggestions',
                          index: 5,
                          badge: 'New',
                          badgeColor: PremiumSaaSTheme.accentGreen,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Tools Section
                    _buildSection(
                      title: 'TOOLS & RESOURCES',
                      items: [
                        NavigationItem(
                          icon: LucideIcons.layout,
                          label: 'Templates',
                          index: 6,
                        ),
                        NavigationItem(
                          icon: LucideIcons.barChart2,
                          label: 'Analytics',
                          index: 7,
                        ),
                        NavigationItem(
                          icon: LucideIcons.history,
                          label: 'Version History',
                          index: 9,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // User Profile Footer
            _buildUserProfile(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  PremiumSaaSTheme.accentGreen,
                  Color(0xFF34D399), // lighter emerald
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: PremiumSaaSTheme.accentGreen.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              LucideIcons.leaf,
              color: Colors.white,
              size: 18,
            ),
          ),
          if (!widget.isCollapsed) ...[
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'EduCV',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: PremiumSaaSTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
          if (widget.onToggleCollapse != null)
            IconButton(
              onPressed: widget.onToggleCollapse,
              icon: Icon(
                widget.isCollapsed
                    ? LucideIcons.panelLeftOpen
                    : LucideIcons.panelLeftClose,
                size: 18,
                color: PremiumSaaSTheme.textTertiary,
              ),
              tooltip:
                  widget.isCollapsed ? 'Expand Sidebar' : 'Collapse Sidebar',
              splashRadius: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<NavigationItem> items,
  }) {
    if (widget.isCollapsed) {
      return Column(
        children: items.map((item) => _buildCollapsedNavItem(item)).toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: PremiumSaaSTheme.textTertiary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 4),
        ...items.map((item) => _buildNavItem(item)),
      ],
    );
  }

  Widget _buildNavItem(NavigationItem item) {
    final isActive = widget.currentIndex == item.index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onNavigationChanged(item.index),
          borderRadius: BorderRadius.circular(8),
          hoverColor: PremiumSaaSTheme.lightSurfaceVariant,
          splashColor: PremiumSaaSTheme.accentGreen.withValues(alpha: 0.1),
          highlightColor: PremiumSaaSTheme.accentGreen.withValues(alpha: 0.05),
          child: Stack(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isActive
                      ? PremiumSaaSTheme.accentGreen.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: 20,
                      color: isActive
                          ? PremiumSaaSTheme.accentGreen
                          : PremiumSaaSTheme.textSecondary,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w500,
                          color: isActive
                              ? PremiumSaaSTheme.textPrimary
                              : PremiumSaaSTheme.textSecondary,
                        ),
                      ),
                    ),
                    if (item.badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color:
                              item.badgeColor ?? PremiumSaaSTheme.accentGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.badge!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (isActive)
                Positioned(
                  left: 0,
                  top: 8,
                  bottom: 8,
                  child: Container(
                    width: 3,
                    decoration: const BoxDecoration(
                      color: PremiumSaaSTheme.accentGreen,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedNavItem(NavigationItem item) {
    final isActive = widget.currentIndex == item.index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Tooltip(
        message: item.label,
        preferBelow: false,
        verticalOffset: 24,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => widget.onNavigationChanged(item.index),
            borderRadius: BorderRadius.circular(10),
            hoverColor: PremiumSaaSTheme.lightSurfaceVariant,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isActive
                    ? PremiumSaaSTheme.accentGreen.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      item.icon,
                      size: 20,
                      color: isActive
                          ? PremiumSaaSTheme.accentGreen
                          : PremiumSaaSTheme.textSecondary,
                    ),
                  ),
                  if (item.badge != null)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color:
                              item.badgeColor ?? PremiumSaaSTheme.accentGreen,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  if (isActive)
                    Positioned(
                      left: 0,
                      top: 10,
                      bottom: 10,
                      child: Container(
                        width: 3,
                        decoration: const BoxDecoration(
                          color: PremiumSaaSTheme.accentGreen,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(4),
                            bottomRight: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    final name = widget.userName ?? 'Guest User';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    final email = widget.userEmail ?? 'Not signed in';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: PremiumSaaSTheme.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: widget.isCollapsed
          ? Center(
              child: _buildAvatar(initials),
            )
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onProfileTap,
                borderRadius: BorderRadius.circular(8),
                hoverColor: PremiumSaaSTheme.lightSurfaceVariant,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      _buildAvatar(initials),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: PremiumSaaSTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: const TextStyle(
                                fontSize: 12,
                                color: PremiumSaaSTheme.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        LucideIcons.settings,
                        size: 16,
                        color: PremiumSaaSTheme.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildAvatar(String initials) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: PremiumSaaSTheme.lightSurfaceVariant,
        shape: BoxShape.circle,
        border: Border.all(
          color: PremiumSaaSTheme.lightBorder,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: PremiumSaaSTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final int index;
  final String? badge;
  final Color? badgeColor;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.index,
    this.badge,
    this.badgeColor,
  });
}
