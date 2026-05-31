import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/premium_portfolio_colors.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/widgets/cv_dashboard_skeleton.dart';
import '../../../../core/widgets/enterprise_loading.dart';
import '../../../../core/widgets/modern_saas_sidebar.dart';
import '../../../../core/layout/responsive_layout.dart';
import '../../../../core/accessibility/accessibility_foundation.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../core/widgets/breadcrumb_navigation.dart';
import '../../../../core/widgets/help_tooltip.dart';
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
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isSidebarCollapsed = false;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cvProfileAsync = ref.watch(cvProfileProvider);

    return Container(
      color: PremiumPortfolioColors.background,
      child: Stack(
        children: [
          _buildGridBackground(),
          EnterpriseLoadingManager(
            state: cvProfileAsync.when(
              loading: () => LoadingState.loading,
              error: (_, __) => LoadingState.error,
              data: (profile) => profile == null ? LoadingState.loading : LoadingState.loaded,
            ),
            loadingWidget: const DashboardSkeleton(),
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
    return Column(
      children: [
        // Breadcrumb Navigation
        BreadcrumbNavigation(
          items: AppBreadcrumbs.dashboard(),
          onNavigate: (route) => context.go(route),
        ),
        
        // Main Dashboard Content
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildWelcomeSection(profile)),
                      const SizedBox(width: 16),
                      const QuickHelpButton(),
                    ],
                  ),
            const SizedBox(height: 32),
            _buildProfileCompletionCard(profile),
            const SizedBox(height: 32),
            _buildQuickStatsRow(profile),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildRecentDownloadsSection(),
                      const SizedBox(height: 24),
                      _buildDownloadStatsSection(),
                      const SizedBox(height: 24),
                      _buildAIInsightsSection(),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildQuickActionsSection(),
                      const SizedBox(height: 24),
                      _buildRecentActivitySection(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(CVProfileModel profile) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '$greeting, Wes! ',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: PremiumPortfolioColors.primaryText,
                  ),
                ),
                const Text(
                  '👋',
                  style: TextStyle(fontSize: 28),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
              style: const TextStyle(
                fontSize: 16,
                color: PremiumPortfolioColors.secondaryText,
              ),
            ),
          ],
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
                  fontWeight: FontWeight.w600,
                  color: PremiumPortfolioColors.success,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatsRow(CVProfileModel profile) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Profile Sections',
            '${_getFilledSectionCount(profile)}/7',
            'Completed',
            LucideIcons.user,
            PremiumPortfolioColors.accentPurple,
            '12%',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Experience',
            '${profile.experiences.length}',
            'Added',
            LucideIcons.briefcase,
            PremiumPortfolioColors.accentBlue,
            '8%',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Skills',
            '${profile.skills.length}',
            'Added',
            LucideIcons.zap,
            PremiumPortfolioColors.success,
            '16%',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Projects',
            '${profile.projects.length}',
            'Added',
            LucideIcons.folder,
            PremiumPortfolioColors.warning,
            '5%',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color, String percentage) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.trendingUp,
                    color: PremiumPortfolioColors.success,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    percentage,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: PremiumPortfolioColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: PremiumPortfolioColors.primaryText,
              height: 1.2,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 4,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.7,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletionCard(CVProfileModel profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile Completion',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: PremiumPortfolioColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${profile.completionPercentage}%',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: PremiumPortfolioColors.accentPurple,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: PremiumPortfolioColors.borderLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: profile.completionPercentage / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: PremiumPortfolioColors.accentPurple,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Almost there! Complete your profile to 100%',
                  style: TextStyle(
                    fontSize: 14,
                    color: PremiumPortfolioColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: PremiumPortfolioColors.accentPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              LucideIcons.clipboard,
              size: 60,
              color: PremiumPortfolioColors.accentPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: PremiumPortfolioColors.primaryText,
            ),
          ),
          const SizedBox(height: 20),
          _buildQuickActionItem(
            LucideIcons.plus,
            'Create New CV',
            PremiumPortfolioColors.accentPurple,
            () => context.go('/pdf/result'),
          ),
          const SizedBox(height: 16),
          _buildQuickActionItem(
            LucideIcons.upload,
            'Upload Resume',
            PremiumPortfolioColors.accentBlue,
            () {},
          ),
          const SizedBox(height: 16),
          _buildQuickActionItem(
            LucideIcons.sparkles,
            'AI Suggestions',
            PremiumPortfolioColors.success,
            () => context.go('/cv/intelligence'),
          ),
          const SizedBox(height: 16),
          _buildQuickActionItem(
            LucideIcons.layout,
            'Browse Templates',
            PremiumPortfolioColors.warning,
            () => context.go('/templates'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(IconData icon, String title, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: PremiumPortfolioColors.primaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadStatsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              LucideIcons.download,
              'Total Downloads',
              '12',
              PremiumPortfolioColors.accentBlue,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: PremiumPortfolioColors.borderLight,
          ),
          Expanded(
            child: _buildStatItem(
              LucideIcons.calendar,
              'This Month',
              '5',
              PremiumPortfolioColors.accentPurple,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: PremiumPortfolioColors.borderLight,
          ),
          Expanded(
            child: _buildStatItem(
              LucideIcons.hardDrive,
              'Storage Used',
              '24 MB / 1 GB',
              PremiumPortfolioColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: color,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: PremiumPortfolioColors.primaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: PremiumPortfolioColors.secondaryText,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAIInsightsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Insights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: PremiumPortfolioColors.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Improve your profile with AI',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: PremiumPortfolioColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Get personalized suggestions to make your CV stand out and land more interviews.',
                      style: TextStyle(
                        fontSize: 14,
                        color: PremiumPortfolioColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.go('/cv/intelligence'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PremiumPortfolioColors.accentPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Get Suggestions'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: PremiumPortfolioColors.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.sparkles,
                  size: 40,
                  color: PremiumPortfolioColors.accentPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: PremiumPortfolioColors.primaryText,
            ),
          ),
          const SizedBox(height: 20),
          _buildActivityItem(
            LucideIcons.fileText,
            'Academic CV.pdf downloaded',
            '1 day ago',
            PremiumPortfolioColors.accentPurple,
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            LucideIcons.user,
            'Profile updated',
            '2 days ago',
            PremiumPortfolioColors.accentBlue,
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            LucideIcons.zap,
            'Skills updated',
            '3 days ago',
            PremiumPortfolioColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(IconData icon, String title, String time, Color color) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: PremiumPortfolioColors.primaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 12,
                  color: PremiumPortfolioColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentDownloadsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const Text(
                  'Recent Downloads',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: PremiumPortfolioColors.primaryText,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go('/cv/downloads'),
                  child: const Text(
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
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: const BoxDecoration(
              color: PremiumPortfolioColors.background,
              border: Border(
                top: BorderSide(color: PremiumPortfolioColors.borderLight),
                bottom: BorderSide(color: PremiumPortfolioColors.borderLight),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'File Name',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: PremiumPortfolioColors.secondaryText,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Type',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: PremiumPortfolioColors.secondaryText,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Generated',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: PremiumPortfolioColors.secondaryText,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: PremiumPortfolioColors.secondaryText,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Action',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: PremiumPortfolioColors.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                  
                  final recentDownloads = history.take(3).toList();
                  return Column(
                    children: recentDownloads.map((cv) => _buildDownloadTableRow(cv)).toList(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadTableRow(GeneratedCVModel cv) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: PremiumPortfolioColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: PremiumPortfolioColors.accentPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    LucideIcons.fileText,
                    size: 16,
                    color: PremiumPortfolioColors.accentPurple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${cv.templateDisplay} CV.pdf',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: PremiumPortfolioColors.primaryText,
                        ),
                      ),
                      const Text(
                        'A4 • PDF',
                        style: TextStyle(
                          fontSize: 12,
                          color: PremiumPortfolioColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            flex: 1,
            child: Text(
              'CV',
              style: TextStyle(
                fontSize: 14,
                color: PremiumPortfolioColors.primaryText,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              TimeUtils.timeAgo(cv.generatedAt),
              style: const TextStyle(
                fontSize: 14,
                color: PremiumPortfolioColors.primaryText,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: PremiumPortfolioColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Ready',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: PremiumPortfolioColors.success,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => _downloadCV(cv),
                  icon: const Icon(
                    LucideIcons.download,
                    size: 16,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: PremiumPortfolioColors.accentPurple.withOpacity(0.1),
                    foregroundColor: PremiumPortfolioColors.accentPurple,
                    minimumSize: const Size(32, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    LucideIcons.moreHorizontal,
                    size: 16,
                  ),
                  style: IconButton.styleFrom(
                    foregroundColor: PremiumPortfolioColors.secondaryText,
                    minimumSize: const Size(32, 32),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDownloadsState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            LucideIcons.download,
            size: 48,
            color: PremiumPortfolioColors.secondaryText.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No CVs generated yet',
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

  String _getInitials(String fullName) {
    if (fullName.isEmpty) return 'U';

    final names = fullName.trim().split(' ');
    if (names.length == 1) {
      return names[0][0].toUpperCase();
    }

    final firstInitial = names.first.isNotEmpty ? names.first[0].toUpperCase() : '';
    final lastInitial = names.last.isNotEmpty ? names.last[0].toUpperCase() : '';

    return '$firstInitial$lastInitial';
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

    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

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