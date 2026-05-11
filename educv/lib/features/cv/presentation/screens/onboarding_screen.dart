import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: LucideIcons.fileText,
      title: 'Welcome to EduCV',
      description: 'Fill in your details once and get 3 professionally designed CVs — Classic, Modern, and Academic — ready to download as PDF.',
      buttonLabel: 'Next',
    ),
    OnboardingPage(
      icon: LucideIcons.clipboardList,
      title: 'Build step by step',
      description: 'Our guided form walks you through 7 simple sections. Add education, experience, skills, and more at your own pace. Everything saves automatically.',
      buttonLabel: 'Next',
    ),
    OnboardingPage(
      icon: LucideIcons.download,
      title: 'Download in seconds',
      description: 'Once done, generate all 3 CV formats instantly and download as PDF — ready to send to employers and internship programs.',
      buttonLabel: 'Get started',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) {
      context.go('/cv/dashboard');
    }
  }

  Future<void> _skipOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) {
      context.go('/cv/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  width: _currentPage == index ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primary
                        : AppColors.divider,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEAF2FF),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page.icon,
                            size: 24,
                            color: AppColors.primary,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Title
                        Text(
                          page.title,
                          style: AppTypography.h1.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0A0A0A),
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 10),

                        // Description
                        Text(
                          page.description,
                          style: AppTypography.body.copyWith(
                            fontSize: 14,
                            color: const Color(0xFF4A4A4A),
                            height: 1.65,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 40),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  AppButton.primary(
                    label: _pages[_currentPage].buttonLabel,
                    onPressed: _nextPage,
                    isFullWidth: true,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'Skip intro',
                      style: AppTypography.caption.copyWith(
                        fontSize: 12,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;

  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
  });
}