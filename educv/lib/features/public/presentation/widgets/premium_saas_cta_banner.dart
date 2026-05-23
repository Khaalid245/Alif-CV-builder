import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/widgets/premium_saas_grid_background.dart';

class PremiumSaasCTABanner extends StatelessWidget {
  const PremiumSaasCTABanner({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumSaaSGridBackground(
      opacity: 0.03,
      showRadialGradient: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF070B14),
              const Color(0xFF0D1320),
              const Color(0xFF4F46E5).withValues(alpha: 0.08),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Floating gradient orbs
            _buildFloatingOrbs(),
            // Main content
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 600;
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                            border: Border.all(
                              color: const Color(0xFF4F46E5).withValues(alpha: 0.2),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'GET STARTED TODAY',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4F46E5),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ).animate()
                            .fadeIn(duration: 800.ms)
                            .slideY(begin: 0.3, end: 0),
                        
                        const SizedBox(height: 32),
                        
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Colors.white,
                              Color(0xFF4F46E5),
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'Your professional CV is\\n3 minutes away',
                            style: TextStyle(
                              fontSize: isDesktop ? 48 : 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ).animate(delay: 200.ms)
                            .fadeIn(duration: 800.ms)
                            .slideY(begin: 0.3, end: 0),
                        
                        const SizedBox(height: 24),
                        
                        Text(
                          'Join 2,400+ students who already built their career with EduCV',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.7),
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ).animate(delay: 400.ms)
                            .fadeIn(duration: 800.ms)
                            .slideY(begin: 0.3, end: 0),
                        
                        const SizedBox(height: 48),
                        
                        _buildCTAButton(context)
                            .animate(delay: 600.ms)
                            .fadeIn(duration: 800.ms)
                            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0))
                            .then()
                            .animate(
                              onPlay: (controller) => controller.repeat(reverse: true),
                            )
                            .shimmer(
                              duration: 3000.ms,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                        
                        const SizedBox(height: 40),
                        
                        _buildTrustIndicators()
                            .animate(delay: 800.ms)
                            .fadeIn(duration: 800.ms)
                            .slideY(begin: 0.3, end: 0),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingOrbs() {
    return Stack(
      children: [
        // Left orb
        Positioned(
          top: 50,
          left: -100,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF4F46E5).withValues(alpha: 0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ).animate(
            onPlay: (controller) => controller.repeat(reverse: true),
          ).moveX(
            begin: 0,
            end: 30,
            duration: 6000.ms,
            curve: Curves.easeInOut,
          ),
        ),
        // Right orb
        Positioned(
          bottom: 30,
          right: -80,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF7C3AED).withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ).animate(
            onPlay: (controller) => controller.repeat(reverse: true),
          ).moveY(
            begin: 0,
            end: -20,
            duration: 5000.ms,
            curve: Curves.easeInOut,
          ),
        ),
      ],
    );
  }

  Widget _buildCTAButton(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.4),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.2),
            blurRadius: 64,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/register'),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    LucideIcons.users,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Create My CV Free',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrustIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTrustItem(
          LucideIcons.shield,
          'Secure & Private',
          const Color(0xFF10B981),
        ),
        const SizedBox(width: 40),
        _buildTrustItem(
          LucideIcons.zap,
          'Instant Results',
          const Color(0xFFF59E0B),
        ),
        const SizedBox(width: 40),
        _buildTrustItem(
          LucideIcons.award,
          'University Approved',
          const Color(0xFF4F46E5),
        ),
      ],
    );
  }

  Widget _buildTrustItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            size: 24,
            color: color,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}