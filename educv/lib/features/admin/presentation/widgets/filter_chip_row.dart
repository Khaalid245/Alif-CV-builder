import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class FilterChipRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  const FilterChipRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: options.map((option) {
          final isSelected = option.toLowerCase() == selected.toLowerCase();
          
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => onChanged(option.toLowerCase()),
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primaryLight,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.divider,
                width: isSelected ? 1.5 : 1,
              ),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}