import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/premium_portfolio_colors.dart';
import '../widgets/public_layout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PublicLayout(
      child: Container(
        decoration: const BoxDecoration(
          color: PremiumPortfolioColors.background,
        ),
        child: Stack(
          children: [
            // Grid overlay background
            _buildGridOverlay(),
            // Main content with animations
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildHeroSection(),
                    _buildStatsSection(),
                    _buildHowItWorksSection(),
                    _buildTemplatesSection(),
                    _buildFeaturesSection(),
                    _buildCTASection(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridOverlay() {
    return Positioned.fill(
      child: CustomPaint(
        painter: HomeGridPainter(),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: PremiumPortfolioColors.accentPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: PremiumPortfolioColors.accentPurple.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                'UNIVERSITY CV BUILDER',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: PremiumPortfolioColors.accentPurple,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Professional CVs\nMade Simple',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w800,
                color: PremiumPortfolioColors.primaryText,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Text(
                'Fill in your information once. Get 3 professionally designed CVs as ready-to-download PDFs. No design skills needed.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: PremiumPortfolioColors.secondaryText,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPremiumButton(
                  'Get Started Free',
                  () => context.go('/register'),
                  isPrimary: true,
                ),
                const SizedBox(width: 24),
                _buildPremiumButton(
                  'View Templates',
                  () => context.go('/#templates'),
                  isPrimary: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatCard('3', 'Professional\nTemplates'),
            _buildStatCard('1000+', 'Students\nHelped'),
            _buildStatCard('100%', 'Free for\nStudents'),
            _buildStatCard('24/7', 'Platform\nAccess'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String number, String label) {
    return _PremiumHoverCard(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Text(
              number,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: PremiumPortfolioColors.accentPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: PremiumPortfolioColors.secondaryText,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            Text(
              'How It Works',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: PremiumPortfolioColors.primaryText,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Three simple steps to your professional CV',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: PremiumPortfolioColors.secondaryText,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 64),
            Row(
              children: [
                Expanded(child: _buildStepCard('1', 'Fill Information', 'Add your education, skills, and experience once')),
                const SizedBox(width: 32),
                Expanded(child: _buildStepCard('2', 'Generate CVs', 'Platform creates 3 professional PDF templates')),
                const SizedBox(width: 32),
                Expanded(child: _buildStepCard('3', 'Download & Apply', 'Choose the best CV for each job application')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(String step, String title, String description) {
    return _PremiumHoverCard(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    PremiumPortfolioColors.accentPurple,
                    PremiumPortfolioColors.accentBlue,
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Center(
                child: Text(
                  step,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: PremiumPortfolioColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: PremiumPortfolioColors.secondaryText,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplatesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            Text(
              'Choose Your Style',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: PremiumPortfolioColors.primaryText,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Three professionally designed templates for every career path',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: PremiumPortfolioColors.secondaryText,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 64),
            Row(
              children: [
                Expanded(child: _buildTemplateCard('Classic', 'Corporate & Government', 'Navy blue sidebar, formal layout')),
                const SizedBox(width: 32),
                Expanded(child: _buildTemplateCard('Modern', 'Tech & Startups', 'Clean design, teal accents')),
                const SizedBox(width: 32),
                Expanded(child: _buildTemplateCard('Academic', 'Research & Education', 'Structured format, burgundy theme')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(String name, String category, String description) {
    return _PremiumHoverCard(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                color: PremiumPortfolioColors.accentPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: PremiumPortfolioColors.accentPurple.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                LucideIcons.fileText,
                size: 48,
                color: PremiumPortfolioColors.accentPurple,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: PremiumPortfolioColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: PremiumPortfolioColors.accentPurple,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: PremiumPortfolioColors.secondaryText,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            Text(
              'Why Choose EduCV?',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: PremiumPortfolioColors.primaryText,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 64),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 32,
              mainAxisSpacing: 32,
              childAspectRatio: 1.2,
              children: [
                _buildFeatureCard(LucideIcons.shield, 'Secure & Private', 'Your data is protected with enterprise-grade security'),
                _buildFeatureCard(LucideIcons.zap, 'Instant Generation', 'Get all 3 CVs in seconds, not hours'),
                _buildFeatureCard(LucideIcons.users, 'University Approved', 'Built for students, endorsed by faculty'),
                _buildFeatureCard(LucideIcons.download, 'Always Accessible', 'Download your CVs anytime, anywhere'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return _PremiumHoverCard(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: PremiumPortfolioColors.accentPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: PremiumPortfolioColors.accentPurple.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                icon,
                size: 32,
                color: PremiumPortfolioColors.accentPurple,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: PremiumPortfolioColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: PremiumPortfolioColors.secondaryText,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTASection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: _PremiumHoverCard(
          child: Padding(
            padding: const EdgeInsets.all(64),
            child: Column(
              children: [
                Text(
                  'Ready to Build Your Professional CV?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: PremiumPortfolioColors.primaryText,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Join thousands of students who have already created their professional CVs with EduCV.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: PremiumPortfolioColors.secondaryText,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildPremiumButton(
                  'Start Building Now',
                  () => context.go('/register'),
                  isPrimary: true,
                  isLarge: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumButton(
    String text,
    VoidCallback onPressed, {
    bool isPrimary = true,
    bool isLarge = false,
  }) {
    final height = isLarge ? 64.0 : 56.0;
    final fontSize = isLarge ? 18.0 : 16.0;
    final padding = isLarge ? 32.0 : 24.0;

    return Container(
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: padding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: isPrimary
                ? LinearGradient(
                    colors: [
                      PremiumPortfolioColors.accentPurple,
                      PremiumPortfolioColors.accentBlue,
                    ],
                  )
                : null,
            color: isPrimary ? null : Colors.transparent,
            border: isPrimary
                ? null
                : Border.all(
                    color: PremiumPortfolioColors.borderLight,
                  ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: PremiumPortfolioColors.accentPurple.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : PremiumPortfolioColors.primaryText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumHoverCard extends StatefulWidget {
  final Widget child;

  const _PremiumHoverCard({required this.child});

  @override
  State<_PremiumHoverCard> createState() => _PremiumHoverCardState();
}

class _PremiumHoverCardState extends State<_PremiumHoverCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _elevationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
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
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _elevationAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: PremiumPortfolioColors.cardBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: PremiumPortfolioColors.borderLight,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05 + (0.1 * _elevationAnimation.value)),
                  blurRadius: 20 + (20 * _elevationAnimation.value),
                  offset: Offset(0, 4 + (8 * _elevationAnimation.value)),
                ),
              ],
            ),
            child: widget.child,
          );
        },
      ),
    );
  }
}

class HomeGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PremiumPortfolioColors.gridOverlay
      ..strokeWidth = 1;

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
