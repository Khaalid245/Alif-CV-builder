import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/premium_dark_colors.dart';
import '../../../../core/theme/premium_dark_typography.dart';
import '../../../../core/widgets/premium_saas_grid_background.dart';

class PremiumSaaSHeroSection extends StatelessWidget {
  const PremiumSaaSHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumSaaSGridBackground(
      opacity: 0.03,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 800),
        child: Stack(
          children: [
            // Animated gradient orbs
            _buildAnimatedOrbs(),
            // Main content
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 900;
                      return isDesktop ? _buildDesktopLayout() : _buildMobileLayout();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedOrbs() {
    return Stack(
      children: [
        // Top-left orb
        Positioned(
          top: 100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF4F46E5).withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ).animate(
            onPlay: (controller) => controller.repeat(reverse: true),
          ).moveX(
            begin: 0,
            end: 50,
            duration: 8000.ms,
            curve: Curves.easeInOut,
          ),
        ),
        // Bottom-right orb
        Positioned(
          bottom: 50,
          right: -150,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF7C3AED).withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ).animate(
            onPlay: (controller) => controller.repeat(reverse: true),
          ).moveY(
            begin: 0,
            end: -30,
            duration: 6000.ms,
            curve: Curves.easeInOut,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: _buildLeftContent(isDesktop: true),
        ),
        const SizedBox(width: 80),
        Expanded(
          flex: 2,
          child: _buildFloatingDashboard(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildLeftContent(isDesktop: false),
        const SizedBox(height: 60),
        _buildFloatingDashboard(),
      ],
    );
  }

  Widget _buildLeftContent({required bool isDesktop}) {
    return Column(
      crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        _buildTrustBadge()
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: 32),
        _buildMainHeadline(isDesktop: isDesktop)
            .animate(delay: 200.ms)
            .fadeIn(duration: 800.ms)
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: 24),
        _buildSubheadline(isDesktop: isDesktop)
            .animate(delay: 400.ms)
            .fadeIn(duration: 800.ms)
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: 48),
        _buildCTAButtons(isDesktop: isDesktop)
            .animate(delay: 600.ms)
            .fadeIn(duration: 800.ms)
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: 56),
        _buildSocialProof()
            .animate(delay: 800.ms)
            .fadeIn(duration: 800.ms)
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildTrustBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
        border: Border.all(
          color: const Color(0xFF4F46E5).withValues(alpha: 0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF4F46E5),
              shape: BoxShape.circle,
            ),
          ).animate(
            onPlay: (controller) => controller.repeat(),
          ).shimmer(
            duration: 2000.ms,
            color: const Color(0xFF4F46E5).withValues(alpha: 0.5),
          ),
          const SizedBox(width: 12),
          Text(
            'OFFICIAL UNIVERSITY PLATFORM',
            style: PremiumDarkTypography.captionBold.copyWith(
              color: const Color(0xFF4F46E5),
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainHeadline({required bool isDesktop}) {
    return RichText(
      textAlign: isDesktop ? TextAlign.left : TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: isDesktop ? 64 : 48,
          fontWeight: FontWeight.w900,
          height: 1.1,
          letterSpacing: -0.02,
        ),
        children: [
          const TextSpan(
            text: 'Your career starts\\nwith a ',
            style: TextStyle(color: Colors.white),
          ),
          TextSpan(
            text: 'perfect CV',
            style: TextStyle(
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [
                    Color(0xFF4F46E5),
                    Color(0xFF7C3AED),
                  ],
                ).createShader(const Rect.fromLTWH(0, 0, 300, 100)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubheadline({required bool isDesktop}) {
    return Text(
      'Fill in your details once. EduCV instantly generates three professionally designed, recruiter-ready CV templates — downloaded as PDF in seconds.',
      style: TextStyle(
        fontSize: isDesktop ? 20 : 18,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF94A3B8),
        height: 1.6,
      ),
      textAlign: isDesktop ? TextAlign.left : TextAlign.center,
    );
  }

  Widget _buildCTAButtons({required bool isDesktop}) {
    return Builder(
      builder: (context) => Flex(
        direction: isDesktop ? Axis.horizontal : Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildPrimaryButton(
            context: context,
            label: 'Create My CV Free',
            onPressed: () => context.go('/register'),
          ),
          SizedBox(
            width: isDesktop ? 20 : 0,
            height: isDesktop ? 0 : 16,
          ),
          _buildSecondaryButton(
            label: 'See How It Works',
            onPressed: () {
              // Scroll to how-it-works section
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 60,
      constraints: const BoxConstraints(minWidth: 200),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.users,
                  size: 20,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    ).shimmer(
      duration: 3000.ms,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 60,
      constraints: const BoxConstraints(minWidth: 200),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.playCircle,
                  size: 20,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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

  Widget _buildSocialProof() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAvatarStack(),
        const SizedBox(width: 20),
        Flexible(
          child: RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF94A3B8),
              ),
              children: [
                TextSpan(text: 'Trusted by '),
                TextSpan(
                  text: '2,400+ students',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                TextSpan(text: ' at our university'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarStack() {
    final avatars = [
      {'initials': 'AK', 'color': const Color(0xFF4F46E5)},
      {'initials': 'SR', 'color': const Color(0xFF7C3AED)},
      {'initials': 'MN', 'color': const Color(0xFF059669)},
      {'initials': 'FO', 'color': const Color(0xFFDC2626)},
    ];

    return SizedBox(
      width: 40 + (avatars.length - 1) * 28,
      height: 40,
      child: Stack(
        children: avatars.asMap().entries.map((entry) {
          final index = entry.key;
          final avatar = entry.value;

          return Positioned(
            left: index * 28.0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF111827),
                  width: 3,
                ),
              ),
              child: CircleAvatar(
                backgroundColor: avatar['color'] as Color,
                child: Text(
                  avatar['initials'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ).animate(delay: (index * 100).ms).fadeIn(duration: 600.ms).scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.0, 1.0),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFloatingDashboard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDashboardHeader(),
          const SizedBox(height: 24),
          _buildDivider(),
          const SizedBox(height: 24),
          _buildCompletionSection(),
          const SizedBox(height: 24),
          _buildDivider(),
          const SizedBox(height: 24),
          _buildSkillsPreview(),
          const SizedBox(height: 24),
          _buildDownloadSection(),
        ],
      ),
    ).animate().fadeIn(duration: 1000.ms, delay: 400.ms).slideX(begin: 0.3, end: 0).then().animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    ).moveY(
      begin: 0,
      end: -8,
      duration: 4000.ms,
      curve: Curves.easeInOut,
    );
  }

  Widget _buildDashboardHeader() {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
            ),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              'AK',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ahmed Khalil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Computer Science · Year 3',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'CV Ready',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF10B981),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CV COMPLETION',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4F46E5),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 20),
        _buildProgressBar('Education', 100, const Color(0xFF4F46E5)),
        const SizedBox(height: 16),
        _buildProgressBar('Experience', 85, const Color(0xFF06B6D4)),
        const SizedBox(height: 16),
        _buildProgressBar('Skills', 90, const Color(0xFF8B5CF6)),
        const SizedBox(height: 16),
        _buildProgressBar('Projects', 75, const Color(0xFF10B981)),
      ],
    );
  }

  Widget _buildProgressBar(String label, int percentage, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ).animate().scaleX(
                begin: 0,
                end: 1,
                duration: 1000.ms,
                delay: 800.ms,
                curve: Curves.easeOutCubic,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          '$percentage%',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TOP SKILLS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4F46E5),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSkillChip('Flutter', const Color(0xFF4F46E5)),
            _buildSkillChip('Python', const Color(0xFF8B5CF6)),
            _buildSkillChip('Django', const Color(0xFF10B981)),
            _buildSkillChip('+5 more', Colors.white.withValues(alpha: 0.4)),
          ],
        ),
      ],
    );
  }

  Widget _buildSkillChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDownloadSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              LucideIcons.download,
              size: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '3 CVs generated · Modern, Classic, Academic',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
          Text(
            'Download',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4F46E5),
            ),
          ),
        ],
      ),
    );
  }
}