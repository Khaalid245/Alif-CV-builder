import 'package:flutter/material.dart';

class PremiumSaaSGridBackground extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double gridSize;
  final bool showRadialGradient;

  const PremiumSaaSGridBackground({
    super.key,
    required this.child,
    this.opacity = 0.04,
    this.gridSize = 50.0,
    this.showRadialGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Stack(
        children: [
          // Grid pattern - only paint when we have finite constraints
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Only show grid if we have finite constraints
                if (constraints.maxHeight == double.infinity) {
                  return const SizedBox.shrink();
                }
                return CustomPaint(
                  painter: _GridPainter(
                    opacity: opacity,
                    gridSize: gridSize,
                  ),
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                );
              },
            ),
          ),
          // Radial gradient overlay
          if (showRadialGradient)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.0, -0.3),
                    radius: 1.2,
                    colors: [
                      const Color(0xFF4F46E5).withValues(alpha: 0.08),
                      const Color(0xFF7C3AED).withValues(alpha: 0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          // Content
          child,
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final double opacity;
  final double gridSize;

  _GridPainter({
    required this.opacity,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Don't paint if size is infinite or invalid
    if (!size.isFinite || size.width <= 0 || size.height <= 0) {
      return;
    }

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

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
