import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/modern_saas_theme.dart';
import 'responsive_layout.dart';

class ProfileCompletionHeroCard extends StatefulWidget {
  final int completionPercentage;
  final VoidCallback? onCompleteProfile;
  final VoidCallback? onViewProfile;
  final String? userName;
  final int totalSections;
  final int completedSections;
  final bool showAnimation;

  const ProfileCompletionHeroCard({
    super.key,
    required this.completionPercentage,
    this.onCompleteProfile,
    this.onViewProfile,
    this.userName,
    this.totalSections = 7,
    this.completedSections = 0,
    this.showAnimation = true,
  });

  @override
  State<ProfileCompletionHeroCard> createState() =>
      _ProfileCompletionHeroCardState();
}

class _ProfileCompletionHeroCardState extends State<ProfileCompletionHeroCard>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.completionPercentage / 100.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    if (widget.showAnimation) {
      _fadeController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _progressController.forward();
      });
    } else {
      _fadeController.value = 1.0;
      _progressController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ProfileCompletionHeroCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.completionPercentage != widget.completionPercentage) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.completionPercentage / 100.0,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ));
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(
                horizontal: _getHorizontalMargin(deviceType),
              ),
              decoration: _buildCardDecoration(deviceType),
              child: deviceType.isMobile
                  ? _buildMobileLayout()
                  : _buildDesktopLayout(deviceType),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _buildCardDecoration(DeviceType deviceType) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          ModernSaaSDashboardTheme.accentPurple.withOpacity(0.08),
          ModernSaaSDashboardTheme.accentPurpleLight.withOpacity(0.04),
          ModernSaaSDashboardTheme.surfaceBackground,
        ],
        stops: const [0.0, 0.6, 1.0],
      ),
      borderRadius: BorderRadius.circular(
        deviceType.isMobile ? 16 : 20,
      ),
      border: Border.all(
        color: ModernSaaSDashboardTheme.accentPurple.withOpacity(0.1),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: ModernSaaSDashboardTheme.accentPurple.withOpacity(0.08),
          blurRadius: deviceType.isMobile ? 16 : 24,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: deviceType.isMobile ? 8 : 12,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          _buildHeaderSection(compact: true),

          const SizedBox(height: 20),

          // Progress section
          _buildProgressSection(compact: true),

          const SizedBox(height: 24),

          // Illustration
          _buildIllustration(size: 120),

          const SizedBox(height: 24),

          // Action buttons
          _buildActionButtons(stacked: true),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(DeviceType deviceType) {
    final isTablet = deviceType.isTablet;

    return Padding(
      padding: EdgeInsets.all(isTablet ? 28 : 32),
      child: Row(
        children: [
          // Content section
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(compact: false),
                SizedBox(height: isTablet ? 20 : 24),
                _buildProgressSection(compact: false),
                SizedBox(height: isTablet ? 24 : 32),
                _buildActionButtons(stacked: false),
              ],
            ),
          ),

          SizedBox(width: isTablet ? 24 : 32),

          // Illustration section
          Expanded(
            flex: 2,
            child: _buildIllustration(
              size: isTablet ? 160 : 200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection({required bool compact}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ModernSaaSDashboardTheme.accentPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ModernSaaSDashboardTheme.accentPurple.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.user,
                size: 14,
                color: ModernSaaSDashboardTheme.accentPurple,
              ),
              const SizedBox(width: 6),
              Text(
                'Profile Setup',
                style: ModernSaaSDashboardTheme.labelSmall.copyWith(
                  color: ModernSaaSDashboardTheme.accentPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: compact ? 12 : 16),

        // Title
        Text(
          _getTitle(),
          style: compact
              ? ModernSaaSDashboardTheme.headlineLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                )
              : ModernSaaSDashboardTheme.displaySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
        ),

        SizedBox(height: compact ? 8 : 12),

        // Subtitle
        Text(
          _getSubtitle(),
          style: compact
              ? ModernSaaSDashboardTheme.bodyMedium.copyWith(
                  color: ModernSaaSDashboardTheme.secondaryText,
                  height: 1.5,
                )
              : ModernSaaSDashboardTheme.bodyLarge.copyWith(
                  color: ModernSaaSDashboardTheme.secondaryText,
                  height: 1.5,
                ),
        ),
      ],
    );
  }

  Widget _buildProgressSection({required bool compact}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Completion Progress',
              style: compact
                  ? ModernSaaSDashboardTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    )
                  : ModernSaaSDashboardTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
            ),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                final percentage = (_progressAnimation.value * 100).round();
                return Text(
                  '$percentage%',
                  style: compact
                      ? ModernSaaSDashboardTheme.headlineSmall.copyWith(
                          color: ModernSaaSDashboardTheme.accentPurple,
                          fontWeight: FontWeight.w700,
                        )
                      : ModernSaaSDashboardTheme.headlineLarge.copyWith(
                          color: ModernSaaSDashboardTheme.accentPurple,
                          fontWeight: FontWeight.w700,
                        ),
                );
              },
            ),
          ],
        ),

        SizedBox(height: compact ? 12 : 16),

        // Progress bar
        _buildProgressBar(compact: compact),

        SizedBox(height: compact ? 8 : 12),

        // Progress details
        Text(
          '${widget.completedSections} of ${widget.totalSections} sections completed',
          style: ModernSaaSDashboardTheme.bodySmall.copyWith(
            color: ModernSaaSDashboardTheme.tertiaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar({required bool compact}) {
    return Container(
      height: compact ? 8 : 10,
      decoration: BoxDecoration(
        color: ModernSaaSDashboardTheme.accentPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(compact ? 4 : 5),
      ),
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              // Background track
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: ModernSaaSDashboardTheme.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(compact ? 4 : 5),
                ),
              ),

              // Progress fill
              FractionallySizedBox(
                widthFactor: _progressAnimation.value,
                child: Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        ModernSaaSDashboardTheme.accentPurple,
                        ModernSaaSDashboardTheme.accentPurpleLight,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(compact ? 4 : 5),
                    boxShadow: [
                      BoxShadow(
                        color: ModernSaaSDashboardTheme.accentPurple
                            .withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),

              // Shimmer effect
              if (_progressAnimation.value > 0)
                FractionallySizedBox(
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.0),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(compact ? 4 : 5),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIllustration({required double size}) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              ModernSaaSDashboardTheme.accentPurple.withOpacity(0.1),
              ModernSaaSDashboardTheme.accentPurpleLight.withOpacity(0.05),
              Colors.transparent,
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring
            Container(
              width: size * 0.9,
              height: size * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ModernSaaSDashboardTheme.accentPurple.withOpacity(0.2),
                  width: 2,
                ),
              ),
            ),

            // Inner circle with icon
            Container(
              width: size * 0.6,
              height: size * 0.6,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ModernSaaSDashboardTheme.accentPurple,
                    ModernSaaSDashboardTheme.accentPurpleLight,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        ModernSaaSDashboardTheme.accentPurple.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _getIllustrationIcon(),
                size: size * 0.25,
                color: Colors.white,
              ),
            ),

            // Floating elements
            ..._buildFloatingElements(size),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingElements(double size) {
    return [
      // Top right
      Positioned(
        top: size * 0.15,
        right: size * 0.15,
        child: _buildFloatingElement(
          icon: LucideIcons.check,
          color: ModernSaaSDashboardTheme.success,
          size: 16,
        ),
      ),

      // Bottom left
      Positioned(
        bottom: size * 0.2,
        left: size * 0.1,
        child: _buildFloatingElement(
          icon: LucideIcons.star,
          color: ModernSaaSDashboardTheme.warning,
          size: 14,
        ),
      ),

      // Top left
      Positioned(
        top: size * 0.25,
        left: size * 0.2,
        child: _buildFloatingElement(
          icon: LucideIcons.zap,
          color: ModernSaaSDashboardTheme.info,
          size: 12,
        ),
      ),
    ];
  }

  Widget _buildFloatingElement({
    required IconData icon,
    required Color color,
    required double size,
  }) {
    return Container(
      width: size + 16,
      height: size + 16,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        size: size,
        color: color,
      ),
    );
  }

  Widget _buildActionButtons({required bool stacked}) {
    final buttons = [
      // Primary button
      Expanded(
        child: ElevatedButton(
          onPressed: widget.onCompleteProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: ModernSaaSDashboardTheme.accentPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.edit, size: 18),
              const SizedBox(width: 8),
              Text(
                'Complete Profile',
                style: ModernSaaSDashboardTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),

      // Secondary button
      Expanded(
        child: OutlinedButton(
          onPressed: widget.onViewProfile,
          style: OutlinedButton.styleFrom(
            foregroundColor: ModernSaaSDashboardTheme.accentPurple,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(
              color: ModernSaaSDashboardTheme.accentPurple.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.eye, size: 18),
              const SizedBox(width: 8),
              Text(
                'View Profile',
                style: ModernSaaSDashboardTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ];

    if (stacked) {
      return Column(
        children: [
          buttons[0],
          const SizedBox(height: 12),
          buttons[1],
        ],
      );
    } else {
      return Row(
        children: [
          buttons[0],
          const SizedBox(width: 16),
          buttons[1],
        ],
      );
    }
  }

  double _getHorizontalMargin(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 0;
      case DeviceType.tablet:
        return 0;
      case DeviceType.desktop:
        return 0;
    }
  }

  String _getTitle() {
    if (widget.completionPercentage >= 100) {
      return 'Profile Complete! 🎉';
    } else if (widget.completionPercentage >= 75) {
      return 'Almost There!';
    } else if (widget.completionPercentage >= 50) {
      return 'Great Progress!';
    } else if (widget.completionPercentage >= 25) {
      return 'Getting Started';
    } else {
      return 'Let\'s Build Your Profile';
    }
  }

  String _getSubtitle() {
    if (widget.completionPercentage >= 100) {
      return 'Your profile is complete and ready to impress employers. You can now generate professional CVs.';
    } else if (widget.completionPercentage >= 75) {
      return 'You\'re almost done! Complete the remaining sections to unlock all CV templates.';
    } else if (widget.completionPercentage >= 50) {
      return 'You\'re making excellent progress. Keep going to create a standout profile.';
    } else if (widget.completionPercentage >= 25) {
      return 'Good start! Add more information to make your profile shine and attract opportunities.';
    } else {
      return 'Complete your profile to create professional CVs that stand out to employers.';
    }
  }

  IconData _getIllustrationIcon() {
    if (widget.completionPercentage >= 100) {
      return LucideIcons.trophy;
    } else if (widget.completionPercentage >= 75) {
      return LucideIcons.target;
    } else if (widget.completionPercentage >= 50) {
      return LucideIcons.trendingUp;
    } else {
      return LucideIcons.user;
    }
  }
}

// Compact version for smaller spaces
class CompactProfileCompletionCard extends StatelessWidget {
  final int completionPercentage;
  final VoidCallback? onTap;
  final bool showPercentage;

  const CompactProfileCompletionCard({
    super.key,
    required this.completionPercentage,
    this.onTap,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ModernSaaSDashboardTheme.accentPurple.withOpacity(0.1),
                ModernSaaSDashboardTheme.accentPurpleLight.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ModernSaaSDashboardTheme.accentPurple.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      ModernSaaSDashboardTheme.accentPurple,
                      ModernSaaSDashboardTheme.accentPurpleLight,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.user,
                  color: Colors.white,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Completion',
                      style: ModernSaaSDashboardTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: ModernSaaSDashboardTheme.accentPurple
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: completionPercentage / 100.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      ModernSaaSDashboardTheme.accentPurple,
                                      ModernSaaSDashboardTheme
                                          .accentPurpleLight,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (showPercentage) ...[
                          const SizedBox(width: 8),
                          Text(
                            '$completionPercentage%',
                            style: ModernSaaSDashboardTheme.bodySmall.copyWith(
                              color: ModernSaaSDashboardTheme.accentPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              const Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: ModernSaaSDashboardTheme.tertiaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
