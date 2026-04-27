import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/utils/auth_utils.dart';
import '../providers/cv_provider.dart';

class CVDashboardScreen extends ConsumerWidget {
  const CVDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(cvProfileProvider);
    
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
            onPressed: () => logoutUser(context, ref),
            icon: Icon(
              Icons.logout,
              color: AppColors.text,
              size: 20,
            ),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error loading profile: $error',
            style: AppTypography.body.copyWith(color: AppColors.error),
          ),
        ),
        data: (profile) => SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                'Hello, ${profile.fullName.split(' ').first} 👋',
                style: AppTypography.h1,
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                'Let\'s build your professional CV',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              
              SizedBox(height: AppSpacing.xl),
              
              // Completion Card
              SectionCard(
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
                              SizedBox(height: AppSpacing.sm),
                              Text(
                                '${profile.completionPercentage}%',
                                style: AppTypography.display.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 32,
                                ),
                              ),
                              SizedBox(height: AppSpacing.xs),
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
                            value: profile.completionPercentage / 100,
                            backgroundColor: AppColors.primaryLight,
                            valueColor: AlwaysStoppedAnimation(AppColors.primary),
                            strokeWidth: 6,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: AppSpacing.md),
                    
                    LinearProgressIndicator(
                      value: profile.completionPercentage / 100,
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      minHeight: 3,
                    ),
                    
                    SizedBox(height: AppSpacing.md),
                    
                    if (profile.completionPercentage < 100)
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
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            'Your CV is complete!',
                            style: AppTypography.caption.copyWith(
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              
              SizedBox(height: AppSpacing.xl),
              
              // Quick Actions
              Text(
                'Quick Actions',
                style: AppTypography.h3,
              ),
              SizedBox(height: AppSpacing.sm),
              
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.go('/cv/form'),
                      child: SectionCard(
                        child: Column(
                          children: [
                            Icon(
                              Icons.edit,
                              color: AppColors.primary,
                              size: 28,
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              'Edit My CV',
                              style: AppTypography.h3,
                            ),
                            SizedBox(height: AppSpacing.xs),
                            Text(
                              'Update your information',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: AppSpacing.md),
                  
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.go('/pdf/result'),
                      child: SectionCard(
                        child: Column(
                          children: [
                            Icon(
                              Icons.download,
                              color: AppColors.primary,
                              size: 28,
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              'Generate CVs',
                              style: AppTypography.h3,
                            ),
                            SizedBox(height: AppSpacing.xs),
                            Text(
                              'Download 3 formats',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: AppSpacing.xl),
              
              // CV Sections Status
              Text(
                'Your CV Sections',
                style: AppTypography.h3,
              ),
              SizedBox(height: AppSpacing.sm),
              
              _CVSectionStatusTile(
                icon: Icons.school,
                title: 'Education',
                hasData: profile.education.isNotEmpty,
                onTap: () => context.go('/cv/form?step=1'),
              ),
              
              SizedBox(height: AppSpacing.sm),
              
              _CVSectionStatusTile(
                icon: Icons.work,
                title: 'Experience',
                hasData: profile.experiences.isNotEmpty,
                onTap: () => context.go('/cv/form?step=2'),
              ),
              
              SizedBox(height: AppSpacing.sm),
              
              _CVSectionStatusTile(
                icon: Icons.flash_on,
                title: 'Skills',
                hasData: profile.skills.isNotEmpty,
                onTap: () => context.go('/cv/form?step=3'),
              ),
              
              SizedBox(height: AppSpacing.sm),
              
              _CVSectionStatusTile(
                icon: Icons.language,
                title: 'Languages',
                hasData: profile.languages.isNotEmpty,
                onTap: () => context.go('/cv/form?step=4'),
              ),
              
              SizedBox(height: AppSpacing.sm),
              
              _CVSectionStatusTile(
                icon: Icons.code,
                title: 'Projects',
                hasData: profile.projects.isNotEmpty,
                onTap: () => context.go('/cv/form?step=5'),
              ),
              
              SizedBox(height: AppSpacing.sm),
              
              _CVSectionStatusTile(
                icon: Icons.emoji_events,
                title: 'Certifications',
                hasData: profile.certifications.isNotEmpty,
                onTap: () => context.go('/cv/form?step=6'),
              ),
              
              SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _CVSectionStatusTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool hasData;
  final VoidCallback onTap;

  const _CVSectionStatusTile({
    required this.icon,
    required this.title,
    required this.hasData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
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
                Icons.check_circle,
                color: Colors.green,
                size: 18,
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