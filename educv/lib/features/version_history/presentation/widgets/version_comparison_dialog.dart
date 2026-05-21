import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../data/models/version_models.dart';

class VersionComparisonDialog extends StatelessWidget {
  final VersionComparisonModel comparison;

  const VersionComparisonDialog({
    super.key,
    required this.comparison,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Version Comparison',
                  style: AppTypography.h5.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildVersionHeaders(),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: _buildDifferencesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionHeaders() {
    return Row(
      children: [
        Expanded(
          child: _buildVersionHeader(
            'From Version',
            comparison.fromVersion,
            AppColors.error.withOpacity(0.1),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        const Icon(
          Icons.arrow_forward,
          color: AppColors.textHint,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildVersionHeader(
            'To Version',
            comparison.toVersion,
            AppColors.success.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildVersionHeader(String title, CVVersionModel version, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.caption.copyWith(
              color: AppColors.textHint,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Version ${version.versionNumber}',
            style: AppTypography.body1.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            DateFormatter.formatDateTime(version.changedAt),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (version.changeSummary.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              version.changeSummary,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDifferencesList() {
    if (comparison.differences.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppColors.success.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Differences Found',
              style: AppTypography.h6.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'These versions contain identical data.',
              style: AppTypography.body2.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: comparison.differences.length,
      itemBuilder: (context, index) {
        final diff = comparison.differences[index];
        return _buildDifferenceItem(diff);
      },
    );
  }

  Widget _buildDifferenceItem(VersionDiffModel diff) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
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
                    color: _getDiffTypeColor(diff.diffType),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusBtn),
                  ),
                  child: Text(
                    _getDiffTypeLabel(diff.diffType),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _formatFieldPath(diff.fieldPath),
                    style: AppTypography.body2.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildValueContainer(
                    'Old Value',
                    diff.oldValue,
                    AppColors.error.withOpacity(0.1),
                    AppColors.error,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildValueContainer(
                    'New Value',
                    diff.newValue,
                    AppColors.success.withOpacity(0.1),
                    AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueContainer(String label, dynamic value, Color backgroundColor, Color borderColor) {
    final displayValue = _formatValue(value);
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: borderColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: borderColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            displayValue,
            style: AppTypography.body2.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDiffTypeColor(String diffType) {
    switch (diffType.toLowerCase()) {
      case 'field_change':
        return AppColors.primary;
      case 'section_add':
        return AppColors.success;
      case 'section_remove':
        return AppColors.error;
      case 'section_modify':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getDiffTypeLabel(String diffType) {
    switch (diffType.toLowerCase()) {
      case 'field_change':
        return 'Changed';
      case 'section_add':
        return 'Added';
      case 'section_remove':
        return 'Removed';
      case 'section_modify':
        return 'Modified';
      default:
        return diffType;
    }
  }

  String _formatFieldPath(String fieldPath) {
    return fieldPath
        .split('.')
        .map((part) => part
            .split('_')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' '))
        .join(' → ');
  }

  String _formatValue(dynamic value) {
    if (value == null) {
      return '(empty)';
    }
    
    if (value is String) {
      return value.isEmpty ? '(empty)' : value;
    }
    
    if (value is List) {
      return value.isEmpty ? '(empty list)' : '${value.length} items';
    }
    
    if (value is Map) {
      return value.isEmpty ? '(empty object)' : '${value.length} fields';
    }
    
    return value.toString();
  }
}