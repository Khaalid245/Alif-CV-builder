import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class AnalyticsFilterBar extends StatelessWidget {
  final int selectedPeriod;
  final ValueChanged<int> onPeriodChanged;
  final bool showSnapshotFilters;

  const AnalyticsFilterBar({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.showSnapshotFilters = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time Period',
            style: AppTypography.body2.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              _buildPeriodChip(7, '7 Days'),
              _buildPeriodChip(30, '30 Days'),
              _buildPeriodChip(90, '90 Days'),
              _buildPeriodChip(365, '1 Year'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(int days, String label) {
    final isSelected = selectedPeriod == days;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onPeriodChanged(days);
        }
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: AppTypography.body2.copyWith(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}