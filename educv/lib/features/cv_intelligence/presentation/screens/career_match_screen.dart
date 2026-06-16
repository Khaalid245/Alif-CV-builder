import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../cv/presentation/providers/cv_provider.dart';
import '../providers/career_match_provider.dart';
import '../../data/models/career_match_models.dart';

class CareerMatchScreen extends HookConsumerWidget {
  const CareerMatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobDescriptionController = useTextEditingController();
    final matchState = ref.watch(careerMatchProvider);
    final cvProfileState = ref.watch(cvProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Career Match Intelligence'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
      ),
      body: cvProfileState.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text("Please create a CV first."));
          }
          
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeroSection(matchState),
                    const SizedBox(height: AppSpacing.xl),
                    _buildJobDescriptionInput(context, ref, jobDescriptionController, profile.id),
                    const SizedBox(height: AppSpacing.xl),
                    
                    if (matchState.result != null) ...[
                      _buildStrengthsSection(matchState.result!),
                      const SizedBox(height: AppSpacing.xl),
                      _buildMissingSkillsSection(matchState.result!),
                      const SizedBox(height: AppSpacing.xl),
                      _buildMissingKeywordsSection(matchState.result!),
                      const SizedBox(height: AppSpacing.xl),
                      _buildImprovementPlanSection(matchState.result!),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildOptimizeButton(),
                    ],
                    
                    if (matchState.error != null)
                      AppErrorState(
                        message: matchState.error!,
                        onRetry: () => ref.read(careerMatchProvider.notifier).analyzeMatch(profile.id, jobDescriptionController.text),
                      ),
                      
                    const SizedBox(height: 100), // padding
                  ],
                ),
              ),
              if (matchState.isLoading)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black26,
                    child: Center(child: AppLoader()),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: AppLoader()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildHeroSection(CareerMatchState state) {
    final score = state.result?.overallMatch ?? 0;
    final status = state.result?.status ?? "Analyze a Job Description";
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryLight, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3310B981),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Overall Match',
            style: AppTypography.headingSmall.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: AppSpacing.sm),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Text(
                state.result != null ? '$score%' : '--',
                style: AppTypography.headingLarge.copyWith(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: AppTypography.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobDescriptionInput(BuildContext context, WidgetRef ref, TextEditingController controller, String cvId) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Target Job Description',
              style: AppTypography.headingSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: controller,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Paste the job description here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  ref.read(careerMatchProvider.notifier).analyzeMatch(cvId, controller.text);
                },
                icon: const Icon(LucideIcons.sparkles),
                label: const Text('Analyze Match'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrengthsSection(CareerMatchResult result) {
    if (result.strengths.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detected Strengths',
          style: AppTypography.headingSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'These skills match the job description and increase your compatibility.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: result.strengths.map((s) => _buildStrengthChip(s)).toList(),
        ),
      ],
    );
  }

  Widget _buildStrengthChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.checkCircle2, size: 16, color: AppColors.success),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingSkillsSection(CareerMatchResult result) {
    if (result.missingSkills.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Missing Skills',
          style: AppTypography.headingSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.md),
        ...result.missingSkills.map((ms) => _buildMissingSkillRow(ms)),
      ],
    );
  }

  Widget _buildMissingSkillRow(MissingSkill skill) {
    Color importanceColor;
    switch (skill.importance) {
      case 'High':
        importanceColor = AppColors.error;
        break;
      case 'Medium':
        importanceColor = AppColors.warning;
        break;
      default:
        importanceColor = AppColors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skill.name,
                  style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Importance: ',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      skill.importance,
                      style: AppTypography.bodySmall.copyWith(color: importanceColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+${skill.estimatedImprovement}%',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingKeywordsSection(CareerMatchResult result) {
    if (result.missingKeywords.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Keywords Analysis',
          style: AppTypography.headingSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          elevation: 0,
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (result.presentKeywords.isNotEmpty) ...[
                  Text('Present', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: result.presentKeywords.map((k) => Chip(
                      label: Text(k, style: const TextStyle(fontSize: 12)),
                      backgroundColor: AppColors.success.withOpacity(0.1),
                      side: BorderSide.none,
                    )).toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                Text('Missing', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: 6, runSpacing: 6,
                  children: result.missingKeywords.map((k) => Chip(
                    label: Text(k, style: const TextStyle(fontSize: 12)),
                    backgroundColor: AppColors.error.withOpacity(0.1),
                    side: BorderSide.none,
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImprovementPlanSection(CareerMatchResult result) {
    if (result.improvementPlan.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Improvement Plan',
          style: AppTypography.headingSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'A prioritized roadmap to increase your match score.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        ...result.improvementPlan.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final plan = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$index',
                    style: AppTypography.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.action,
                        style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Estimated improvement: +${plan.estimatedImprovement}%',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOptimizeButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          // Future Sprint: AI Rewrite Assistant
        },
        icon: const Icon(LucideIcons.wand2),
        label: const Text('Generate Optimized Resume'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
