import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'section_padding.dart';
import 'section_header.dart';

class FeaturesGrid extends StatelessWidget {
  const FeaturesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionPadding(
      child: Column(
        children: [
          const SectionHeader(
            eyebrow: 'Why EduCV',
            title: 'Built for students.\nTrusted by the university.',
          ),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWeb = constraints.maxWidth >= 800;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isWeb ? 3 : 2,
                mainAxisSpacing: isWeb ? 16 : 12,
                crossAxisSpacing: isWeb ? 16 : 12,
                childAspectRatio: isWeb ? 1.2 : 1.1,
                children: [
                  _buildFeatureCard(
                    LucideIcons.lock,
                    'Your data is private',
                    'All information is encrypted and stored securely. Only you control your data.',
                  ),
                  _buildFeatureCard(
                    LucideIcons.zap,
                    'Instant generation',
                    'Generate all three CV formats in seconds. No waiting, no delays.',
                  ),
                  _buildFeatureCard(
                    LucideIcons.download,
                    'PDF ready to send',
                    'Download print-quality PDFs that work with any application system.',
                  ),
                  _buildFeatureCard(
                    LucideIcons.smartphone,
                    'Mobile and web',
                    'Access your CV builder from any device. Start on mobile, finish on desktop.',
                  ),
                  _buildFeatureCard(
                    LucideIcons.award,
                    'University endorsed',
                    'Built in partnership with career services. Meets all professional standards.',
                  ),
                  _buildFeatureCard(
                    LucideIcons.users,
                    'Built for all students',
                    'From first-year to PhD. Every field of study. Every career path supported.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: const Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: AppTypography.body.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0A0A0A),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              description,
              style: AppTypography.body.copyWith(
                fontSize: 12,
                color: const Color(0xFF6B7280),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}