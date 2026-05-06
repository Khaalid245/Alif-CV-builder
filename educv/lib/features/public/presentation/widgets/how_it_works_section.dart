import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'section_padding.dart';
import 'section_header.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionPadding(
      child: Column(
        children: [
          const SectionHeader(
            eyebrow: 'How it works',
            title: 'From zero to professional CV\nin three steps',
            subtitle: 'No design skills needed. No templates to fight with. Just fill in what you know and we handle the rest.',
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
    );
  }

  Widget _buildWebLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildStepCard(1, 'Create your account', 'Register with your university email and student ID. Takes 30 seconds. Secured and private.')),
        _buildConnector(),
        Expanded(child: _buildStepCard(2, 'Fill in your information', 'Add education, experience, skills, projects, and languages through our guided step-by-step form.')),
        _buildConnector(),
        Expanded(child: _buildStepCard(3, 'Download your CVs', 'Instantly receive 3 professionally designed PDFs — Classic, Modern, and Academic formats ready to send.')),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildStepCard(1, 'Create your account', 'Register with your university email and student ID. Takes 30 seconds. Secured and private.'),
        const SizedBox(height: 24),
        _buildStepCard(2, 'Fill in your information', 'Add education, experience, skills, projects, and languages through our guided step-by-step form.'),
        const SizedBox(height: 24),
        _buildStepCard(3, 'Download your CVs', 'Instantly receive 3 professionally designed PDFs — Classic, Modern, and Academic formats ready to send.'),
      ],
    );
  }

  Widget _buildStepCard(int stepNumber, String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              stepNumber.toString(),
              style: AppTypography.body.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1565C0),
              ),
            ),
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
        Text(
          description,
          style: AppTypography.body.copyWith(
            fontSize: 12,
            color: const Color(0xFF6B7280),
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector() {
    return Container(
      width: 24,
      height: 36,
      child: Stack(
        children: [
          Positioned(
            top: 18,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              color: const Color(0xFFEEEEEE),
            ),
          ),
          Positioned(
            top: 15,
            right: 0,
            child: Container(
              width: 6,
              height: 6,
              child: CustomPaint(
                painter: ArrowPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(3, 3);
    path.lineTo(0, 6);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}