import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../providers/cv_provider.dart';

/// Role Picker Card — shown on the CV Intelligence overview tab.
/// Lets the user select their target role in one tap.
/// When a role is set, shows the current selection with a glowing badge.
class TargetRolePicker extends ConsumerStatefulWidget {
  /// Currently selected role from the user's CVProfile (nullable).
  final Map<String, dynamic>? currentRole;

  const TargetRolePicker({super.key, this.currentRole});

  @override
  ConsumerState<TargetRolePicker> createState() => _TargetRolePickerState();
}

class _TargetRolePickerState extends ConsumerState<TargetRolePicker> {
  // Maps role slugs to Lucide icon data
  static const Map<String, IconData> _iconMap = {
    'code-2': LucideIcons.code2,
    'briefcase': LucideIcons.briefcase,
    'bar-chart-2': LucideIcons.barChart2,
    'palette': LucideIcons.palette,
    'git-branch': LucideIcons.gitBranch,
    'megaphone': LucideIcons.megaphone,
  };

  @override
  Widget build(BuildContext context) {
    final rolesAsync = ref.watch(rolesProvider);
    final selectedRoleId = widget.currentRole?['id'] as String?;
    final selectedRoleName = widget.currentRole?['name'] as String?;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selectedRoleId != null
              ? AppColors.primary.withOpacity(0.4)
              : AppColors.border,
          width: selectedRoleId != null ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    LucideIcons.target,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target Role',
                        style: AppTypography.headingSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Tell us what role you are targeting',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Current role badge
                if (selectedRoleName != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Text(
                      selectedRoleName,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Role chips
            rolesAsync.when(
              loading: () => const Center(
                child: SizedBox(
                  height: 36,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (e, _) => Text(
                'Could not load roles. Please try again.',
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
              data: (roles) => _buildRoleChips(roles, selectedRoleId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChips(List<dynamic> roles, String? selectedRoleId) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        ...roles.map((role) {
          final roleMap = role as Map<String, dynamic>;
          final isSelected = roleMap['id'] == selectedRoleId;
          final iconKey = roleMap['icon'] as String? ?? 'briefcase';
          final icon = _iconMap[iconKey] ?? LucideIcons.briefcase;

          return _RoleChip(
            label: roleMap['name'] as String,
            icon: icon,
            isSelected: isSelected,
            onTap: () => _handleRoleSelection(roleMap, isSelected),
          );
        }),
        // Clear selection chip
        if (selectedRoleId != null)
          _RoleChip(
            label: 'Any Role',
            icon: LucideIcons.x,
            isSelected: false,
            isDestructive: true,
            onTap: () => _handleRoleSelection(null, false),
          ),
      ],
    );
  }

  Future<void> _handleRoleSelection(
      Map<String, dynamic>? role, bool isAlreadySelected) async {
    if (isAlreadySelected) return; // Tapping selected role does nothing

    try {
      await ref
          .read(targetRoleProvider.notifier)
          .setTargetRole(role?['id'] as String?);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              role != null
                  ? 'Target role set to ${role['name']}. Re-analyze to see role-specific feedback.'
                  : 'Target role cleared.',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update role: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isDestructive;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppColors.textSecondary
        : isSelected
            ? AppColors.primary
            : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
