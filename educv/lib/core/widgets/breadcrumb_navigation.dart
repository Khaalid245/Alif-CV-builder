import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/premium_portfolio_colors.dart';

class BreadcrumbNavigation extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final Function(String)? onNavigate;

  const BreadcrumbNavigation({
    super.key,
    required this.items,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: PremiumPortfolioColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // "You are here" indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: PremiumPortfolioColors.accentPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: PremiumPortfolioColors.accentPurple.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.mapPin,
                  size: 14,
                  color: PremiumPortfolioColors.accentPurple,
                ),
                const SizedBox(width: 6),
                Text(
                  'You are here',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: PremiumPortfolioColors.accentPurple,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Breadcrumb items
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _buildBreadcrumbItems(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBreadcrumbItems() {
    final List<Widget> widgets = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;
      final isClickable = item.route != null && onNavigate != null && !isLast;

      // Add breadcrumb item
      widgets.add(
        GestureDetector(
          onTap: isClickable ? () => onNavigate!(item.route!) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isLast
                  ? PremiumPortfolioColors.accentBlue.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.icon != null) ...[
                  Icon(
                    item.icon,
                    size: 16,
                    color: isLast
                        ? PremiumPortfolioColors.accentBlue
                        : isClickable
                            ? PremiumPortfolioColors.accentPurple
                            : PremiumPortfolioColors.secondaryText,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isLast ? FontWeight.w600 : FontWeight.w500,
                    color: isLast
                        ? PremiumPortfolioColors.accentBlue
                        : isClickable
                            ? PremiumPortfolioColors.accentPurple
                            : PremiumPortfolioColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Add separator (except for last item)
      if (!isLast) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              LucideIcons.chevronRight,
              size: 14,
              color: PremiumPortfolioColors.borderLight,
            ),
          ),
        );
      }
    }

    return widgets;
  }
}

class BreadcrumbItem {
  final String label;
  final IconData? icon;
  final String? route;

  BreadcrumbItem({
    required this.label,
    this.icon,
    this.route,
  });
}

// Predefined breadcrumb configurations for common pages
class AppBreadcrumbs {
  static List<BreadcrumbItem> dashboard() => [
        BreadcrumbItem(
          label: 'Dashboard',
          icon: LucideIcons.home,
          route: '/cv/dashboard',
        ),
      ];

  static List<BreadcrumbItem> cvForm(int step) {
    final stepNames = [
      'Personal Info',
      'Education',
      'Experience',
      'Skills',
      'Languages',
      'Projects',
      'Certifications',
    ];

    return [
      BreadcrumbItem(
        label: 'Dashboard',
        icon: LucideIcons.home,
        route: '/cv/dashboard',
      ),
      BreadcrumbItem(
        label: 'Build CV',
        icon: LucideIcons.edit3,
        route: '/cv/form',
      ),
      BreadcrumbItem(
        label: stepNames[step],
        icon: LucideIcons.user,
      ),
    ];
  }

  static List<BreadcrumbItem> cvPreview() => [
        BreadcrumbItem(
          label: 'Dashboard',
          icon: LucideIcons.home,
          route: '/cv/dashboard',
        ),
        BreadcrumbItem(
          label: 'Build CV',
          icon: LucideIcons.edit3,
          route: '/cv/form',
        ),
        BreadcrumbItem(
          label: 'Preview',
          icon: LucideIcons.eye,
        ),
      ];

  static List<BreadcrumbItem> downloads() => [
        BreadcrumbItem(
          label: 'Dashboard',
          icon: LucideIcons.home,
          route: '/cv/dashboard',
        ),
        BreadcrumbItem(
          label: 'Downloads',
          icon: LucideIcons.download,
        ),
      ];

  static List<BreadcrumbItem> intelligence() => [
        BreadcrumbItem(
          label: 'Dashboard',
          icon: LucideIcons.home,
          route: '/cv/dashboard',
        ),
        BreadcrumbItem(
          label: 'AI Suggestions',
          icon: LucideIcons.brain,
        ),
      ];

  static List<BreadcrumbItem> templates() => [
        BreadcrumbItem(
          label: 'Dashboard',
          icon: LucideIcons.home,
          route: '/cv/dashboard',
        ),
        BreadcrumbItem(
          label: 'Templates',
          icon: LucideIcons.layout,
        ),
      ];

  static List<BreadcrumbItem> analytics() => [
        BreadcrumbItem(
          label: 'Dashboard',
          icon: LucideIcons.home,
          route: '/cv/dashboard',
        ),
        BreadcrumbItem(
          label: 'Analytics',
          icon: LucideIcons.barChart3,
        ),
      ];

  static List<BreadcrumbItem> account() => [
        BreadcrumbItem(
          label: 'Dashboard',
          icon: LucideIcons.home,
          route: '/cv/dashboard',
        ),
        BreadcrumbItem(
          label: 'Account Settings',
          icon: LucideIcons.settings,
        ),
      ];
}
