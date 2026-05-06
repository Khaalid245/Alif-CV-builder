import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

class StatItem {
  final String value;
  final String label;

  const StatItem(this.value, this.label);
}

class StatsBar extends StatelessWidget {
  const StatsBar({super.key});

  static const List<StatItem> _stats = [
    StatItem('2,400+', 'Students registered'),
    StatItem('8,900+', 'CVs generated'),
    StatItem('3', 'Professional templates'),
    StatItem('5 min', 'Average time to CV'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFF),
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 40),
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
                          height: 40,
                          color: const Color(0xFFEEEEEE),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                      Expanded(child: _buildStatItem(stat)),
                    ],
                  ),
                );
              }).toList(),
            );
          } else {
            return Column(
              children: _stats.map((stat) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _buildStatItem(stat),
                )
              ).toList(),
            );
          }
        },
      ),
    );
  }

  Widget _buildStatItem(StatItem stat) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          stat.value,
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.02,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stat.label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}