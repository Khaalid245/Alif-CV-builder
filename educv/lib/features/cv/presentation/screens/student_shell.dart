import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/premium_portfolio_colors.dart';

class StudentShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const StudentShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumPortfolioColors.background,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: PremiumPortfolioColors.cardBackground,
          border: Border(
            top: BorderSide(color: PremiumPortfolioColors.borderLight),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: PremiumPortfolioColors.cardBackground,
          elevation: 0,
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(index),
          selectedItemColor: PremiumPortfolioColors.accentPurple,
          unselectedItemColor: PremiumPortfolioColors.lightText,
          selectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
          ),
          iconSize: 22,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.layoutDashboard),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.fileText),
              label: 'My CV',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.download),
              label: 'Downloads',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.brain),
              label: 'Intelligence',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.user),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
