import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/premium_saas_theme.dart';

class ImprovedOnboardingScreen extends StatefulWidget {
  const ImprovedOnboardingScreen({super.key});

  @override
  State<ImprovedOnboardingScreen> createState() =>
      _ImprovedOnboardingScreenState();
}

class _ImprovedOnboardingScreenState extends State<ImprovedOnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _currentPage = 0;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: 'Welcome to EduCV!',
      subtitle: 'Your Professional CV Builder',
      description:
          'Create stunning, professional CVs in minutes. No design skills needed - just fill in your information and we\'ll handle the rest.',
      icon: LucideIcons.sparkles,
      color: PremiumSaaSTheme.primaryPurple,
      features: [
        'Fill information once, get 3 CV templates',
        'Professional designs approved by employers',
        'Download ready-to-use PDF files',
        'Free for all university students',
      ],
    ),
    OnboardingStep(
      title: 'How It Works',
      subtitle: 'Simple 3-Step Process',
      description:
          'Building your CV is as easy as 1-2-3. Follow our guided process and you\'ll have a professional CV ready in no time.',
      icon: LucideIcons.target,
      color: PremiumSaaSTheme.accentBlue,
      features: [
        '1. Fill in your personal information',
        '2. Add education, skills, and experience',
        '3. Generate and download your CVs',
        'Edit anytime - your data is saved automatically',
      ],
    ),
    OnboardingStep(
      title: 'Three Professional Templates',
      subtitle: 'Choose What Fits Your Career',
      description:
          'Each template is designed for different career paths. You get all three automatically - use the right one for each job application.',
      icon: LucideIcons.layout,
      color: PremiumSaaSTheme.accentGreen,
      features: [
        'Classic: Perfect for corporate and government jobs',
        'Modern: Great for tech and creative roles',
        'Academic: Ideal for research and education',
        'All templates are ATS-friendly',
      ],
    ),
    OnboardingStep(
      title: 'Ready to Start?',
      subtitle: 'Let\'s Build Your First CV',
      description:
          'You\'re all set! Click the button below to start building your professional CV. Remember, you can always edit and improve it later.',
      icon: LucideIcons.rocket,
      color: PremiumSaaSTheme.accentAmber,
      features: [
        'Start with basic information',
        'Add sections one by one',
        'Preview your CV anytime',
        'Download when you\'re ready',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumSaaSTheme.lightBackground,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header with progress
              _buildHeader(),

              // Main content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _steps.length,
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(_steps[index]);
                  },
                ),
              ),

              // Bottom navigation
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PremiumSaaSTheme.lightSurface,
        boxShadow: PremiumSaaSTheme.shadowSoft,
      ),
      child: Column(
        children: [
          // Logo and skip
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      PremiumSaaSTheme.primaryPurple,
                      PremiumSaaSTheme.accentBlue,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.fileText,
                  color: PremiumSaaSTheme.lightSurface,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'EduCV',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: PremiumSaaSTheme.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/cv/dashboard'),
                child: const Text(
                  'Skip Tour',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: PremiumSaaSTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Progress indicator
          Row(
            children: List.generate(_steps.length, (index) {
              final isActive = index == _currentPage;
              final isCompleted = index < _currentPage;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: index < _steps.length - 1 ? 8 : 0,
                  ),
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive || isCompleted
                        ? _steps[_currentPage].color
                        : PremiumSaaSTheme.lightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingStep step) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  step.color.withOpacity(0.1),
                  step.color.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(
                color: step.color.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Icon(
              step.icon,
              size: 48,
              color: step.color,
            ),
          ),

          const SizedBox(height: 32),

          // Title and subtitle
          Text(
            step.title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: PremiumSaaSTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            step.subtitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: step.color,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Description
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              step.description,
              style: const TextStyle(
                fontSize: 16,
                color: PremiumSaaSTheme.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 40),

          // Features list
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: step.features.map((feature) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PremiumSaaSTheme.lightSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: step.color.withOpacity(0.1),
                    ),
                    boxShadow: PremiumSaaSTheme.shadowSoft,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: step.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          LucideIcons.check,
                          size: 14,
                          color: step.color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: PremiumSaaSTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final isLastPage = _currentPage == _steps.length - 1;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PremiumSaaSTheme.lightSurface,
        boxShadow: PremiumSaaSTheme.shadowSoft,
      ),
      child: Row(
        children: [
          // Previous button
          if (_currentPage > 0)
            Expanded(
              child: _buildNavigationButton(
                text: 'Previous',
                icon: LucideIcons.arrowLeft,
                onPressed: _goToPreviousPage,
                isPrimary: false,
              ),
            )
          else
            const Expanded(child: SizedBox()),

          const SizedBox(width: 16),

          // Next/Get Started button
          Expanded(
            flex: 2,
            child: _buildNavigationButton(
              text: isLastPage ? 'Start Building My CV' : 'Next',
              icon: isLastPage ? LucideIcons.rocket : LucideIcons.arrowRight,
              onPressed: isLastPage ? _startBuilding : _goToNextPage,
              isPrimary: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: isPrimary
                ? const LinearGradient(
                    colors: [
                      PremiumSaaSTheme.primaryPurple,
                      PremiumSaaSTheme.accentBlue,
                    ],
                  )
                : null,
            color: isPrimary ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isPrimary
                ? null
                : Border.all(
                    color: PremiumSaaSTheme.lightBorder,
                  ),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: PremiumSaaSTheme.primaryPurple.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isPrimary) ...[
                  Icon(
                    icon,
                    size: 18,
                    color: PremiumSaaSTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isPrimary
                        ? Colors.white
                        : PremiumSaaSTheme.textSecondary,
                  ),
                ),
                if (isPrimary) ...[
                  const SizedBox(width: 8),
                  Icon(
                    icon,
                    size: 18,
                    color: PremiumSaaSTheme.lightSurface,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _startBuilding() {
    context.go('/cv/form');
  }
}

class OnboardingStep {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> features;

  OnboardingStep({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.features,
  });
}
