import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/premium_portfolio_colors.dart';
import '../providers/cv_provider.dart';
import '../widgets/form_steps/personal_info_step.dart';
import '../widgets/form_steps/education_step.dart';
import '../widgets/form_steps/experience_step.dart';
import '../widgets/form_steps/skills_step.dart';
import '../widgets/form_steps/languages_step.dart';
import '../widgets/form_steps/projects_step.dart';
import '../widgets/form_steps/certifications_step.dart';
import '../../../../core/widgets/breadcrumb_navigation.dart';

class ImprovedCVFormScreen extends ConsumerStatefulWidget {
  final int initialStep;

  const ImprovedCVFormScreen({
    super.key,
    this.initialStep = 0,
  });

  @override
  ConsumerState<ImprovedCVFormScreen> createState() => _ImprovedCVFormScreenState();
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
      description: 'Add your degrees, certifications, and academic achievements',
      isRequired: true,
    ),
    CVFormStep(
      title: 'Work Experience',
      subtitle: 'Your professional journey',
      icon: LucideIcons.briefcase,
      description: 'Add your work history, internships, and professional experience',
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

    return Scaffold(
      backgroundColor: PremiumPortfolioColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Breadcrumb Navigation
              BreadcrumbNavigation(
                items: AppBreadcrumbs.cvForm(currentStep),
                onNavigate: (route) => context.go(route),
              ),
              
              // Modern Header with Progress
              _buildModernHeader(currentStep, cvProfile.value?.completionPercentage ?? 0),
              
              // Step Navigation Pills
              _buildStepNavigation(currentStep),
              
              // Main Content Area
              Expanded(
                child: Row(
                  children: [
                    // Left Sidebar - Step Overview
                    _buildStepSidebar(currentStep),
                    
                    // Main Form Content
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: PageView(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
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
                      ),
                    ),
                  ],
                ),
              ),
              
              // Modern Bottom Navigation
              _buildModernBottomNavigation(currentStep, isLoading),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(int currentStep, int completionPercentage) {
    final step = _steps[currentStep];
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row - Back button and completion
          Row(
            children: [
              // Back to Dashboard
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showExitConfirmation(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: PremiumPortfolioColors.borderLight),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.arrowLeft,
                          size: 16,
                          color: PremiumPortfolioColors.secondaryText,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Back to Dashboard',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: PremiumPortfolioColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Completion Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      PremiumPortfolioColors.success.withOpacity(0.1),
                      PremiumPortfolioColors.accentBlue.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: PremiumPortfolioColors.success.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.checkCircle2,
                      size: 16,
                      color: PremiumPortfolioColors.success,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$completionPercentage% Complete',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: PremiumPortfolioColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Main Title Section
          Row(
            children: [
              // Step Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      PremiumPortfolioColors.accentPurple,
                      PremiumPortfolioColors.accentBlue,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: PremiumPortfolioColors.accentPurple.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  step.icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Step Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Step ${currentStep + 1} of ${_steps.length}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: PremiumPortfolioColors.accentPurple,
                          ),
                        ),
                        if (step.isRequired) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: PremiumPortfolioColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Required',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: PremiumPortfolioColors.error,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.title,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: PremiumPortfolioColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: PremiumPortfolioColors.secondaryText,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Progress Bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: PremiumPortfolioColors.borderLight,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (currentStep + 1) / _steps.length,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      PremiumPortfolioColors.accentPurple,
                      PremiumPortfolioColors.accentBlue,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepNavigation(int currentStep) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isActive = index == currentStep;
            final isCompleted = index < currentStep;
            
            return GestureDetector(
              onTap: () => _goToStep(index),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive 
                    ? PremiumPortfolioColors.accentPurple.withOpacity(0.1)
                    : isCompleted
                      ? PremiumPortfolioColors.success.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive 
                      ? PremiumPortfolioColors.accentPurple
                      : isCompleted
                        ? PremiumPortfolioColors.success
                        : PremiumPortfolioColors.borderLight,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCompleted ? LucideIcons.check : step.icon,
                      size: 16,
                      color: isActive 
                        ? PremiumPortfolioColors.accentPurple
                        : isCompleted
                          ? PremiumPortfolioColors.success
                          : PremiumPortfolioColors.secondaryText,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      step.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isActive 
                          ? PremiumPortfolioColors.accentPurple
                          : isCompleted
                            ? PremiumPortfolioColors.success
                            : PremiumPortfolioColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStepSidebar(int currentStep) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(left: 24, top: 24, bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CV Builder Guide',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: PremiumPortfolioColors.primaryText,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Complete each section to build your professional CV. Required sections are marked with a red badge.',
            style: TextStyle(
              fontSize: 14,
              color: PremiumPortfolioColors.secondaryText,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Steps List
          Expanded(
            child: ListView.builder(
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                final step = _steps[index];
                final isActive = index == currentStep;
                final isCompleted = index < currentStep;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _goToStep(index),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isActive 
                            ? PremiumPortfolioColors.accentPurple.withOpacity(0.05)
                            : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive 
                              ? PremiumPortfolioColors.accentPurple.withOpacity(0.2)
                              : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isCompleted
                                  ? PremiumPortfolioColors.success
                                  : isActive
                                    ? PremiumPortfolioColors.accentPurple
                                    : PremiumPortfolioColors.borderLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isCompleted ? LucideIcons.check : step.icon,
                                size: 16,
                                color: isCompleted || isActive 
                                  ? Colors.white 
                                  : PremiumPortfolioColors.secondaryText,
                              ),
                            ),
                            
                            const SizedBox(width: 12),
                            
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          step.title,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: isActive 
                                              ? PremiumPortfolioColors.accentPurple
                                              : PremiumPortfolioColors.primaryText,
                                          ),
                                        ),
                                      ),
                                      if (step.isRequired)
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: PremiumPortfolioColors.error,
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    step.subtitle,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: PremiumPortfolioColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Help Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PremiumPortfolioColors.accentBlue.withOpacity(0.05),
                  PremiumPortfolioColors.accentPurple.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: PremiumPortfolioColors.accentBlue.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.helpCircle,
                      size: 16,
                      color: PremiumPortfolioColors.accentBlue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Need Help?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: PremiumPortfolioColors.accentBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Fill out each section with accurate information. You can always come back and edit later.',
                  style: TextStyle(
                    fontSize: 12,
                    color: PremiumPortfolioColors.secondaryText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernBottomNavigation(int currentStep, bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous Button
          if (currentStep > 0)
            Expanded(
              child: _buildNavigationButton(
                text: 'Previous',
                icon: LucideIcons.arrowLeft,
                onPressed: _goToPreviousStep,
                isPrimary: false,
              ),
            )
          else
            const Expanded(child: SizedBox()),
          
          const SizedBox(width: 16),
          
          // Save & Continue / Finish Button
          Expanded(
            flex: 2,
            child: _buildNavigationButton(
              text: currentStep == _steps.length - 1 ? 'Preview CV' : 'Save & Continue',
              icon: currentStep == _steps.length - 1 ? LucideIcons.eye : LucideIcons.arrowRight,
              onPressed: isLoading ? null : _goToNextStep,
              isPrimary: true,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required String text,
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isPrimary,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: isPrimary ? LinearGradient(
              colors: [
                PremiumPortfolioColors.accentPurple,
                PremiumPortfolioColors.accentBlue,
              ],
            ) : null,
            color: isPrimary ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isPrimary ? null : Border.all(
              color: PremiumPortfolioColors.borderLight,
            ),
            boxShadow: isPrimary ? [
              BoxShadow(
                color: PremiumPortfolioColors.accentPurple.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: Center(
            child: isLoading ? 
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isPrimary ? Colors.white : PremiumPortfolioColors.accentPurple,
                  ),
                ),
              ) :
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isPrimary) ...[
                    Icon(
                      icon,
                      size: 18,
                      color: PremiumPortfolioColors.secondaryText,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isPrimary ? Colors.white : PremiumPortfolioColors.secondaryText,
                    ),
                  ),
                  if (isPrimary) ...[
                    const SizedBox(width: 8),
                    Icon(
                      icon,
                      size: 18,
                      color: Colors.white,
                    ),
                  ],
                ],
              ),
          ),
        ),
      ),
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
        title: Row(
          children: [
            Icon(
              LucideIcons.alertTriangle,
              color: PremiumPortfolioColors.warning,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Exit CV Builder?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: PremiumPortfolioColors.primaryText,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to go back to the dashboard? Any unsaved changes will be lost.',
          style: TextStyle(
            fontSize: 14,
            color: PremiumPortfolioColors.secondaryText,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Stay Here',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: PremiumPortfolioColors.secondaryText,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/cv/dashboard');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PremiumPortfolioColors.error,
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