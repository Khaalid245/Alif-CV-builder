import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/modern_saas_theme.dart';
import 'responsive_layout.dart';

class DashboardStatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final double? progress;
  final String? statusText;
  final Color? statusColor;
  final VoidCallback? onTap;
  final bool showTrend;
  final double? trendValue;
  final bool isLoading;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.progress,
    this.statusText,
    this.statusColor,
    this.onTap,
    this.showTrend = false,
    this.trendValue,
    this.isLoading = false,
  });

  @override
  State<DashboardStatCard> createState() => _DashboardStatCardState();
}

class _DashboardStatCardState extends State<DashboardStatCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _progressController;
  late Animation<double> _hoverAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _hoverAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress ?? 0.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );

    // Start progress animation
    if (widget.progress != null && !widget.isLoading) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _progressController.forward();
      });
    }
  }

  @override
  void didUpdateWidget(DashboardStatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress && widget.progress != null) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress!,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ));
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        return MouseRegion(
          onEnter: (_) => _onHover(true),
          onExit: (_) => _onHover(false),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(_getPadding(deviceType)),
                      decoration: _buildCardDecoration(deviceType),
                      child: widget.isLoading
                          ? _buildLoadingState(deviceType)
                          : _buildCardContent(deviceType),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  BoxDecoration _buildCardDecoration(DeviceType deviceType) {
    return BoxDecoration(
      color: ModernSaaSDashboardTheme.surfaceBackground,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: _isHovered
            ? widget.color.withOpacity(0.2)
            : ModernSaaSDashboardTheme.borderLight,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: _isHovered
              ? widget.color.withOpacity(0.08)
              : Colors.black.withOpacity(0.04),
          blurRadius: _isHovered ? 16 : 8,
          offset: const Offset(0, 2),
        ),
        if (_isHovered)
          BoxShadow(
            color: widget.color.withOpacity(0.04),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
      ],
    );
  }

  Widget _buildCardContent(DeviceType deviceType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with icon and status
        _buildHeaderRow(deviceType),
        
        SizedBox(height: _getSpacing(deviceType)),
        
        // Value and title
        _buildValueSection(deviceType),
        
        if (widget.subtitle != null) ...[
          const SizedBox(height: 4),
          _buildSubtitle(deviceType),
        ],
        
        SizedBox(height: _getSpacing(deviceType)),
        
        // Progress bar or accent line
        _buildProgressSection(),
        
        // Status indicator
        if (widget.statusText != null) ...[
          const SizedBox(height: 8),
          _buildStatusIndicator(),
        ],
      ],
    );
  }

  Widget _buildHeaderRow(DeviceType deviceType) {
    return Row(
      children: [
        // Icon container
        Container(
          width: _getIconSize(deviceType),
          height: _getIconSize(deviceType),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.icon,
            size: _getIconSize(deviceType) * 0.5,
            color: widget.color,
          ),
        ),
        
        const Spacer(),
        
        // Trend indicator
        if (widget.showTrend && widget.trendValue != null)
          _buildTrendIndicator(),
      ],
    );
  }

  Widget _buildTrendIndicator() {
    final isPositive = widget.trendValue! > 0;
    final color = isPositive 
        ? ModernSaaSDashboardTheme.success 
        : ModernSaaSDashboardTheme.error;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? LucideIcons.trendingUp : LucideIcons.trendingDown,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            '${isPositive ? '+' : ''}${widget.trendValue!.toStringAsFixed(1)}%',
            style: ModernSaaSDashboardTheme.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueSection(DeviceType deviceType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Value
        Text(
          widget.value,
          style: _getValueStyle(deviceType).copyWith(
            color: widget.color,
            fontWeight: FontWeight.w700,
          ),
        ),
        
        const SizedBox(height: 2),
        
        // Title
        Text(
          widget.title,
          style: _getTitleStyle(deviceType),
        ),
      ],
    );
  }

  Widget _buildSubtitle(DeviceType deviceType) {
    return Text(
      widget.subtitle!,
      style: ModernSaaSDashboardTheme.bodySmall.copyWith(
        color: ModernSaaSDashboardTheme.tertiaryText,
      ),
    );
  }

  Widget _buildProgressSection() {
    if (widget.progress != null) {
      return _buildProgressBar();
    } else {
      return _buildAccentLine();
    }
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: ModernSaaSDashboardTheme.labelSmall.copyWith(
                color: ModernSaaSDashboardTheme.tertiaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Text(
                  '${(_progressAnimation.value * 100).round()}%',
                  style: ModernSaaSDashboardTheme.labelSmall.copyWith(
                    color: widget.color,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.color,
                        widget.color.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAccentLine() {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.color,
            widget.color.withOpacity(0.3),
            Colors.transparent,
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (widget.statusColor ?? widget.color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: widget.statusColor ?? widget.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            widget.statusText!,
            style: ModernSaaSDashboardTheme.labelSmall.copyWith(
              color: widget.statusColor ?? widget.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(DeviceType deviceType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header skeleton
        Row(
          children: [
            Container(
              width: _getIconSize(deviceType),
              height: _getIconSize(deviceType),
              decoration: BoxDecoration(
                color: ModernSaaSDashboardTheme.borderLight,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const Spacer(),
            Container(
              width: 40,
              height: 16,
              decoration: BoxDecoration(
                color: ModernSaaSDashboardTheme.borderLight,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
        
        SizedBox(height: _getSpacing(deviceType)),
        
        // Value skeleton
        Container(
          width: 60,
          height: _getValueStyle(deviceType).fontSize! * 1.2,
          decoration: BoxDecoration(
            color: ModernSaaSDashboardTheme.borderLight,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        
        const SizedBox(height: 4),
        
        // Title skeleton
        Container(
          width: 100,
          height: _getTitleStyle(deviceType).fontSize! * 1.2,
          decoration: BoxDecoration(
            color: ModernSaaSDashboardTheme.borderLight,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        
        SizedBox(height: _getSpacing(deviceType)),
        
        // Progress skeleton
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: ModernSaaSDashboardTheme.borderLight,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  void _onHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  double _getPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 16;
      case DeviceType.tablet:
        return 20;
      case DeviceType.desktop:
        return 24;
    }
  }

  double _getIconSize(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 40;
      case DeviceType.tablet:
        return 44;
      case DeviceType.desktop:
        return 48;
    }
  }

  double _getSpacing(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 12;
      case DeviceType.tablet:
        return 16;
      case DeviceType.desktop:
        return 20;
    }
  }

  TextStyle _getValueStyle(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return ModernSaaSDashboardTheme.headlineLarge;
      case DeviceType.tablet:
        return ModernSaaSDashboardTheme.displaySmall;
      case DeviceType.desktop:
        return ModernSaaSDashboardTheme.displayMedium;
    }
  }

  TextStyle _getTitleStyle(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return ModernSaaSDashboardTheme.bodyMedium;
      case DeviceType.tablet:
        return ModernSaaSDashboardTheme.bodyLarge;
      case DeviceType.desktop:
        return ModernSaaSDashboardTheme.bodyLarge;
    }
  }
}

// Grid layout for dashboard stats
class DashboardStatsGrid extends StatelessWidget {
  final List<DashboardStatCard> cards;
  final EdgeInsets? padding;
  final double? spacing;

  const DashboardStatsGrid({
    super.key,
    required this.cards,
    this.padding,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        return Padding(
          padding: padding ?? _getDefaultPadding(deviceType),
          child: _buildGrid(deviceType),
        );
      },
    );
  }

  Widget _buildGrid(DeviceType deviceType) {
    final columns = _getColumnCount(deviceType);
    final cardSpacing = spacing ?? _getDefaultSpacing(deviceType);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: _getAspectRatio(deviceType),
        crossAxisSpacing: cardSpacing,
        mainAxisSpacing: cardSpacing,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => cards[index],
    );
  }

  int _getColumnCount(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 2;
      case DeviceType.tablet:
        return cards.length >= 3 ? 3 : 2;
      case DeviceType.desktop:
        return 4;
    }
  }

  double _getAspectRatio(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 1.1;
      case DeviceType.tablet:
        return 1.2;
      case DeviceType.desktop:
        return 1.3;
    }
  }

  EdgeInsets _getDefaultPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(16);
      case DeviceType.tablet:
        return const EdgeInsets.all(24);
      case DeviceType.desktop:
        return const EdgeInsets.all(32);
    }
  }

  double _getDefaultSpacing(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 16;
      case DeviceType.tablet:
        return 20;
      case DeviceType.desktop:
        return 24;
    }
  }
}

// Specialized stat cards for common use cases
class ProfileSectionStatCard extends DashboardStatCard {
  ProfileSectionStatCard({
    super.key,
    required int completedSections,
    required int totalSections,
    super.onTap,
  }) : super(
          title: 'Profile Sections',
          value: '$completedSections/$totalSections',
          icon: LucideIcons.user,
          color: ModernSaaSDashboardTheme.accentPurple,
          subtitle: 'Completed',
          progress: completedSections / totalSections,
          statusText: completedSections == totalSections ? 'Complete' : 'In Progress',
          statusColor: completedSections == totalSections 
              ? ModernSaaSDashboardTheme.success 
              : ModernSaaSDashboardTheme.warning,
          showTrend: true,
          trendValue: completedSections > 0 ? 12.5 : 0,
        );
}

class ExperienceStatCard extends DashboardStatCard {
  ExperienceStatCard({
    super.key,
    required int experienceCount,
    super.onTap,
  }) : super(
          title: 'Experience',
          value: '$experienceCount',
          icon: LucideIcons.briefcase,
          color: ModernSaaSDashboardTheme.info,
          subtitle: 'Positions',
          statusText: experienceCount > 0 ? 'Added' : 'Empty',
          statusColor: experienceCount > 0 
              ? ModernSaaSDashboardTheme.success 
              : ModernSaaSDashboardTheme.error,
        );
}

class SkillsStatCard extends DashboardStatCard {
  SkillsStatCard({
    super.key,
    required int skillsCount,
    super.onTap,
  }) : super(
          title: 'Skills',
          value: '$skillsCount',
          icon: LucideIcons.zap,
          color: ModernSaaSDashboardTheme.success,
          subtitle: 'Listed',
          progress: (skillsCount / 15).clamp(0.0, 1.0), // Assuming 15 is ideal
          statusText: skillsCount >= 10 ? 'Excellent' : skillsCount >= 5 ? 'Good' : 'Add More',
          statusColor: skillsCount >= 10 
              ? ModernSaaSDashboardTheme.success 
              : skillsCount >= 5 
                  ? ModernSaaSDashboardTheme.warning 
                  : ModernSaaSDashboardTheme.error,
          showTrend: true,
          trendValue: skillsCount > 0 ? 8.3 : 0,
        );
}

class ProjectsStatCard extends DashboardStatCard {
  ProjectsStatCard({
    super.key,
    required int projectsCount,
    super.onTap,
  }) : super(
          title: 'Projects',
          value: '$projectsCount',
          icon: LucideIcons.folder,
          color: ModernSaaSDashboardTheme.warning,
          subtitle: 'Showcased',
          progress: (projectsCount / 5).clamp(0.0, 1.0), // Assuming 5 is ideal
          statusText: projectsCount >= 3 ? 'Great' : projectsCount >= 1 ? 'Good' : 'Add Projects',
          statusColor: projectsCount >= 3 
              ? ModernSaaSDashboardTheme.success 
              : projectsCount >= 1 
                  ? ModernSaaSDashboardTheme.warning 
                  : ModernSaaSDashboardTheme.error,
        );
}