import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/premium_saas_theme.dart';
import '../../../../core/theme/premium_portfolio_colors.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/enterprise_loading.dart';
import '../../../../core/widgets/enterprise_components.dart';
import '../../../../core/accessibility/accessibility_foundation.dart';
import '../../../../core/accessibility/accessible_navigation.dart';
import '../../../../core/performance/performance_foundation.dart';
import '../../../../core/performance/optimized_components.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../pdf/presentation/providers/pdf_provider.dart';
import '../../../pdf/data/models/generated_cv_model.dart';
import '../../data/models/cv_models.dart';
import '../providers/cv_provider.dart';

class CVDashboardScreen extends ConsumerStatefulWidget {
  const CVDashboardScreen({super.key});

  @override
  ConsumerState<CVDashboardScreen> createState() => _CVDashboardScreenState();
}

class _CVDashboardScreenState extends ConsumerState<CVDashboardScreen>
    with TickerProviderStateMixin {
  bool _isAnnouncementDismissed = false;
  late AnimationController _fadeController;
  late AnimationController _heroController;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _heroAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
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
    _heroAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.elasticOut),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 0.85).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOutExpo),
    );
    
    _fadeController.forward();
    _heroController.forward();
    _glowController.repeat(reverse: true);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(cvProfileProvider);
      if (state is AsyncData && state.value == null) {
        ref.invalidate(cvProfileProvider);
      }
      ref.read(pdfHistoryProvider.notifier).fetch();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _heroController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final cvProfileAsync = ref.watch(cvProfileProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AccessibleAppBar(
        title: 'Dashboard',
        showBackButton: false,
        actions: [
          Semantics(
            label: 'User profile menu',
            button: true,
            child: GestureDetector(
              onTap: () => _showProfileBottomSheet(
                  context, user?.fullName ?? '', user?.email ?? ''),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: PremiumSaaSTheme.primaryPurple,
                  child: Text(
                    _getInitials(user?.fullName ?? ''),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    semanticsLabel: 'User avatar: ${_getInitials(user?.fullName ?? '')}',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Grid background
            _buildGridBackground(),
            // Main content - EXACT structure: SingleChildScrollView → Padding → Column
            EnterpriseLoadingManager(
              state: cvProfileAsync.when(
                loading: () => LoadingState.loading,
                error: (_, __) => LoadingState.error,
                data: (profile) => profile == null ? LoadingState.loading : LoadingState.loaded,
              ),
              loadingWidget: const CVDashboardSkeleton(),
              errorMessage: cvProfileAsync.hasError ? cvProfileAsync.error.toString() : null,
              onRetry: () => ref.invalidate(cvProfileProvider),
              child: cvProfileAsync.hasValue && cvProfileAsync.value != null
                  ? FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildDashboard(cvProfileAsync.value!),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridBackground() {
    return Positioned.fill(
      child: CustomPaint(
        painter: DashboardGridPainter(),
      ),
    );
  }

  Widget _buildDashboard(CVProfileModel profile) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header Card - matching screenshot style
            _buildWelcomeCard(profile),
            
            const SizedBox(height: 24),
            
            // Quick Stats Row
            _buildQuickStatsRow(profile),
            
            const SizedBox(height: 24),
            
            // Recent Downloads Section - matching screenshot style
            _buildRecentDownloadsSection(),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeroSection(CVProfileModel profile) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
    final firstName = profile.fullName.split(' ').first;
    
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                PremiumSaaSTheme.primaryPurple.withOpacity(0.08 + (_glowAnimation.value * 0.04)),
                PremiumSaaSTheme.accentBlue.withOpacity(0.06 + (_glowAnimation.value * 0.03)),
                PremiumSaaSTheme.lightBackground.withOpacity(0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: PremiumPortfolioColors.accentPurple.withOpacity(0.1 + (_glowAnimation.value * 0.1)),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: PremiumPortfolioColors.accentPurple.withOpacity(0.1 + (_glowAnimation.value * 0.1)),
                blurRadius: 24 + (_glowAnimation.value * 12),
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                PremiumPortfolioColors.accentPurple,
                                PremiumPortfolioColors.accentBlue,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.sparkles,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'AI Powered',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$greeting, $firstName 👋',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: PremiumSaaSTheme.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your CV is looking exceptional! AI analysis shows strong potential for optimization.',
                      style: TextStyle(
                        fontSize: 16,
                        color: PremiumSaaSTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _buildHeroActionButton(
                          'Complete Profile',
                          LucideIcons.userPlus,
                          PremiumSaaSTheme.primaryPurple,
                          () => context.go('/cv/form'),
                        ),
                        const SizedBox(width: 16),
                        _buildHeroActionButton(
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
              const SizedBox(width: 32),
              Expanded(
                child: _buildProgressVisualization(profile),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroActionButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(12),
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
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressVisualization(CVProfileModel profile) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
            ),
          ),
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
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        PremiumPortfolioColors.accentPurple,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${(_progressAnimation.value * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: PremiumPortfolioColors.accentPurple,
                        ),
                      ),
                      Text(
                        'Complete',
                        style: TextStyle(
                          fontSize: 14,
                          color: PremiumPortfolioColors.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: PremiumPortfolioColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: PremiumPortfolioColors.success.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.trendingUp,
                      color: PremiumPortfolioColors.success,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Strong Profile',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: PremiumPortfolioColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAIInsightsSection(CVProfileModel profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PremiumPortfolioColors.accentPurple.withOpacity(0.05),
            PremiumPortfolioColors.accentBlue.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: PremiumPortfolioColors.accentPurple.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      PremiumPortfolioColors.accentPurple,
                      PremiumPortfolioColors.accentBlue,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LucideIcons.brain,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Insights & Analytics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: PremiumPortfolioColors.primaryText,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: PremiumPortfolioColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: PremiumPortfolioColors.success.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.trendingUp,
                      color: PremiumPortfolioColors.success,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ATS Score: 92/100',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: PremiumPortfolioColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInsightCard(
                  'Profile Views',
                  '1,247',
                  '+23% this month',
                  LucideIcons.eye,
                  PremiumPortfolioColors.accentBlue,
                  [0.4, 0.6, 0.5, 0.8, 0.7, 0.9, 0.85],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInsightCard(
                  'Skills Match',
                  '85%',
                  '+12% improved',
                  LucideIcons.zap,
                  PremiumPortfolioColors.accentPurple,
                  [0.6, 0.7, 0.65, 0.8, 0.75, 0.85, 0.82],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInsightCard(
                  'Job Matches',
                  '34',
                  '+8 this week',
                  LucideIcons.briefcase,
                  PremiumSaaSTheme.accentTeal,
                  [0.3, 0.5, 0.4, 0.7, 0.6, 0.8, 0.75],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, String value, String change, IconData icon, Color color, List<double> chartData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: PremiumPortfolioColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: PremiumPortfolioColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: PremiumPortfolioColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          _buildMiniChart(chartData, color),
        ],
      ),
    );
  }

  Widget _buildMiniChart(List<double> data, Color color) {
    return Container(
      height: 32,
      child: Row(
        children: data.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: index < data.length - 1 ? 2 : 0,
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
                            color,
                            color.withOpacity(0.6),
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

  Widget _buildPremiumStatsGrid(CVProfileModel profile) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildPremiumStatsCard(
          'Profile Strength',
          '${profile.completionPercentage}%',
          LucideIcons.user,
          PremiumPortfolioColors.accentBlue,
          'Excellent',
        ),
        _buildPremiumStatsCard(
          'Experience',
          '${profile.experiences.length}',
          LucideIcons.briefcase,
          PremiumPortfolioColors.accentPurple,
          'Positions',
        ),
        _buildPremiumStatsCard(
          'Skills',
          '${profile.skills.length}',
          LucideIcons.zap,
          PremiumPortfolioColors.success,
          'Added',
        ),
        _buildPremiumStatsCard(
          'Downloads',
          '8',
          LucideIcons.download,
          PremiumSaaSTheme.accentTeal,
          'This month',
        ),
      ],
    );
  }

  Widget _buildPremiumStatsCard(String title, String value, IconData icon, Color color, String subtitle) {
    return MouseRegion(
      onEnter: (_) {},
      onExit: (_) {},
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Icon(
                  LucideIcons.trendingUp,
                  color: PremiumPortfolioColors.success,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: PremiumPortfolioColors.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: PremiumPortfolioColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: PremiumPortfolioColors.primaryText,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: [
            _buildPremiumActionCard(
              'Complete Profile',
              'Add missing sections to boost CV strength',
              LucideIcons.userPlus,
              PremiumPortfolioColors.accentPurple,
              () => context.go('/cv/form'),
            ),
            _buildPremiumActionCard(
              'AI Optimize',
              'Let AI improve your content and keywords',
              LucideIcons.sparkles,
              PremiumSaaSTheme.accentTeal,
              () {},
            ),
            _buildPremiumActionCard(
              'Generate PDFs',
              'Create professional CVs in 3 templates',
              LucideIcons.fileDown,
              PremiumPortfolioColors.accentBlue,
              () => context.go('/pdf/result'),
            ),
            _buildPremiumActionCard(
              'View Analytics',
              'Track your CV performance and insights',
              LucideIcons.barChart3,
              PremiumPortfolioColors.success,
              () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPremiumActionCard(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return MouseRegion(
      onEnter: (_) {},
      onExit: (_) {},
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                color.withOpacity(0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: color.withOpacity(0.2),
                  ),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: PremiumPortfolioColors.primaryText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: PremiumPortfolioColors.secondaryText,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    LucideIcons.arrowRight,
                    color: color,
                    size: 14,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIRecommendationsPanel(CVProfileModel profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PremiumPortfolioColors.accentPurple.withOpacity(0.05),
            PremiumPortfolioColors.accentBlue.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: PremiumPortfolioColors.accentPurple.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      PremiumPortfolioColors.accentPurple,
                      PremiumPortfolioColors.accentBlue,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LucideIcons.sparkles,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: PremiumPortfolioColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildRecommendationItem(
            'Add "Python" skill',
            'Based on your experience, this would increase job matches by 34%',
            LucideIcons.plus,
            PremiumPortfolioColors.success,
          ),
          _buildRecommendationItem(
            'Improve work descriptions',
            'Use more action verbs and quantify your achievements',
            LucideIcons.edit3,
            PremiumPortfolioColors.accentBlue,
          ),
          _buildRecommendationItem(
            'ATS Optimization',
            'Your CV scores 92/100 for applicant tracking systems',
            LucideIcons.target,
            PremiumPortfolioColors.accentPurple,
          ),
          _buildRecommendationItem(
            'Industry Trends',
            'Cloud computing skills are trending +45% in your field',
            LucideIcons.trendingUp,
            PremiumSaaSTheme.accentTeal,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String title, String description, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: PremiumPortfolioColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: PremiumPortfolioColors.secondaryText,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            LucideIcons.chevronRight,
            color: PremiumPortfolioColors.secondaryText,
            size: 16,
          ),
        ],
      ),
    );
  }

  int _getFilledSectionCount(CVProfileModel profile) {
    int count = 0;
    if (profile.phone.isNotEmpty) count++;
    if (profile.education.isNotEmpty) count++;
    if (profile.experiences.isNotEmpty) count++;
    if (profile.skills.isNotEmpty) count++;
    if (profile.languages.isNotEmpty) count++;
    if (profile.projects.isNotEmpty) count++;
    if (profile.certifications.isNotEmpty) count++;
    return count;
  }

  Widget _buildActionCard(String title, String description, IconData icon, VoidCallback onTap) {
    return ResponsiveBuilder(
      builder: (context, constraints) {
        return OptimizedEnterpriseCard(
          onTap: onTap,
          enableMicroInteractions: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: constraints.isMobile ? 40 : 48,
                height: constraints.isMobile ? 40 : 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      PremiumPortfolioColors.accentPurple.withValues(alpha: 0.1),
                      PremiumPortfolioColors.accentBlue.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: PremiumPortfolioColors.accentPurple.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  icon,
                  size: constraints.isMobile ? 20 : 24,
                  color: PremiumPortfolioColors.accentPurple,
                ),
              ),
              SizedBox(height: constraints.isMobile ? 12 : 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: constraints.isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: PremiumPortfolioColors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: constraints.isMobile ? 12 : 14,
                  color: PremiumPortfolioColors.secondaryText,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPremiumDownloadsTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PremiumPortfolioColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: PremiumPortfolioColors.borderLight),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Recent Downloads',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: PremiumPortfolioColors.primaryText,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go('/cv/downloads'),
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: PremiumPortfolioColors.accentPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Table Content
          Consumer(
            builder: (context, ref, child) {
              final historyAsync = ref.watch(pdfHistoryProvider);
              
              return historyAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      'Failed to load downloads',
                      style: TextStyle(
                        color: PremiumPortfolioColors.secondaryText,
                      ),
                    ),
                  ),
                ),
                data: (history) {
                  if (history.isEmpty) {
                    return _buildEmptyState();
                  }
                  
                  final recentDownloads = history.take(5).toList();
                  return Column(
                    children: recentDownloads.map((cv) => _buildPremiumTableRow(cv)).toList(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumTableRow(GeneratedCVModel cv) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: PremiumPortfolioColors.borderLight.withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          // Template Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PremiumPortfolioColors.accentPurple.withOpacity(0.1),
                  PremiumPortfolioColors.accentBlue.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: PremiumPortfolioColors.accentPurple.withOpacity(0.2),
              ),
            ),
            child: Icon(
              LucideIcons.fileText,
              size: 20,
              color: PremiumPortfolioColors.accentPurple,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Template Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${cv.templateDisplay} CV',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: PremiumPortfolioColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Generated ${TimeUtils.timeAgo(cv.generatedAt)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: PremiumPortfolioColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: PremiumPortfolioColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: PremiumPortfolioColors.success.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.checkCircle2,
                  size: 12,
                  color: PremiumPortfolioColors.success,
                ),
                const SizedBox(width: 6),
                Text(
                  'Ready',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: PremiumPortfolioColors.success,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _downloadCV(cv),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: PremiumPortfolioColors.accentPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LucideIcons.download,
                      size: 16,
                      color: PremiumPortfolioColors.accentPurple,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      LucideIcons.moreHorizontal,
                      size: 16,
                      color: PremiumPortfolioColors.secondaryText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            LucideIcons.fileText,
            size: 48,
            color: PremiumPortfolioColors.secondaryText.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No CVs Generated Yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: PremiumPortfolioColors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate your first professional CV to see it here',
            style: TextStyle(
              fontSize: 14,
              color: PremiumPortfolioColors.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/pdf/result'),
            style: ElevatedButton.styleFrom(
              backgroundColor: PremiumPortfolioColors.accentPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Generate CV'),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(GeneratedCVModel cv) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: PremiumPortfolioColors.borderLight.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          // Template Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: PremiumPortfolioColors.accentPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              LucideIcons.fileText,
              size: 20,
              color: PremiumPortfolioColors.accentPurple,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Template Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${cv.templateDisplay} CV',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: PremiumPortfolioColors.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Generated ${TimeUtils.timeAgo(cv.generatedAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: PremiumPortfolioColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: PremiumPortfolioColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Ready',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: PremiumPortfolioColors.success,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Download Button
          IconButton(
            onPressed: () => _downloadCV(cv),
            icon: Icon(
              LucideIcons.download,
              size: 18,
              color: PremiumPortfolioColors.accentPurple,
            ),
            style: IconButton.styleFrom(
              backgroundColor: PremiumPortfolioColors.accentPurple.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }



  String _getInitials(String fullName) {
    if (fullName.isEmpty) return 'U';

    final names = fullName.trim().split(' ');
    if (names.length == 1) {
      return names[0][0].toUpperCase();
    }

    final firstInitial =
        names.first.isNotEmpty ? names.first[0].toUpperCase() : '';
    final lastInitial =
        names.last.isNotEmpty ? names.last[0].toUpperCase() : '';

    return '$firstInitial$lastInitial';
  }

  Future<void> _logout() async {
    final secureStorage = ref.read(secureStorageProvider);
    await secureStorage.clearAll();
    ref.read(currentUserProvider.notifier).state = null;
    if (mounted) {
      context.go('/');
    }
  }

  Widget _buildRecentDownloadsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: PremiumPortfolioColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Text(
                  'Recent downloads',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: PremiumPortfolioColors.primaryText,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go('/cv/downloads'),
                  child: Text(
                    'View all',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: PremiumPortfolioColors.accentPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Downloads List
          Consumer(
            builder: (context, ref, child) {
              final historyAsync = ref.watch(pdfHistoryProvider);
              
              return historyAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => _buildEmptyDownloadsState(),
                data: (history) {
                  if (history.isEmpty) {
                    return _buildEmptyDownloadsState();
                  }
                  
                  final recentDownloads = history.take(5).toList();
                  return Column(
                    children: recentDownloads.map((cv) => _buildCleanDownloadRow(cv)).toList(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showProfileBottomSheet(
      BuildContext context, String name, String email) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // User info
            Column(
              children: [
                Text(
                  name.isNotEmpty ? name : 'User',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: PremiumPortfolioColors.primaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 16,
                    color: PremiumPortfolioColors.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Divider
            Container(
              height: 1,
              color: PremiumPortfolioColors.borderLight,
            ),

            const SizedBox(height: 8),

            // Sign out
            ListTile(
              leading: const Icon(
                LucideIcons.logOut,
                color: PremiumPortfolioColors.error,
              ),
              title: Text(
                'Sign out',
                style: TextStyle(
                  fontSize: 16,
                  color: PremiumPortfolioColors.error,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDownloadsState() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: PremiumPortfolioColors.borderLight,
          width: 0.5,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(
            LucideIcons.download,
            size: 24,
            color: Color(0xFF9E9E9E),
          ),
          const SizedBox(height: 8),
          const Text(
            'No CVs generated yet',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () {
              context.go('/pdf/result');
            },
            child: Text(
              'Generate my CVs',
              style: TextStyle(
                fontSize: 16,
                color: PremiumPortfolioColors.accentPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDownloadTile(GeneratedCVModel cv) {
    return SectionCard(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // CV Thumbnail
          _buildCVThumbnail(),

          const SizedBox(width: 12),

          // CV Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cv.templateDisplay,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: PremiumPortfolioColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  TimeUtils.timeAgo(cv.generatedAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: PremiumPortfolioColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),

          // Download Button
          GestureDetector(
            onTap: () => _downloadCV(cv),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: PremiumPortfolioColors.accentPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                LucideIcons.download,
                size: 14,
                color: PremiumPortfolioColors.accentPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCVThumbnail() {
    return Container(
      width: 28,
      height: 36,
      decoration: BoxDecoration(
        border: Border.all(
          color: PremiumPortfolioColors.borderLight,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(3),
        color: const Color(0xFFEAF2FF),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          Container(
            height: 3,
            width: double.infinity * 0.6,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            height: 2,
            width: double.infinity,
            decoration: BoxDecoration(
              color: PremiumPortfolioColors.borderLight,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 1),
          Container(
            height: 2,
            width: double.infinity * 0.8,
            color: PremiumPortfolioColors.borderLight,
          ),
        ],
      ),
    );
  }

  void _downloadCV(GeneratedCVModel cv) async {
    try {
      final repository = ref.read(pdfRepositoryProvider);
      await repository.downloadPDF(cv.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${cv.templateDisplay} CV downloaded successfully'),
            backgroundColor: PremiumPortfolioColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download CV: ${e.toString()}'),
            backgroundColor: PremiumPortfolioColors.error,
          ),
        );
      }
    }
  }
}

class DashboardGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PremiumPortfolioColors.gridOverlay
      ..strokeWidth = 0.5;

    const gridSize = 60.0;

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
  Widget _buildWelcomeCard(CVProfileModel profile) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: PremiumPortfolioColors.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: PremiumPortfolioColors.primaryText,
                  ),
                ),
                Text(
                  DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
                  style: TextStyle(
                    fontSize: 14,
                    color: PremiumPortfolioColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: PremiumPortfolioColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.checkCircle2,
                  size: 16,
                  color: PremiumPortfolioColors.success,
                ),
                const SizedBox(width: 6),
                Text(
                  '${profile.completionPercentage}% Complete',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: PremiumPortfolioColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsRow(CVProfileModel profile) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Profile Sections',
            '${_getFilledSectionCount(profile)}/7',
            LucideIcons.user,
            PremiumPortfolioColors.accentPurple,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Experience',
            '${profile.experiences.length}',
            LucideIcons.briefcase,
            PremiumPortfolioColors.accentBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Skills',
            '${profile.skills.length}',
            LucideIcons.zap,
            PremiumPortfolioColors.success,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Projects',
            '${profile.projects.length}',
            LucideIcons.folder,
            PremiumPortfolioColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: PremiumPortfolioColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Icon(
                LucideIcons.trendingUp,
                color: PremiumPortfolioColors.success,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: PremiumPortfolioColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildCleanDownloadRow(GeneratedCVModel cv) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: PremiumPortfolioColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // CV Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: PremiumPortfolioColors.accentPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              LucideIcons.fileText,
              size: 20,
              color: PremiumPortfolioColors.accentPurple,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // CV Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${cv.templateDisplay} CV',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: PremiumPortfolioColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Generated ${TimeUtils.timeAgo(cv.generatedAt)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: PremiumPortfolioColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: PremiumPortfolioColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Ready',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: PremiumPortfolioColors.success,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Download Button
          IconButton(
            onPressed: () => _downloadCV(cv),
            icon: Icon(
              LucideIcons.download,
              size: 18,
              color: PremiumPortfolioColors.accentPurple,
            ),
            style: IconButton.styleFrom(
              backgroundColor: PremiumPortfolioColors.accentPurple.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }