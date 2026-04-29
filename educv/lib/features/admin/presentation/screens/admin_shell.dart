import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/admin_provider.dart';
import '../providers/search_provider.dart';
import '../widgets/admin_avatar.dart';
import 'admin_dashboard_screen.dart';
import 'students_list_screen.dart';
import 'admin_cvs_screen.dart';
import 'audit_logs_screen.dart';

class AdminShell extends ConsumerWidget {
  const AdminShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(adminTabProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          _getTabTitle(currentTab),
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          if (currentTab == 1) // Students tab
            Consumer(
              builder: (context, ref, _) => IconButton(
                icon: const Icon(LucideIcons.search, color: AppColors.textPrimary),
                onPressed: () {
                  final currentState = ref.read(studentsSearchToggleProvider);
                  ref.read(studentsSearchToggleProvider.notifier).state = !currentState;
                },
              ),
            ),
          if (currentTab == 3) // Audit Logs tab
            IconButton(
              icon: const Icon(LucideIcons.filter, color: AppColors.textPrimary),
              onPressed: () {
                // Filter functionality would be handled by the AuditLogsScreen
                // This is just the UI trigger
              },
            ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: AdminAvatar(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.divider,
          ),
        ),
      ),
      body: IndexedStack(
        index: currentTab,
        children: const [
          AdminDashboardScreen(),
          StudentsListScreen(),
          AdminCVsScreen(),
          AuditLogsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentTab,
          onTap: (index) => ref.read(adminTabProvider.notifier).state = index,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textPrimary.withValues(alpha: 0.4),
          selectedLabelStyle: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTypography.caption,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.layoutDashboard),
              label: 'Overview',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.users),
              label: 'Students',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.fileText),
              label: 'CVs',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.clipboardList),
              label: 'Audit Logs',
            ),
          ],
        ),
      ),
    );
  }

  String _getTabTitle(int tab) {
    switch (tab) {
      case 0:
        return 'Overview';
      case 1:
        return 'Students';
      case 2:
        return 'Generated CVs';
      case 3:
        return 'Audit Logs';
      default:
        return 'Admin';
    }
  }
}