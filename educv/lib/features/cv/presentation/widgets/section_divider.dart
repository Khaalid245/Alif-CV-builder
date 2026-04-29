import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class SectionDivider extends StatelessWidget {
  final String label;

  const SectionDivider({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: AppColors.divider,
            height: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            color: AppColors.divider,
            height: 1,
          ),
        ),
      ],
    );
  }
}