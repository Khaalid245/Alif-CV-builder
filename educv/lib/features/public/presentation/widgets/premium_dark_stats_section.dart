import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StatItem {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const StatItem(this.value, this.label, this.icon, this.color);
}

class PremiumDarkStatsSection extends StatelessWidget {
  const PremiumDarkStatsSection({super.key});

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
        height: 400,
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
            // Content
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 900;
                    return isDesktop
                        ? _buildDesktopLayout()
                        : _buildMobileLayout();
                  },
                ),
              ),
            ),
          ],
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
    return Column(
      children: [
        Row(
          children: [
            Flexible(child: _buildStatCard(_stats[0], 0)),
            const SizedBox(width: 20),
            Flexible(child: _buildStatCard(_stats[1], 1)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Flexible(child: _buildStatCard(_stats[2], 2)),
            const SizedBox(width: 20),
            Flexible(child: _buildStatCard(_stats[3], 3)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(StatItem stat, int index) {
    return _StatCard(
      stat: stat,
      index: index,
    );
  }
}

class _StatCard extends StatefulWidget {
  final StatItem stat;
  final int index;

  const _StatCard({
    required this.stat,
    required this.index,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -8.0 : 0.0),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          border: Border.all(
            color: _isHovered
                ? widget.stat.color.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? widget.stat.color.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: _isHovered ? 32 : 20,
              offset: Offset(0, _isHovered ? 16 : 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
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
                    color: widget.stat.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    widget.stat.icon,
                    size: 32,
                    color: widget.stat.color,
                  ),
                )
                    .animate(delay: (200 + widget.index * 100).ms)
                    .fadeIn(duration: 600.ms)
                    .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.0, 1.0)),

                const SizedBox(height: 24),

                // Value with gradient
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      widget.stat.color,
                      widget.stat.color.withValues(alpha: 0.7),
                    ],
                  ).createShader(bounds),
                  child: Text(
                    widget.stat.value,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                )
                    .animate(delay: (300 + widget.index * 100).ms)
                    .fadeIn(duration: 800.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 12),

                // Label
                Text(
                  widget.stat.label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate(delay: (400 + widget.index * 100).ms)
                    .fadeIn(duration: 800.ms)
                    .slideY(begin: 0.3, end: 0),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: (100 + widget.index * 150).ms)
        .fadeIn(duration: 1000.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
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
