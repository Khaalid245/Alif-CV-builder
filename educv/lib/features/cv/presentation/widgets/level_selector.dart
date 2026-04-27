import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

class LevelSelector extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onChanged;

  const LevelSelector({
    super.key,
    required this.options,
    this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: options.map((option) {
          final isSelected = selected == option;
          final isFirst = options.first == option;
          final isLast = options.last == option;
          
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(option),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                  horizontal: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.horizontal(
                    left: isFirst ? Radius.circular(7) : Radius.zero,
                    right: isLast ? Radius.circular(7) : Radius.zero,
                  ),
                ),
                child: Text(
                  option,
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}