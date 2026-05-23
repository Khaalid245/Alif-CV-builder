import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/premium_portfolio_colors.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/app_loader.dart';
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

class _CVDashboardScreenState extends ConsumerState<CVDashboardScreen> {
  bool _isAnnouncementDismissed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Force fetch CV profile if not already loaded
      final state = ref.read(cvProfileProvider);
      if (state is AsyncData && state.value == null) {
        ref.invalidate(cvProfileProvider);
      }
      // Always fetch PDF history
      ref.read(pdfHistoryProvider.notifier).fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final cvProfileAsync = ref.watch(cvProfileProvider);

    return Scaffold(
      backgroundColor: PremiumPortfolioColors.background,
      appBar: AppBar(
        backgroundColor: PremiumPortfolioColors.background,
        elevation: 0,
        title: Text(
          'Home',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: PremiumPortfolioColors.primaryText,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: PremiumPortfolioColors.borderLight,
          ),
        ),
        actions: [
          GestureDetector(
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
        ],
      ),
      body: cvProfileAsync.when(
        loading: () => const Center(
          child: AppLoader(message: 'Loading dashboard...'),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.alertCircle,
                size: 48,
                color: PremiumPortfolioColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load dashboard',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: PremiumPortfolioColors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(
                  fontSize: 16,
                  color: PremiumPortfolioColors.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(cvProfileProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return const Center(
              child: AppLoader(message: 'Loading profile...'),
            );
          }
          return _buildDashboard(profile);
        },
      ),
    );
  }

  Widget _buildDashboard(CVProfileModel profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Admin Announcement Banner
          if (!_isAnnouncementDismissed) _buildAnnouncementBanner(),

          // Greeting
          _buildGreeting(profile),

          const SizedBox(height: 24),

          // Completion Card
          _buildCompletionCard(profile),

          const SizedBox(height: 24),

          // Quick Actions
          _buildQuickActions(),

          const SizedBox(height: 24),

          // Recent Downloads Section
          _buildRecentDownloadsSection(),

          const SizedBox(height: 48), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildGreeting(CVProfileModel profile) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    final firstName = profile.fullName.split(' ').first;
    final dateStr = DateFormat('EEEE, d MMMM yyyy')
        .format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, $firstName',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: PremiumPortfolioColors.primaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dateStr,
          style: TextStyle(
            fontSize: 16,
            color: PremiumPortfolioColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionCard(CVProfileModel profile) {
    final pct = profile.completionPercentage;
    // determine tip based on missing sections
    String tip = '';
    String tipRoute = '/cv/form';
    int tipStep = 0;

    if (profile.summary.isEmpty) {
      tip = 'Add a professional summary — CVs with '
            'summaries get noticed faster.';
      tipStep = 0;
    } else if (profile.skills.isEmpty) {
      tip = 'Add your skills — they appear on all 3 '
            'CV templates.';
      tipStep = 3;
    } else if (profile.languages.isEmpty) {
      tip = 'Adding languages shows international '
            'awareness to employers.';
      tipStep = 4;
    } else if (pct < 100) {
      tip = 'You are $pct% done. Complete your profile '
            'for the best CV results.';
      tipStep = 0;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PremiumPortfolioColors.cardBackground,
        border: Border.all(
          color: PremiumPortfolioColors.borderLight,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: pct / 100,
                      backgroundColor: PremiumPortfolioColors.accentPurple.withValues(alpha: 0.1),
                      color: PremiumPortfolioColors.accentPurple,
                      strokeWidth: 4,
                    ),
                    Text(
                      '$pct%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: PremiumPortfolioColors.accentPurple,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CV completion',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: PremiumPortfolioColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_filledSectionCount(profile)}'
                      ' of 7 sections filled',
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
          if (pct < 100 && tip.isNotEmpty) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => context.go('/cv/form',
                  extra: {'initialStep': tipStep}),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: PremiumPortfolioColors.warning.withValues(alpha: 0.1),
                  border: Border.all(
                    color: PremiumPortfolioColors.warning,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.lightbulb,
                      size: 14,
                      color: Color(0xFFE65100),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(
                          fontSize: 12,
                          color: PremiumPortfolioColors.warning,
                          height: 1.5,
                        ),
                      ),
                    ),
                    Text(
                      'Add now',
                      style: TextStyle(
                        fontSize: 12,
                        color: PremiumPortfolioColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  int _filledSectionCount(CVProfileModel profile) {
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

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: PremiumPortfolioColors.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: LucideIcons.edit3,
                title: 'Edit CV',
                subtitle: 'Update your information',
                onTap: () => context.go('/cv/form'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                icon: LucideIcons.fileDown,
                title: 'Generate CVs',
                subtitle: 'Create 3 PDF templates',
                onTap: () => context.go('/pdf/result'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: PremiumPortfolioColors.cardBackground,
          border: Border.all(
            color: PremiumPortfolioColors.borderLight,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: PremiumPortfolioColors.accentPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: PremiumPortfolioColors.accentPurple,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: PremiumPortfolioColors.primaryText,
              ),
            ),
            const SizedBox(height: 4),
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

  Widget _buildAnnouncementBanner() {
    // Mock announcement - in real app this would come from API
    const announcement =
        "Welcome to EduCV! Generate professional CVs in 3 different templates. Complete your profile to get started.";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: PremiumPortfolioColors.accentBlue.withValues(alpha: 0.1),
        border: Border.all(color: PremiumPortfolioColors.accentBlue.withValues(alpha: 0.3), width: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            LucideIcons.megaphone,
            size: 16,
            color: Color(0xFF1565C0),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              announcement,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF1565C0),
                height: 1.5,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _isAnnouncementDismissed = true;
              });
            },
            child: Icon(
              LucideIcons.x,
              size: 16,
              color: PremiumPortfolioColors.accentBlue.withValues(alpha: 0.6),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
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
              onPressed: () {
                context.go('/cv/downloads');
              },
              child: Text(
                'View all',
                style: TextStyle(
                  fontSize: 16,
                  color: PremiumPortfolioColors.accentPurple,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Downloads Content
        Consumer(
          builder: (context, ref, child) {
            final historyAsync = ref.watch(pdfHistoryProvider);

            return historyAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (error, stack) => const SizedBox.shrink(),
              data: (history) {
                if (history.isEmpty) {
                  return _buildEmptyDownloadsState();
                }

                // Show last 3 downloads
                final recentDownloads = history.take(3).toList();
                return Column(
                  children: recentDownloads
                      .map((cv) => _buildRecentDownloadTile(cv))
                      .toList(),
                );
              },
            );
          },
        ),
      ],
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