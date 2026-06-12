import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/widgets/premium_saas_grid_background.dart';

class StatItem {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const StatItem(this.value, this.label, this.icon, this.color);
}

class PremiumSaaSStatsSection extends StatelessWidget {
  const PremiumSaaSStatsSection({super.key});

  static const List<StatItem> _stats = [
    StatItem('2,400+', 'Students registered', Icons.people_outline,
        Color(0xFF4F46E5)),
    StatItem('8,900+', 'CVs generated', Icons.description_outlined,
        Color(0xFF7C3AED)),
    StatItem('3', 'Professional templates', Icons.design_services_outlined,
        Color(0xFF10B981)),
    StatItem('5 min', 'Average time to CV', Icons.schedule_outlined,
        Color(0xFFF59E0B)),
  ];

  @override
  Widget build(BuildContext context) {
    return PremiumSaaSGridBackground(
      opacity: 0.02,
      showRadialGradient: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 24),
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
    );
  }

  Widget _buildDesktopLayout() {
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
      childAspectRatio: 1.0,
      children: _stats
          .asMap()
          .entries
          .map((entry) => _buildStatCard(entry.value, entry.key))
          .toList(),
    );
  }

  Widget _buildStatCard(StatItem stat, int index) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: stat.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  stat.icon,
                  size: 32,
                  color: stat.color,
                ),
              )
                  .animate(delay: (200 + index * 100).ms)
                  .fadeIn(duration: 600.ms)
                  .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0)),

              const SizedBox(height: 24),

              // Value with gradient
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    stat.color,
                    stat.color.withValues(alpha: 0.7),
                  ],
                ).createShader(bounds),
                child: Text(
                  stat.value,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
              )
                  .animate(delay: (300 + index * 100).ms)
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: 0.3, end: 0)
                  .then()
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .shimmer(
                    duration: 3000.ms,
                    color: stat.color.withValues(alpha: 0.3),
                  ),

              const SizedBox(height: 12),

              // Label
              Text(
                stat.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              )
                  .animate(delay: (400 + index * 100).ms)
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: 0.3, end: 0),
            ],
          ),
        ),
      ),
    )
        .animate(delay: (100 + index * 150).ms)
        .fadeIn(duration: 1000.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0))
        .then()
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .moveY(
          begin: 0,
          end: -6,
          duration: (4000 + index * 500).ms,
          curve: Curves.easeInOut,
        );
  }
}
