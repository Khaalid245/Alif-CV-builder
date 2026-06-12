import 'package:flutter/material.dart';

class PremiumGridBackground extends StatelessWidget {
  final Widget child;
  final double gridSpacing;
  final double gridOpacity;
  final Color gridColor;

  const PremiumGridBackground({
    super.key,
    required this.child,
    this.gridSpacing = 50.0,
    this.gridOpacity = 0.06,
    this.gridColor = const Color(0xFF94A3B8),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base background
        Positioned.fill(
          child: Container(
            color: const Color(0xFFF5F7FB),
          ),
        ),
        // Grid background
        Positioned.fill(
          child: CustomPaint(
            painter: GridPainter(
              spacing: gridSpacing,
              opacity: gridOpacity,
              color: gridColor,
            ),
          ),
        ),
        // Radial gradient overlays for premium depth
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.8, -0.6),
                radius: 1.2,
                colors: [
                  const Color(0xFF7C3AED).withValues(alpha: 0.03),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.8, 0.8),
                radius: 1.0,
                colors: [
                  const Color(0xFF3B82F6).withValues(alpha: 0.02),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Content with proper scrolling
        child,
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  final double spacing;
  final double opacity;
  final Color color;

  GridPainter({
    required this.spacing,
    required this.opacity,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GridPainter &&
        other.spacing == spacing &&
        other.opacity == opacity &&
        other.color == color;
  }

  @override
  int get hashCode => Object.hash(spacing, opacity, color);
}
