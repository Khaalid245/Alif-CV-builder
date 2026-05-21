import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/premium_dark_colors.dart';
import '../../../../core/theme/premium_dark_typography.dart';

class PremiumDarkHowItWorksSection extends StatelessWidget {
  const PremiumDarkHowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
      decoration: const BoxDecoration(
        color: PremiumDarkColors.backgroundSecondary,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            _buildSectionHeader()
                .animate()
                .fadeIn(duration: 800.ms)
                .slideY(begin: 0.3, end: 0),
            const SizedBox(height: 80),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWeb = constraints.maxWidth >= 800;
                return isWeb ? _buildWebLayout() : _buildMobileLayout();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Column(
      children: [
        Text(
          'HOW IT WORKS',
          style: PremiumDarkTypography.eyebrow.copyWith(
            color: PremiumDarkColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'From zero to professional CV\nin three steps',
          style: PremiumDarkTypography.sectionTitle.copyWith(
            color: PremiumDarkColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          'No design skills needed. No templates to fight with. Just fill in what you know and we handle the rest.',
          style: PremiumDarkTypography.bodyLarge.copyWith(
            color: PremiumDarkColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWebLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildStepCard(
            1,
            LucideIcons.userPlus,
            'Create your account',
            'Register with your university email and student ID. Takes 30 seconds. Secured and private.',
          ),
        ),
        _buildConnector(),
        Expanded(
          child: _buildStepCard(
            2,
            LucideIcons.edit3,
            'Fill in your information',
            'Add education, experience, skills, projects, and languages through our guided step-by-step form.',
          ),
        ),
        _buildConnector(),
        Expanded(
          child: _buildStepCard(
            3,
            LucideIcons.download,
            'Download your CVs',
            'Instantly receive 3 professionally designed PDFs — Classic, Modern, and Academic formats ready to send.',
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildStepCard(
          1,
          LucideIcons.userPlus,
          'Create your account',
          'Register with your university email and student ID. Takes 30 seconds. Secured and private.',
        ),
        const SizedBox(height: 40),
        _buildStepCard(
          2,
          LucideIcons.edit3,
          'Fill in your information',
          'Add education, experience, skills, projects, and languages through our guided step-by-step form.',
        ),
        const SizedBox(height: 40),
        _buildStepCard(
          3,
          LucideIcons.download,
          'Download your CVs',
          'Instantly receive 3 professionally designed PDFs — Classic, Modern, and Academic formats ready to send.',
        ),
      ],
    );
  }

  Widget _buildStepCard(int stepNumber, IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: PremiumDarkColors.glassBackground,
        border: Border.all(color: PremiumDarkColors.glassBorder),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          PremiumDarkColors.gradientStart,
                          PremiumDarkColors.gradientEnd,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: PremiumDarkColors.glow,
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        stepNumber.toString(),
                        style: PremiumDarkTypography.cardTitle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: PremiumDarkColors.glassBackground,
                      border: Border.all(color: PremiumDarkColors.glassBorder),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: PremiumDarkColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: PremiumDarkTypography.cardTitle.copyWith(
                  color: PremiumDarkColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: PremiumDarkTypography.body.copyWith(
                  color: PremiumDarkColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: (stepNumber * 200).ms)
        .fadeIn(duration: 800.ms)
        .slideY(begin: 0.3, end: 0)
        .then()
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .moveY(
          begin: 0,
          end: -6,
          duration: (3000 + stepNumber * 500).ms,
          curve: Curves.easeInOut,
        );
  }

  Widget _buildConnector() {
    return Container(
      width: 80,
      height: 48,
      margin: const EdgeInsets.only(top: 24),
      child: Stack(
        children: [
          Positioned(
            top: 24,
            left: 0,
            right: 20,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    PremiumDarkColors.glassBorder,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 18,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: PremiumDarkColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: PremiumDarkColors.glow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: 800.ms)
        .fadeIn(duration: 1000.ms)
        .then()
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .shimmer(
          duration: 2000.ms,
          color: PremiumDarkColors.primary.withValues(alpha: 0.3),
        );
  }
}