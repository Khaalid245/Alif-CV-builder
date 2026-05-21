import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../data/models/analytics_models.dart';

class RecentSnapshotsList extends StatelessWidget {
  final List<ScoreSnapshotModel> snapshots;
  final int maxItems;

  const RecentSnapshotsList({
    super.key,
    required this.snapshots,
    this.maxItems = 10,
  });

  @override
  Widget build(BuildContext context) {
    final displaySnapshots = snapshots.take(maxItems).toList();
    
    if (displaySnapshots.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 48,
                color: AppColors.textHint,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No Snapshots Yet',
                style: AppTypography.h6.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Create your first snapshot to start tracking your CV performance.',
                style: AppTypography.body2.copyWith(
                  color: AppColors.textHint,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Text(
                  'Recent Snapshots',
                  style: AppTypography.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (snapshots.length > maxItems)
                  Text(
                    'Showing ${maxItems} of ${snapshots.length}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
              ],
            ),
          ),
          
          ...displaySnapshots.asMap().entries.map((entry) {
            final index = entry.key;
            final snapshot = entry.value;
            final isLast = index == displaySnapshots.length - 1;
            
            return Column(
              children: [
                _buildSnapshotItem(snapshot),
                if (!isLast) const Divider(height: 1),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSnapshotItem(ScoreSnapshotModel snapshot) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getScoreColor(snapshot.overallScore).withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            ),
            child: Center(
              child: Text(
                snapshot.overallScore.toString(),
                style: AppTypography.body2.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _getScoreColor(snapshot.overallScore),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: AppSpacing.md),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _formatSnapshotType(snapshot.snapshotType),
                      style: AppTypography.body2.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    if (snapshot.submissionReady)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Ready',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.xs),
                
                Row(
                  children: [
                    Text(
                      'Completion: ${snapshot.completionPercentage}%',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (snapshot.grade.isNotEmpty) ...[
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'Grade: ${snapshot.grade}',
                        style: AppTypography.caption.copyWith(
                          color: _getGradeColor(snapshot.grade),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormatter.formatShortDate(snapshot.createdAt),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                DateFormatter.formatTime(snapshot.createdAt),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
          
          if (snapshot.percentileRank != null) ...[
            const SizedBox(width: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: _getPercentileColor(snapshot.percentileRank!).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusBtn),
              ),
              child: Text(
                '${snapshot.percentileRank!.toStringAsFixed(0)}%',
                style: AppTypography.caption.copyWith(
                  color: _getPercentileColor(snapshot.percentileRank!),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) {
      return AppColors.success;
    } else if (score >= 75) {
      return AppColors.primary;
    } else if (score >= 60) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  Color _getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A':
      case 'A+':
        return AppColors.success;
      case 'B':
      case 'B+':
        return AppColors.primary;
      case 'C':
      case 'C+':
        return AppColors.warning;
      case 'D':
      case 'F':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getPercentileColor(double percentile) {
    if (percentile >= 90) {
      return AppColors.success;
    } else if (percentile >= 75) {
      return AppColors.primary;
    } else if (percentile >= 50) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  String _formatSnapshotType(String type) {
    switch (type.toLowerCase()) {
      case 'manual':
        return 'Manual Snapshot';
      case 'automatic':
        return 'Auto Snapshot';
      case 'triggered':
        return 'Triggered';
      case 'scheduled':
        return 'Scheduled';
      case 'milestone':
        return 'Milestone';
      case 'review':
        return 'Review';
      default:
        return type;
    }
  }
}