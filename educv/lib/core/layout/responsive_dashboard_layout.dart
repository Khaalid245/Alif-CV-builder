import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/premium_portfolio_colors.dart';
import 'responsive_layout.dart';

class ResponsiveDashboardLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final int currentIndex;
  final Function(int)? onNavigationChanged;

  const ResponsiveDashboardLayout({
    super.key,
    required this.child,
    required this.title,
    this.actions,
    this.floatingActionButton,
    this.currentIndex = 0,
    this.onNavigationChanged,
  });

  @override
  State<ResponsiveDashboardLayout> createState() => _ResponsiveDashboardLayoutState();
}

class _ResponsiveDashboardLayoutState extends State<ResponsiveDashboardLayout> {
  bool _isSidebarCollapsed = false;

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
    return Scaffold(
      backgroundColor: PremiumPortfolioColors.background,
      body: widget.child,
      floatingActionButton: widget.floatingActionButton,
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      backgroundColor: PremiumPortfolioColors.background,
      body: Row(
        children: [
          _buildCollapsibleSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTabletTopBar(),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: PremiumPortfolioColors.background,
      body: Row(
        children: [
          _buildPermanentSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildDesktopTopBar(),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }



  Widget _buildTabletTopBar() {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: PremiumPortfolioColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _isSidebarCollapsed = !_isSidebarCollapsed;
                });
              },
              icon: const Icon(
                LucideIcons.menu,
                color: PremiumPortfolioColors.primaryText,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: PremiumPortfolioColors.primaryText,
              ),
            ),
            const Spacer(),
            if (widget.actions != null) ...widget.actions!,
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTopBar() {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: PremiumPortfolioColors.borderLight,
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
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: PremiumPortfolioColors.primaryText,
              ),
            ),
            const Spacer(),
            if (widget.actions != null) ...widget.actions!,
          ],
        ),
      ),
    );
  }



  Widget _buildCollapsibleSidebar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isSidebarCollapsed ? 80 : 280,
      child: DashboardSidebar(
        isCollapsed: _isSidebarCollapsed,
        currentIndex: widget.currentIndex,
        onNavigationChanged: widget.onNavigationChanged,
      ),
    );
  }

  Widget _buildPermanentSidebar() {
    return SizedBox(
      width: 280,
      child: DashboardSidebar(
        isCollapsed: false,
        currentIndex: widget.currentIndex,
        onNavigationChanged: widget.onNavigationChanged,
      ),
    );
  }
}

class DashboardSidebar extends StatelessWidget {
  final bool isCollapsed;
  final int currentIndex;
  final Function(int)? onNavigationChanged;

  const DashboardSidebar({
    super.key,
    required this.isCollapsed,
    required this.currentIndex,
    this.onNavigationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: PremiumPortfolioColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildSidebarHeader(),
          Expanded(
            child: _buildNavigationItems(),
          ),
          _buildSidebarFooter(),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 16 : 24,
        vertical: 16,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: PremiumPortfolioColors.accentPurple,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              LucideIcons.fileText,
              color: Colors.white,
              size: 18,
            ),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 12),
            const Text(
              'EduCV',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: PremiumPortfolioColors.primaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationItems() {
    final items = [
      _NavigationItem(
        icon: LucideIcons.home,
        label: 'Dashboard',
        index: 0,
      ),
      _NavigationItem(
        icon: LucideIcons.user,
        label: 'Profile',
        index: 1,
      ),
      _NavigationItem(
        icon: LucideIcons.fileText,
        label: 'Generate CV',
        index: 2,
      ),
      _NavigationItem(
        icon: LucideIcons.download,
        label: 'Downloads',
        index: 3,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = currentIndex == item.index;

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 8 : 16,
            vertical: 2,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onNavigationChanged?.call(item.index),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isCollapsed ? 16 : 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? PremiumPortfolioColors.accentPurple.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: 20,
                      color: isSelected
                          ? PremiumPortfolioColors.accentPurple
                          : PremiumPortfolioColors.secondaryText,
                    ),
                    if (!isCollapsed) ...[
                      const SizedBox(width: 12),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? PremiumPortfolioColors.accentPurple
                              : PremiumPortfolioColors.primaryText,
                        ),
                      ),
                    ],
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
      padding: EdgeInsets.all(isCollapsed ? 16 : 24),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: PremiumPortfolioColors.accentPurple,
            child: const Text(
              'U',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'User',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: PremiumPortfolioColors.primaryText,
                    ),
                  ),
                  Text(
                    'user@example.com',
                    style: TextStyle(
                      fontSize: 12,
                      color: PremiumPortfolioColors.secondaryText,
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
}

class _NavigationItem {
  final IconData icon;
  final String label;
  final int index;

  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}