import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/enterprise_theme.dart';
import '../../../../core/layout/responsive_layout.dart';
import '../../../../core/widgets/enterprise_ui_components.dart';
import '../../../../core/widgets/modern_sidebar.dart';
import '../../../../core/widgets/modern_top_bar.dart';

class EnterpriseDashboardScreen extends StatefulWidget {
  const EnterpriseDashboardScreen({super.key});

  @override
  State<EnterpriseDashboardScreen> createState() =>
      _EnterpriseDashboardScreenState();
}

class _EnterpriseDashboardScreenState extends State<EnterpriseDashboardScreen>
    with TickerProviderStateMixin {
  bool _isSidebarCollapsed = false;
  String _currentRoute = '/dashboard';
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: EnterpriseTheme.backgroundSecondary,
      body: Row(
        children: [
          ModernSidebar(
            isCollapsed: _isSidebarCollapsed,
            onToggle: () =>
                setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
            currentRoute: _currentRoute,
            onNavigate: (route) => setState(() => _currentRoute = route),
          ),
          Expanded(
            child: Column(
              children: [
                ModernTopBar(
                  title: 'Dashboard',
                  onNotificationPressed: () {},
                  onProfilePressed: () {},
                  notificationCount: 3,
                ),
                Expanded(child: _buildDashboardContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: EnterpriseTheme.backgroundSecondary,
      appBar: ModernTopBar(
        title: 'Dashboard',
        onMenuPressed: () => Scaffold.of(context).openDrawer(),
        onNotificationPressed: () {},
        onProfilePressed: () {},
        notificationCount: 3,
      ),
      drawer: Drawer(
        child: ModernSidebar(
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(EnterpriseTheme.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreetingSection(),
              const SizedBox(height: EnterpriseTheme.spacing32),
              _buildStatsGrid(),
              const SizedBox(height: EnterpriseTheme.spacing32),
              _buildQuickActionsGrid(),
              const SizedBox(height: EnterpriseTheme.spacing32),
              ResponsiveBuilder(
                builder: (context, deviceType) {
                  if (deviceType.isMobile) {
                    return Column(
                      children: [
                        _buildRecentDownloadsTable(),
                        const SizedBox(height: EnterpriseTheme.spacing24),
                        _buildAISuggestionsPanel(),
                        const SizedBox(height: EnterpriseTheme.spacing24),
                        _buildActivityTimeline(),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildRecentDownloadsTable(),
                      ),
                      const SizedBox(width: EnterpriseTheme.spacing24),
                      Expanded(
                        child: Column(
                          children: [
                            _buildAISuggestionsPanel(),
                            const SizedBox(height: EnterpriseTheme.spacing24),
                            _buildActivityTimeline(),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingSection() {
    return EnterpriseCard(
      backgroundColor: EnterpriseTheme.primaryPurple.withOpacity(0.02),
      boxShadow: const [], // flat inside the top section
      child: ResponsiveBuilder(
        builder: (context, deviceType) {
          if (deviceType.isMobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good afternoon, William 👋',
                  style: EnterpriseTheme.h3.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: EnterpriseTheme.spacing8),
                Text(
                  'Your CV is looking great! Let\'s make it even better with AI suggestions.',
                  style: EnterpriseTheme.bodyMedium.copyWith(
                    color: EnterpriseTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: EnterpriseTheme.spacing16),
                Text(
                  'Sunday, May 24, 2026',
                  style: EnterpriseTheme.bodySmall.copyWith(
                    color: EnterpriseTheme.textTertiary,
                  ),
                ),
                const SizedBox(height: EnterpriseTheme.spacing16),
                ProgressIndicator(
                  progress: 0.85,
                  label: '85% Complete',
                  color: EnterpriseTheme.success,
                ),
              ],
            );
          }
          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good afternoon, William 👋',
                      style: EnterpriseTheme.h2.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: EnterpriseTheme.spacing8),
                    Text(
                      'Your CV is looking great! Let\'s make it even better with AI suggestions.',
                      style: EnterpriseTheme.bodyLarge.copyWith(
                        color: EnterpriseTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: EnterpriseTheme.spacing16),
                    Text(
                      'Sunday, May 24, 2026',
                      style: EnterpriseTheme.bodyMedium.copyWith(
                        color: EnterpriseTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: EnterpriseTheme.spacing24),
              ProgressIndicator(
                progress: 0.85,
                label: '85% Complete',
                color: EnterpriseTheme.success,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid() {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: deviceType.isMobile ? 2 : 4,
          crossAxisSpacing: EnterpriseTheme.spacing16,
          mainAxisSpacing: EnterpriseTheme.spacing16,
          childAspectRatio: deviceType.isMobile ? 1.2 : 1.4,
          children: const [
            StatCard(
              title: 'Profile Progress',
              value: '85%',
              icon: LucideIcons.user,
              color: EnterpriseTheme.success,
              subtitle: 'Almost complete',
            ),
            StatCard(
              title: 'Work Experience',
              value: '3',
              icon: LucideIcons.briefcase,
              color: EnterpriseTheme.primaryPurple,
              subtitle: 'Positions added',
            ),
            StatCard(
              title: 'Skills Added',
              value: '12',
              icon: LucideIcons.zap,
              color: EnterpriseTheme.accentBlue,
              subtitle: 'Technical & soft',
            ),
            StatCard(
              title: 'CV Downloads',
              value: '8',
              icon: LucideIcons.download,
              color: EnterpriseTheme.accentOrange,
              subtitle: 'This month',
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActionsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: EnterpriseTheme.h3.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: EnterpriseTheme.spacing16),
        ResponsiveBuilder(
          builder: (context, deviceType) {
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: deviceType.isMobile ? 1 : 3,
              crossAxisSpacing: EnterpriseTheme.spacing16,
              mainAxisSpacing: EnterpriseTheme.spacing16,
              childAspectRatio: deviceType.isMobile ? 2.5 : 1.3,
              children: [
                ActionCard(
                  title: 'Edit CV Information',
                  description:
                      'Update your personal details, experience, and skills',
                  icon: LucideIcons.edit3,
                  onTap: () {},
                  accentColor: EnterpriseTheme.primaryPurple,
                ),
                ActionCard(
                  title: 'Generate PDF',
                  description: 'Create professional CVs in multiple templates',
                  icon: LucideIcons.fileDown,
                  onTap: () {},
                  accentColor: EnterpriseTheme.accentBlue,
                ),
                ActionCard(
                  title: 'Improve with AI',
                  description: 'Get AI-powered suggestions and optimizations',
                  icon: LucideIcons.sparkles,
                  onTap: () {},
                  accentColor: EnterpriseTheme.accentTeal,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentDownloadsTable() {
    return EnterpriseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recent Downloads',
                style: EnterpriseTheme.h4.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: EnterpriseTheme.labelLarge.copyWith(
                    color: EnterpriseTheme.primaryPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: EnterpriseTheme.spacing16),
          _buildDownloadItem('Academic CV', '16 hours ago', StatusType.success),
          _buildDownloadItem('Modern CV', '16 hours ago', StatusType.success),
          _buildDownloadItem('Classic CV', '16 hours ago', StatusType.success),
          _buildDownloadItem('Academic CV', '19 hours ago', StatusType.success),
          _buildDownloadItem('Modern CV', '19 hours ago', StatusType.success),
        ],
      ),
    );
  }

  Widget _buildDownloadItem(String name, String time, StatusType status) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: EnterpriseTheme.spacing12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: EnterpriseTheme.cardBorder.withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: EnterpriseTheme.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(EnterpriseTheme.radiusMd),
            ),
            child: const Icon(
              LucideIcons.fileText,
              color: EnterpriseTheme.primaryPurple,
              size: 20,
            ),
          ),
          const SizedBox(width: EnterpriseTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: EnterpriseTheme.labelLarge),
                Text(
                  'Generated $time',
                  style: EnterpriseTheme.bodySmall.copyWith(
                    color: EnterpriseTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(text: 'Ready', type: status),
          const SizedBox(width: EnterpriseTheme.spacing12),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              LucideIcons.download,
              color: EnterpriseTheme.primaryPurple,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISuggestionsPanel() {
    return EnterpriseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.sparkles,
                color: EnterpriseTheme.primaryPurple,
                size: 20,
              ),
              const SizedBox(width: EnterpriseTheme.spacing8),
              Text(
                'AI Suggestions',
                style: EnterpriseTheme.h4.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: EnterpriseTheme.spacing16),
          _buildSuggestionItem(
            'Add Python to your skills',
            'Based on your experience, Python would strengthen your profile',
            LucideIcons.plus,
          ),
          _buildSuggestionItem(
            'Improve work descriptions',
            'Use more action verbs and quantify your achievements',
            LucideIcons.edit,
          ),
          _buildSuggestionItem(
            'ATS Optimization',
            'Your CV scores 78/100 for ATS compatibility',
            LucideIcons.target,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: EnterpriseTheme.spacing12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: EnterpriseTheme.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(EnterpriseTheme.radiusSm),
            ),
            child: Icon(icon, color: EnterpriseTheme.primaryPurple, size: 16),
          ),
          const SizedBox(width: EnterpriseTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: EnterpriseTheme.labelMedium),
                Text(
                  description,
                  style: EnterpriseTheme.bodySmall.copyWith(
                    color: EnterpriseTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTimeline() {
    return EnterpriseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: EnterpriseTheme.h4.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: EnterpriseTheme.spacing16),
          _buildTimelineItem(
            'CV Generated',
            '2 hours ago',
            LucideIcons.fileText,
            EnterpriseTheme.success,
          ),
          _buildTimelineItem(
            'Skills Updated',
            '1 day ago',
            LucideIcons.zap,
            EnterpriseTheme.accentBlue,
          ),
          _buildTimelineItem(
            'Profile Edited',
            '3 days ago',
            LucideIcons.user,
            EnterpriseTheme.primaryPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
      String title, String time, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: EnterpriseTheme.spacing8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: EnterpriseTheme.spacing12),
          Icon(icon, color: color, size: 16),
          const SizedBox(width: EnterpriseTheme.spacing8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: EnterpriseTheme.labelMedium),
                Text(
                  time,
                  style: EnterpriseTheme.bodySmall.copyWith(
                    color: EnterpriseTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: EnterpriseTheme.cardBackground,
        border: Border(
          top: BorderSide(color: EnterpriseTheme.cardBorder),
        ),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: EnterpriseTheme.primaryPurple,
        unselectedItemColor: EnterpriseTheme.textTertiary,
        currentIndex: 0,
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
            icon: Icon(LucideIcons.brain),
            label: 'AI Tools',
          ),
        ],
      ),
    );
  }
}
