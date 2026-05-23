import 'package:flutter/material.dart';
import '../../../../core/theme/premium_portfolio_colors.dart';

class PremiumGridBackground extends StatelessWidget {
  final Widget child;
  final double gridSize;
  final double opacity;

  const PremiumGridBackground({
    super.key,
    required this.child,
    this.gridSize = 50.0,
    this.opacity = 0.06,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Grid background
        Positioned.fill(
          child: CustomPaint(
            painter: GridPainter(
              gridSize: gridSize,
              opacity: opacity,
            ),
          ),
        ),
        // Radial gradient overlay for depth
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.0, -0.5),
                radius: 1.5,
                colors: [
                  PremiumPortfolioColors.background.withValues(alpha: 0.0),
                  PremiumPortfolioColors.background.withValues(alpha: 0.3),
                  PremiumPortfolioColors.background.withValues(alpha: 0.8),
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),
        ),
        // Content
        child,
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  final double gridSize;
  final double opacity;

  GridPainter({
    required this.gridSize,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PremiumPortfolioColors.primaryText.withValues(alpha: opacity)
      ..strokeWidth = 0.5
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