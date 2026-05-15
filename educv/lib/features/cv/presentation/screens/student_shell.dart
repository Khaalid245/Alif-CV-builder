import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';

class StudentShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const StudentShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(
              color: AppColors.divider,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.background,
          elevation: 0,
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(index),
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textPrimary.withOpacity(0.4),
          selectedLabelStyle: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
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
              icon: Icon(LucideIcons.user),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
