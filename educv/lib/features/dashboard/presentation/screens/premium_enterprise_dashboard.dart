import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/premium_saas_theme.dart';
import '../../../../core/layout/responsive_layout.dart';
import '../../../../core/widgets/premium_enterprise_sidebar.dart';
import '../../../../core/widgets/premium_top_navigation.dart';
import '../../../../core/widgets/premium_enterprise_components.dart';

class PremiumEnterpriseDashboard extends StatefulWidget {
  const PremiumEnterpriseDashboard({super.key});

  @override
  State<PremiumEnterpriseDashboard> createState() =>
      _PremiumEnterpriseDashboardState();
}

class _PremiumEnterpriseDashboardState extends State<PremiumEnterpriseDashboard>
    with TickerProviderStateMixin {
  bool _isSidebarCollapsed = false;
  String _currentRoute = '/dashboard';

  late AnimationController _pageController;
  late AnimationController _staggerController;
  late Animation<double> _pageAnimation;
  late Animation<double> _staggerAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = AnimationController(
      duration: PremiumSaaSTheme.animationSlower,
      vsync: this,
    );
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _pageController, curve: PremiumSaaSTheme.curveEmphasized),
    );
    _staggerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _staggerController, curve: PremiumSaaSTheme.curveDefault),
    );

    _pageController.forward();
    _staggerController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: PremiumSaaSTheme.lightBackground,
      body: FadeTransition(
        opacity: _pageAnimation,
        child: Row(
          children: [
            PremiumEnterpriseSidebar(
              isCollapsed: _isSidebarCollapsed,
              onToggle: () =>
                  setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
              currentRoute: _currentRoute,
              onNavigate: (route) => setState(() => _currentRoute = route),
            ),
            Expanded(
              child: Column(
                children: [
                  PremiumTopNavigation(
                    onNotificationPressed: () {},
                    onProfilePressed: () {},
                    notificationCount: 3,
                  ),
                  Expanded(
                    child: _buildDashboardContent(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      backgroundColor: PremiumSaaSTheme.lightBackground,
      appBar: PremiumTopNavigation(
        onMenuPressed: () => Scaffold.of(context).openDrawer(),
        onNotificationPressed: () {},
        onProfilePressed: () {},
        notificationCount: 3,
      ),
      drawer: Drawer(
        child: PremiumEnterpriseSidebar(
          isCollapsed: false,
          onToggle: () {},
          currentRoute: _currentRoute,
          onNavigate: (route) {
            setState(() => _currentRoute = route);
            Navigator.pop(context);
          },
        ),
      ),
      body: _buildDashboardContent(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: PremiumSaaSTheme.lightBackground,
      appBar: PremiumTopNavigation(
        onMenuPressed: () => Scaffold.of(context).openDrawer(),
        onNotificationPressed: () {},
        onProfilePressed: () {},
        notificationCount: 3,
      ),
      drawer: Drawer(
        child: PremiumEnterpriseSidebar(
          isCollapsed: false,
          onToggle: () {},
          currentRoute: _currentRoute,
          onNavigate: (route) {
            setState(() => _currentRoute = route);
            Navigator.pop(context);
          },
        ),
      ),
      body: _buildDashboardContent(),
      bottomNavigationBar: _buildMobileBottomNav(),
    );
  }

  Widget _buildDashboardContent() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(PremiumSaaSTheme.space6),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Hero Section
              _buildAnimatedSection(
                delay: 0,
                child: PremiumHeroSection(
                  greeting: 'Good afternoon, William 👋',
                  subtitle:
                      'Your CV is looking great! Let\'s make it even better with AI-powered insights and optimizations.',
                  completionProgress: 0.85,
                  onActionPressed: () {},
                ),
              ),

              SizedBox(height: PremiumSaaSTheme.space8),

              // Analytics & AI Insights Section
              _buildAnimatedSection(
                delay: 200,
                child: _buildAnalyticsSection(),
              ),

              SizedBox(height: PremiumSaaSTheme.space8),

              // Quick Actions & Activity Section
              _buildAnimatedSection(
                delay: 400,
                child: _buildQuickActionsAndActivity(),
              ),

              SizedBox(height: PremiumSaaSTheme.space8),

              // Recent Downloads Table
              _buildAnimatedSection(
                delay: 600,
                child: _buildRecentDownloadsTable(),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedSection({required int delay, required Widget child}) {
    return AnimatedBuilder(
      animation: _staggerAnimation,
      builder: (context, _) {
        final delayedAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(
              (delay / 1000).clamp(0.0, 0.8),
              ((delay + 300) / 1000).clamp(0.2, 1.0),
              curve: PremiumSaaSTheme.curveEmphasized,
            ),
          ),
        );

        return FadeTransition(
          opacity: delayedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(delayedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Analytics & AI Insights',
              style: PremiumSaaSTheme.headingMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: PremiumSaaSTheme.space3),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: PremiumSaaSTheme.space3,
                vertical: PremiumSaaSTheme.space1,
              ),
              decoration: BoxDecoration(
                gradient: PremiumSaaSTheme.heroGradient,
                borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.sparkles,
                    color: PremiumSaaSTheme.textInverse,
                    size: 12,
                  ),
                  SizedBox(width: PremiumSaaSTheme.space1),
                  Text(
                    'AI Powered',
                    style: PremiumSaaSTheme.labelSmall.copyWith(
                      color: PremiumSaaSTheme.textInverse,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: PremiumSaaSTheme.space5),
        ResponsiveBuilder(
          builder: (context, deviceType) {
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: deviceType.isMobile ? 2 : 4,
              crossAxisSpacing: PremiumSaaSTheme.space4,
              mainAxisSpacing: PremiumSaaSTheme.space4,
              childAspectRatio: deviceType.isMobile ? 1.1 : 1.3,
              children: [
                PremiumAnalyticsWidget(
                  title: 'ATS Score',
                  value: '92/100',
                  change: '+8 this week',
                  icon: LucideIcons.target,
                  color: PremiumSaaSTheme.accentGreen,
                  chartData: [0.7, 0.8, 0.6, 0.9, 0.85, 0.92, 0.88],
                ),
                PremiumAnalyticsWidget(
                  title: 'Profile Views',
                  value: '1,247',
                  change: '+23% this month',
                  icon: LucideIcons.eye,
                  color: PremiumSaaSTheme.accentBlue,
                  chartData: [0.4, 0.6, 0.5, 0.8, 0.7, 0.9, 0.85],
                ),
                PremiumAnalyticsWidget(
                  title: 'Skills Match',
                  value: '85%',
                  change: '+12% improved',
                  icon: LucideIcons.zap,
                  color: PremiumSaaSTheme.primaryPurple,
                  chartData: [0.6, 0.7, 0.65, 0.8, 0.75, 0.85, 0.82],
                ),
                PremiumAnalyticsWidget(
                  title: 'Downloads',
                  value: '24',
                  change: '+6 this week',
                  icon: LucideIcons.download,
                  color: PremiumSaaSTheme.accentTeal,
                  chartData: [0.3, 0.5, 0.4, 0.7, 0.6, 0.8, 0.75],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionsAndActivity() {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        if (deviceType.isMobile) {
          return Column(
            children: [
              _buildQuickActionsSection(),
              SizedBox(height: PremiumSaaSTheme.space6),
              _buildAIInsightsPanel(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildQuickActionsSection(),
            ),
            SizedBox(width: PremiumSaaSTheme.space6),
            Expanded(
              child: _buildAIInsightsPanel(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: PremiumSaaSTheme.headingMedium.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: PremiumSaaSTheme.space5),
        ResponsiveBuilder(
          builder: (context, deviceType) {
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: deviceType.isMobile ? 1 : 2,
              crossAxisSpacing: PremiumSaaSTheme.space4,
              mainAxisSpacing: PremiumSaaSTheme.space4,
              childAspectRatio: deviceType.isMobile ? 2.2 : 1.4,
              children: [
                PremiumActionCard(
                  title: 'Complete Your Profile',
                  description:
                      'Add missing sections to boost your CV strength by 15%',
                  icon: LucideIcons.userPlus,
                  color: PremiumSaaSTheme.primaryPurple,
                  onTap: () {},
                ),
                PremiumActionCard(
                  title: 'AI Optimize Content',
                  description: 'Let AI improve your descriptions and keywords',
                  icon: LucideIcons.sparkles,
                  color: PremiumSaaSTheme.accentTeal,
                  onTap: () {},
                ),
                PremiumActionCard(
                  title: 'Generate New CV',
                  description: 'Create professional PDFs in multiple templates',
                  icon: LucideIcons.fileDown,
                  color: PremiumSaaSTheme.accentBlue,
                  onTap: () {},
                ),
                PremiumActionCard(
                  title: 'Skills Analysis',
                  description: 'Discover trending skills in your industry',
                  icon: LucideIcons.trendingUp,
                  color: PremiumSaaSTheme.accentGreen,
                  onTap: () {},
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildAIInsightsPanel() {
    return Container(
      padding: EdgeInsets.all(PremiumSaaSTheme.space6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PremiumSaaSTheme.primaryPurple.withOpacity(0.05),
            PremiumSaaSTheme.accentBlue.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusXl),
        border: Border.all(
          color: PremiumSaaSTheme.primaryPurple.withOpacity(0.1),
        ),
        boxShadow: PremiumSaaSTheme.shadowMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(PremiumSaaSTheme.space2),
                decoration: BoxDecoration(
                  gradient: PremiumSaaSTheme.heroGradient,
                  borderRadius:
                      BorderRadius.circular(PremiumSaaSTheme.radiusMd),
                ),
                child: Icon(
                  LucideIcons.brain,
                  color: PremiumSaaSTheme.textInverse,
                  size: 16,
                ),
              ),
              SizedBox(width: PremiumSaaSTheme.space3),
              Text(
                'AI Insights',
                style: PremiumSaaSTheme.headingSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: PremiumSaaSTheme.space5),
          _buildInsightItem(
            'Add "Python" skill',
            'Based on your experience, this would increase job matches by 34%',
            LucideIcons.plus,
            PremiumSaaSTheme.accentGreen,
          ),
          _buildInsightItem(
            'Improve work descriptions',
            'Use more action verbs and quantify achievements',
            LucideIcons.edit3,
            PremiumSaaSTheme.accentBlue,
          ),
          _buildInsightItem(
            'ATS Optimization',
            'Your CV scores 92/100 for applicant tracking systems',
            LucideIcons.target,
            PremiumSaaSTheme.primaryPurple,
          ),
          _buildInsightItem(
            'Industry Trends',
            'Cloud computing skills are trending +45% in your field',
            LucideIcons.trendingUp,
            PremiumSaaSTheme.accentTeal,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(
      String title, String description, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: PremiumSaaSTheme.space4),
      padding: EdgeInsets.all(PremiumSaaSTheme.space4),
      decoration: BoxDecoration(
        color: PremiumSaaSTheme.lightSurface,
        borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusLg),
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
              borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusMd),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          SizedBox(width: PremiumSaaSTheme.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PremiumSaaSTheme.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: PremiumSaaSTheme.space1),
                Text(
                  description,
                  style: PremiumSaaSTheme.bodySmall.copyWith(
                    color: PremiumSaaSTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            LucideIcons.chevronRight,
            color: PremiumSaaSTheme.textTertiary,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDownloadsTable() {
    return PremiumDataTable(
      title: 'Recent Downloads',
      headers: ['Template', 'Generated', 'Status', 'Actions'],
      onViewAll: () {},
      rows: [
        [
          _buildTemplateCell('Academic CV', LucideIcons.graduationCap,
              PremiumSaaSTheme.primaryPurple),
          Text('16 hours ago', style: PremiumSaaSTheme.bodyMedium),
          _buildStatusBadge('Ready', PremiumSaaSTheme.accentGreen),
          _buildActionButtons(),
        ],
        [
          _buildTemplateCell(
              'Modern CV', LucideIcons.layout, PremiumSaaSTheme.accentBlue),
          Text('16 hours ago', style: PremiumSaaSTheme.bodyMedium),
          _buildStatusBadge('Ready', PremiumSaaSTheme.accentGreen),
          _buildActionButtons(),
        ],
        [
          _buildTemplateCell(
              'Classic CV', LucideIcons.fileText, PremiumSaaSTheme.accentTeal),
          Text('16 hours ago', style: PremiumSaaSTheme.bodyMedium),
          _buildStatusBadge('Ready', PremiumSaaSTheme.accentGreen),
          _buildActionButtons(),
        ],
        [
          _buildTemplateCell('Academic CV', LucideIcons.graduationCap,
              PremiumSaaSTheme.primaryPurple),
          Text('19 hours ago', style: PremiumSaaSTheme.bodyMedium),
          _buildStatusBadge('Ready', PremiumSaaSTheme.accentGreen),
          _buildActionButtons(),
        ],
      ],
    );
  }

  Widget _buildTemplateCell(String name, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusMd),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        SizedBox(width: PremiumSaaSTheme.space3),
        Text(
          name,
          style: PremiumSaaSTheme.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: PremiumSaaSTheme.space3,
        vertical: PremiumSaaSTheme.space1,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusSm),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: PremiumSaaSTheme.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusMd),
            child: Container(
              padding: EdgeInsets.all(PremiumSaaSTheme.space2),
              child: Icon(
                LucideIcons.download,
                color: PremiumSaaSTheme.primaryPurple,
                size: 16,
              ),
            ),
          ),
        ),
        SizedBox(width: PremiumSaaSTheme.space2),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusMd),
            child: Container(
              padding: EdgeInsets.all(PremiumSaaSTheme.space2),
              child: Icon(
                LucideIcons.moreHorizontal,
                color: PremiumSaaSTheme.textTertiary,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: PremiumSaaSTheme.lightSurface,
        border: Border(
          top: BorderSide(color: PremiumSaaSTheme.lightBorder),
        ),
        boxShadow: PremiumSaaSTheme.shadowSoft,
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: PremiumSaaSTheme.primaryPurple,
        unselectedItemColor: PremiumSaaSTheme.textTertiary,
        currentIndex: 0,
        selectedLabelStyle: PremiumSaaSTheme.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: PremiumSaaSTheme.labelSmall,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.layoutDashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.fileText),
            label: 'My CV',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.download),
            label: 'Downloads',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.sparkles),
            label: 'AI Tools',
          ),
        ],
      ),
    );
  }
}
