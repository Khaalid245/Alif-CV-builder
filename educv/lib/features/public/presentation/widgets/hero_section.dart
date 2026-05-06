import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth >= 800;
          
          return Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.symmetric(
              horizontal: isWeb ? 40 : 20,
              vertical: isWeb ? 72 : 48,
            ),
            child: isWeb ? _buildWebLayout() : _buildMobileLayout(),
          );
        },
      ),
    );
  }

  Widget _buildWebLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildLeftContent(isWeb: true)),
        const SizedBox(width: 48),
        SizedBox(width: 320, child: _buildCVPreviewCard()),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLeftContent(isWeb: false),
        const SizedBox(height: 40),
        _buildCVPreviewCard(),
      ],
    );
  }

  Widget _buildLeftContent({required bool isWeb}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBadge(),
        const SizedBox(height: 20),
        _buildHeading(isWeb: isWeb),
        const SizedBox(height: 16),
        _buildSubtitle(),
        const SizedBox(height: 32),
        _buildButtons(),
        const SizedBox(height: 36),
        _buildTrustRow(),
      ],
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF1565C0),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Official university platform',
            style: AppTypography.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1565C0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeading({required bool isWeb}) {
    return RichText(
      text: TextSpan(
        style: AppTypography.display.copyWith(
          fontSize: isWeb ? 42 : 28,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0A0A0A),
          letterSpacing: -0.025,
          height: 1.15,
        ),
        children: [
          const TextSpan(text: 'Your career starts with a '),
          TextSpan(
            text: '\ngreat CV',
            style: TextStyle(color: const Color(0xFF1565C0)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Fill in your details once. EduCV instantly generates three formally designed, recruiter-ready CV templates — downloaded as PDF in seconds.',
      style: AppTypography.body.copyWith(
        fontSize: 15,
        color: const Color(0xFF4A4A4A),
        height: 1.65,
      ),
    );
  }

  Widget _buildButtons() {
    return Builder(
      builder: (context) => Row(
        children: [
          Expanded(
            child: AppButton(
              text: 'Create My CV Free',
              onPressed: () => context.go('/register'),
              icon: LucideIcons.users,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton.secondary(
              'See how it works',
              onPressed: () {
                // TODO: Scroll to how-it-works section
              },
              icon: LucideIcons.playCircle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustRow() {
    return Row(
      children: [
        _buildAvatarStack(),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTypography.caption.copyWith(
                fontSize: 12,
                color: const Color(0xFF6B7280),
                height: 1.45,
              ),
              children: [
                const TextSpan(text: 'Trusted by '),
                TextSpan(
                  text: '2,400+ students',
                  style: TextStyle(fontWeight: FontWeight.w700),
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
      {'initials': 'AK', 'bg': Color(0xFFFFDDD2), 'text': Color(0xFFC0440A)},
      {'initials': 'SR', 'bg': Color(0xFFD1FAE5), 'text': Color(0xFF065F46)},
      {'initials': 'MN', 'bg': Color(0xFFEDE9FE), 'text': Color(0xFF5B21B6)},
      {'initials': 'FO', 'bg': Color(0xFFDBEAFE), 'text': Color(0xFF1E40AF)},
    ];

    return SizedBox(
      width: 28 + (avatars.length - 1) * 21, // 28px + overlap
      height: 28,
      child: Stack(
        children: avatars.asMap().entries.map((entry) {
          final index = entry.key;
          final avatar = entry.value;
          
          return Positioned(
            left: index * 21.0,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: CircleAvatar(
                backgroundColor: avatar['bg'] as Color,
                child: Text(
                  avatar['initials'] as String,
                  style: AppTypography.caption.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: avatar['text'] as Color,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          _buildCompletionSection(),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          _buildSkillsSection(),
          const SizedBox(height: 12),
          _buildBottomStrip(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              'AK',
              style: AppTypography.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ahmed Khalil',
                style: AppTypography.body.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Computer Science · Year 3',
                style: AppTypography.caption.copyWith(
                  fontSize: 11,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'CV Ready',
            style: AppTypography.caption.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1565C0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CV COMPLETION',
          style: AppTypography.caption.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B7280),
            letterSpacing: 0.07,
          ),
        ),
        const SizedBox(height: 8),
        _buildCompletionBar('Education', 100, const Color(0xFF1565C0)),
        const SizedBox(height: 6),
        _buildCompletionBar('Experience', 80, const Color(0xFF0FB9B1)),
        const SizedBox(height: 6),
        _buildCompletionBar('Skills', 90, const Color(0xFF8B5CF6)),
        const SizedBox(height: 6),
        _buildCompletionBar('Projects', 65, const Color(0xFF34C48B)),
      ],
    );
  }

  Widget _buildCompletionBar(String label, int percentage, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 68,
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              fontSize: 10,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$percentage%',
          style: AppTypography.caption.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B7280),
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
          style: AppTypography.caption.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B7280),
            letterSpacing: 0.07,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: [
            _buildSkillChip('Flutter', const Color(0xFFEAF2FF), const Color(0xFF1565C0)),
            _buildSkillChip('Python', const Color(0xFFF3EFFF), const Color(0xFF7C3AED)),
            _buildSkillChip('Django', const Color(0xFFE6FBF5), const Color(0xFF059669)),
            _buildSkillChip('+5 more', const Color(0xFFF3F4F6), const Color(0xFF6B7280)),
          ],
        ),
      ],
    );
  }

  Widget _buildSkillChip(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildBottomStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0),
              borderRadius: BorderRadius.circular(3),
            ),
            child: const Icon(
              LucideIcons.download,
              size: 10,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '3 CVs generated · Modern, Classic, Academic',
              style: AppTypography.caption.copyWith(
                fontSize: 10,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          Text(
            'Download',
            style: AppTypography.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1565C0),
            ),
          ),
        ],
      ),
    );
  }
}