import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/auth_utils.dart';
import '../../../../core/widgets/section_card.dart';
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
    // Fetch CV data on screen load
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
        title: Text(
          'My CV',
          style: AppTypography.h2,
        ),
        actions: [
          IconButton(
            onPressed: () => logoutUser(ref, context),
            icon: const Icon(
              LucideIcons.logOut,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Section
            _buildGreetingSection(currentUser?.fullName ?? ''),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Completion Card
            cvProfile.when(
              data: (profile) => _buildCompletionCard(profile?.completionPercentage ?? 0),
              loading: () => _buildCompletionCardSkeleton(),
              error: (_, __) => _buildCompletionCard(0),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Quick Actions
            _buildQuickActions(),
            
            const SizedBox(height: AppSpacing.xl),
            
            // CV Sections Status
            _buildSectionsStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingSection(String firstName) {
    final name = firstName.split(' ').first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, $name 👋',
          style: AppTypography.h1,
        ),
        const SizedBox(height: 4),
        Text(
          'Let\'s build your professional CV',
          style: AppTypography.body.copyWith(
            color: AppColors.textSecondary,
          ),
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
                    Text(
                      'CV Completion',
                      style: AppTypography.h3,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '$completionPercentage%',
                      style: AppTypography.display.copyWith(
                        color: AppColors.primary,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'of your CV is filled',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
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
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            Row(
              children: [
                Icon(
                  LucideIcons.check,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Your CV is complete!',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCompletionCardSkeleton() {
    return SectionCard(
      child: Column(
        children: [
          Row(
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
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTypography.h3,
        ),
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
            Icon(
              icon,
              size: 28,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionsStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your CV Sections',
          style: AppTypography.h3,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildSectionStatusTile(
          icon: LucideIcons.graduationCap,
          name: 'Education',
          hasData: true, // TODO: Get from actual data
          step: 1,
        ),
        _buildSectionStatusTile(
          icon: LucideIcons.briefcase,
          name: 'Experience',
          hasData: false,
          step: 2,
        ),
        _buildSectionStatusTile(
          icon: LucideIcons.zap,
          name: 'Skills',
          hasData: false,
          step: 3,
        ),
        _buildSectionStatusTile(
          icon: LucideIcons.globe,
          name: 'Languages',
          hasData: false,
          step: 4,
        ),
        _buildSectionStatusTile(
          icon: LucideIcons.code2,
          name: 'Projects',
          hasData: false,
          step: 5,
        ),
        _buildSectionStatusTile(
          icon: LucideIcons.award,
          name: 'Certifications',
          hasData: false,
          step: 6,
        ),
      ],
    );
  }

  Widget _buildSectionStatusTile({
    required IconData icon,
    required String name,
    required bool hasData,
    required int step,
  }) {
    return GestureDetector(
      onTap: () => context.go('/cv/form?step=$step'),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTypography.body,
                  ),
                  Text(
                    hasData ? 'Completed' : 'Not added yet',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (hasData)
              Icon(
                LucideIcons.check,
                size: 18,
                color: AppColors.success,
              )
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