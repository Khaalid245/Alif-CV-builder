import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/premium_dark_colors.dart';
import '../../../../core/theme/premium_dark_typography.dart';

class StatItem {
  final String value;
  final String label;

  const StatItem(this.value, this.label);
}

class PremiumStatsBar extends StatelessWidget {
  const PremiumStatsBar({super.key});

  static const List<StatItem> _stats = [
    StatItem('2,400+', 'Students registered'),
    StatItem('8,900+', 'CVs generated'),
    StatItem('3', 'Professional templates'),
    StatItem('5 min', 'Average time to CV'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PremiumDarkColors.card,
        border: Border(
          top: BorderSide(color: PremiumDarkColors.border, width: 1),
          bottom: BorderSide(color: PremiumDarkColors.border, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth >= 800;

          if (isWeb) {
            return Row(
              children: _stats.asMap().entries.map((entry) {
                final index = entry.key;
                final stat = entry.value;

                return Expanded(
                  child: Row(
                    children: [
                      if (index > 0)
                        Container(
                          width: 1,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                PremiumDarkColors.border,
                                Colors.transparent,
                              ],
                            ),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                      Expanded(child: _buildStatItem(stat, index)),
                    ],
                  ),
                );
              }).toList(),
            );
          } else {
            return Column(
              children: _stats
                  .asMap()
                  .entries
                  .map((entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: _buildStatItem(entry.value, entry.key),
                      ))
                  .toList(),
            );
          }
        },
      ),
    );
  }

  Widget _buildStatItem(StatItem stat, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          stat.value,
          style: PremiumDarkTypography.sectionTitle.copyWith(
            fontSize: 32,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [
                  PremiumDarkColors.gradientStart,
                  PremiumDarkColors.gradientEnd,
                ],
              ).createShader(const Rect.fromLTWH(0, 0, 100, 50)),
          ),
        )
            .animate(delay: (200 + index * 100).ms)
            .fadeIn(duration: 800.ms)
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: 8),
        Text(
          stat.label,
          style: PremiumDarkTypography.bodyMedium,
          textAlign: TextAlign.center,
        )
            .animate(delay: (300 + index * 100).ms)
            .fadeIn(duration: 800.ms)
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }
}