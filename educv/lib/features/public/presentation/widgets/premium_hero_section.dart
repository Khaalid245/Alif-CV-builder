import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/premium_dark_colors.dart';
import '../../../../core/theme/premium_dark_typography.dart';
import '../../../../core/widgets/app_button.dart';

class PremiumHeroSection extends StatelessWidget {
  const PremiumHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PremiumDarkColors.background,
            Color(0xFF0F1419),
          ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth >= 800;
          
          return Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.symmetric(
              horizontal: isWeb ? 40 : 20,
              vertical: isWeb ? 100 : 60,
            ),
            child: isWeb ? _buildWebLayout() : _buildMobileLayout(),
          );
        },
      ),
    );
  }

  Widget _buildWebLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _buildLeftContent(isWeb: true)),
        const SizedBox(width: 60),
        SizedBox(width: 400, child: _buildCVPreviewCard()),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLeftContent(isWeb: false),
        const SizedBox(height: 50),
        _buildCVPreviewCard(),
      ],
    );
  }

  Widget _buildLeftContent({required bool isWeb}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTrustBadge()
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: 24),
        _buildHeading(isWeb: isWeb)
            .animate(delay: 200.ms)
            .fadeIn(duration: 800.ms)
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: 20),
        _buildSubtitle()
            .animate(delay: 400.ms)
            .fadeIn(duration: 800.ms)
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: 40),
        _buildButtons()
            .animate(delay: 600.ms)
            .fadeIn(duration: 800.ms)
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: 48),
        _buildSocialProof()
            .animate(delay: 800.ms)
            .fadeIn(duration: 800.ms)
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildTrustBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: PremiumDarkColors.glassBackground,
        border: Border.all(color: PremiumDarkColors.glassBorder),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: PremiumDarkColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'OFFICIAL UNIVERSITY PLATFORM',
            style: PremiumDarkTypography.trustBadge,
          ),
        ],
      ),
    );
  }

  Widget _buildHeading({required bool isWeb}) {
    return RichText(
      text: TextSpan(
        style: isWeb 
            ? PremiumDarkTypography.heroDisplay 
            : PremiumDarkTypography.heroDisplayMobile,
        children: [
          const TextSpan(text: 'Your career starts\nwith a '),
          TextSpan(
            text: 'great CV',
            style: TextStyle(
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [
                    PremiumDarkColors.gradientStart,
                    PremiumDarkColors.gradientEnd,
                  ],
                ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Fill in your details once. EduCV instantly generates three professionally designed, recruiter-ready CV templates — downloaded as PDF in seconds.',
      style: PremiumDarkTypography.bodyLarge,
    );
  }

  Widget _buildButtons() {
    return Builder(
      builder: (context) => Row(
        children: [
          Expanded(
            child: _buildPrimaryButton(
              label: 'Create My CV Free',
              onPressed: () => context.go('/register'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSecondaryButton(
              label: 'See How It Works',
              onPressed: () {
                // TODO: Scroll to how-it-works section
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({required String label, required VoidCallback onPressed}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            PremiumDarkColors.gradientStart,
            PremiumDarkColors.gradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: PremiumDarkColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.users,
                  size: 20,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(label, style: PremiumDarkTypography.buttonPrimary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({required String label, required VoidCallback onPressed}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: PremiumDarkColors.glassBackground,
        border: Border.all(color: PremiumDarkColors.glassBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.playCircle,
                  size: 20,
                  color: PremiumDarkColors.textPrimary,
                ),
                const SizedBox(width: 8),
                Text(label, style: PremiumDarkTypography.buttonSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialProof() {
    return Row(
      children: [
        _buildAvatarStack(),
        const SizedBox(width: 16),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: PremiumDarkTypography.body,
              children: [
                const TextSpan(text: 'Trusted by '),
                TextSpan(
                  text: '2,400+ students',
                  style: PremiumDarkTypography.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: PremiumDarkColors.textPrimary,
                  ),
                ),
                const TextSpan(text: ' at our university this year'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarStack() {
    final avatars = [
      {'initials': 'AK', 'color': PremiumDarkColors.avatarColors[0]},
      {'initials': 'SR', 'color': PremiumDarkColors.avatarColors[1]},
      {'initials': 'MN', 'color': PremiumDarkColors.avatarColors[2]},
      {'initials': 'FO', 'color': PremiumDarkColors.avatarColors[3]},
    ];

    return SizedBox(
      width: 32 + (avatars.length - 1) * 24,
      height: 32,
      child: Stack(
        children: avatars.asMap().entries.map((entry) {
          final index = entry.key;
          final avatar = entry.value;

          return Positioned(
            left: index * 24.0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: PremiumDarkColors.background, width: 2),
              ),
              child: CircleAvatar(
                backgroundColor: avatar['color'] as Color,
                child: Text(
                  avatar['initials'] as String,
                  style: PremiumDarkTypography.captionBold.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCVPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PremiumDarkColors.card,
        border: Border.all(color: PremiumDarkColors.border),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(),
          const SizedBox(height: 20),
          _buildDivider(),
          const SizedBox(height: 20),
          _buildCompletionSection(),
          const SizedBox(height: 20),
          _buildDivider(),
          const SizedBox(height: 20),
          _buildSkillsSection(),
          const SizedBox(height: 20),
          _buildDownloadSection(),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 1000.ms, delay: 400.ms)
        .slideX(begin: 0.3, end: 0);
  }

  Widget _buildCardHeader() {
    return Row(
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
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              'AK',
              style: PremiumDarkTypography.label.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ahmed Khalil',
                style: PremiumDarkTypography.cardTitle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 2),
              Text(
                'Computer Science · Year 3',
                style: PremiumDarkTypography.caption,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: PremiumDarkColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'CV Ready',
            style: PremiumDarkTypography.captionBold.copyWith(
              color: PremiumDarkColors.success,
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
            PremiumDarkColors.border,
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
          style: PremiumDarkTypography.eyebrow,
        ),
        const SizedBox(height: 16),
        _buildCompletionBar('Education', 100, PremiumDarkColors.primary),
        const SizedBox(height: 12),
        _buildCompletionBar('Experience', 80, const Color(0xFF06B6D4)),
        const SizedBox(height: 12),
        _buildCompletionBar('Skills', 90, const Color(0xFF8B5CF6)),
        const SizedBox(height: 12),
        _buildCompletionBar('Projects', 65, const Color(0xFF10B981)),
      ],
    );
  }

  Widget _buildCompletionBar(String label, int percentage, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: PremiumDarkTypography.caption,
          ),
        ),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: PremiumDarkColors.surface,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$percentage%',
          style: PremiumDarkTypography.captionBold.copyWith(
            color: PremiumDarkColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TOP SKILLS',
          style: PremiumDarkTypography.eyebrow,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSkillChip('Flutter', PremiumDarkColors.primary),
            _buildSkillChip('Python', const Color(0xFF8B5CF6)),
            _buildSkillChip('Django', const Color(0xFF10B981)),
            _buildSkillChip('+5 more', PremiumDarkColors.textSecondary),
          ],
        ),
      ],
    );
  }

  Widget _buildSkillChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: PremiumDarkTypography.captionBold.copyWith(
          color: color,
        ),
      ),
    );
  }

  Widget _buildDownloadSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PremiumDarkColors.glassBackground,
        border: Border.all(color: PremiumDarkColors.glassBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: PremiumDarkColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              LucideIcons.download,
              size: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '3 CVs generated · Modern, Classic, Academic',
              style: PremiumDarkTypography.caption,
            ),
          ),
          Text(
            'Download',
            style: PremiumDarkTypography.captionBold.copyWith(
              color: PremiumDarkColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}