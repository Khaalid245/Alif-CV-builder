import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/section_card.dart';

class CVSectionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? trailing;
  final Widget? badge;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CVSectionTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.badge,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.h3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      badge!,
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    trailing!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    child: Icon(
                      LucideIcons.edit,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              if (onDelete != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    child: Icon(
                      LucideIcons.trash2,
                      size: 20,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}