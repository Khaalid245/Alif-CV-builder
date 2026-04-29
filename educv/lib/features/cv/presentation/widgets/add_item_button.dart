import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class AddItemButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const AddItemButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary,
            width: 1.5,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          color: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.plus,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              text,
              style: AppTypography.body.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}