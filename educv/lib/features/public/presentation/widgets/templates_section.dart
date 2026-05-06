import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'section_padding.dart';
import 'section_header.dart';

class TemplatesSection extends StatelessWidget {
  const TemplatesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFF),
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: SectionPadding(
        child: Column(
          children: [
            const SectionHeader(
              eyebrow: 'CV Templates',
              title: 'Three formats.\nEvery opportunity covered.',
            ),
            const SizedBox(height: 40),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWeb = constraints.maxWidth >= 800;
                return isWeb ? _buildWebLayout() : _buildMobileLayout();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebLayout() {
    return Row(
      children: [
        Expanded(child: _buildTemplateCard('Classic', 'Professional two-column layout with navy sidebar. Perfect for corporate and government positions.', 'Professional', false, _buildClassicThumbnail())),
        const SizedBox(width: 16),
        Expanded(child: _buildTemplateCard('Modern', 'Clean single-column design with teal header. Ideal for tech companies and creative roles.', 'Popular', true, _buildModernThumbnail())),
        const SizedBox(width: 16),
        Expanded(child: _buildTemplateCard('Academic', 'Structured formal layout with burgundy accents. Best for research positions and scholarships.', 'Academic', false, _buildAcademicThumbnail())),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildTemplateCard('Classic', 'Professional two-column layout with navy sidebar. Perfect for corporate and government positions.', 'Professional', false, _buildClassicThumbnail()),
        const SizedBox(height: 16),
        _buildTemplateCard('Modern', 'Clean single-column design with teal header. Ideal for tech companies and creative roles.', 'Popular', true, _buildModernThumbnail()),
        const SizedBox(height: 16),
        _buildTemplateCard('Academic', 'Structured formal layout with burgundy accents. Best for research positions and scholarships.', 'Academic', false, _buildAcademicThumbnail()),
      ],
    );
  }

  Widget _buildTemplateCard(String name, String description, String tag, bool isFeatured, Widget thumbnail) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isFeatured ? const Color(0xFF1565C0) : AppColors.divider,
          width: isFeatured ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFeatured) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Most Popular',
                style: AppTypography.caption.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          thumbnail,
          const SizedBox(height: 14),
          Text(
            name,
            style: AppTypography.body.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0A0A0A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: AppTypography.body.copyWith(
              fontSize: 11,
              color: const Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          _buildTagChip(tag, isFeatured),
        ],
      ),
    );
  }

  Widget _buildTagChip(String tag, bool isFeatured) {
    Color bgColor;
    Color textColor;
    
    if (isFeatured) {
      bgColor = const Color(0xFFEAF2FF);
      textColor = const Color(0xFF1565C0);
    } else {
      bgColor = const Color(0xFFF3F4F6);
      textColor = const Color(0xFF6B7280);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tag,
        style: AppTypography.caption.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildClassicThumbnail() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Left column (sidebar)
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // Right column (main content)
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernThumbnail() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Container(
                width: 40,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Content lines
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 3),
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 3),
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicThumbnail() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Centered header
          Center(
            child: Container(
              width: 30,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Divider line
          Container(
            height: 1,
            decoration: BoxDecoration(
              color: const Color(0xFF666666),
              borderRadius: BorderRadius.circular(0.5),
            ),
          ),
          const SizedBox(height: 4),
          // Content lines
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 3),
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 3),
          Container(
            height: 2,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}