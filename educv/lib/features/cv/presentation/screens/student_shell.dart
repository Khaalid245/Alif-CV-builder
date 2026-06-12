import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/premium_portfolio_colors.dart';

class StudentShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const StudentShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumPortfolioColors.background,
      body: SizedBox(
        width: double.infinity,
        child: navigationShell,
      ),
    );
  }
}
