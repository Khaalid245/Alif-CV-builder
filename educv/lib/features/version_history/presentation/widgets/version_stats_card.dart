import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/version_models.dart';

class VersionStatsCard extends StatelessWidget {
  final VersionStatsModel stats;

  const VersionStatsCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version Statistics',
              style: AppTypography.h6.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Versions',
                    stats.totalVersions.toString(),
                    Icons.history,
                    AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Storage Used',
                    '${stats.totalSizeMb.toStringAsFixed(1)} MB',
                    Icons.storage,
                    AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Oldest Version',
                    'v${stats.oldestVersion}',
                    Icons.first_page,
                    AppColors.textSecondary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Latest Version',
                    'v${stats.newestVersion}',
                    Icons.last_page,
                    AppColors.success,
                  ),
                ),
              ],
            ),
            if (stats.changeTypes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Change Types',
                style: AppTypography.body2.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: stats.changeTypes.entries.map((entry) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _getChangeTypeColor(entry.key).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusBtn),
                      border: Border.all(
                        color: _getChangeTypeColor(entry.key).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '${_formatChangeType(entry.key)}: ${entry.value}',
                      style: AppTypography.caption.copyWith(
                        color: _getChangeTypeColor(entry.key),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.h6.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textHint,
          ),
          textAlign: TextAlign.center,
        ),
      ],
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

  String _formatChangeType(String changeType) {
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
        return 'Bulk Updates';
      default:
        return changeType;
    }
  }
}