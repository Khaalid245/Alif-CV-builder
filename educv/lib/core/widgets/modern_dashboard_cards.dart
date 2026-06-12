import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/modern_saas_theme.dart';
import 'responsive_layout.dart';

class ModernWelcomeCard extends StatelessWidget {
  final String greeting;
  final String date;
  final int completionPercentage;

  const ModernWelcomeCard({
    super.key,
    required this.greeting,
    required this.date,
    required this.completionPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(_getPadding(deviceType)),
          decoration: ModernComponentStyles.card,
          child: deviceType.isMobile
              ? _buildMobileLayout()
              : _buildDesktopLayout(),
        );
      },
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: ModernSaaSDashboardTheme.displaySmall,
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: ModernSaaSDashboardTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        _buildCompletionBadge(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: ModernSaaSDashboardTheme.displayMedium,
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: ModernSaaSDashboardTheme.bodyMedium,
              ),
            ],
          ),
        ),
        _buildCompletionBadge(),
      ],
    );
  }

  Widget _buildCompletionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ModernSaaSDashboardTheme.spacingMd,
        vertical: ModernSaaSDashboardTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: ModernSaaSDashboardTheme.successLight,
        borderRadius: BorderRadius.circular(ModernSaaSDashboardTheme.radius3xl),
        border: Border.all(
          color: ModernSaaSDashboardTheme.success.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            LucideIcons.checkCircle2,
            size: ModernSaaSDashboardTheme.iconSm,
            color: ModernSaaSDashboardTheme.success,
          ),
          const SizedBox(width: 6),
          Text(
            '$completionPercentage% Complete',
            style: ModernSaaSDashboardTheme.labelMedium.copyWith(
              color: ModernSaaSDashboardTheme.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  double _getPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return ModernSaaSDashboardTheme.spacingLg;
      case DeviceType.tablet:
        return ModernSaaSDashboardTheme.spacingXl;
      case DeviceType.desktop:
        return ModernSaaSDashboardTheme.spacing2xl;
    }
  }
}

class ModernStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;

  const ModernStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius:
                BorderRadius.circular(ModernSaaSDashboardTheme.radiusLg),
            child: Container(
              padding: EdgeInsets.all(_getPadding(deviceType)),
              decoration: ModernComponentStyles.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(
                            ModernSaaSDashboardTheme.spacingSm),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                              ModernSaaSDashboardTheme.radiusMd),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: _getIconSize(deviceType),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        LucideIcons.trendingUp,
                        color: ModernSaaSDashboardTheme.success,
                        size: ModernSaaSDashboardTheme.iconSm,
                      ),
                    ],
                  ),
                  SizedBox(height: _getSpacing(deviceType)),
                  Text(
                    value,
                    style: _getValueStyle(deviceType).copyWith(color: color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: ModernSaaSDashboardTheme.bodyMedium,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: ModernSaaSDashboardTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _getPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return ModernSaaSDashboardTheme.spacingMd;
      case DeviceType.tablet:
        return ModernSaaSDashboardTheme.spacingLg;
      case DeviceType.desktop:
        return ModernSaaSDashboardTheme.spacingXl;
    }
  }

  double _getIconSize(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return ModernSaaSDashboardTheme.iconMd;
      case DeviceType.tablet:
        return ModernSaaSDashboardTheme.iconMd;
      case DeviceType.desktop:
        return ModernSaaSDashboardTheme.iconLg;
    }
  }

  double _getSpacing(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return ModernSaaSDashboardTheme.spacingMd;
      case DeviceType.tablet:
        return ModernSaaSDashboardTheme.spacingMd;
      case DeviceType.desktop:
        return ModernSaaSDashboardTheme.spacingLg;
    }
  }

  TextStyle _getValueStyle(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return ModernSaaSDashboardTheme.displaySmall;
      case DeviceType.tablet:
        return ModernSaaSDashboardTheme.displaySmall;
      case DeviceType.desktop:
        return ModernSaaSDashboardTheme.displayMedium;
    }
  }
}

class ModernSectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;
  final VoidCallback? onViewAll;

  const ModernSectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.actions,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ModernComponentStyles.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          child,
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        return Padding(
          padding: EdgeInsets.all(_getHeaderPadding(deviceType)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: _getTitleStyle(deviceType),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: ModernSaaSDashboardTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (actions != null) ...actions!,
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ModernSaaSDashboardTheme.spacingMd,
                      vertical: ModernSaaSDashboardTheme.spacingSm,
                    ),
                  ),
                  child: Text(
                    'View all',
                    style: ModernSaaSDashboardTheme.labelMedium.copyWith(
                      color: ModernSaaSDashboardTheme.accentPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  double _getHeaderPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return ModernSaaSDashboardTheme.spacingLg;
      case DeviceType.tablet:
        return ModernSaaSDashboardTheme.spacingXl;
      case DeviceType.desktop:
        return ModernSaaSDashboardTheme.spacing2xl;
    }
  }

  TextStyle _getTitleStyle(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return ModernSaaSDashboardTheme.headlineMedium;
      case DeviceType.tablet:
        return ModernSaaSDashboardTheme.headlineLarge;
      case DeviceType.desktop:
        return ModernSaaSDashboardTheme.headlineLarge;
    }
  }
}

class ModernEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionText;
  final VoidCallback? onAction;

  const ModernEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        return Padding(
          padding: EdgeInsets.all(_getPadding(deviceType)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.all(ModernSaaSDashboardTheme.spacingLg),
                decoration: BoxDecoration(
                  color: ModernSaaSDashboardTheme.accentPurpleSubtle,
                  borderRadius:
                      BorderRadius.circular(ModernSaaSDashboardTheme.radius2xl),
                ),
                child: Icon(
                  icon,
                  size: _getIconSize(deviceType),
                  color: ModernSaaSDashboardTheme.mutedText,
                ),
              ),
              SizedBox(height: _getSpacing(deviceType)),
              Text(
                title,
                style: _getTitleStyle(deviceType),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ModernSaaSDashboardTheme.spacingSm),
              Text(
                description,
                style: ModernSaaSDashboardTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (actionText != null && onAction != null) ...[
                SizedBox(height: _getSpacing(deviceType)),
                ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ModernSaaSDashboardTheme.accentPurple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: ModernSaaSDashboardTheme.spacingXl,
                      vertical: _getButtonPadding(deviceType),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          ModernSaaSDashboardTheme.radiusMd),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    actionText!,
                    style: ModernSaaSDashboardTheme.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  double _getPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return ModernSaaSDashboardTheme.spacing2xl;
      case DeviceType.tablet:
        return ModernSaaSDashboardTheme.spacing3xl;
      case DeviceType.desktop:
        return ModernSaaSDashboardTheme.spacing4xl;
    }
  }

  double _getIconSize(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 32;
      case DeviceType.tablet:
        return 40;
      case DeviceType.desktop:
        return 48;
    }
  }

  double _getSpacing(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return ModernSaaSDashboardTheme.spacingLg;
      case DeviceType.tablet:
        return ModernSaaSDashboardTheme.spacingXl;
      case DeviceType.desktop:
        return ModernSaaSDashboardTheme.spacing2xl;
    }
  }

  TextStyle _getTitleStyle(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return ModernSaaSDashboardTheme.headlineMedium;
      case DeviceType.tablet:
        return ModernSaaSDashboardTheme.headlineLarge;
      case DeviceType.desktop:
        return ModernSaaSDashboardTheme.displaySmall;
    }
  }

  double _getButtonPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return ModernSaaSDashboardTheme.spacingSm;
      case DeviceType.tablet:
        return ModernSaaSDashboardTheme.spacingMd;
      case DeviceType.desktop:
        return ModernSaaSDashboardTheme.spacingMd;
    }
  }
}
