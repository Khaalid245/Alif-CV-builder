import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= BreakPoints.desktop) {
          return desktop;
        } else if (constraints.maxWidth >= BreakPoints.tablet) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

class BreakPoints {
  static const double mobile = 768;
  static const double tablet = 1024;
  static const double desktop = 1024;
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        DeviceType deviceType;
        if (constraints.maxWidth >= BreakPoints.desktop) {
          deviceType = DeviceType.desktop;
        } else if (constraints.maxWidth >= BreakPoints.tablet) {
          deviceType = DeviceType.tablet;
        } else {
          deviceType = DeviceType.mobile;
        }
        return builder(context, deviceType);
      },
    );
  }
}

enum DeviceType { mobile, tablet, desktop }

extension DeviceTypeExtension on DeviceType {
  bool get isMobile => this == DeviceType.mobile;
  bool get isTablet => this == DeviceType.tablet;
  bool get isDesktop => this == DeviceType.desktop;

  int get gridColumns {
    switch (this) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.desktop:
        return 4;
    }
  }

  EdgeInsets get padding {
    switch (this) {
      case DeviceType.mobile:
        return const EdgeInsets.all(16);
      case DeviceType.tablet:
        return const EdgeInsets.all(24);
      case DeviceType.desktop:
        return const EdgeInsets.all(32);
    }
  }

  double get sidebarWidth {
    switch (this) {
      case DeviceType.mobile:
        return 280;
      case DeviceType.tablet:
        return 280;
      case DeviceType.desktop:
        return 280;
    }
  }
}
