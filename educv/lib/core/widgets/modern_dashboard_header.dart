import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../theme/modern_saas_theme.dart';
import 'responsive_layout.dart';

class ModernDashboardHeader extends StatefulWidget {
  final String? userName;
  final String? userEmail;
  final String? userAvatar;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onMenuTap;
  final Function(String)? onSearch;
  final int notificationCount;
  final bool showSearch;
  final List<Widget>? additionalActions;

  const ModernDashboardHeader({
    super.key,
    this.userName,
    this.userEmail,
    this.userAvatar,
    this.onProfileTap,
    this.onNotificationTap,
    this.onMenuTap,
    this.onSearch,
    this.notificationCount = 0,
    this.showSearch = true,
    this.additionalActions,
  });

  @override
  State<ModernDashboardHeader> createState() => _ModernDashboardHeaderState();
}

class _ModernDashboardHeaderState extends State<ModernDashboardHeader> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        switch (deviceType) {
          case DeviceType.mobile:
            return _buildMobileHeader();
          case DeviceType.tablet:
            return _buildTabletHeader();
          case DeviceType.desktop:
            return _buildDesktopHeader();
        }
      },
    );
  }

  Widget _buildMobileHeader() {
    return Container(
      height: 64,
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Menu button
              IconButton(
                onPressed: widget.onMenuTap,
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
              
              const SizedBox(width: 12),
              
              // Greeting and date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getGreeting(),
                      style: ModernSaaSDashboardTheme.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _getFormattedDate(),
                      style: ModernSaaSDashboardTheme.bodySmall.copyWith(
                        color: ModernSaaSDashboardTheme.tertiaryText,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Notification button
              _buildNotificationButton(compact: true),
              
              const SizedBox(width: 8),
              
              // User avatar
              _buildUserAvatar(size: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletHeader() {
    return Container(
      height: 80,
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
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            // Menu button
            IconButton(
              onPressed: widget.onMenuTap,
              icon: const Icon(
                LucideIcons.menu,
                color: ModernSaaSDashboardTheme.primaryText,
              ),
              style: IconButton.styleFrom(
                backgroundColor: ModernSaaSDashboardTheme.hover,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            
            const SizedBox(width: 20),
            
            // Greeting and date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getGreeting(),
                    style: ModernSaaSDashboardTheme.headlineLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getFormattedDate(),
                    style: ModernSaaSDashboardTheme.bodyMedium.copyWith(
                      color: ModernSaaSDashboardTheme.tertiaryText,
                    ),
                  ),
                ],
              ),
            ),
            
            // Actions
            if (widget.additionalActions != null) ...widget.additionalActions!,
            
            // Notification button
            _buildNotificationButton(),
            
            const SizedBox(width: 12),
            
            // User avatar
            _buildUserAvatar(size: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopHeader() {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: ModernSaaSDashboardTheme.surfaceBackground,
        border: const Border(
          bottom: BorderSide(
            color: ModernSaaSDashboardTheme.borderLight,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          children: [
            // Greeting and date section
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getGreeting(),
                    style: ModernSaaSDashboardTheme.displaySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.calendar,
                        size: 16,
                        color: ModernSaaSDashboardTheme.tertiaryText,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getFormattedDate(),
                        style: ModernSaaSDashboardTheme.bodyMedium.copyWith(
                          color: ModernSaaSDashboardTheme.tertiaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Search bar (desktop only)
            if (widget.showSearch)
              Expanded(
                flex: 3,
                child: _buildSearchBar(),
              ),
            
            const SizedBox(width: 24),
            
            // Actions section
            Row(
              children: [
                if (widget.additionalActions != null) ...widget.additionalActions!,
                
                // Notification button
                _buildNotificationButton(),
                
                const SizedBox(width: 16),
                
                // User profile section
                _buildUserProfileSection(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isSearchFocused 
              ? ModernSaaSDashboardTheme.surfaceBackground
              : ModernSaaSDashboardTheme.hover,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isSearchFocused
                ? ModernSaaSDashboardTheme.accentPurple
                : ModernSaaSDashboardTheme.borderLight,
            width: _isSearchFocused ? 2 : 1,
          ),
          boxShadow: _isSearchFocused
              ? [
                  BoxShadow(
                    color: ModernSaaSDashboardTheme.accentPurple.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: widget.onSearch,
          decoration: InputDecoration(
            hintText: 'Search dashboard...',
            hintStyle: ModernSaaSDashboardTheme.bodyMedium.copyWith(
              color: ModernSaaSDashboardTheme.mutedText,
            ),
            prefixIcon: Icon(
              LucideIcons.search,
              size: 20,
              color: _isSearchFocused
                  ? ModernSaaSDashboardTheme.accentPurple
                  : ModernSaaSDashboardTheme.tertiaryText,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      widget.onSearch?.call('');
                    },
                    icon: const Icon(
                      LucideIcons.x,
                      size: 16,
                      color: ModernSaaSDashboardTheme.tertiaryText,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: ModernSaaSDashboardTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildNotificationButton({bool compact = false}) {
    return Stack(
      children: [
        IconButton(
          onPressed: widget.onNotificationTap,
          icon: Icon(
            LucideIcons.bell,
            size: compact ? 20 : 22,
            color: ModernSaaSDashboardTheme.tertiaryText,
          ),
          style: IconButton.styleFrom(
            backgroundColor: ModernSaaSDashboardTheme.hover,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(compact ? 8 : 10),
            ),
            padding: EdgeInsets.all(compact ? 8 : 10),
          ),
        ),
        if (widget.notificationCount > 0)
          Positioned(
            right: compact ? 6 : 8,
            top: compact ? 6 : 8,
            child: Container(
              min: 16,
              height: 16,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: ModernSaaSDashboardTheme.error,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: ModernSaaSDashboardTheme.surfaceBackground,
                    blurRadius: 2,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.notificationCount > 99 ? '99+' : '${widget.notificationCount}',
                  style: ModernSaaSDashboardTheme.labelSmall.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUserAvatar({required double size}) {
    return GestureDetector(
      onTap: widget.onProfileTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              ModernSaaSDashboardTheme.accentPurple,
              ModernSaaSDashboardTheme.accentPurpleLight,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(size * 0.25),
          boxShadow: [
            BoxShadow(
              color: ModernSaaSDashboardTheme.accentPurple.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: widget.userAvatar != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(size * 0.25),
                child: Image.network(
                  widget.userAvatar!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(size),
                ),
              )
            : _buildAvatarFallback(size),
      ),
    );
  }

  Widget _buildAvatarFallback(double size) {
    return Center(
      child: Text(
        _getInitials(widget.userName ?? 'User'),
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildUserProfileSection() {
    return GestureDetector(
      onTap: widget.onProfileTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: ModernSaaSDashboardTheme.hover,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ModernSaaSDashboardTheme.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildUserAvatar(size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.userName ?? 'User',
                  style: ModernSaaSDashboardTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.userEmail != null)
                  Text(
                    widget.userEmail!,
                    style: ModernSaaSDashboardTheme.bodySmall.copyWith(
                      color: ModernSaaSDashboardTheme.tertiaryText,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(
              LucideIcons.chevronDown,
              size: 16,
              color: ModernSaaSDashboardTheme.tertiaryText,
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    final name = widget.userName?.split(' ').first ?? '';
    
    if (hour < 12) {
      return 'Good morning${name.isNotEmpty ? ', $name' : ''}';
    } else if (hour < 17) {
      return 'Good afternoon${name.isNotEmpty ? ', $name' : ''}';
    } else {
      return 'Good evening${name.isNotEmpty ? ', $name' : ''}';
    }
  }

  String _getFormattedDate() {
    return DateFormat('EEEE, MMMM d, y').format(DateTime.now());
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

// Specialized header for different dashboard sections
class DashboardSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;

  const DashboardSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: deviceType.isMobile ? 16 : 24,
            vertical: deviceType.isMobile ? 12 : 16,
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: deviceType.isMobile
                          ? ModernSaaSDashboardTheme.headlineSmall
                          : ModernSaaSDashboardTheme.headlineLarge,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: ModernSaaSDashboardTheme.bodyMedium.copyWith(
                          color: ModernSaaSDashboardTheme.tertiaryText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
        );
      },
    );
  }
}

// Quick stats header for dashboard overview
class DashboardStatsHeader extends StatelessWidget {
  final List<DashboardStat> stats;

  const DashboardStatsHeader({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        if (deviceType.isMobile) {
          return _buildMobileStats();
        }
        return _buildDesktopStats();
      },
    );
  }

  Widget _buildMobileStats() {
    return Container(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stats.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) => _buildStatCard(stats[index], compact: true),
      ),
    );
  }

  Widget _buildDesktopStats() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        children: stats.map((stat) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _buildStatCard(stat),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatCard(DashboardStat stat, {bool compact = false}) {
    return Container(
      width: compact ? 120 : null,
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: ModernSaaSDashboardTheme.surfaceBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernSaaSDashboardTheme.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                stat.icon,
                size: compact ? 16 : 20,
                color: stat.color,
              ),
              const Spacer(),
              if (stat.trend != null)
                Icon(
                  stat.trend! > 0 ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                  size: compact ? 12 : 14,
                  color: stat.trend! > 0 
                      ? ModernSaaSDashboardTheme.success 
                      : ModernSaaSDashboardTheme.error,
                ),
            ],
          ),
          SizedBox(height: compact ? 4 : 8),
          Text(
            stat.value,
            style: (compact 
                ? ModernSaaSDashboardTheme.headlineSmall 
                : ModernSaaSDashboardTheme.headlineLarge).copyWith(
              color: stat.color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            stat.label,
            style: (compact 
                ? ModernSaaSDashboardTheme.bodySmall 
                : ModernSaaSDashboardTheme.bodyMedium).copyWith(
              color: ModernSaaSDashboardTheme.tertiaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardStat {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double? trend;

  const DashboardStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
  });
}