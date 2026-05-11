import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Account',
          style: AppTypography.h2.copyWith(color: const Color(0xFF0A0A0A)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.divider,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: const Color(0xFF1565C0),
                    child: Text(
                      _getInitials(user?.fullName ?? ''),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.fullName ?? 'User',
                    style: AppTypography.h3,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: AppTypography.body.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Account Options
            Expanded(
              child: Column(
                children: [
                  _buildAccountOption(
                    icon: LucideIcons.user,
                    title: 'Profile Settings',
                    subtitle: 'Update your personal information',
                    onTap: () {
                      // TODO: Navigate to profile settings
                    },
                  ),
                  _buildAccountOption(
                    icon: LucideIcons.bell,
                    title: 'Notifications',
                    subtitle: 'Manage your notification preferences',
                    onTap: () {
                      // TODO: Navigate to notifications
                    },
                  ),
                  _buildAccountOption(
                    icon: LucideIcons.shield,
                    title: 'Privacy & Security',
                    subtitle: 'Control your privacy settings',
                    onTap: () {
                      // TODO: Navigate to privacy settings
                    },
                  ),
                  _buildAccountOption(
                    icon: LucideIcons.helpCircle,
                    title: 'Help & Support',
                    subtitle: 'Get help and contact support',
                    onTap: () {
                      // TODO: Navigate to help
                    },
                  ),

                  const Spacer(),

                  // Sign Out Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: TextButton(
                      onPressed: () => _logout(ref, context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.logOut,
                            size: 18,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sign out',
                            style: AppTypography.body.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF6B7280),
          ),
        ),
        title: Text(
          title,
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.caption.copyWith(
            color: const Color(0xFF6B7280),
          ),
        ),
        trailing: const Icon(
          LucideIcons.chevronRight,
          size: 18,
          color: Color(0xFF9E9E9E),
        ),
        onTap: onTap,
      ),
    );
  }

  String _getInitials(String fullName) {
    if (fullName.isEmpty) return 'U';

    final names = fullName.trim().split(' ');
    if (names.length == 1) {
      return names[0][0].toUpperCase();
    }

    final firstInitial =
        names.first.isNotEmpty ? names.first[0].toUpperCase() : '';
    final lastInitial =
        names.last.isNotEmpty ? names.last[0].toUpperCase() : '';

    return '$firstInitial$lastInitial';
  }

  void _logout(WidgetRef ref, BuildContext context) async {
    final secureStorage = ref.read(secureStorageProvider);
    await secureStorage.clearAll();
    ref.read(currentUserProvider.notifier).state = null;
    if (context.mounted) {
      context.go('/');
    }
  }
}
