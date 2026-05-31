import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/premium_portfolio_colors.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/widgets/cv_dashboard_skeleton.dart';
import '../../../../core/widgets/enterprise_loading.dart';
import '../../../../core/accessibility/accessibility_foundation.dart';
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

    return Scaffold(
      backgroundColor: PremiumPortfolioColors.background,
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
                  backgroundColor: PremiumPortfolioColors.accentPurple,
                  child: Text(
                    _getInitials(user?.fullName ?? ''),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(profile),
            const SizedBox(height: 24),
            _buildQuickStatsRow(profile),
            const SizedBox(height: 24),
            _buildRecentDownloadsSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
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

  Widget _buildRecentDownloadsSection() {
    return Container(
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
        children: [
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
                    children: recentDownloads.map((cv) => _buildDownloadRow(cv)).toList(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadRow(GeneratedCVModel cv) {
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

  Future<void> _logout() async {
    final secureStorage = ref.read(secureStorageProvider);
    await secureStorage.clearAll();
    ref.read(currentUserProvider.notifier).state = null;
    if (mounted) {
      context.go('/');
    }
  }

  void _showProfileBottomSheet(BuildContext context, String name, String email) {
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
            Container(
              height: 1,
              color: PremiumPortfolioColors.borderLight,
            ),
            const SizedBox(height: 8),
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