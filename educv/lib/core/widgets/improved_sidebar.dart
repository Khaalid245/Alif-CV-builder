import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/premium_portfolio_colors.dart';

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
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with Logo and User Info
            _buildHeader(),
            
            // Main Navigation
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    // Quick Actions Section
                    _buildSection(
                      title: 'Quick Start',
                      items: [
                        NavigationItem(
                          icon: LucideIcons.home,
                          label: 'Dashboard',
                          description: 'Overview of your CV progress',
                          index: 0,
                        ),
                        NavigationItem(
                          icon: LucideIcons.edit3,
                          label: 'Build My CV',
                          description: 'Add and edit your information',
                          index: 2,
                          badge: 'Start Here',
                          badgeColor: PremiumPortfolioColors.success,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // CV Management Section
                    _buildSection(
                      title: 'My CV',
                      items: [
                        NavigationItem(
                          icon: LucideIcons.eye,
                          label: 'Preview CV',
                          description: 'See how your CV looks',
                          index: 3,
                        ),
                        NavigationItem(
                          icon: LucideIcons.download,
                          label: 'Download CVs',
                          description: 'Get your PDF files',
                          index: 4,
                        ),
                        NavigationItem(
                          icon: LucideIcons.brain,
                          label: 'AI Suggestions',
                          description: 'Improve with AI help',
                          index: 5,
                          badge: 'New',
                          badgeColor: PremiumPortfolioColors.accentPurple,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Tools Section
                    _buildSection(
                      title: 'Tools & Resources',
                      items: [
                        NavigationItem(
                          icon: LucideIcons.layout,
                          label: 'CV Templates',
                          description: 'Browse available designs',
                          index: 6,
                        ),
                        NavigationItem(
                          icon: LucideIcons.barChart3,
                          label: 'Analytics',
                          description: 'Track your CV performance',
                          index: 7,
                        ),
                        NavigationItem(
                          icon: LucideIcons.history,
                          label: 'Version History',
                          description: 'See previous versions',
                          index: 9,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Account Section
                    _buildSection(
                      title: 'Account',
                      items: [
                        NavigationItem(
                          icon: LucideIcons.bell,
                          label: 'Notifications',
                          description: 'Manage your alerts',
                          index: 8,
                        ),
                        NavigationItem(
                          icon: LucideIcons.settings,
                          label: 'Settings',
                          description: 'Account preferences',
                          index: 10,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Footer with Help
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PremiumPortfolioColors.accentPurple.withOpacity(0.05),
            PremiumPortfolioColors.accentBlue.withOpacity(0.05),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: PremiumPortfolioColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo and Brand
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      PremiumPortfolioColors.accentPurple,
                      PremiumPortfolioColors.accentBlue,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.fileText,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              if (!widget.isCollapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EduCV',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: PremiumPortfolioColors.primaryText,
                        ),
                      ),
                      Text(
                        'CV Builder',
                        style: TextStyle(
                          fontSize: 12,
                          color: PremiumPortfolioColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (widget.onToggleCollapse != null)
                IconButton(
                  onPressed: widget.onToggleCollapse,
                  icon: Icon(
                    widget.isCollapsed ? LucideIcons.chevronRight : LucideIcons.chevronLeft,
                    size: 16,
                    color: PremiumPortfolioColors.secondaryText,
                  ),
                ),
            ],
          ),
          
          if (!widget.isCollapsed) ...[
            const SizedBox(height: 16),
            
            // User Profile Card
            GestureDetector(
              onTap: widget.onProfileTap,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: PremiumPortfolioColors.borderLight,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: PremiumPortfolioColors.accentPurple,
                      child: Text(
                        _getInitials(widget.userName ?? ''),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.userName ?? 'User',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: PremiumPortfolioColors.primaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Student Account',
                            style: TextStyle(
                              fontSize: 12,
                              color: PremiumPortfolioColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronDown,
                      size: 16,
                      color: PremiumPortfolioColors.secondaryText,
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: PremiumPortfolioColors.secondaryText,
              letterSpacing: 0.5,
            ),
          ),
        ),
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
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive 
                ? PremiumPortfolioColors.accentPurple.withOpacity(0.1)
                : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive 
                  ? PremiumPortfolioColors.accentPurple.withOpacity(0.3)
                  : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isActive 
                      ? PremiumPortfolioColors.accentPurple
                      : PremiumPortfolioColors.borderLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    size: 18,
                    color: isActive 
                      ? Colors.white 
                      : PremiumPortfolioColors.secondaryText,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isActive 
                                  ? PremiumPortfolioColors.accentPurple
                                  : PremiumPortfolioColors.primaryText,
                              ),
                            ),
                          ),
                          if (item.badge != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: item.badgeColor ?? PremiumPortfolioColors.accentPurple,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.badge!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: PremiumPortfolioColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedNavItem(NavigationItem item) {
    final isActive = widget.currentIndex == item.index;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Tooltip(
        message: item.label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => widget.onNavigationChanged(item.index),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isActive 
                  ? PremiumPortfolioColors.accentPurple.withOpacity(0.1)
                  : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive 
                    ? PremiumPortfolioColors.accentPurple.withOpacity(0.3)
                    : Colors.transparent,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      item.icon,
                      size: 20,
                      color: isActive 
                        ? PremiumPortfolioColors.accentPurple
                        : PremiumPortfolioColors.secondaryText,
                    ),
                  ),
                  if (item.badge != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: item.badgeColor ?? PremiumPortfolioColors.accentPurple,
                          borderRadius: BorderRadius.circular(4),
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

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: PremiumPortfolioColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: widget.isCollapsed 
        ? Center(
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                LucideIcons.helpCircle,
                size: 20,
                color: PremiumPortfolioColors.secondaryText,
              ),
            ),
          )
        : Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      PremiumPortfolioColors.accentBlue.withOpacity(0.1),
                      PremiumPortfolioColors.accentPurple.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: PremiumPortfolioColors.accentBlue.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.helpCircle,
                      size: 16,
                      color: PremiumPortfolioColors.accentBlue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Need Help?',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: PremiumPortfolioColors.accentBlue,
                            ),
                          ),
                          Text(
                            'Get support and tips',
                            style: TextStyle(
                              fontSize: 10,
                              color: PremiumPortfolioColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  String _getInitials(String fullName) {
    if (fullName.isEmpty) return 'U';
    final names = fullName.trim().split(' ');
    if (names.length == 1) {
      return names[0][0].toUpperCase();
    }
    final firstInitial = names.first.isNotEmpty ? names.first[0].toUpperCase() : '';
    final lastInitial = names.last.isNotEmpty ? names.last[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final String description;
  final int index;
  final String? badge;
  final Color? badgeColor;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.description,
    required this.index,
    this.badge,
    this.badgeColor,
  });
}