import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/premium_dark_colors.dart';
import '../../../../core/theme/premium_dark_typography.dart';

class StatItem {
  final String value;
  final String label;

  const StatItem(this.value, this.label);
}

class PremiumDarkStatsSection extends StatelessWidget {
  const PremiumDarkStatsSection({super.key});

  static const List<StatItem> _stats = [
    StatItem('2,400+', 'Students registered'),
    StatItem('8,900+', 'CVs generated'),
    StatItem('3', 'Professional templates'),
    StatItem('5 min', 'Average time to CV'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PremiumDarkColors.background,
            PremiumDarkColors.backgroundSecondary,
          ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth >= 800;
          return Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: isWeb ? _buildWebLayout() : _buildMobileLayout(),
          );
        },
      ),
    );
  }

  Widget _buildWebLayout() {
    return Row(
      children: _stats
          .asMap()
          .entries
          .map((entry) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: entry.key < _stats.length - 1 ? 24 : 0,
                  ),
                  child: _buildStatCard(entry.value, entry.key),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildMobileLayout() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: 1.1,
      children: _stats
          .asMap()
          .entries
          .map((entry) => _buildStatCard(entry.value, entry.key))
          .toList(),
    );
  }

  Widget _buildStatCard(StatItem stat, int index) {
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    PremiumDarkColors.gradientStart,
                    PremiumDarkColors.gradientEnd,
                  ],
                ).createShader(bounds),
                child: Text(
                  stat.value,
                  style: PremiumDarkTypography.heroDisplay.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              )
                  .animate(delay: (300 + index * 150).ms)
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: 0.3, end: 0)
                  .then()
                  .shimmer(duration: 2000.ms, color: PremiumDarkColors.primary.withValues(alpha: 0.3)),
              const SizedBox(height: 12),
              Text(
                stat.label,
                style: PremiumDarkTypography.bodyMedium.copyWith(
                  color: PremiumDarkColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              )
                  .animate(delay: (400 + index * 150).ms)
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: 0.3, end: 0),
            ],
          ),
        ),
      ),
    )
        .animate(delay: (200 + index * 100).ms)
        .fadeIn(duration: 1000.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0))
        .then()
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .moveY(
          begin: 0,
          end: -4,
          duration: 3000.ms,
          curve: Curves.easeInOut,
        );
  }
}