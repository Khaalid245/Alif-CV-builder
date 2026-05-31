import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/improved_sidebar.dart';
import '../theme/premium_portfolio_colors.dart';
import 'responsive_layout.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../core/storage/secure_storage.dart';

class ImprovedAppLayout extends ConsumerStatefulWidget {
  final Widget child;
  final String? currentRoute;

  const ImprovedAppLayout({
    super.key,
    required this.child,
    this.currentRoute,
  });

  @override
  ConsumerState<ImprovedAppLayout> createState() => _ImprovedAppLayoutState();
}

class _ImprovedAppLayoutState extends ConsumerState<ImprovedAppLayout> {
  bool _isSidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        return Scaffold(
          backgroundColor: PremiumPortfolioColors.background,
          body: Row(
            children: [
              // Improved Sidebar
              ImprovedSidebar(
                currentIndex: _getCurrentIndex(),
                onNavigationChanged: _handleNavigation,
                isCollapsed: deviceType.isTablet ? _isSidebarCollapsed : false,
                onToggleCollapse: deviceType.isTablet ? () {
                  setState(() {
                    _isSidebarCollapsed = !_isSidebarCollapsed;
                  });
                } : null,
                userName: user?.fullName,
                userEmail: user?.email,
                onProfileTap: () => _showProfileBottomSheet(context),
              ),
              
              // Main content area
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: PremiumPortfolioColors.background,
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
    
    // Quick Start (0-1)
    if (currentPath == '/cv/dashboard') return 0;
    if (currentPath == '/cv/form') return 2; // Build My CV
    
    // My CV (2-5)
    if (currentPath == '/cv/preview') return 3;
    if (currentPath == '/cv/downloads') return 4;
    if (currentPath == '/cv/intelligence') return 5;
    
    // Tools & Resources (6-9)
    if (currentPath == '/templates') return 6;
    if (currentPath == '/analytics') return 7;
    if (currentPath == '/cv/version-history') return 9;
    
    // Account (8, 10)
    if (currentPath == '/notifications') return 8;
    if (currentPath == '/account') return 10;
    if (currentPath == '/account/change-password') return 10;
    
    return 0; // Default to dashboard
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0: // Dashboard
        context.go('/cv/dashboard');
        break;
      case 2: // Build My CV
        context.go('/cv/form');
        break;
      case 3: // Preview CV
        context.go('/cv/preview');
        break;
      case 4: // Download CVs
        context.go('/cv/downloads');
        break;
      case 5: // AI Suggestions
        context.go('/cv/intelligence');
        break;
      case 6: // CV Templates
        context.go('/templates');
        break;
      case 7: // Analytics
        context.go('/analytics');
        break;
      case 8: // Notifications
        context.go('/notifications');
        break;
      case 9: // Version History
        context.go('/cv/version-history');
        break;
      case 10: // Settings
        context.go('/account');
        break;
    }
  }

  void _showProfileBottomSheet(BuildContext context) {
    final user = ref.read(currentUserProvider);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: PremiumPortfolioColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // User info
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: PremiumPortfolioColors.accentPurple,
                  child: Text(
                    _getInitials(user?.fullName ?? ''),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? 'User',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: PremiumPortfolioColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: PremiumPortfolioColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: PremiumPortfolioColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Student Account',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: PremiumPortfolioColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Divider
            Container(
              height: 1,
              color: PremiumPortfolioColors.borderLight,
            ),
            
            const SizedBox(height: 16),
            
            // Menu items
            _buildProfileMenuItem(
              icon: Icons.person_outline,
              title: 'Account Settings',
              onTap: () {
                Navigator.pop(context);
                context.go('/account');
              },
            ),
            
            _buildProfileMenuItem(
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () {
                Navigator.pop(context);
                context.go('/account/change-password');
              },
            ),
            
            _buildProfileMenuItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {
                Navigator.pop(context);
                // Add help navigation
              },
            ),
            
            const SizedBox(height: 16),
            
            // Divider
            Container(
              height: 1,
              color: PremiumPortfolioColors.borderLight,
            ),
            
            const SizedBox(height: 16),
            
            // Sign out
            _buildProfileMenuItem(
              icon: Icons.logout,
              title: 'Sign Out',
              isDestructive: true,
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

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isDestructive 
                  ? PremiumPortfolioColors.error
                  : PremiumPortfolioColors.secondaryText,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDestructive 
                      ? PremiumPortfolioColors.error
                      : PremiumPortfolioColors.primaryText,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: PremiumPortfolioColors.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String fullName) {
    if (fullName.isEmpty) return 'U';
    final names = fullName.trim().split(' ');
    if (names.length == 1) {
      return names[0][0].toUpperCase();
    }
    final firstInitial = names.first.isNotEmpty ? names.first[0].toUpperCase() : '';
    final lastInitial = names.last.isNotEmpty ? names.last[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  Future<void> _logout() async {
    final secureStorage = ref.read(secureStorageProvider);
    await secureStorage.clearAll();
    ref.read(currentUserProvider.notifier).state = null;
    if (mounted) {
      context.go('/');
    }
  }
}