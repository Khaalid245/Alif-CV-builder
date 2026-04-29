import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/cv_provider.dart';
import '../widgets/form_steps/personal_info_step.dart';
import '../widgets/form_steps/education_step.dart';
import '../widgets/form_steps/experience_step.dart';
import '../widgets/form_steps/skills_step.dart';
import '../widgets/form_steps/languages_step.dart';
import '../widgets/form_steps/projects_step.dart';
import '../widgets/form_steps/certifications_step.dart';

class CVFormScreen extends ConsumerStatefulWidget {
  final int initialStep;

  const CVFormScreen({
    super.key,
    this.initialStep = 0,
  });

  @override
  ConsumerState<CVFormScreen> createState() => _CVFormScreenState();
}

class _CVFormScreenState extends ConsumerState<CVFormScreen> {
  late PageController _pageController;

  final List<String> _stepTitles = [
    'Personal Info',
    'Education',
    'Work Experience',
    'Skills',
    'Languages',
    'Projects',
    'Certifications',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialStep);
    
    // Set initial step in provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cvFormStepProvider.notifier).state = widget.initialStep;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = ref.watch(cvFormStepProvider);
    final isLoading = ref.watch(cvFormLoadingProvider);
    final cvProfile = ref.watch(cvProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Step Indicator
            _buildStepIndicator(currentStep, cvProfile.value?.completionPercentage ?? 0),
            
            // Step Content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  ref.read(cvFormStepProvider.notifier).state = index;
                },
                children: const [
                  PersonalInfoStep(),
                  EducationStep(),
                  ExperienceStep(),
                  SkillsStep(),
                  LanguagesStep(),
                  ProjectsStep(),
                  CertificationsStep(),
                ],
              ),
            ),
            
            // Bottom Navigation
            _buildBottomNavigation(currentStep, isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int currentStep, int completionPercentage) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Step ${currentStep + 1} of 7',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                _stepTitles[currentStep],
                style: AppTypography.h3,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completionPercentage%',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          LinearProgressIndicator(
            value: (currentStep + 1) / 7,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(int currentStep, bool isLoading) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back Button
          if (currentStep > 0)
            SizedBox(
              width: 140,
              child: AppButton(
                text: 'Back',
                onPressed: _goToPreviousStep,
              ),
            )
          else
            const SizedBox(width: 140),
          
          const Spacer(),
          
          // Next Button
          SizedBox(
            width: 140,
            child: AppButton(
              text: currentStep == 6 ? 'Preview CV' : 'Next',
              onPressed: isLoading ? null : _goToNextStep,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }

  void _goToPreviousStep() {
    final currentStep = ref.read(cvFormStepProvider);
    if (currentStep > 0) {
      final newStep = currentStep - 1;
      ref.read(cvFormStepProvider.notifier).state = newStep;
      _pageController.animateToPage(
        newStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Go back to dashboard with confirmation if there are unsaved changes
      _showExitConfirmation();
    }
  }

  void _goToNextStep() async {
    final currentStep = ref.read(cvFormStepProvider);
    
    if (currentStep < 6) {
      // Move to next step
      final newStep = currentStep + 1;
      ref.read(cvFormStepProvider.notifier).state = newStep;
      _pageController.animateToPage(
        newStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Go to preview screen
      context.go('/cv/preview');
    }
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Exit CV Form',
          style: AppTypography.h3,
        ),
        content: Text(
          'Are you sure you want to go back to the dashboard? Any unsaved changes will be lost.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Stay',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/cv/dashboard');
            },
            child: Text(
              'Exit',
              style: AppTypography.body.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}