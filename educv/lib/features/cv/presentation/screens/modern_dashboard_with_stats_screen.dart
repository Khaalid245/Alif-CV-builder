import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/modern_saas_theme.dart';
import '../../../../core/widgets/dashboard_stat_cards.dart';
import '../../../../core/layout/modern_dashboard_layout_with_header.dart';
import '../../../../core/widgets/profile_completion_hero_card.dart';
import '../../../../core/widgets/modern_dashboard_cards.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/cv_models.dart';
import '../providers/cv_provider.dart';

class ModernDashboardWithStatsScreen extends ConsumerStatefulWidget {
  const ModernDashboardWithStatsScreen({super.key});

  @override
  ConsumerState<ModernDashboardWithStatsScreen> createState() => _ModernDashboardWithStatsScreenState();
}

class _ModernDashboardWithStatsScreenState extends ConsumerState<ModernDashboardWithStatsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _currentNavIndex = 0;

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

    return ModernDashboardLayoutWithHeader(
      currentIndex: _currentNavIndex,
      onNavigationChanged: _handleNavigation,
      userName: user?.fullName,
      userEmail: user?.email,
      onProfileTap: _showProfileMenu,
      onNotificationTap: _showNotifications,
      onSearch: _handleSearch,
      notificationCount: 2,
      child: cvProfileAsync.when(
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error.toString()),
        data: (profile) => profile != null
            ? FadeTransition(
                opacity: _fadeAnimation,
                child: _buildDashboardContent(profile),
              )
            : _buildEmptyState(),
      ),
    );
  }

  Widget _buildDashboardContent(CVProfileModel profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile completion hero card
          ProfileCompletionHeroCard(
            completionPercentage: profile.completionPercentage,
            userName: ref.watch(currentUserProvider)?.fullName,
            totalSections: 7,
            completedSections: _getFilledSectionCount(profile),
            onCompleteProfile: () => _handleNavigation(1), // My CV
            onViewProfile: () => _handleNavigation(1), // My CV
          ),
          
          const SizedBox(height: 32),
          
          // Section header
          Text(
            'Overview',
            style: ModernSaaSDashboardTheme.headlineLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Track your profile progress and manage your CV sections',
            style: ModernSaaSDashboardTheme.bodyLarge.copyWith(
              color: ModernSaaSDashboardTheme.secondaryText,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Statistics grid
          DashboardStatsGrid(
            cards: _buildStatCards(profile),
          ),
          
          const SizedBox(height: 32),
          
          // Additional content sections
          _buildQuickActionsSection(),
          
          const SizedBox(height: 24),
          
          _buildRecentActivitySection(),
        ],
      ),
    );
  }

  List<DashboardStatCard> _buildStatCards(CVProfileModel profile) {
    return [
      // Profile Sections
      ProfileSectionStatCard(
        completedSections: _getFilledSectionCount(profile),
        totalSections: 7,
        onTap: () => _handleNavigation(1), // My CV
      ),
      
      // Experience
      ExperienceStatCard(
        experienceCount: profile.experiences.length,
        onTap: () => _handleNavigation(2), // Experience
      ),
      
      // Skills
      SkillsStatCard(
        skillsCount: profile.skills.length,
        onTap: () => _handleNavigation(3), // Skills
      ),
      
      // Projects
      ProjectsStatCard(
        projectsCount: profile.projects.length,
        onTap: () => _handleNavigation(4), // Projects
      ),
    ];
  }

  Widget _buildQuickActionsSection() {
    return ModernSectionCard(
      title: 'Quick Actions',
      subtitle: 'Common tasks to improve your CV',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildQuickActionRow([
              _QuickAction(
                icon: LucideIcons.fileText,
                title: 'Generate CV',
                subtitle: 'Create PDF',
                color: ModernSaaSDashboardTheme.accentPurple,
                onTap: () => _handleNavigation(5),
              ),
              _QuickAction(
                icon: LucideIcons.bot,
                title: 'AI Assistant',
                subtitle: 'Get help',
                color: ModernSaaSDashboardTheme.success,
                onTap: () => _handleNavigation(6),
              ),
            ]),
            
            const SizedBox(height: 16),
            
            _buildQuickActionRow([
              _QuickAction(
                icon: LucideIcons.layout,
                title: 'Templates',
                subtitle: 'Browse designs',
                color: ModernSaaSDashboardTheme.info,
                onTap: () => _handleNavigation(7),
              ),
              _QuickAction(
                icon: LucideIcons.download,
                title: 'Downloads',
                subtitle: 'View history',
                color: ModernSaaSDashboardTheme.warning,
                onTap: () => _handleNavigation(5),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionRow(List<_QuickAction> actions) {
    return Row(
      children: actions.map((action) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: actions.indexOf(action) < actions.length - 1 ? 16 : 0,
            ),
            child: _buildQuickActionCard(action),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActionCard(_QuickAction action) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: action.color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: action.color.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                action.title,
                style: ModernSaaSDashboardTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                action.subtitle,
                style: ModernSaaSDashboardTheme.bodySmall.copyWith(
                  color: ModernSaaSDashboardTheme.tertiaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return ModernSectionCard(
      title: 'Recent Activity',
      subtitle: 'Your latest profile updates',
      onViewAll: () => _showActivityHistory(),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildActivityItem(
              icon: LucideIcons.edit,
              title: 'Updated work experience',
              subtitle: '2 hours ago',
              color: ModernSaaSDashboardTheme.info,
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              icon: LucideIcons.plus,
              title: 'Added new skill: Flutter',
              subtitle: '1 day ago',
              color: ModernSaaSDashboardTheme.success,
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              icon: LucideIcons.folder,
              title: 'Created new project',
              subtitle: '3 days ago',
              color: ModernSaaSDashboardTheme.warning,
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
        const SizedBox(width: 16),
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
                style: ModernSaaSDashboardTheme.bodySmall.copyWith(
                  color: ModernSaaSDashboardTheme.tertiaryText,
                ),
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

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Hero card skeleton
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: ModernSaaSDashboardTheme.borderLight,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Stats grid skeleton
          DashboardStatsGrid(
            cards: List.generate(4, (index) {
              return DashboardStatCard(
                title: '',
                value: '',
                icon: LucideIcons.loader,
                color: ModernSaaSDashboardTheme.borderLight,
                isLoading: true,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: ModernEmptyState(
        icon: LucideIcons.alertCircle,
        title: 'Something went wrong',
        description: 'Unable to load your dashboard. Please try again.',
        actionText: 'Retry',
        onAction: () => ref.invalidate(cvProfileProvider),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: ModernEmptyState(
        icon: LucideIcons.user,
        title: 'Welcome to EduCV',
        description: 'Start building your professional CV by completing your profile.',
        actionText: 'Get Started',
        onAction: () => _handleNavigation(1),
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
    // Show notifications
  }

  void _showProfileMenu() {
    // Show profile menu
  }

  void _showActivityHistory() {
    // Show full activity history
  }
}

class _QuickAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}