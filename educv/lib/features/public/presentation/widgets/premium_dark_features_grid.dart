import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/premium_dark_colors.dart';
import '../../../../core/theme/premium_dark_typography.dart';

class PremiumDarkFeaturesGrid extends StatelessWidget {
  const PremiumDarkFeaturesGrid({super.key});

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
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isWeb ? 3 : 2,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                  childAspectRatio: isWeb ? 1.1 : 1.0,
                  children: [
                    _buildFeatureCard(
                      LucideIcons.shield,
                      'Your data is private',
                      'All information is encrypted and stored securely. Only you control your data.',
                      0,
                    ),
                    _buildFeatureCard(
                      LucideIcons.zap,
                      'Instant generation',
                      'Generate all three CV formats in seconds. No waiting, no delays.',
                      1,
                    ),
                    _buildFeatureCard(
                      LucideIcons.download,
                      'PDF ready to send',
                      'Download print-quality PDFs that work with any application system.',
                      2,
                    ),
                    _buildFeatureCard(
                      LucideIcons.smartphone,
                      'Mobile and web',
                      'Access your CV builder from any device. Start on mobile, finish on desktop.',
                      3,
                    ),
                    _buildFeatureCard(
                      LucideIcons.award,
                      'University endorsed',
                      'Built in partnership with career services. Meets all professional standards.',
                      4,
                    ),
                    _buildFeatureCard(
                      LucideIcons.users,
                      'Built for all students',
                      'From first-year to PhD. Every field of study. Every career path supported.',
                      5,
                    ),
                  ],
                );
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
          'WHY EDUCV',
          style: PremiumDarkTypography.eyebrow.copyWith(
            color: PremiumDarkColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Built for students.\nTrusted by the university.',
          style: PremiumDarkTypography.sectionTitle.copyWith(
            color: PremiumDarkColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description, int index) {
    return _FeatureCard(
      icon: icon,
      title: title,
      description: description,
      index: index,
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final int index;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.index,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -8.0 : 0.0),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: _isHovered 
              ? PremiumDarkColors.glassHover 
              : PremiumDarkColors.glassBackground,
          border: Border.all(
            color: _isHovered 
                ? PremiumDarkColors.borderLight 
                : PremiumDarkColors.glassBorder,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _isHovered 
                  ? PremiumDarkColors.glow.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: _isHovered ? 30 : 20,
              offset: Offset(0, _isHovered ? 12 : 8),
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
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isHovered ? [
                        PremiumDarkColors.gradientStart,
                        PremiumDarkColors.gradientEnd,
                      ] : [
                        PremiumDarkColors.primary.withValues(alpha: 0.1),
                        PremiumDarkColors.primaryLight.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _isHovered ? [
                      BoxShadow(
                        color: PremiumDarkColors.glow,
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ] : null,
                  ),
                  child: Icon(
                    widget.icon,
                    size: 24,
                    color: _isHovered 
                        ? Colors.white 
                        : PremiumDarkColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.title,
                  style: PremiumDarkTypography.cardTitle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: PremiumDarkColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    widget.description,
                    style: PremiumDarkTypography.bodyMedium.copyWith(
                      color: PremiumDarkColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: (200 + widget.index * 100).ms)
        .fadeIn(duration: 800.ms)
        .slideY(begin: 0.3, end: 0)
        .then()
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .moveY(
          begin: 0,
          end: -4,
          duration: (3000 + widget.index * 300).ms,
          curve: Curves.easeInOut,
        );
  }
}