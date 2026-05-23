import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PremiumDarkHowItWorksSection extends StatelessWidget {
  const PremiumDarkHowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
      ),
      child: SizedBox(
        height: 600,
        child: Stack(
          children: [
            // Subtle grid background
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _GridPainter(),
                ),
              ),
            ),
            // Radial gradient overlay
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.0, -0.3),
                      radius: 1.5,
                      colors: [
                        const Color(0xFF4F46E5).withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Content
            Center(
              child: ConstrainedBox(
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
                        final isDesktop = constraints.maxWidth >= 900;
                        return isDesktop ? _buildDesktopLayout() : _buildMobileLayout();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
            border: Border.all(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'HOW IT WORKS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4F46E5),
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'From zero to professional CV\nin three simple steps',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          'No design skills needed. No templates to fight with. Just fill in what you know and we handle the rest.',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.7),
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: _buildStepCard(
            1,
            LucideIcons.userPlus,
            'Create your account',
            'Register with your university email and student ID. Takes 30 seconds. Secured and private.',
            const Color(0xFF4F46E5),
          ),
        ),
        _buildConnector(),
        Flexible(
          child: _buildStepCard(
            2,
            LucideIcons.edit3,
            'Fill in your information',
            'Add education, experience, skills, projects, and languages through our guided step-by-step form.',
            const Color(0xFF7C3AED),
          ),
        ),
        _buildConnector(),
        Flexible(
          child: _buildStepCard(
            3,
            LucideIcons.download,
            'Download your CVs',
            'Instantly receive 3 professionally designed PDFs — Classic, Modern, and Academic formats ready to send.',
            const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildStepCard(
          1,
          LucideIcons.userPlus,
          'Create your account',
          'Register with your university email and student ID. Takes 30 seconds. Secured and private.',
          const Color(0xFF4F46E5),
        ),
        const SizedBox(height: 40),
        _buildStepCard(
          2,
          LucideIcons.edit3,
          'Fill in your information',
          'Add education, experience, skills, projects, and languages through our guided step-by-step form.',
          const Color(0xFF7C3AED),
        ),
        const SizedBox(height: 40),
        _buildStepCard(
          3,
          LucideIcons.download,
          'Download your CVs',
          'Instantly receive 3 professionally designed PDFs — Classic, Modern, and Academic formats ready to send.',
          const Color(0xFF10B981),
        ),
      ],
    );
  }

  Widget _buildStepCard(int stepNumber, IconData icon, String title, String description, Color accentColor) {
    return _StepCard(
      stepNumber: stepNumber,
      icon: icon,
      title: title,
      description: description,
      accentColor: accentColor,
    );
  }

  Widget _buildConnector() {
    return Container(
      width: 100,
      height: 64,
      margin: const EdgeInsets.only(top: 32),
      child: Stack(
        children: [
          // Connecting line
          Positioned(
            top: 32,
            left: 0,
            right: 20,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
          ),
          // Arrow
          Positioned(
            top: 26,
            right: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 8,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: 800.ms)
        .fadeIn(duration: 1000.ms);
  }
}

class _StepCard extends StatefulWidget {
  final int stepNumber;
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;

  const _StepCard({
    required this.stepNumber,
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
  });

  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard> {
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
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          border: Border.all(
            color: _isHovered 
                ? widget.accentColor.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: _isHovered 
                  ? widget.accentColor.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: _isHovered ? 32 : 20,
              offset: Offset(0, _isHovered ? 16 : 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step number and icon row
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.accentColor,
                            widget.accentColor.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: widget.accentColor.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.stepNumber.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: widget.accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        widget.icon,
                        size: 24,
                        color: widget.accentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Title
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Description
                Text(
                  widget.description,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: (widget.stepNumber * 200).ms)
        .fadeIn(duration: 800.ms)
        .slideY(begin: 0.3, end: 0);
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const gridSize = 50.0;

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}