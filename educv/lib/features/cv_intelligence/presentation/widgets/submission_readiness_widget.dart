import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/cv_intelligence_models.dart';

class SubmissionReadinessWidget extends StatelessWidget {
  final SubmissionReadinessModel readiness;
  final VoidCallback? onImprove;

  const SubmissionReadinessWidget({
    super.key,
    required this.readiness,
    this.onImprove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSpacing.lg),
            _buildScoreSection(),
            const SizedBox(height: AppSpacing.lg),
            _buildStatusSections(),
            if (!readiness.isReady && onImprove != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _buildActionButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getReadinessColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getReadinessIcon(),
            size: 24,
            color: _getReadinessColor(),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Submission Readiness',
                style: AppTypography.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                readiness.overallAssessment.isNotEmpty
                    ? readiness.overallAssessment
                    : _getDefaultAssessment(),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _getReadinessColor().withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getReadinessColor().withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Readiness Score',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  readiness.readinessLevel,
                  style: AppTypography.bodySmall.copyWith(
                    color: _getReadinessColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${readiness.readinessScore.toStringAsFixed(0)}%',
                style: AppTypography.headingMedium.copyWith(
                  color: _getReadinessColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: 80,
                height: 6,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: readiness.readinessScore / 100,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getReadinessColor(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSections() {
    return Column(
      children: [
        if (readiness.readyAspects.isNotEmpty)
          _buildStatusSection(
            title: 'Ready Aspects',
            items: readiness.readyAspects,
            icon: LucideIcons.checkCircle,
            color: AppColors.success,
          ),
        if (readiness.missingAspects.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _buildStatusSection(
            title: 'Missing Aspects',
            items: readiness.missingAspects,
            icon: LucideIcons.xCircle,
            color: AppColors.error,
          ),
        ],
        if (readiness.improvementAreas.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _buildStatusSection(
            title: 'Improvement Areas',
            items: readiness.improvementAreas,
            icon: LucideIcons.alertCircle,
            color: AppColors.warning,
          ),
        ],
      ],
    );
  }

  Widget _buildStatusSection({
    required String title,
    required List<String> items,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: AppSpacing.sm),
            Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.lg,
            bottom: AppSpacing.xs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  item,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onImprove,
        icon: const Icon(LucideIcons.trendingUp),
        label: const Text('Improve CV'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Color _getReadinessColor() {
    if (readiness.readinessScore >= 90) return AppColors.success;
    if (readiness.readinessScore >= 75) return AppColors.primary;
    if (readiness.readinessScore >= 60) return AppColors.warning;
    return AppColors.error;
  }

  IconData _getReadinessIcon() {
    if (readiness.isReady) return LucideIcons.checkCircle;
    if (readiness.readinessScore >= 75) return LucideIcons.clock;
    return LucideIcons.alertTriangle;
  }

  String _getDefaultAssessment() {
    if (readiness.isReady) {
      return 'Your CV is ready for submission!';
    } else if (readiness.readinessScore >= 75) {
      return 'Almost ready! A few improvements will make it perfect.';
    } else if (readiness.readinessScore >= 50) {
      return 'Good progress! Some key areas need attention.';
    } else {
      return 'Several improvements needed before submission.';
    }
  }
}

class ReadinessStatusBadge extends StatelessWidget {
  final SubmissionReadinessModel readiness;
  final bool compact;

  const ReadinessStatusBadge({
    super.key,
    required this.readiness,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getReadinessColor();
    final icon = _getReadinessIcon();
    final text = compact ? _getCompactText() : readiness.readinessLevel;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.sm : AppSpacing.md,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: compact ? 12 : 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: (compact ? AppTypography.bodySmall : AppTypography.bodyMedium).copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getReadinessColor() {
    if (readiness.readinessScore >= 90) return AppColors.success;
    if (readiness.readinessScore >= 75) return AppColors.primary;
    if (readiness.readinessScore >= 60) return AppColors.warning;
    return AppColors.error;
  }

  IconData _getReadinessIcon() {
    if (readiness.isReady) return LucideIcons.checkCircle;
    if (readiness.readinessScore >= 75) return LucideIcons.clock;
    return LucideIcons.alertTriangle;
  }

  String _getCompactText() {
    if (readiness.isReady) return 'Ready';
    if (readiness.readinessScore >= 75) return 'Almost';
    return '${readiness.readinessScore.toStringAsFixed(0)}%';
  }
}