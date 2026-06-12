import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PremiumDarkFeaturesGrid extends StatelessWidget {
  const PremiumDarkFeaturesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF070B14),
            Color(0xFF0D1320),
            Color(0xFF111827),
          ],
        ),
      ),
      child: SizedBox(
        height: 800,
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
                      center: const Alignment(0.3, -0.2),
                      radius: 1.2,
                      colors: [
                        const Color(0xFF7C3AED).withValues(alpha: 0.06),
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
                        return isDesktop
                            ? _buildDesktopGrid()
                            : _buildMobileGrid();
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
            'WHY EDUCV',
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
          'Built for students.\nTrusted by the university.',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDesktopGrid() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildFeatureCard(
                LucideIcons.shield,
                'Your data is private',
                'All information is encrypted and stored securely. Only you control your data.',
                const Color(0xFF4F46E5),
                0,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildFeatureCard(
                LucideIcons.zap,
                'Instant generation',
                'Generate all three CV formats in seconds. No waiting, no delays.',
                const Color(0xFFF59E0B),
                1,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildFeatureCard(
                LucideIcons.download,
                'PDF ready to send',
                'Download print-quality PDFs that work with any application system.',
                const Color(0xFF10B981),
                2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildFeatureCard(
                LucideIcons.smartphone,
                'Mobile and web',
                'Access your CV builder from any device. Start on mobile, finish on desktop.',
                const Color(0xFF7C3AED),
                3,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildFeatureCard(
                LucideIcons.award,
                'University endorsed',
                'Built in partnership with career services. Meets all professional standards.',
                const Color(0xFFDC2626),
                4,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildFeatureCard(
                LucideIcons.users,
                'Built for all students',
                'From first-year to PhD. Every field of study. Every career path supported.',
                const Color(0xFF06B6D4),
                5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileGrid() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildFeatureCard(
                LucideIcons.shield,
                'Your data is private',
                'All information is encrypted and stored securely. Only you control your data.',
                const Color(0xFF4F46E5),
                0,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildFeatureCard(
                LucideIcons.zap,
                'Instant generation',
                'Generate all three CV formats in seconds. No waiting, no delays.',
                const Color(0xFFF59E0B),
                1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildFeatureCard(
                LucideIcons.download,
                'PDF ready to send',
                'Download print-quality PDFs that work with any application system.',
                const Color(0xFF10B981),
                2,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildFeatureCard(
                LucideIcons.smartphone,
                'Mobile and web',
                'Access your CV builder from any device. Start on mobile, finish on desktop.',
                const Color(0xFF7C3AED),
                3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildFeatureCard(
                LucideIcons.award,
                'University endorsed',
                'Built in partnership with career services. Meets all professional standards.',
                const Color(0xFFDC2626),
                4,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildFeatureCard(
                LucideIcons.users,
                'Built for all students',
                'From first-year to PhD. Every field of study. Every career path supported.',
                const Color(0xFF06B6D4),
                5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description,
      Color accentColor, int index) {
    return _FeatureCard(
      icon: icon,
      title: title,
      description: description,
      accentColor: accentColor,
      index: index,
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;
  final int index;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.index,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -12.0 : 0.0),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _isHovered
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.white.withValues(alpha: 0.02),
          border: Border.all(
            color: _isHovered
                ? widget.accentColor.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.08),
            width: _isHovered ? 2 : 1,
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
                // Icon container
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: _isHovered
                        ? LinearGradient(
                            colors: [
                              widget.accentColor,
                              widget.accentColor.withValues(alpha: 0.8),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              widget.accentColor.withValues(alpha: 0.1),
                              widget.accentColor.withValues(alpha: 0.05),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: _isHovered
                        ? [
                            BoxShadow(
                              color: widget.accentColor.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    widget.icon,
                    size: 28,
                    color: _isHovered ? Colors.white : widget.accentColor,
                  ),
                )
                    .animate(delay: (200 + widget.index * 100).ms)
                    .fadeIn(duration: 600.ms)
                    .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.0, 1.0)),

                const SizedBox(height: 24),

                // Title
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.3,
                  ),
                )
                    .animate(delay: (300 + widget.index * 100).ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 12),

                // Description
                Text(
                  widget.description,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.6,
                  ),
                )
                    .animate(delay: (400 + widget.index * 100).ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: (100 + widget.index * 150).ms)
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
