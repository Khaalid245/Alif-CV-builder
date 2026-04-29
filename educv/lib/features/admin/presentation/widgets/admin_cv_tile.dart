import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../data/models/admin_models.dart';

class AdminCVTile extends StatelessWidget {
  final AdminCVModel cv;
  final VoidCallback? onTap;

  const AdminCVTile({
    super.key,
    required this.cv,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      onTap: onTap,
      child: Row(
        children: [
          // Template thumbnail
          Container(
            width: 28,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(height: 3, width: 20, color: AppColors.primary),
                const SizedBox(height: 2),
                Container(height: 2, width: 22, color: AppColors.divider),
                const SizedBox(height: 1),
                Container(height: 2, width: 18, color: AppColors.divider),
                const SizedBox(height: 1),
                Container(height: 2, width: 20, color: AppColors.divider),
              ],
            ),
          ),
          
          const SizedBox(width: AppSpacing.sm),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      cv.templateDisplay,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormatter.toDisplayFormat(cv.generatedAt),
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  cv.studentName,
                  style: AppTypography.caption.copyWith(color: AppColors.primary),
                ),
                
                const SizedBox(height: 4),
                
                Row(
                  children: [
                    const Icon(LucideIcons.download, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${cv.downloadCount} downloads',
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 16),
                    const Icon(LucideIcons.hardDrive, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      cv.fileSize,
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}