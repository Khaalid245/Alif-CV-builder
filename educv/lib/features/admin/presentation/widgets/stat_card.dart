import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/section_card.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String change;
  final IconData icon;
  final Color? iconColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.change,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              ),
              const Spacer(),
              Icon(
                icon,
                size: 20,
                color: iconColor ?? AppColors.primary,
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          Text(
            value,
            style: AppTypography.display.copyWith(
              fontSize: 32,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            change,
            style: AppTypography.caption.copyWith(
              color: change.startsWith('+') ? AppColors.success : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}