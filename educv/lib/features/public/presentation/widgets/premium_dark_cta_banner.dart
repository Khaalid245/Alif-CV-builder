import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/premium_dark_colors.dart';
import '../../../../core/theme/premium_dark_typography.dart';

class PremiumDarkCTABanner extends StatelessWidget {
  const PremiumDarkCTABanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 100),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PremiumDarkColors.background,
            PremiumDarkColors.backgroundSecondary,
            PremiumDarkColors.primary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWeb = constraints.maxWidth >= 600;

            return Column(
              children: [
                Text(
                  'GET STARTED TODAY',
                  style: PremiumDarkTypography.eyebrow.copyWith(
                    color: PremiumDarkColors.primary,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .slideY(begin: 0.3, end: 0),
                const SizedBox(height: 20),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      PremiumDarkColors.textPrimary,
                      PremiumDarkColors.primary,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'Your professional CV is\n3 minutes away',
                    style: isWeb 
                        ? PremiumDarkTypography.heroDisplay.copyWith(
                            fontSize: 40,
                            color: Colors.white,
                          )
                        : PremiumDarkTypography.heroDisplayMobile.copyWith(
                            color: Colors.white,
                          ),
                    textAlign: TextAlign.center,
                  ),
                )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 800.ms)
                    .slideY(begin: 0.3, end: 0),
                const SizedBox(height: 16),
                Text(
                  'Join 2,400+ students who already built their career with EduCV',
                  style: PremiumDarkTypography.bodyLarge.copyWith(
                    color: PremiumDarkColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 800.ms)
                    .slideY(begin: 0.3, end: 0),
                const SizedBox(height: 40),
                _buildCTAButton(context)
                    .animate(delay: 600.ms)
                    .fadeIn(duration: 800.ms)
                    .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0))
                    .then()
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .shimmer(
                      duration: 2000.ms,
                      color: PremiumDarkColors.primary.withValues(alpha: 0.3),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCTAButton(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            PremiumDarkColors.gradientStart,
            PremiumDarkColors.gradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: PremiumDarkColors.glow,
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: PremiumDarkColors.primary.withValues(alpha: 0.3),
            blurRadius: 60,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/register'),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.users,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Create My CV Free',
                  style: PremiumDarkTypography.buttonPrimary.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}