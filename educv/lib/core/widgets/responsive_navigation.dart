import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/modern_saas_theme.dart';
import 'responsive_layout.dart';

class ResponsiveNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onNavigationChanged;
  final String? userName;
  final String? userEmail;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogout;

  const ResponsiveNavigation({
    super.key,
    required this.currentIndex,
    this.onNavigationChanged,
    this.userName,
    this.userEmail,
    this.onProfileTap,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        switch (deviceType) {
          case DeviceType.mobile:
            return _buildMobileNavigation();
          case DeviceType.tablet:
          case DeviceType.desktop:
            return _buildSidebarNavigation(deviceType);
        }
      },
    );
  }

  Widget _buildMobileNavigation() {
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
          currentIndex: currentIndex,
          onTap: onNavigationChanged,
          type: BottomNavigationBarType.fixed,
          backgroundColor: ModernSaaSDashboardTheme.surfaceBackground,
          selectedItemColor: ModernSaaSDashboardTheme.accentPurple,
          unselectedItemColor: ModernSaaSDashboardTheme.tertiaryText,
          selectedLabelStyle: ModernSaaSDashboardTheme.labelSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: ModernSaaSDashboardTheme.labelSmall,
          elevation: 0,
          items: _getNavigationItems(),
        ),
      ),
    );
  }

  Widget _buildSidebarNavigation(DeviceType deviceType) {
    return Container(
      width: ModernSaaSDashboardTheme.sidebarWidth,
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
          _buildSidebarHeader(),
          Expanded(
            child: _buildSidebarItems(),
          ),
          _buildSidebarFooter(),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      height: ModernSaaSDashboardTheme.appBarHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: ModernSaaSDashboardTheme.spacingXl,
        vertical: ModernSaaSDashboardTheme.spacingMd,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: ModernSaaSDashboardTheme.accentPurple,
              borderRadius:
                  BorderRadius.circular(ModernSaaSDashboardTheme.radiusMd),
            ),
            child: const Icon(
              LucideIcons.fileText,
              color: Colors.white,
              size: ModernSaaSDashboardTheme.iconMd,
            ),
          ),
          const SizedBox(width: ModernSaaSDashboardTheme.spacingSm),
          Text(
            'EduCV',
            style: ModernSaaSDashboardTheme.headlineMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItems() {
    final items = _getSidebarItems();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        vertical: ModernSaaSDashboardTheme.spacingMd,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = currentIndex == item.index;

        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: ModernSaaSDashboardTheme.spacingMd,
            vertical: 2,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onNavigationChanged?.call(item.index),
              borderRadius:
                  BorderRadius.circular(ModernSaaSDashboardTheme.radiusMd),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ModernSaaSDashboardTheme.spacingMd,
                  vertical: ModernSaaSDashboardTheme.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ModernSaaSDashboardTheme.accentPurple.withOpacity(0.08)
                      : Colors.transparent,
                  borderRadius:
                      BorderRadius.circular(ModernSaaSDashboardTheme.radiusMd),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: ModernSaaSDashboardTheme.iconMd,
                      color: isSelected
                          ? ModernSaaSDashboardTheme.accentPurple
                          : ModernSaaSDashboardTheme.tertiaryText,
                    ),
                    const SizedBox(width: ModernSaaSDashboardTheme.spacingSm),
                    Text(
                      item.label,
                      style: ModernSaaSDashboardTheme.bodyMedium.copyWith(
                        color: isSelected
                            ? ModernSaaSDashboardTheme.accentPurple
                            : ModernSaaSDashboardTheme.primaryText,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSidebarFooter() {
    return Container(
      padding: const EdgeInsets.all(ModernSaaSDashboardTheme.spacingXl),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onProfileTap,
          borderRadius:
              BorderRadius.circular(ModernSaaSDashboardTheme.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(ModernSaaSDashboardTheme.spacingSm),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: ModernSaaSDashboardTheme.accentPurple,
                  child: Text(
                    _getInitials(userName ?? 'User'),
                    style: ModernSaaSDashboardTheme.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: ModernSaaSDashboardTheme.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userName ?? 'User',
                        style: ModernSaaSDashboardTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (userEmail != null)
                        Text(
                          userEmail!,
                          style: ModernSaaSDashboardTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.moreHorizontal,
                  size: ModernSaaSDashboardTheme.iconSm,
                  color: ModernSaaSDashboardTheme.tertiaryText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _getNavigationItems() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(LucideIcons.home),
        activeIcon: Icon(LucideIcons.home),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(LucideIcons.user),
        activeIcon: Icon(LucideIcons.user),
        label: 'Profile',
      ),
      BottomNavigationBarItem(
        icon: Icon(LucideIcons.fileText),
        activeIcon: Icon(LucideIcons.fileText),
        label: 'Generate',
      ),
      BottomNavigationBarItem(
        icon: Icon(LucideIcons.download),
        activeIcon: Icon(LucideIcons.download),
        label: 'Downloads',
      ),
    ];
  }

  List<_SidebarItem> _getSidebarItems() {
    return const [
      _SidebarItem(
        icon: LucideIcons.home,
        label: 'Dashboard',
        index: 0,
      ),
      _SidebarItem(
        icon: LucideIcons.user,
        label: 'CV Profile',
        index: 1,
      ),
      _SidebarItem(
        icon: LucideIcons.fileText,
        label: 'Generate CV',
        index: 2,
      ),
      _SidebarItem(
        icon: LucideIcons.download,
        label: 'Downloads',
        index: 3,
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

class _SidebarItem {
  final IconData icon;
  final String label;
  final int index;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}

class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onMenuPressed;

  const ResponsiveAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        if (deviceType.isMobile) {
          return AppBar(
            title: Text(
              title,
              style: ModernSaaSDashboardTheme.headlineMedium,
            ),
            backgroundColor: ModernSaaSDashboardTheme.surfaceBackground,
            elevation: 0,
            centerTitle: false,
            leading: showBackButton
                ? IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      LucideIcons.arrowLeft,
                      color: ModernSaaSDashboardTheme.primaryText,
                    ),
                  )
                : null,
            actions: actions,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                color: ModernSaaSDashboardTheme.borderLight,
              ),
            ),
          );
        }

        // For tablet and desktop, return empty container as they use sidebar
        return Container(
          height: ModernSaaSDashboardTheme.appBarHeight,
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
            padding: const EdgeInsets.symmetric(
              horizontal: ModernSaaSDashboardTheme.spacing2xl,
            ),
            child: Row(
              children: [
                if (deviceType.isTablet && onMenuPressed != null)
                  IconButton(
                    onPressed: onMenuPressed,
                    icon: const Icon(
                      LucideIcons.menu,
                      color: ModernSaaSDashboardTheme.primaryText,
                    ),
                  ),
                if (deviceType.isTablet && onMenuPressed != null)
                  const SizedBox(width: ModernSaaSDashboardTheme.spacingMd),
                Text(
                  title,
                  style: deviceType.isDesktop
                      ? ModernSaaSDashboardTheme.displaySmall
                      : ModernSaaSDashboardTheme.headlineLarge,
                ),
                const Spacer(),
                if (actions != null) ...actions!,
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(ModernSaaSDashboardTheme.appBarHeight);
}
