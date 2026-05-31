import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/modern_saas_theme.dart';
import '../../../../core/layout/modern_responsive_dashboard_layout.dart';
import '../../../../core/widgets/modern_dashboard_cards.dart';
import '../../../../core/widgets/enterprise_loading.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../pdf/presentation/providers/pdf_provider.dart';
import '../../../pdf/data/models/generated_cv_model.dart';
import '../../data/models/cv_models.dart';
import '../providers/cv_provider.dart';

class ModernCVDashboardScreen extends ConsumerStatefulWidget {
  const ModernCVDashboardScreen({super.key});

  @override
  ConsumerState<ModernCVDashboardScreen> createState() => _ModernCVDashboardScreenState();
}

class _ModernCVDashboardScreenState extends ConsumerState<ModernCVDashboardScreen>
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

    return ModernResponsiveDashboardLayout(
      title: 'Dashboard',
      currentIndex: _currentNavIndex,
      onNavigationChanged: _handleNavigation,
      userName: user?.fullName,
      userEmail: user?.email,
      onProfileTap: _showProfileMenu,
      onUpgradeTap: _handleUpgrade,
      actions: [
        _buildNotificationButton(),
        const SizedBox(width: ModernSaaSDashboardTheme.spacingMd),
        _buildProfileButton(user),
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
    );
  }

  Widget _buildNotificationButton() {
    return IconButton(
      onPressed: _showNotifications,
      icon: Stack(
        children: [
          const Icon(
            LucideIcons.bell,
            color: ModernSaaSDashboardTheme.tertiaryText,
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: ModernSaaSDashboardTheme.error,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
      style: IconButton.styleFrom(
        backgroundColor: ModernSaaSDashboardTheme.hover,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildProfileButton(user) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            ModernSaaSDashboardTheme.accentPurple,
            ModernSaaSDashboardTheme.accentPurpleLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: ModernSaaSDashboardTheme.accentPurple.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showProfileMenu,
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: Text(
              _getInitials(user?.fullName ?? 'User'),
              style: ModernSaaSDashboardTheme.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(CVProfileModel profile) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
    
    return ModernDashboardContent(
      children: [
        ModernWelcomeCard(
          greeting: greeting,
          date: DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
          completionPercentage: profile.completionPercentage,
        ),
        _buildQuickActionsCard(),
        ..._buildStatsCards(profile),
        _buildRecentDownloadsSection(),
        _buildAIInsightsCard(profile),
      ],
    );
  }

  Widget _buildQuickActionsCard() {
    return ModernSectionCard(
      title: 'Quick Actions',
      subtitle: 'Common tasks to improve your CV',
      child: Padding(
        padding: const EdgeInsets.all(ModernSaaSDashboardTheme.spacingXl),
        child: Column(
          children: [
            _buildQuickActionItem(
              icon: LucideIcons.fileText,
              title: 'Generate CV',
              subtitle: 'Create professional PDFs',
              color: ModernSaaSDashboardTheme.accentPurple,
              onTap: () => _handleNavigation(5), // Downloads
            ),
            const SizedBox(height: ModernSaaSDashboardTheme.spacingMd),
            _buildQuickActionItem(
              icon: LucideIcons.bot,
              title: 'AI Assistant',
              subtitle: 'Get personalized suggestions',
              color: ModernSaaSDashboardTheme.success,
              onTap: () => _handleNavigation(6), // AI Assistant
            ),
            const SizedBox(height: ModernSaaSDashboardTheme.spacingMd),
            _buildQuickActionItem(
              icon: LucideIcons.layout,
              title: 'Browse Templates',
              subtitle: 'Explore new CV designs',
              color: ModernSaaSDashboardTheme.info,
              onTap: () => _handleNavigation(7), // Templates
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem({
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
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: ModernSaaSDashboardTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: ModernSaaSDashboardTheme.bodyLarge.copyWith(
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
                color: ModernSaaSDashboardTheme.tertiaryText,
                size: 16,
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
        title: 'Profile Completion',
        value: '${profile.completionPercentage}%',
        icon: LucideIcons.user,
        color: ModernSaaSDashboardTheme.accentPurple,
        subtitle: '${_getFilledSectionCount(profile)}/7 sections',
        onTap: () => _handleNavigation(1), // My CV
      ),
      ModernStatCard(
        title: 'Work Experience',
        value: '${profile.experiences.length}',
        icon: LucideIcons.briefcase,
        color: ModernSaaSDashboardTheme.info,
        subtitle: 'Positions added',
        onTap: () => _handleNavigation(2), // Experience
      ),
      ModernStatCard(
        title: 'Skills',
        value: '${profile.skills.length}',
        icon: LucideIcons.zap,
        color: ModernSaaSDashboardTheme.success,
        subtitle: 'Skills listed',
        onTap: () => _handleNavigation(3), // Skills
      ),
      ModernStatCard(
        title: 'Projects',
        value: '${profile.projects.length}',
        icon: LucideIcons.folder,
        color: ModernSaaSDashboardTheme.warning,
        subtitle: 'Projects showcased',
        onTap: () => _handleNavigation(4), // Projects
      ),
    ];
  }

  Widget _buildRecentDownloadsSection() {
    return ModernSectionCard(
      title: 'Recent Downloads',
      subtitle: 'Your latest generated CVs',
      onViewAll: () => _handleNavigation(5), // Downloads
      child: Consumer(
        builder: (context, ref, child) {
          final historyAsync = ref.watch(pdfHistoryProvider);
          
          return historyAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(ModernSaaSDashboardTheme.spacing3xl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => _buildEmptyDownloadsState(),
            data: (history) {
              if (history.isEmpty) {
                return _buildEmptyDownloadsState();
              }
              
              final recentDownloads = history.take(3).toList();
              return Column(
                children: recentDownloads.map((cv) => _buildDownloadRow(cv)).toList(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDownloadRow(GeneratedCVModel cv) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ModernSaaSDashboardTheme.spacingXl,
        vertical: ModernSaaSDashboardTheme.spacingMd,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ModernSaaSDashboardTheme.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ModernSaaSDashboardTheme.accentPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              LucideIcons.fileText,
              size: 20,
              color: ModernSaaSDashboardTheme.accentPurple,
            ),
          ),
          const SizedBox(width: ModernSaaSDashboardTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${cv.templateDisplay} CV',
                  style: ModernSaaSDashboardTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Generated ${TimeUtils.timeAgo(cv.generatedAt)}',
                  style: ModernSaaSDashboardTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ModernSaaSDashboardTheme.spacingSm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: ModernSaaSDashboardTheme.successLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Ready',
              style: ModernSaaSDashboardTheme.labelSmall.copyWith(
                color: ModernSaaSDashboardTheme.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: ModernSaaSDashboardTheme.spacingMd),
          IconButton(
            onPressed: () => _downloadCV(cv),
            icon: const Icon(LucideIcons.download, size: 16),
            style: IconButton.styleFrom(
              backgroundColor: ModernSaaSDashboardTheme.accentPurple.withOpacity(0.1),
              foregroundColor: ModernSaaSDashboardTheme.accentPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDownloadsState() {
    return ModernEmptyState(
      icon: LucideIcons.download,
      title: 'No CVs generated yet',
      description: 'Generate your first professional CV to see it here',
      actionText: 'Generate CV',
      onAction: () => _handleNavigation(5), // Downloads
    );
  }

  Widget _buildAIInsightsCard(CVProfileModel profile) {
    return ModernSectionCard(
      title: 'AI Insights',
      subtitle: 'Personalized recommendations for your CV',
      child: Padding(
        padding: const EdgeInsets.all(ModernSaaSDashboardTheme.spacingXl),
        child: Column(
          children: [
            _buildInsightItem(
              icon: LucideIcons.trendingUp,
              title: 'Add more skills',
              description: 'Your profile would benefit from 3-5 more technical skills',
              color: ModernSaaSDashboardTheme.info,
            ),
            const SizedBox(height: ModernSaaSDashboardTheme.spacingMd),
            _buildInsightItem(
              icon: LucideIcons.award,
              title: 'Include certifications',
              description: 'Adding certifications can increase your profile strength by 25%',
              color: ModernSaaSDashboardTheme.warning,
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
  }) {
    return Row(
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
    );
  }

  Widget _buildLoadingSkeleton() {
    return ModernDashboardContent(
      children: List.generate(6, (index) {
        return Container(
          height: index == 0 ? 120 : 140,
          decoration: ModernComponentStyles.card,
        );
      }),
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

  void _handleNavigation(int index) {
    setState(() {
      _currentNavIndex = index;
    });

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

  void _showNotifications() {
    // Implement notifications
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: ModernSaaSDashboardTheme.surfaceBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildProfileBottomSheet(),
    );
  }

  Widget _buildProfileBottomSheet() {
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

  void _logout() {
    Navigator.pop(context);
    context.go('/');
  }

  void _downloadCV(GeneratedCVModel cv) async {
    // Implement download logic
  }
}