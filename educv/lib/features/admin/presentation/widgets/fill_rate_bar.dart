import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class FillRateBar extends StatelessWidget {
  final String sectionName;
  final int percentage;

  const FillRateBar({
    super.key,
    required this.sectionName,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              sectionName,
              style: AppTypography.body.copyWith(color: AppColors.textPrimary),
            ),
          ),
          
          const SizedBox(width: 8),
          
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage / 100,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          SizedBox(
            width: 40,
            child: Text(
              '$percentage%',
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}