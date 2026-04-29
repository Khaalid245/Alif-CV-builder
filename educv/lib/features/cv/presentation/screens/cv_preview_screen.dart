import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/section_card.dart';
import '../providers/cv_provider.dart';

class CVPreviewScreen extends ConsumerWidget {
  const CVPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cvProfile = ref.watch(cvProfileProvider);
    // Mock completion data since cvCompletionProvider is not available
    final mockCompletion = {'percentage': 75};

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'CV Preview',
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: AppButton(
              text: 'Generate PDFs',
              onPressed: () => context.go('/pdf/result'),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.divider,
          ),
        ),
      ),
      body: cvProfile.when(
        data: (profile) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student Identity Card
              SectionCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: profile.photoUrl != null 
                          ? NetworkImage(profile.photoUrl!) 
                          : null,
                      child: profile.photoUrl == null
                          ? Text(
                              profile.fullName.isNotEmpty 
                                  ? profile.fullName[0].toUpperCase()
                                  : 'U',
                              style: AppTypography.h3.copyWith(
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.fullName.isNotEmpty ? profile.fullName : 'No name provided',
                            style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile.email.isNotEmpty ? profile.email : 'No email provided',
                            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile.studentId.isNotEmpty ? profile.studentId : 'No student ID',
                            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Completion Banner
              _buildCompletionBanner(context, mockCompletion),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Sections Summary
              if (profile.education.isNotEmpty) ...[
                _buildEducationSection(profile.education),
                const SizedBox(height: AppSpacing.lg),
              ],
              
              if (profile.experience.isNotEmpty) ...[
                _buildExperienceSection(profile.experience),
                const SizedBox(height: AppSpacing.lg),
              ],
              
              if (profile.skills.isNotEmpty) ...[
                _buildSkillsSection(profile.skills),
                const SizedBox(height: AppSpacing.lg),
              ],
              
              if (profile.languages.isNotEmpty) ...[
                _buildLanguagesSection(profile.languages),
                const SizedBox(height: AppSpacing.lg),
              ],
              
              if (profile.projects.isNotEmpty) ...[
                _buildProjectsSection(profile.projects),
                const SizedBox(height: AppSpacing.lg),
              ],
              
              if (profile.certifications.isNotEmpty) ...[
                _buildCertificationsSection(profile.certifications),
                const SizedBox(height: AppSpacing.lg),
              ],
              
              const SizedBox(height: AppSpacing.xl),
              
              // Generate Button
              AppButton(
                text: 'Generate My 3 CVs',
                onPressed: () => context.go('/pdf/result'),
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              Text(
                'Classic • Modern • Academic formats',
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 4),
              
              Text(
                'Ready to download as PDF',
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Error loading CV data',
            style: AppTypography.body.copyWith(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionBanner(BuildContext context, Map<String, dynamic> completionData) {
    final percentage = completionData['percentage'] as int;
    final isComplete = percentage >= 60;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isComplete ? const Color(0xFFF0FFF4) : const Color(0xFFFFF8E1),
        border: Border.all(
          color: isComplete ? const Color(0xFFA3D9B1) : const Color(0xFFFFCC02),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            isComplete ? LucideIcons.checkCircle : LucideIcons.alertTriangle,
            color: isComplete ? AppColors.success : AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isComplete 
                      ? 'Great! Your CV is $percentage% complete.'
                      : 'Your CV is $percentage% complete. Consider adding more information for better results.',
                  style: AppTypography.body.copyWith(
                    color: isComplete ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!isComplete) ...[
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () => context.go('/cv/form'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Complete Now',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationSection(List<dynamic> education) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.graduationCap, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Education',
                style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...education.asMap().entries.map((entry) {
            final index = entry.key;
            final edu = entry.value;
            return Column(
              children: [
                if (index > 0) const Divider(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${edu.degree} — ${edu.institution}',
                            style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${edu.startYear}–${edu.endYear ?? 'Present'}',
                            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildExperienceSection(List<dynamic> experience) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.briefcase, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Experience',
                style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...experience.asMap().entries.map((entry) {
            final index = entry.key;
            final exp = entry.value;
            return Column(
              children: [
                if (index > 0) const Divider(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${exp.position} — ${exp.company}',
                            style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${exp.startDate}–${exp.endDate ?? 'Present'}',
                            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(List<dynamic> skills) {
    final skillNames = skills.take(10).map((skill) => skill.name).join(', ');
    final remainingCount = skills.length - 10;
    
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.zap, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Skills',
                style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            remainingCount > 0 ? '$skillNames +$remainingCount more' : skillNames,
            style: AppTypography.body.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagesSection(List<dynamic> languages) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.globe, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Languages',
                style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: languages.map((lang) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${lang.language} (${lang.proficiency})',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsSection(List<dynamic> projects) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.folder, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Projects',
                style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...projects.asMap().entries.map((entry) {
            final index = entry.key;
            final project = entry.value;
            return Column(
              children: [
                if (index > 0) const Divider(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${project.startDate}–${project.endDate ?? 'Present'}',
                            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCertificationsSection(List<dynamic> certifications) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.award, size: 20, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Certifications',
                style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...certifications.asMap().entries.map((entry) {
            final index = entry.key;
            final cert = entry.value;
            return Column(
              children: [
                if (index > 0) const Divider(height: AppSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${cert.name} — ${cert.issuer}',
                            style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            cert.issueDate,
                            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}