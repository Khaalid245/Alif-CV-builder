import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/modern_saas_sidebar.dart';
import '../theme/modern_saas_theme.dart';
import 'responsive_layout.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class AppLayout extends ConsumerStatefulWidget {
  final Widget child;
  final String? currentRoute;

  const AppLayout({
    super.key,
    required this.child,
    this.currentRoute,
  });

  @override
  ConsumerState<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends ConsumerState<AppLayout> {
  bool _isSidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return ResponsiveBuilder(
      builder: (context, deviceType) {
        return Scaffold(
          backgroundColor: ModernSaaSDashboardTheme.background,
          body: Row(
            children: [
              // Sidebar for all devices
              ModernSaaSSidebar(
                currentIndex: _getCurrentIndex(),
                onNavigationChanged: _handleNavigation,
                isCollapsed: deviceType.isTablet ? _isSidebarCollapsed : false,
                onToggleCollapse: deviceType.isTablet
                    ? () {
                        setState(() {
                          _isSidebarCollapsed = !_isSidebarCollapsed;
                        });
                      }
                    : null,
                userName: user?.fullName,
                userEmail: user?.email,
                onProfileTap: () => _showProfileBottomSheet(context),
              ),

              // Main content area
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: ModernSaaSDashboardTheme.background,
                  ),
                  child: widget.child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int _getCurrentIndex() {
    final currentPath = widget.currentRoute ?? '';

    // Main Navigation (0-1)
    if (currentPath == '/cv/dashboard') return 0;
    if (currentPath == '/cv/sections') return 1;

    // CV Builder items (2-5)
    if (currentPath == '/cv/form') return 2;
    if (currentPath == '/cv/preview') return 3;
    if (currentPath == '/cv/downloads') return 4;
    if (currentPath == '/cv/intelligence') return 5;

    // Tools items (6-9)
    if (currentPath == '/templates') return 6;
    if (currentPath == '/analytics') return 7;
    if (currentPath == '/notifications') return 8;
    if (currentPath == '/cv/version-history') return 9;

    // Account items (10-11)
    if (currentPath == '/account') return 10;
    if (currentPath == '/account/change-password') return 11;

    return 0; // Default to dashboard
  }

  void _handleNavigation(int index) {
    // Main Navigation (0-1)
    if (index == 0) {
      context.go('/cv/dashboard');
      return;
    } else if (index == 1) {
      context.go('/cv/sections');
      return;
    }

    // CV Builder items (2-5)
    final cvBuilderStartIndex = 2;
    if (index >= cvBuilderStartIndex && index < cvBuilderStartIndex + 4) {
      final cvBuilderIndex = index - cvBuilderStartIndex;
      switch (cvBuilderIndex) {
        case 0: // CV Form
          context.go('/cv/form');
          break;
        case 1: // Preview
          context.go('/cv/preview');
          break;
        case 2: // Downloads
          context.go('/cv/downloads');
          break;
        case 3: // CV Intelligence
          context.go('/cv/intelligence');
          break;
      }
      return;
    }

    // Tools items (6-9)
    final toolsStartIndex = 6;
    if (index >= toolsStartIndex && index < toolsStartIndex + 4) {
      final toolsIndex = index - toolsStartIndex;
      switch (toolsIndex) {
        case 0: // Templates
          context.go('/templates');
          break;
        case 1: // Analytics
          context.go('/analytics');
          break;
        case 2: // Notifications
          context.go('/notifications');
          break;
        case 3: // Version History
          context.go('/cv/version-history');
          break;
      }
      return;
    }

    // Account items (10-11)
    final accountStartIndex = 10;
    if (index >= accountStartIndex && index < accountStartIndex + 2) {
      final accountIndex = index - accountStartIndex;
      switch (accountIndex) {
        case 0: // Account Settings
          context.go('/account');
          break;
        case 1: // Change Password
          context.go('/account/change-password');
          break;
      }
    }
  }

  void _showProfileBottomSheet(BuildContext context) {
    final user = ref.read(currentUserProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                Text(
                  user?.fullName ?? 'User',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ModernSaaSDashboardTheme.primaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    color: ModernSaaSDashboardTheme.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 1,
              color: ModernSaaSDashboardTheme.borderLight,
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: ModernSaaSDashboardTheme.error,
              ),
              title: const Text(
                'Sign out',
                style: TextStyle(
                  fontSize: 16,
                  color: ModernSaaSDashboardTheme.error,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    // Handle logout logic here
    ref.read(currentUserProvider.notifier).state = null;
    if (mounted) {
      context.go('/');
    }
  }
}
