import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/premium_saas_theme.dart';
import '../providers/cv_provider.dart';
import '../widgets/form_steps/personal_info_step.dart';
import '../widgets/form_steps/education_step.dart';
import '../widgets/form_steps/experience_step.dart';
import '../widgets/form_steps/skills_step.dart';
import '../widgets/form_steps/languages_step.dart';
import '../widgets/form_steps/projects_step.dart';
import '../widgets/form_steps/certifications_step.dart';
import '../widgets/cv_form_step_shell.dart';
import '../widgets/cv_form_bottom_bar.dart';
import '../../../../core/layout/responsive_layout.dart';
import '../widgets/live_preview/cv_live_preview_widget.dart';

class ImprovedCVFormScreen extends ConsumerStatefulWidget {
  final int initialStep;

  const ImprovedCVFormScreen({
    super.key,
    this.initialStep = 0,
  });

  @override
  ConsumerState<ImprovedCVFormScreen> createState() =>
      _ImprovedCVFormScreenState();
}

class _ImprovedCVFormScreenState extends ConsumerState<ImprovedCVFormScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late int _initialStep;

  final List<CVFormStep> _steps = [
    CVFormStep(
      title: 'Personal Information',
      subtitle: 'Tell us about yourself',
      icon: LucideIcons.user,
      description: 'Add your basic contact information and personal details',
      isRequired: true,
    ),
    CVFormStep(
      title: 'Education',
      subtitle: 'Your academic background',
      icon: LucideIcons.graduationCap,
      description:
          'Add your degrees, certifications, and academic achievements',
      isRequired: true,
    ),
    CVFormStep(
      title: 'Work Experience',
      subtitle: 'Your professional journey',
      icon: LucideIcons.briefcase,
      description:
          'Add your work history, internships, and professional experience',
      isRequired: false,
    ),
    CVFormStep(
      title: 'Skills',
      subtitle: 'What you\'re good at',
      icon: LucideIcons.zap,
      description: 'Add your technical skills, soft skills, and competencies',
      isRequired: false,
    ),
    CVFormStep(
      title: 'Languages',
      subtitle: 'Languages you speak',
      icon: LucideIcons.globe,
      description: 'Add languages you speak and your proficiency level',
      isRequired: false,
    ),
    CVFormStep(
      title: 'Projects',
      subtitle: 'Your notable work',
      icon: LucideIcons.folder,
      description: 'Add personal, academic, or professional projects',
      isRequired: false,
    ),
    CVFormStep(
      title: 'Certifications',
      subtitle: 'Your achievements',
      icon: LucideIcons.award,
      description: 'Add professional certifications and courses',
      isRequired: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initialStep = widget.initialStep;
    _pageController = PageController(initialPage: _initialStep);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cvFormStepProvider.notifier).state = _initialStep;
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = ref.watch(cvFormStepProvider);
    final isLoading = ref.watch(cvFormLoadingProvider);
    final cvProfile = ref.watch(cvProfileProvider);

    final completion = cvProfile.value?.completionPercentage ?? 0;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ResponsiveBuilder(
        builder: (context, deviceType) {
          final step = _steps[currentStep];
          final isLastStep = currentStep == _steps.length - 1;

          final formColumn = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFormToolbar(currentStep, completion, deviceType),
              Expanded(
                child: ColoredBox(
                  color: PremiumSaaSTheme.lightBackground,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      ref.read(cvFormStepProvider.notifier).state = index;
                    },
                    children: List.generate(
                      _steps.length,
                      (index) => _buildStepPage(index),
                    ),
                  ),
                ),
              ),
              CVFormBottomBar(
                currentStep: currentStep,
                totalSteps: _steps.length,
                stepTitle: step.title,
                isLoading: isLoading,
                showPrevious: currentStep > 0,
                onPrevious: _goToPreviousStep,
                onPrimary: isLoading ? null : _goToNextStep,
                primaryLabel: isLastStep ? 'Preview CV' : 'Save & continue',
                primaryIcon:
                    isLastStep ? LucideIcons.eye : LucideIcons.arrowRight,
              ),
            ],
          );

          if (!deviceType.isMobile) {
            // Split Screen Layout
            return Row(
              children: [
                Expanded(
                  flex: 1,
                  child: formColumn,
                ),
                Container(width: 1, color: PremiumSaaSTheme.lightBorder),
                const Expanded(
                  flex: 1,
                  child: CVLivePreviewWidget(),
                ),
              ],
            );
          }

          return formColumn;
        },
      ),
    );
  }

  /// Single compact toolbar — clear hierarchy, no stacked headers.
  Widget _buildFormToolbar(
    int currentStep,
    int completionPercentage,
    DeviceType deviceType,
  ) {
    final step = _steps[currentStep];
    final horizontalPadding = deviceType.isMobile ? 12.0 : 20.0;

    return Material(
      color: PremiumSaaSTheme.lightSurface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              deviceType.isMobile ? 8 : 12,
              horizontalPadding,
              8,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _showExitConfirmation,
                  icon: const Icon(LucideIcons.arrowLeft, size: 20),
                  color: PremiumSaaSTheme.textSecondary,
                  tooltip: 'Back to dashboard',
                  visualDensity: VisualDensity.compact,
                ),
                Expanded(
                  child: PopupMenuButton<int>(
                    offset: const Offset(0, 40),
                    onSelected: _goToStep,
                    itemBuilder: (context) => List.generate(_steps.length, (i) {
                      final s = _steps[i];
                      return PopupMenuItem(
                        value: i,
                        child: Row(
                          children: [
                            if (i < currentStep)
                              const Icon(
                                LucideIcons.check,
                                size: 16,
                                color: PremiumSaaSTheme.accentGreen,
                              )
                            else
                              const SizedBox(width: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(s.title)),
                          ],
                        ),
                      );
                    }),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Step ${currentStep + 1} of ${_steps.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: PremiumSaaSTheme.textSecondary,
                          ),
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                step.title,
                                style: TextStyle(
                                  fontSize: deviceType.isMobile ? 16 : 18,
                                  fontWeight: FontWeight.w700,
                                  color: PremiumSaaSTheme.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              LucideIcons.chevronDown,
                              size: 18,
                              color: PremiumSaaSTheme.textSecondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: PremiumSaaSTheme.primaryPurple.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$completionPercentage%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: PremiumSaaSTheme.primaryPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                horizontalPadding, 0, horizontalPadding, 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: (currentStep + 1) / _steps.length,
                minHeight: 3,
                backgroundColor: PremiumSaaSTheme.lightBorder,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  PremiumSaaSTheme.primaryPurple,
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: PremiumSaaSTheme.lightBorder),
        ],
      ),
    );
  }

  Widget _buildStepPage(int index) {
    final step = _steps[index];
    final Widget body;
    switch (index) {
      case 0:
        body = const PersonalInfoStep();
        break;
      case 1:
        body = const EducationStep();
        break;
      case 2:
        body = const ExperienceStep();
        break;
      case 3:
        body = const SkillsStep();
        break;
      case 4:
        body = const LanguagesStep();
        break;
      case 5:
        body = const ProjectsStep();
        break;
      case 6:
        body = const CertificationsStep();
        break;
      default:
        body = const SizedBox.shrink();
    }

    return CVFormStepShell(
      icon: step.icon,
      title: step.title,
      description: step.description,
      isRequired: step.isRequired,
      child: body,
    );
  }

  void _goToStep(int step) {
    ref.read(cvFormStepProvider.notifier).state = step;
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToPreviousStep() {
    final currentStep = ref.read(cvFormStepProvider);
    if (currentStep > 0) {
      _goToStep(currentStep - 1);
    }
  }

  void _goToNextStep() async {
    final currentStep = ref.read(cvFormStepProvider);

    // Handle save logic for step 0
    if (currentStep == 0) {
      final saveFn = ref.read(cvFormSaveProvider);
      if (saveFn != null) {
        final success = await saveFn();
        if (!success) return;
      }
    }

    if (!mounted) return;

    if (currentStep < _steps.length - 1) {
      _goToStep(currentStep + 1);
    } else {
      context.go('/cv/preview');
    }
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(
              LucideIcons.alertTriangle,
              color: PremiumSaaSTheme.accentAmber,
              size: 24,
            ),
            SizedBox(width: 12),
            Text(
              'Exit CV Builder?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: PremiumSaaSTheme.textPrimary,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to go back to the dashboard? Any unsaved changes will be lost.',
          style: TextStyle(
            fontSize: 14,
            color: PremiumSaaSTheme.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Stay Here',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: PremiumSaaSTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/cv/dashboard');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PremiumSaaSTheme.accentRose,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}

class CVFormStep {
  final String title;
  final String subtitle;
  final IconData icon;
  final String description;
  final bool isRequired;

  CVFormStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.description,
    required this.isRequired,
  });
}
