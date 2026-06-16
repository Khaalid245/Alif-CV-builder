import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/premium_saas_theme.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/app_button.dart';

class TopActionData {
  final String action;
  final int estimatedImprovement;

  TopActionData({required this.action, required this.estimatedImprovement});
}

class ResumeActionCenterDialog extends StatelessWidget {
  final int score;
  final String status;
  final String confidence;
  final List<String> basedOn;
  final TopActionData? topAction;
  final Map<String, int> categories;
  final List<String> warnings;
  final List<String> recommendations;

  const ResumeActionCenterDialog({
    super.key,
    required this.score,
    required this.status,
    required this.confidence,
    required this.basedOn,
    this.topAction,
    required this.categories,
    required this.warnings,
    required this.recommendations,
  });

  static void show(
    BuildContext context, {
    required int score,
    required String status,
    required String confidence,
    required List<String> basedOn,
    TopActionData? topAction,
    required Map<String, int> categories,
    required List<String> warnings,
    required List<String> recommendations,
  }) {
    showDialog(
      context: context,
      builder: (context) => ResumeActionCenterDialog(
        score: score,
        status: status,
        confidence: confidence,
        basedOn: basedOn,
        topAction: topAction,
        categories: categories,
        warnings: warnings,
        recommendations: recommendations,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = score >= 90
        ? PremiumSaaSTheme.accentGreen
        : score >= 75
            ? PremiumSaaSTheme.primaryPurple
            : PremiumSaaSTheme.accentAmber;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: PremiumSaaSTheme.lightBackground,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650, maxHeight: 850),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.activity, color: PremiumSaaSTheme.primaryPurple),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Resume Action Center',
                        style: AppTypography.h2.copyWith(color: PremiumSaaSTheme.textPrimary),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, color: PremiumSaaSTheme.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Resume Health Header
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '$score',
                      style: AppTypography.h1.copyWith(color: color, fontSize: 48),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '/ 100',
                      style: AppTypography.body.copyWith(color: PremiumSaaSTheme.textSecondary),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status,
                            style: AppTypography.h3.copyWith(color: color),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Confidence: $confidence',
                            style: AppTypography.caption.copyWith(color: PremiumSaaSTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Based on:', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                        for (var b in basedOn.take(2))
                          Text(b, style: AppTypography.caption),
                        if (basedOn.length > 2)
                          Text('+${basedOn.length - 2} more', style: AppTypography.caption),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Top Action
              if (topAction != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: PremiumSaaSTheme.primaryPurpleLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: PremiumSaaSTheme.primaryPurple.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.star, color: PremiumSaaSTheme.accentAmber, size: 18),
                          const Icon(LucideIcons.star, color: PremiumSaaSTheme.accentAmber, size: 18),
                          const Icon(LucideIcons.star, color: PremiumSaaSTheme.accentAmber, size: 18),
                          const Icon(LucideIcons.star, color: PremiumSaaSTheme.accentAmber, size: 18),
                          const Icon(LucideIcons.star, color: PremiumSaaSTheme.accentAmber, size: 18),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'TOP ACTION',
                            style: AppTypography.caption.copyWith(
                              color: PremiumSaaSTheme.primaryPurple,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        topAction!.action,
                        style: AppTypography.h3.copyWith(color: PremiumSaaSTheme.textPrimary),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: PremiumSaaSTheme.accentGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '+${topAction!.estimatedImprovement} points',
                              style: AppTypography.body.copyWith(
                                color: PremiumSaaSTheme.accentGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          AppButton(
                            text: 'Fix Now',
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Category Scores
              Text('Category Scores', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: categories.entries.map((e) => _buildCategoryScore(e.key, e.value)).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),

              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildListSection(
                        title: 'Warnings',
                        icon: LucideIcons.alertTriangle,
                        iconColor: PremiumSaaSTheme.accentAmber,
                        items: warnings,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: _buildListSection(
                        title: 'Recommendations',
                        icon: LucideIcons.checkCircle,
                        iconColor: PremiumSaaSTheme.accentGreen,
                        items: recommendations.skip(1).toList(), // Skip top action
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppButton(
                    text: 'Close',
                    isOutlined: true,
                    onPressed: () => Navigator.pop(context),
                  ),
                  AppButton(
                    text: 'Generate PDF',
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/pdf/result');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryScore(String title, int score) {
    final color = score >= 90 ? PremiumSaaSTheme.accentGreen : score >= 75 ? PremiumSaaSTheme.primaryPurple : PremiumSaaSTheme.accentAmber;
    return Container(
      width: 130,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: PremiumSaaSTheme.lightBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PremiumSaaSTheme.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.replaceAll('_', ' ').toUpperCase(),
            style: AppTypography.caption.copyWith(fontSize: 10, color: PremiumSaaSTheme.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '$score',
            style: AppTypography.h3.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildListSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<String> items,
  }) {
    if (items.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text(title, style: AppTypography.h4),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('None', style: AppTypography.body.copyWith(color: PremiumSaaSTheme.textSecondary)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Text(title, style: AppTypography.h4),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Icon(LucideIcons.circle, size: 6, color: PremiumSaaSTheme.textSecondary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      items[index],
                      style: AppTypography.body.copyWith(color: PremiumSaaSTheme.textPrimary, fontSize: 13),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
