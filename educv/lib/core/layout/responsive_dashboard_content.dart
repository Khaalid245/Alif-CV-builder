import 'package:flutter/material.dart';
import '../theme/premium_portfolio_colors.dart';
import 'responsive_layout.dart';

class ResponsiveDashboardContent extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;

  const ResponsiveDashboardContent({
    super.key,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        return SingleChildScrollView(
          padding: padding ?? deviceType.padding,
          child: _buildContent(deviceType),
        );
      },
    );
  }

  Widget _buildContent(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return _buildMobileContent();
      case DeviceType.tablet:
        return _buildTabletContent();
      case DeviceType.desktop:
        return _buildDesktopContent();
    }
  }

  Widget _buildMobileContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: child,
        );
      }).toList(),
    );
  }

  Widget _buildTabletContent() {
    final rows = <Widget>[];
    for (int i = 0; i < children.length; i += 2) {
      final rowChildren = <Widget>[];
      
      // First item
      rowChildren.add(
        Expanded(child: children[i]),
      );
      
      // Second item if exists
      if (i + 1 < children.length) {
        rowChildren.add(const SizedBox(width: 24));
        rowChildren.add(
          Expanded(child: children[i + 1]),
        );
      }
      
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
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

  Widget _buildDesktopContent() {
    // For desktop, we'll use a more flexible grid system
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: children.map((child) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 280 - 64 - 48) / 2, // Sidebar width - padding - spacing
          child: child,
        );
      }).toList(),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? height;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.child,
    this.padding,
    this.height,
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
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: height,
              padding: padding ?? _getCardPadding(deviceType),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: PremiumPortfolioColors.cardShadow,
                border: Border.all(
                  color: PremiumPortfolioColors.borderLight,
                  width: 0.5,
                ),
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }

  EdgeInsets _getCardPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(16);
      case DeviceType.tablet:
        return const EdgeInsets.all(20);
      case DeviceType.desktop:
        return const EdgeInsets.all(24);
    }
  }
}

class DashboardGrid extends StatelessWidget {
  final List<Widget> children;
  final int? crossAxisCount;
  final double? childAspectRatio;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;

  const DashboardGrid({
    super.key,
    required this.children,
    this.crossAxisCount,
    this.childAspectRatio,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        final columns = crossAxisCount ?? deviceType.gridColumns;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: childAspectRatio ?? _getAspectRatio(deviceType),
            crossAxisSpacing: crossAxisSpacing ?? _getSpacing(deviceType),
            mainAxisSpacing: mainAxisSpacing ?? _getSpacing(deviceType),
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }

  double _getAspectRatio(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 1.5;
      case DeviceType.tablet:
        return 1.3;
      case DeviceType.desktop:
        return 1.2;
    }
  }

  double _getSpacing(DeviceType deviceType) {
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

class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        if (deviceType.isMobile && children.length > 2) {
          // Stack vertically on mobile if too many children
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children.map((child) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: child,
              );
            }).toList(),
          );
        }
        
        return Row(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: children,
        );
      },
    );
  }
}

class ResponsiveColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const ResponsiveColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        return Column(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: children.map((child) {
            return Padding(
              padding: EdgeInsets.only(bottom: _getSpacing(deviceType)),
              child: child,
            );
          }).toList(),
        );
      },
    );
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
}