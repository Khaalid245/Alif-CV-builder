import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/analytics_models.dart';

class AnalyticsOverviewCard extends StatelessWidget {
  final UserSummaryModel userSummary;

  const AnalyticsOverviewCard({
    super.key,
    required this.userSummary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your CV Performance',
              style: AppTypography.h5.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            Row(
              children: [
                Expanded(
                  child: _buildScoreCard(
                    'Overall Score',
                    userSummary.latestScore,
                    Icons.star,
                    AppColors.primary,
                    suffix: '/100',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildScoreCard(
                    'Completion',
                    userSummary.latestCompletion,
                    Icons.check_circle,
                    AppColors.success,
                    suffix: '%',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    'Submission Ready',
                    userSummary.submissionReady ? 'Yes' : 'No',
                    userSummary.submissionReady ? Icons.check : Icons.close,
                    userSummary.submissionReady ? AppColors.success : AppColors.error,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildStatusCard(
                    'Grade',
                    userSummary.grade.isNotEmpty ? userSummary.grade : 'Not Graded',
                    Icons.grade,
                    _getGradeColor(userSummary.grade),
                  ),
                ),
              ],
            ),
            
            if (userSummary.percentileRank != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _buildPercentileRank(userSummary.percentileRank!),
            ],
            
            const SizedBox(height: AppSpacing.md),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Snapshots: ${userSummary.totalSnapshots}',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: _getReadinessColor(userSummary.submissionReady).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusBtn),
                  ),
                  child: Text(
                    _getReadinessText(userSummary.submissionReady),
                    style: AppTypography.caption.copyWith(
                      color: _getReadinessColor(userSummary.submissionReady),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(String title, int value, IconData icon, Color color, {String suffix = ''}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$value$suffix',
            style: AppTypography.h4.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            title,
            style: AppTypography.body2.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            title,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPercentileRank(double percentileRank) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.success.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.leaderboard,
            color: AppColors.primary,
            size: 32,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Peer Ranking',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Text(
                      '${percentileRank.toStringAsFixed(1)}th',
                      style: AppTypography.h5.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'percentile',
                      style: AppTypography.body1.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  _getPercentileDescription(percentileRank),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
            ),
            child: Center(
              child: Text(
                '${percentileRank.toInt()}%',
                style: AppTypography.body2.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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

  Color _getReadinessColor(bool ready) {
    return ready ? AppColors.success : AppColors.warning;
  }

  String _getReadinessText(bool ready) {
    return ready ? 'Ready to Submit' : 'Needs Improvement';
  }

  String _getPercentileDescription(double percentile) {
    if (percentile >= 90) {
      return 'Excellent performance';
    } else if (percentile >= 75) {
      return 'Above average performance';
    } else if (percentile >= 50) {
      return 'Average performance';
    } else if (percentile >= 25) {
      return 'Below average performance';
    } else {
      return 'Needs significant improvement';
    }
  }
}