import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/modern_saas_theme.dart';
import '../../../../core/layout/modern_dashboard_layout_with_header.dart';
import '../../../../core/widgets/modern_dashboard_cards.dart';
import '../../../../core/widgets/modern_dashboard_header.dart';
import '../../../../core/widgets/enterprise_loading.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../pdf/presentation/providers/pdf_provider.dart';
import '../../data/models/cv_models.dart';
import '../providers/cv_provider.dart';

class ModernDashboardWithHeaderScreen extends ConsumerStatefulWidget {
  const ModernDashboardWithHeaderScreen({super.key});

  @override
  ConsumerState<ModernDashboardWithHeaderScreen> createState() => _ModernDashboardWithHeaderScreenState();
}

class _ModernDashboardWithHeaderScreenState extends ConsumerState<ModernDashboardWithHeaderScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _currentNavIndex = 0;
  int _notificationCount = 3;
  bool _showMobileSearch = false;

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
    final user = ref.watch(currentUserProvider);
    final cvProfileAsync = ref.watch(cvProfileProvider);

    return Stack(
      children: [
        ModernDashboardLayoutWithHeader(
          currentIndex: _currentNavIndex,
          onNavigationChanged: _handleNavigation,
          userName: user?.fullName,
          userEmail: user?.email,
          onProfileTap: _showProfileMenu,
          onUpgradeTap: _handleUpgrade,
          onNotificationTap: _showNotifications,
          onSearch: _handleSearch,
          notificationCount: _notificationCount,
          showSearch: true,
          headerActions: [
            _buildQuickActionButton(),
          ],
          child: EnterpriseLoadingManager(
            state: cvProfileAsync.when(
              loading: () => LoadingState.loading,
              error: (_, __) => LoadingState.error,
              data: (profile) => profile == null ? LoadingState.loading : LoadingState.loaded,
            ),
            loadingWidget: _buildLoadingSkeleton(),
            errorMessage: cvProfileAsync.hasError ? cvProfileAsync.error.toString() : null,
            onRetry: () => ref.invalidate(cvProfileProvider),
            child: cvProfileAsync.hasValue && cvProfileAsync.value != null
                ? FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildDashboardContent(cvProfileAsync.value!),
                  )
                : const SizedBox.shrink(),
          ),
        ),
        
        // Mobile search overlay
        if (_showMobileSearch)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: ModernSaaSDashboardTheme.background.withOpacity(0.95),
              child: SafeArea(
                child: MobileSearchWidget(
                  onSearch: _handleSearch,
                  onClose: () => setState(() => _showMobileSearch = false),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickActionButton() {
    return IconButton(
      onPressed: () => setState(() => _showMobileSearch = true),
      icon: const Icon(
        LucideIcons.search,
        color: ModernSaaSDashboardTheme.tertiaryText,
      ),
      style: IconButton.styleFrom(
        backgroundColor: ModernSaaSDashboardTheme.hover,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(CVProfileModel profile) {
    return ModernDashboardContentWithHeader(
      children: [
        // Dashboard stats header
        DashboardStatsHeader(
          stats: [
            DashboardStat(
              label: 'Profile Complete',
              value: '${profile.completionPercentage}%',
              icon: LucideIcons.user,
              color: ModernSaaSDashboardTheme.accentPurple,
              trend: 5.2,
            ),
            DashboardStat(
              label: 'CV Downloads',
              value: '12',
              icon: LucideIcons.download,
              color: ModernSaaSDashboardTheme.success,
              trend: 8.1,
            ),
            DashboardStat(
              label: 'Profile Views',
              value: '247',
              icon: LucideIcons.eye,
              color: ModernSaaSDashboardTheme.info,
              trend: -2.3,
            ),
            DashboardStat(
              label: 'Applications',
              value: '18',
              icon: LucideIcons.send,
              color: ModernSaaSDashboardTheme.warning,
              trend: 12.5,
            ),
          ],
        ),
        
        // Welcome card
        ModernWelcomeCard(
          greeting: _getGreeting(),
          date: _getFormattedDate(),
          completionPercentage: profile.completionPercentage,
        ),
        
        // Quick actions
        _buildQuickActionsCard(),
        
        // Stats cards
        ..._buildStatsCards(profile),
        
        // Recent activity
        _buildRecentActivityCard(),
        
        // AI insights
        _buildAIInsightsCard(profile),
      ],
    );
  }

  Widget _buildQuickActionsCard() {
    return ModernSectionCard(
      title: 'Quick Actions',
      subtitle: 'Get things done faster',
      child: Padding(
        padding: const EdgeInsets.all(ModernSaaSDashboardTheme.spacingXl),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionTile(
                    icon: LucideIcons.fileText,
                    title: 'Generate CV',
                    subtitle: 'Create new PDF',
                    color: ModernSaaSDashboardTheme.accentPurple,
                    onTap: () => _handleNavigation(5),
                  ),
                ),
                const SizedBox(width: ModernSaaSDashboardTheme.spacingMd),
                Expanded(
                  child: _buildQuickActionTile(
                    icon: LucideIcons.bot,
                    title: 'AI Assistant',
                    subtitle: 'Get suggestions',
                    color: ModernSaaSDashboardTheme.success,
                    onTap: () => _handleNavigation(6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ModernSaaSDashboardTheme.spacingMd),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionTile(
                    icon: LucideIcons.layout,
                    title: 'Templates',
                    subtitle: 'Browse designs',
                    color: ModernSaaSDashboardTheme.info,
                    onTap: () => _handleNavigation(7),
                  ),
                ),
                const SizedBox(width: ModernSaaSDashboardTheme.spacingMd),
                Expanded(
                  child: _buildQuickActionTile(
                    icon: LucideIcons.settings,
                    title: 'Settings',
                    subtitle: 'Customize app',
                    color: ModernSaaSDashboardTheme.warning,
                    onTap: () => _handleNavigation(8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(ModernSaaSDashboardTheme.spacingMd),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: ModernSaaSDashboardTheme.spacingSm),
              Text(
                title,
                style: ModernSaaSDashboardTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: ModernSaaSDashboardTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStatsCards(CVProfileModel profile) {
    return [
      ModernStatCard(
        title: 'Work Experience',
        value: '${profile.experiences.length}',
        icon: LucideIcons.briefcase,
        color: ModernSaaSDashboardTheme.info,
        subtitle: 'Positions added',
        onTap: () => _handleNavigation(2),
      ),
      ModernStatCard(
        title: 'Skills',
        value: '${profile.skills.length}',
        icon: LucideIcons.zap,
        color: ModernSaaSDashboardTheme.success,
        subtitle: 'Skills listed',
        onTap: () => _handleNavigation(3),
      ),
      ModernStatCard(
        title: 'Projects',
        value: '${profile.projects.length}',
        icon: LucideIcons.folder,
        color: ModernSaaSDashboardTheme.warning,
        subtitle: 'Projects showcased',
        onTap: () => _handleNavigation(4),
      ),
    ];
  }

  Widget _buildRecentActivityCard() {
    return ModernSectionCard(
      title: 'Recent Activity',
      subtitle: 'Your latest actions',
      onViewAll: () => _showActivityHistory(),
      child: Padding(
        padding: const EdgeInsets.all(ModernSaaSDashboardTheme.spacingXl),
        child: Column(
          children: [
            _buildActivityItem(
              icon: LucideIcons.fileText,
              title: 'Generated Modern CV',
              subtitle: '2 hours ago',
              color: ModernSaaSDashboardTheme.accentPurple,
            ),
            const SizedBox(height: ModernSaaSDashboardTheme.spacingMd),
            _buildActivityItem(
              icon: LucideIcons.edit,
              title: 'Updated work experience',
              subtitle: '1 day ago',
              color: ModernSaaSDashboardTheme.info,
            ),
            const SizedBox(height: ModernSaaSDashboardTheme.spacingMd),
            _buildActivityItem(
              icon: LucideIcons.plus,
              title: 'Added new project',
              subtitle: '3 days ago',
              color: ModernSaaSDashboardTheme.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: ModernSaaSDashboardTheme.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: ModernSaaSDashboardTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: ModernSaaSDashboardTheme.bodySmall,
              ),
            ],
          ),
        ),
        Icon(
          LucideIcons.chevronRight,
          size: 16,
          color: ModernSaaSDashboardTheme.tertiaryText,
        ),
      ],
    );
  }

  Widget _buildAIInsightsCard(CVProfileModel profile) {
    return ModernSectionCard(
      title: 'AI Insights',
      subtitle: 'Personalized recommendations',
      child: Padding(
        padding: const EdgeInsets.all(ModernSaaSDashboardTheme.spacingXl),
        child: Column(
          children: [
            _buildInsightItem(
              icon: LucideIcons.trendingUp,
              title: 'Profile Strength: Good',
              description: 'Add 2-3 more skills to reach "Excellent" level',
              color: ModernSaaSDashboardTheme.success,
              progress: 0.75,
            ),
            const SizedBox(height: ModernSaaSDashboardTheme.spacingLg),
            _buildInsightItem(
              icon: LucideIcons.award,
              title: 'Missing Certifications',
              description: 'Adding certifications can boost your profile by 25%',
              color: ModernSaaSDashboardTheme.warning,
              progress: 0.5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required double progress,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: ModernSaaSDashboardTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ModernSaaSDashboardTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: ModernSaaSDashboardTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: ModernSaaSDashboardTheme.spacingSm),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildLoadingSkeleton() {
    return ModernDashboardContentWithHeader(
      children: List.generate(6, (index) {
        return Container(
          height: index == 0 ? 120 : 140,
          decoration: ModernComponentStyles.card,
        );
      }),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getFormattedDate() {
    return DateFormat('EEEE, MMMM d, y').format(DateTime.now());
  }

  void _handleNavigation(int index) {
    setState(() => _currentNavIndex = index);
    
    switch (index) {
      case 0: context.go('/dashboard'); break;
      case 1: context.go('/cv/profile'); break;
      case 2: context.go('/cv/experience'); break;
      case 3: context.go('/cv/skills'); break;
      case 4: context.go('/cv/projects'); break;
      case 5: context.go('/cv/downloads'); break;
      case 6: context.go('/ai/assistant'); break;
      case 7: context.go('/templates'); break;
      case 8: context.go('/settings'); break;
      case 9: context.go('/account'); break;
    }
  }

  void _handleSearch(String query) {
    // Implement search functionality
    print('Searching for: $query');
  }

  void _showNotifications() {
    setState(() => _notificationCount = 0);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: ModernSaaSDashboardTheme.surfaceBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildNotificationsSheet(),
    );
  }

  Widget _buildNotificationsSheet() {
    return Container(
      padding: const EdgeInsets.all(ModernSaaSDashboardTheme.spacing2xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifications',
            style: ModernSaaSDashboardTheme.headlineLarge,
          ),
          const SizedBox(height: ModernSaaSDashboardTheme.spacingLg),
          _buildNotificationItem(
            icon: LucideIcons.checkCircle,
            title: 'CV Generated Successfully',
            subtitle: 'Your Modern CV is ready for download',
            time: '2 hours ago',
            color: ModernSaaSDashboardTheme.success,
          ),
          _buildNotificationItem(
            icon: LucideIcons.bot,
            title: 'AI Suggestion Available',
            subtitle: 'New recommendations for your profile',
            time: '1 day ago',
            color: ModernSaaSDashboardTheme.accentPurple,
          ),
          _buildNotificationItem(
            icon: LucideIcons.star,
            title: 'Profile Viewed',
            subtitle: 'Your profile was viewed 5 times today',
            time: '2 days ago',
            color: ModernSaaSDashboardTheme.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ModernSaaSDashboardTheme.spacingMd),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: ModernSaaSDashboardTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ModernSaaSDashboardTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(subtitle, style: ModernSaaSDashboardTheme.bodySmall),
                Text(
                  time,
                  style: ModernSaaSDashboardTheme.bodySmall.copyWith(
                    color: ModernSaaSDashboardTheme.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: ModernSaaSDashboardTheme.surfaceBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildProfileSheet(),
    );
  }

  Widget _buildProfileSheet() {
    final user = ref.watch(currentUserProvider);
    
    return Container(
      padding: const EdgeInsets.all(ModernSaaSDashboardTheme.spacing2xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      ModernSaaSDashboardTheme.accentPurple,
                      ModernSaaSDashboardTheme.accentPurpleLight,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _getInitials(user?.fullName ?? 'User'),
                    style: ModernSaaSDashboardTheme.headlineSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: ModernSaaSDashboardTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? 'User',
                      style: ModernSaaSDashboardTheme.headlineSmall,
                    ),
                    Text(
                      user?.email ?? 'user@example.com',
                      style: ModernSaaSDashboardTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: ModernSaaSDashboardTheme.spacingXl),
          ListTile(
            leading: const Icon(LucideIcons.settings),
            title: const Text('Settings'),
            onTap: () => _handleNavigation(8),
          ),
          ListTile(
            leading: const Icon(LucideIcons.userCircle),
            title: const Text('Account'),
            onTap: () => _handleNavigation(9),
          ),
          ListTile(
            leading: const Icon(LucideIcons.logOut, color: ModernSaaSDashboardTheme.error),
            title: const Text('Sign Out', style: TextStyle(color: ModernSaaSDashboardTheme.error)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  void _handleUpgrade() {
    // Implement upgrade flow
  }

  void _showActivityHistory() {
    // Show full activity history
  }

  void _logout() {
    Navigator.pop(context);
    context.go('/');
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
}