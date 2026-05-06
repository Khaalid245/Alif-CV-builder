import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'public_nav_bar.dart';
import 'public_footer.dart';

class PublicLayout extends StatelessWidget {
  final Widget child;
  final bool showNav;
  final bool showFooter;

  const PublicLayout({
    super.key,
    required this.child,
    this.showNav = true,
    this.showFooter = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          if (showNav) const PublicNavBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  child,
                  if (showFooter) const PublicFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}