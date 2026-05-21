import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../data/models/version_models.dart';

class VersionItemCard extends StatelessWidget {
  final CVVersionModel version;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onRestore;

  const VersionItemCard({
    super.key,
    required this.version,
    required this.isSelected,
    required this.onTap,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      color: isSelected ? AppColors.primaryLight : AppColors.background,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _getChangeTypeColor(version.changeType),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusBtn),
                    ),
                    child: Text(
                      'v${version.versionNumber}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _getChangeTypeLabel(version.changeType),
                      style: AppTypography.body2.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 20,
                    ),
                ],
              ),
              if (version.changeSummary.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  version.changeSummary,
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    version.changedBy ?? 'System',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    DateFormatter.formatDateTime(version.changedAt),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
              if (version.fieldsChanged.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: version.fieldsChanged.take(3).map((field) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Text(
                        _formatFieldName(field),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }).toList()
                    ..addAll(version.fieldsChanged.length > 3
                        ? [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: 2,
                              ),
                              child: Text(
                                '+${version.fieldsChanged.length - 3} more',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textHint,
                                ),
                              ),
                            )
                          ]
                        : []),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Text(
                    '${(version.dataSize / 1024).toStringAsFixed(1)} KB',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onRestore,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Restore'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getChangeTypeColor(String changeType) {
    switch (changeType.toLowerCase()) {
      case 'create':
        return AppColors.success;
      case 'update':
        return AppColors.primary;
      case 'restore':
        return AppColors.warning;
      case 'delete':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getChangeTypeLabel(String changeType) {
    switch (changeType.toLowerCase()) {
      case 'create':
        return 'Created';
      case 'update':
        return 'Updated';
      case 'restore':
        return 'Restored';
      case 'delete':
        return 'Deleted';
      case 'bulk_update':
        return 'Bulk Update';
      default:
        return changeType;
    }
  }

  String _formatFieldName(String field) {
    return field
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}