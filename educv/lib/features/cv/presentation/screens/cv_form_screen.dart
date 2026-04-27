import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialStep);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cvFormStepProvider.notifier).state = widget.initialStep;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<String> _stepTitles = [
    'Personal Info',
    'Education',
    'Work Experience',
    'Skills',
    'Languages',
    'Projects',
    'Certifications',
  ];

  final List<Widget> _steps = [
    PersonalInfoStep(),
    EducationStep(),
    ExperienceStep(),
    SkillsStep(),
    LanguagesStep(),
    ProjectsStep(),
    CertificationsStep(),
  ];

  void _nextStep() async {
    final currentStep = ref.read(cvFormStepProvider);
    final isLoading = ref.read(cvFormLoadingProvider);
    
    if (isLoading) return;
    
    ref.read(cvFormLoadingProvider.notifier).state = true;
    
    try {
      // Save current step data here if needed
      await Future.delayed(Duration(milliseconds: 500)); // Simulate save
      
      if (currentStep < 6) {
        final nextStep = currentStep + 1;
        ref.read(cvFormStepProvider.notifier).state = nextStep;
        _pageController.animateToPage(
          nextStep,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        // Last step - go to preview
        context.go('/cv/preview');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e')),
      );
    } finally {
      ref.read(cvFormLoadingProvider.notifier).state = false;
    }
  }

  void _previousStep() {
    final currentStep = ref.read(cvFormStepProvider);
    
    if (currentStep > 0) {
      final prevStep = currentStep - 1;
      ref.read(cvFormStepProvider.notifier).state = prevStep;
      _pageController.animateToPage(
        prevStep,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // First step - go back to dashboard with confirmation
      _showExitConfirmation();
    }
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit Form?'),
        content: Text('Any unsaved changes will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/cv/dashboard');
            },
            child: Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = ref.watch(cvFormStepProvider);
    final isLoading = ref.watch(cvFormLoadingProvider);
    final profileAsync = ref.watch(cvProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Step Indicator
            _StepIndicator(
              currentStep: currentStep,
              totalSteps: 7,
              stepTitle: _stepTitles[currentStep],
              completionPercentage: profileAsync.value?.completionPercentage ?? 0,
            ),
            
            // Step Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  ref.read(cvFormStepProvider.notifier).state = index;
                },
                itemCount: _steps.length,
                itemBuilder: (context, index) => _steps[index],
              ),
            ),
            
            // Bottom Navigation
            _BottomNavigation(
              currentStep: currentStep,
              isLoading: isLoading,
              onBack: _previousStep,
              onNext: _nextStep,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String stepTitle;
  final int completionPercentage;

  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitle,
    required this.completionPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
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
                'Step ${currentStep + 1} of $totalSteps',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Spacer(),
              Text(
                stepTitle,
                style: AppTypography.h3,
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completionPercentage%',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppSpacing.sm),
          
          LinearProgressIndicator(
            value: (currentStep + 1) / totalSteps,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
            minHeight: 3,
          ),
        ],
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  final int currentStep;
  final bool isLoading;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _BottomNavigation({
    required this.currentStep,
    required this.isLoading,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (currentStep > 0)
            SizedBox(
              width: 140,
              child: AppButton.secondary(
                'Back',
                onPressed: onBack,
              ),
            )
          else
            SizedBox(width: 140),
          
          Spacer(),
          
          SizedBox(
            width: 140,
            child: AppButton.primary(
              currentStep == 6 ? 'Preview CV' : 'Next',
              onPressed: onNext,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }
}