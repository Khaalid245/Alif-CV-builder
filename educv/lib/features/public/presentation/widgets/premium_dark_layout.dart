import 'package:flutter/material.dart';

import '../../../../core/theme/premium_dark_colors.dart';
import 'premium_nav_bar.dart';
import 'premium_dark_footer.dart';

class PremiumDarkLayout extends StatelessWidget {
  final Widget child;
  final bool showNav;
  final bool showFooter;

  const PremiumDarkLayout({
    super.key,
    required this.child,
    this.showNav = true,
    this.showFooter = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumDarkColors.background,
      body: Column(
        children: [
          if (showNav) const PremiumNavBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  child,
                  if (showFooter) const PremiumDarkFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}