import 'package:flutter/material.dart';

const double kWebBreakpoint = 800;

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget web;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.web,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= kWebBreakpoint) return web;
        return mobile;
      },
    );
  }
}

bool isWeb(BuildContext context) =>
    MediaQuery.of(context).size.width >= kWebBreakpoint;

EdgeInsets sectionPadding(BuildContext context) => isWeb(context)
    ? const EdgeInsets.symmetric(vertical: 72, horizontal: 40)
    : const EdgeInsets.symmetric(vertical: 48, horizontal: 20);
