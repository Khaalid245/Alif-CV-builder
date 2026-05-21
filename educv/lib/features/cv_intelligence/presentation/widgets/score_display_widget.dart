import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/cv_intelligence_models.dart';

class ScoreDisplayWidget extends HookWidget {
  final double score;
  final double maxScore;
  final String title;
  final String? subtitle;
  final bool showPercentage;
  final bool animated;
  final VoidCallback? onTap;

  const ScoreDisplayWidget({
    super.key,
    required this.score,
    required this.maxScore,
    required this.title,
    this.subtitle,
    this.showPercentage = true,
    this.animated = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );
    
    final animation = useAnimation(
      Tween<double>(begin: 0, end: score / maxScore).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOutCubic),
      ),
    );

    useEffect(() {
      if (animated) {
        animationController.forward();
      }
      return null;
    }, []);

    final percentage = maxScore > 0 ? (score / maxScore) * 100 : 0.0;
    final displayValue = animated ? animation * maxScore : score;
    final displayPercentage = animated ? animation * 100 : percentage;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildScoreDisplay(displayValue, displayPercentage),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildProgressBar(animation),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreDisplay(double displayValue, double displayPercentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          showPercentage 
            ? '${displayPercentage.toStringAsFixed(0)}%'
            : '${displayValue.toStringAsFixed(1)}/${maxScore.toStringAsFixed(0)}',
          style: AppTypography.headingSmall.copyWith(
            color: _getScoreColor(displayPercentage),
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          _getScoreLabel(displayPercentage),
          style: AppTypography.bodySmall.copyWith(
            color: _getScoreColor(displayPercentage),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double progress) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getScoreColor(progress * 100),
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 90) return AppColors.success;
    if (percentage >= 70) return AppColors.primary;
    if (percentage >= 50) return AppColors.warning;
    return AppColors.error;
  }

  String _getScoreLabel(double percentage) {
    if (percentage >= 90) return 'Excellent';
    if (percentage >= 70) return 'Good';
    if (percentage >= 50) return 'Average';
    return 'Needs Work';
  }
}

class SectionScoreCard extends StatelessWidget {
  final String sectionName;
  final SectionScoreModel sectionScore;
  final VoidCallback? onTap;

  const SectionScoreCard({
    super.key,
    required this.sectionName,
    required this.sectionScore,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _formatSectionName(sectionName),
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(sectionScore.percentage).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${sectionScore.percentage.toStringAsFixed(0)}%',
                      style: AppTypography.bodySmall.copyWith(
                        color: _getStatusColor(sectionScore.percentage),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              LinearProgressIndicator(
                value: sectionScore.percentage / 100,
                backgroundColor: AppColors.surface,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getStatusColor(sectionScore.percentage),
                ),
              ),
              if (sectionScore.suggestions.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  sectionScore.suggestions.first,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatSectionName(String name) {
    return name.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
  }

  Color _getStatusColor(double percentage) {
    if (percentage >= 90) return AppColors.success;
    if (percentage >= 70) return AppColors.primary;
    if (percentage >= 50) return AppColors.warning;
    return AppColors.error;
  }
}