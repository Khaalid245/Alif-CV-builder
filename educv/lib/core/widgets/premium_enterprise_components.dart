import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/premium_saas_theme.dart';

// Premium Hero Section with Glassmorphism
class PremiumHeroSection extends StatefulWidget {
  final String greeting;
  final String subtitle;
  final double completionProgress;
  final VoidCallback? onActionPressed;

  const PremiumHeroSection({
    super.key,
    required this.greeting,
    required this.subtitle,
    required this.completionProgress,
    this.onActionPressed,
  });

  @override
  State<PremiumHeroSection> createState() => _PremiumHeroSectionState();
}

class _PremiumHeroSectionState extends State<PremiumHeroSection>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _progressController;
  late Animation<double> _gradientAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: PremiumSaaSTheme.animationSlower,
      vsync: this,
    );

    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _gradientController, curve: Curves.easeInOut),
    );
    _progressAnimation =
        Tween<double>(begin: 0.0, end: widget.completionProgress).animate(
      CurvedAnimation(
          parent: _progressController, curve: PremiumSaaSTheme.curveEmphasized),
    );

    _gradientController.repeat(reverse: true);
    _progressController.forward();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _gradientAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(PremiumSaaSTheme.space8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                PremiumSaaSTheme.primaryPurple
                    .withOpacity(0.1 + (_gradientAnimation.value * 0.05)),
                PremiumSaaSTheme.accentBlue
                    .withOpacity(0.08 + (_gradientAnimation.value * 0.04)),
                PremiumSaaSTheme.accentTeal
                    .withOpacity(0.06 + (_gradientAnimation.value * 0.03)),
              ],
            ),
            borderRadius: BorderRadius.circular(PremiumSaaSTheme.radius2xl),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
            boxShadow: PremiumSaaSTheme.shadowLarge,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.greeting,
                      style: PremiumSaaSTheme.displayMedium.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: PremiumSaaSTheme.space3),
                    Text(
                      widget.subtitle,
                      style: PremiumSaaSTheme.bodyLarge.copyWith(
                        color: PremiumSaaSTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: PremiumSaaSTheme.space6),
                    Row(
                      children: [
                        _buildActionButton(
                          'Complete Profile',
                          LucideIcons.user,
                          PremiumSaaSTheme.primaryPurple,
                          widget.onActionPressed,
                        ),
                        SizedBox(width: PremiumSaaSTheme.space4),
                        _buildActionButton(
                          'AI Optimize',
                          LucideIcons.sparkles,
                          PremiumSaaSTheme.accentTeal,
                          () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: PremiumSaaSTheme.space8),
              Expanded(
                child: _buildProgressVisualization(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
      String text, IconData icon, Color color, VoidCallback? onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusLg),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: PremiumSaaSTheme.space5,
            vertical: PremiumSaaSTheme.space3,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusLg),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: PremiumSaaSTheme.textInverse, size: 16),
              SizedBox(width: PremiumSaaSTheme.space2),
              Text(
                text,
                style: PremiumSaaSTheme.labelMedium.copyWith(
                  color: PremiumSaaSTheme.textInverse,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressVisualization() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(PremiumSaaSTheme.space6),
          decoration: PremiumSaaSTheme.glassmorphismLight,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: _progressAnimation.value,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        PremiumSaaSTheme.primaryPurple,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${(_progressAnimation.value * 100).toInt()}%',
                        style: PremiumSaaSTheme.headingMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: PremiumSaaSTheme.primaryPurple,
                        ),
                      ),
                      Text(
                        'Complete',
                        style: PremiumSaaSTheme.labelMedium.copyWith(
                          color: PremiumSaaSTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: PremiumSaaSTheme.space4),
              Text(
                'Profile Strength',
                style: PremiumSaaSTheme.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Premium Analytics Widget
class PremiumAnalyticsWidget extends StatefulWidget {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color color;
  final List<double> chartData;

  const PremiumAnalyticsWidget({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
    required this.chartData,
  });

  @override
  State<PremiumAnalyticsWidget> createState() => _PremiumAnalyticsWidgetState();
}

class _PremiumAnalyticsWidgetState extends State<PremiumAnalyticsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: PremiumSaaSTheme.animationFast,
      vsync: this,
    );
    _elevationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _hoverController, curve: PremiumSaaSTheme.curveDefault),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
          parent: _hoverController, curve: PremiumSaaSTheme.curveDefault),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: EdgeInsets.all(PremiumSaaSTheme.space6),
              decoration: BoxDecoration(
                color: PremiumSaaSTheme.lightSurface,
                borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusXl),
                border: Border.all(
                  color: widget.color
                      .withOpacity(0.1 + (_elevationAnimation.value * 0.1)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: PremiumSaaSTheme.textPrimary
                        .withOpacity(0.04 + (_elevationAnimation.value * 0.04)),
                    blurRadius: 8 + (_elevationAnimation.value * 8),
                    offset: Offset(0, 2 + (_elevationAnimation.value * 4)),
                  ),
                  BoxShadow(
                    color: widget.color
                        .withOpacity(0.05 + (_elevationAnimation.value * 0.1)),
                    blurRadius: 16 + (_elevationAnimation.value * 8),
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(PremiumSaaSTheme.space3),
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(PremiumSaaSTheme.radiusLg),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.color,
                          size: 20,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: PremiumSaaSTheme.space2,
                          vertical: PremiumSaaSTheme.space1,
                        ),
                        decoration: BoxDecoration(
                          color: PremiumSaaSTheme.accentGreen.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(PremiumSaaSTheme.radiusSm),
                        ),
                        child: Text(
                          widget.change,
                          style: PremiumSaaSTheme.labelSmall.copyWith(
                            color: PremiumSaaSTheme.accentGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: PremiumSaaSTheme.space4),
                  Text(
                    widget.value,
                    style: PremiumSaaSTheme.headingLarge.copyWith(
                      color: widget.color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: PremiumSaaSTheme.space1),
                  Text(
                    widget.title,
                    style: PremiumSaaSTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: PremiumSaaSTheme.space4),
                  _buildMiniChart(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniChart() {
    return Container(
      height: 40,
      child: Row(
        children: widget.chartData.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: index < widget.chartData.length - 1 ? 2 : 0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    flex: (value * 10).toInt(),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            widget.color,
                            widget.color.withOpacity(0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 10 - (value * 10).toInt(),
                    child: Container(),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Premium Action Card
class PremiumActionCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const PremiumActionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<PremiumActionCard> createState() => _PremiumActionCardState();
}

class _PremiumActionCardState extends State<PremiumActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: PremiumSaaSTheme.animationMedium,
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _hoverController, curve: PremiumSaaSTheme.curveDefault),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(
          parent: _hoverController, curve: PremiumSaaSTheme.curveDefault),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: EdgeInsets.all(PremiumSaaSTheme.space6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      PremiumSaaSTheme.lightSurface,
                      PremiumSaaSTheme.lightSurfaceVariant,
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(PremiumSaaSTheme.radiusXl),
                  border: Border.all(
                    color: widget.color
                        .withOpacity(0.1 + (_glowAnimation.value * 0.2)),
                    width: 1 + (_glowAnimation.value * 1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: PremiumSaaSTheme.textPrimary.withOpacity(0.04),
                      blurRadius: 8 + (_glowAnimation.value * 8),
                      offset: Offset(0, 2 + (_glowAnimation.value * 4)),
                    ),
                    BoxShadow(
                      color: widget.color
                          .withOpacity(0.1 + (_glowAnimation.value * 0.2)),
                      blurRadius: 16 + (_glowAnimation.value * 16),
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.color.withOpacity(
                                0.1 + (_glowAnimation.value * 0.1)),
                            widget.color.withOpacity(
                                0.05 + (_glowAnimation.value * 0.05)),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(PremiumSaaSTheme.radiusXl),
                        border: Border.all(
                          color: widget.color
                              .withOpacity(0.2 + (_glowAnimation.value * 0.1)),
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.color,
                        size: 28,
                      ),
                    ),
                    SizedBox(height: PremiumSaaSTheme.space5),
                    Text(
                      widget.title,
                      style: PremiumSaaSTheme.headingSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: PremiumSaaSTheme.space2),
                    Text(
                      widget.description,
                      style: PremiumSaaSTheme.bodyMedium.copyWith(
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: PremiumSaaSTheme.space4),
                    Row(
                      children: [
                        Text(
                          'Get Started',
                          style: PremiumSaaSTheme.labelMedium.copyWith(
                            color: widget.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: PremiumSaaSTheme.space2),
                        Icon(
                          LucideIcons.arrowRight,
                          color: widget.color,
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Premium Data Table
class PremiumDataTable extends StatelessWidget {
  final String title;
  final List<String> headers;
  final List<List<Widget>> rows;
  final VoidCallback? onViewAll;

  const PremiumDataTable({
    super.key,
    required this.title,
    required this.headers,
    required this.rows,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PremiumSaaSTheme.lightSurface,
        borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusXl),
        border: Border.all(color: PremiumSaaSTheme.lightBorder),
        boxShadow: PremiumSaaSTheme.shadowMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(PremiumSaaSTheme.space6),
            child: Row(
              children: [
                Text(
                  title,
                  style: PremiumSaaSTheme.headingSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: Text(
                      'View All',
                      style: PremiumSaaSTheme.labelMedium.copyWith(
                        color: PremiumSaaSTheme.primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: PremiumSaaSTheme.space6,
              vertical: PremiumSaaSTheme.space3,
            ),
            decoration: BoxDecoration(
              color: PremiumSaaSTheme.lightSurfaceVariant,
              border: Border(
                top: BorderSide(color: PremiumSaaSTheme.lightBorder),
                bottom: BorderSide(color: PremiumSaaSTheme.lightBorder),
              ),
            ),
            child: Row(
              children: headers.map((header) {
                return Expanded(
                  child: Text(
                    header,
                    style: PremiumSaaSTheme.labelMedium.copyWith(
                      color: PremiumSaaSTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          ...rows.asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: PremiumSaaSTheme.space6,
                vertical: PremiumSaaSTheme.space4,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: index < rows.length - 1
                      ? BorderSide(
                          color: PremiumSaaSTheme.lightBorder.withOpacity(0.5))
                      : BorderSide.none,
                ),
              ),
              child: Row(
                children: row.map((cell) {
                  return Expanded(child: cell);
                }).toList(),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
