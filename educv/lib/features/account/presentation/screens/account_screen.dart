import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/account_settings_tile.dart';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: const Color(0xFF1565C0),
                    child: Text(
                      _getInitials(user?.fullName ?? ''),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.fullName ?? 'User',
                    style: AppTypography.h2.copyWith(color: const Color(0xFF0A0A0A)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${user?.email ?? ''} · ${user?.studentId ?? ''}',
                    style: AppTypography.caption.copyWith(
                      color: const Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Security Section
            Text(
              'SECURITY',
              style: AppTypography.caption.copyWith(
                fontSize: 10,
                color: const Color(0xFF9E9E9E),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.07,
              ),
            ),
            const SizedBox(height: 8),
            
            SectionCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  AccountSettingsTile(
                    icon: LucideIcons.lock,
                    title: 'Change password',
                    onTap: () => context.go('/account/change-password'),
                  ),
                  const Divider(height: 1, indent: 52),
                  AccountSettingsTile(
                    icon: LucideIcons.mailCheck,
                    iconColor: const Color(0xFF2E7D32),
                    title: 'Email verified',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FFF4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Verified',
                        style: AppTypography.caption.copyWith(
                          color: const Color(0xFF2E7D32),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 52),
                  AccountSettingsTile(
                    icon: LucideIcons.smartphone,
                    title: 'Active sessions',
                    subtitle: '2 devices',
                    onTap: () => _showSessionsBottomSheet(context, ref),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Privacy & Legal Section
            Text(
              'PRIVACY & LEGAL',
              style: AppTypography.caption.copyWith(
                fontSize: 10,
                color: const Color(0xFF9E9E9E),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.07,
              ),
            ),
            const SizedBox(height: 8),
            
            SectionCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  AccountSettingsTile(
                    icon: LucideIcons.shield,
                    title: 'Privacy Policy',
                    onTap: () => context.go('/privacy'),
                  ),
                  const Divider(height: 1, indent: 52),
                  AccountSettingsTile(
                    icon: LucideIcons.fileText,
                    title: 'Terms of Service',
                    onTap: () => context.go('/terms'),
                  ),
                  const Divider(height: 1, indent: 52),
                  AccountSettingsTile(
                    icon: LucideIcons.clipboardCheck,
                    title: 'Consent history',
                    subtitle: 'Terms accepted ${_formatDate(user?.createdAt)}',
                    onTap: () => _showConsentBottomSheet(context, user),
                  ),
                  const Divider(height: 1, indent: 52),
                  AccountSettingsTile(
                    icon: LucideIcons.trash2,
                    iconColor: AppColors.error,
                    title: 'Request data deletion',
                    subtitle: 'Requires password confirmation',
                    onTap: () => _showDeletionDialog(context, ref),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showSessionsBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Sessions',
              style: AppTypography.h3,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(LucideIcons.smartphone, color: Color(0xFF2E7D32)),
              title: const Text('Current device'),
              subtitle: const Text('Active now'),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(LucideIcons.monitor, color: Color(0xFF6B7280)),
              title: const Text('Other device'),
              subtitle: const Text('Last seen 2 days ago'),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement logout all other devices
              },
              child: const Text('Sign out all other devices'),
            ),
          ],
        ),
      ),
    );
  }

  void _showConsentBottomSheet(BuildContext context, user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Consent History',
              style: AppTypography.h3,
            ),
            const SizedBox(height: 16),
            _buildConsentItem('Terms of Service', user?.createdAt),
            _buildConsentItem('Privacy Policy', user?.createdAt),
            _buildConsentItem('Data Processing', user?.createdAt),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentItem(String title, DateTime? date) {
    return ListTile(
      leading: const Icon(LucideIcons.checkCircle, color: Color(0xFF2E7D32)),
      title: Text(title),
      subtitle: Text('Accepted ${_formatDate(date)}'),
      contentPadding: EdgeInsets.zero,
    );
  }

  Future<void> _showDeletionDialog(BuildContext context, WidgetRef ref) async {
    final passwordController = TextEditingController();
    final reasonController = TextEditingController();
    var isSubmitting = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: !isSubmitting,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> submit() async {
              final password = passwordController.text;
              if (password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password is required.')),
                );
                return;
              }

              setState(() => isSubmitting = true);
              try {
                await ref.read(authRepositoryProvider).requestDeletion(
                      password: password,
                      reason: reasonController.text,
                    );
                if (!context.mounted) return;
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Deletion request submitted.'),
                  ),
                );
              } catch (error) {
                if (!context.mounted) return;
                setState(() => isSubmitting = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error.toString())),
                );
              }
            }

            return AlertDialog(
              title: const Text('Request Data Deletion'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter your password to confirm this deletion request.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    enabled: !isSubmitting,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reasonController,
                    enabled: !isSubmitting,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Reason (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: isSubmitting ? null : submit,
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );

    passwordController.dispose();
    reasonController.dispose();
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
