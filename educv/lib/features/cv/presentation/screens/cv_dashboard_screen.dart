import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/auth_utils.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/cv_provider.dart';

class CVDashboardScreen extends ConsumerStatefulWidget {
  const CVDashboardScreen({super.key});

  @override
  ConsumerState<CVDashboardScreen> createState() => _CVDashboardScreenState();
}

class _CVDashboardScreenState extends ConsumerState<CVDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cvProfileProvider.notifier).fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final cvProfile = ref.watch(cvProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('My CV', style: AppTypography.h2),
        actions: [
          IconButton(
            onPressed: () => logoutUser(ref, context),
            icon: const Icon(LucideIcons.logOut, color: AppColors.textPrimary, size: 20),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingSection(currentUser?.fullName ?? ''),

            const SizedBox(height: AppSpacing.xl),

            // Completion Card
            cvProfile.when(
              data: (profile) => _buildCompletionCard(profile?.completionPercentage ?? 0),
              loading: () => _buildCompletionCardSkeleton(),
              error: (e, _) => AppErrorState(
                message: e.toString(),
                onRetry: () => ref.read(cvProfileProvider.notifier).fetch(),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            _buildQuickActions(),

            const SizedBox(height: AppSpacing.xl),

            // CV Sections — real data from profile
            Text('Your CV Sections', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.sm),

            cvProfile.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
              data: (profile) {
                if (profile == null) return const SizedBox.shrink();
                return Column(
                  children: [
                    _SectionStatusTile(
                      icon: LucideIcons.user,
                      name: 'Personal Info',
                      hasData: profile.phone.isNotEmpty || profile.summary.isNotEmpty,
                      count: null,
                      step: 0,
                    ),
                    _SectionStatusTile(
                      icon: LucideIcons.graduationCap,
                      name: 'Education',
                      hasData: profile.education.isNotEmpty,
                      count: profile.education.length,
                      step: 1,
                    ),
                    _SectionStatusTile(
                      icon: LucideIcons.briefcase,
                      name: 'Work Experience',
                      hasData: profile.experiences.isNotEmpty,
                      count: profile.experiences.length,
                      step: 2,
                    ),
                    _SectionStatusTile(
                      icon: LucideIcons.zap,
                      name: 'Skills',
                      hasData: profile.skills.isNotEmpty,
                      count: profile.skills.length,
                      step: 3,
                    ),
                    _SectionStatusTile(
                      icon: LucideIcons.globe,
                      name: 'Languages',
                      hasData: profile.languages.isNotEmpty,
                      count: profile.languages.length,
                      step: 4,
                    ),
                    _SectionStatusTile(
                      icon: LucideIcons.code2,
                      name: 'Projects',
                      hasData: profile.projects.isNotEmpty,
                      count: profile.projects.length,
                      step: 5,
                    ),
                    _SectionStatusTile(
                      icon: LucideIcons.award,
                      name: 'Certifications',
                      hasData: profile.certifications.isNotEmpty,
                      count: profile.certifications.length,
                      step: 6,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingSection(String fullName) {
    final name = fullName.split(' ').first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hello, $name 👋', style: AppTypography.h1),
        const SizedBox(height: 4),
        Text(
          'Let\'s build your professional CV',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildCompletionCard(int completionPercentage) {
    return SectionCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CV Completion', style: AppTypography.h3),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '$completionPercentage%',
                      style: AppTypography.display.copyWith(color: AppColors.primary, fontSize: 32),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'of your CV is filled',
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator.adaptive(
                  value: completionPercentage / 100,
                  backgroundColor: AppColors.primaryLight,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  strokeWidth: 6,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: completionPercentage / 100,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 3,
          ),
          const SizedBox(height: AppSpacing.md),
          if (completionPercentage < 100)
            Text(
              'Complete your profile to generate better CVs',
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
            )
          else
            Row(
              children: [
                const Icon(LucideIcons.check, size: 16, color: AppColors.success),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Your CV is complete!',
                  style: AppTypography.caption.copyWith(color: AppColors.success),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCompletionCardSkeleton() {
    return SectionCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  width: 60,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(color: AppColors.divider, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: LucideIcons.fileEdit,
                title: 'Edit My CV',
                subtitle: 'Update your information',
                onTap: () => context.go('/cv/form'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildActionCard(
                icon: LucideIcons.fileDown,
                title: 'Generate CVs',
                subtitle: 'Download 3 formats',
                onTap: () => context.go('/pdf/result'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SectionCard(
        child: Column(
          children: [
            Icon(icon, size: 28, color: AppColors.primary),
            const SizedBox(height: AppSpacing.sm),
            Text(title, style: AppTypography.h3, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionStatusTile extends StatelessWidget {
  final IconData icon;
  final String name;
  final bool hasData;
  final int? count;
  final int step;

  const _SectionStatusTile({
    required this.icon,
    required this.name,
    required this.hasData,
    required this.count,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/cv/form', extra: {'initialStep': step}),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTypography.body),
                  Text(
                    hasData
                        ? (count != null ? '$count ${count == 1 ? 'entry' : 'entries'}' : 'Filled')
                        : 'Not added yet',
                    style: AppTypography.caption.copyWith(
                      color: hasData ? AppColors.success : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (hasData)
              const Icon(LucideIcons.check, size: 18, color: AppColors.success)
            else
              Text(
                'Add',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
