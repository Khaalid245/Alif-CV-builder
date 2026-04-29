import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/auth_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AdminAvatar extends ConsumerWidget {
  const AdminAvatar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    
    return GestureDetector(
      onTap: () => _showProfileSheet(context, ref),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.primary,
        child: Text(
          currentUser?.fullName.isNotEmpty == true 
              ? currentUser!.fullName[0].toUpperCase()
              : 'A',
          style: AppTypography.caption.copyWith(
            color: AppColors.background,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showProfileSheet(BuildContext context, WidgetRef ref) {
    final currentUser = ref.read(currentUserProvider);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary,
              child: Text(
                currentUser?.fullName.isNotEmpty == true 
                    ? currentUser!.fullName[0].toUpperCase()
                    : 'A',
                style: AppTypography.h2.copyWith(
                  color: AppColors.background,
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            Text(
              currentUser?.fullName ?? 'Administrator',
              style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 4),
            
            Text(
              currentUser?.email ?? '',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            
            Text(
              'Administrator',
              style: AppTypography.caption.copyWith(color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            const Divider(),
            
            const SizedBox(height: AppSpacing.md),
            
            ListTile(
              leading: const Icon(
                LucideIcons.logOut,
                color: AppColors.error,
                size: 20,
              ),
              title: Text(
                'Sign Out',
                style: AppTypography.body.copyWith(color: AppColors.error),
              ),
              onTap: () {
                Navigator.of(context).pop();
                logoutUser(ref, context);
              },
            ),
          ],
        ),
      ),
    );
  }
}