import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../widgets/public_layout.dart';
import '../widgets/section_padding.dart';
import '../widgets/section_header.dart';
import '../widgets/stats_bar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PublicLayout(
      child: Column(
        children: [
          _buildPageHero(),
          _buildMissionSection(),
          _buildUniversityEndorsement(),
          const StatsBar(),
          _buildTechnologySection(),
        ],
      ),
    );
  }

  Widget _buildPageHero() {
    return SectionPadding(
      child: SectionHeader(
        eyebrow: 'About EduCV',
        title: 'A platform built\nfor student success',
        subtitle: 'Born from a real problem — thousands of students graduating without knowing how to present themselves professionally.',
        alignment: CrossAxisAlignment.center,
      ),
    );
  }

  Widget _buildMissionSection() {
    return SectionPadding(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth >= 800;
          return isWeb ? _buildMissionWeb() : _buildMissionMobile();
        },
      ),
    );
  }

  Widget _buildMissionWeb() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildQuoteSection()),
        const SizedBox(width: 48),
        Expanded(child: _buildMissionPoints()),
      ],
    );
  }

  Widget _buildMissionMobile() {
    return Column(
      children: [
        _buildQuoteSection(),
        const SizedBox(height: 32),
        _buildMissionPoints(),
      ],
    );
  }

  Widget _buildQuoteSection() {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          child: Text(
            '"',
            style: AppTypography.display.copyWith(
              fontSize: 120,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFEAF2FF),
              height: 0.8,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 24, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Our mission is to ensure that no student at this university is held back from opportunities because of a poorly formatted CV.',
                style: AppTypography.body.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0A0A0A),
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '— University Career Center',
                style: AppTypography.body.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMissionPoints() {
    final points = [
      'Remove barriers to professional presentation',
      'Standardize CV quality across all departments',
      'Prepare students for the real job market',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: points.map((point) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              LucideIcons.checkCircle,
              size: 20,
              color: Color(0xFF2E7D32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                point,
                style: AppTypography.body.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF0A0A0A),
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildUniversityEndorsement() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFF),
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
      child: Column(
        children: [
          const Icon(
            LucideIcons.award,
            size: 40,
            color: Color(0xFF1565C0),
          ),
          const SizedBox(height: 20),
          Text(
            'Officially endorsed by [University Name]',
            style: AppTypography.h2.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0A0A0A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              'EduCV was proposed by the university dean and implemented as the official CV building platform for all enrolled students. It meets the university\'s standards for student data privacy and professional development.',
              style: AppTypography.body.copyWith(
                fontSize: 14,
                color: const Color(0xFF4A4A4A),
                height: 1.65,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnologySection() {
    return SectionPadding(
      child: Column(
        children: [
          Text(
            'Built with',
            style: AppTypography.caption.copyWith(
              color: const Color(0xFF9E9E9E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              'Flutter',
              'Django',
              'PostgreSQL',
              'DigitalOcean',
              'WeasyPrint',
              'JWT',
            ].map((tech) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                tech,
                style: AppTypography.caption.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A4A4A),
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}