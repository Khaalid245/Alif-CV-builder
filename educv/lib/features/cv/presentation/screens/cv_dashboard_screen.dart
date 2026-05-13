import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Home',
          style: AppTypography.h2.copyWith(color: const Color(0xFF0A0A0A)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.divider,
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
                backgroundColor: const Color(0xFF1565C0),
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
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load dashboard',
                style: AppTypography.h3,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
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
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Admin Announcement Banner
          if (!_isAnnouncementDismissed) _buildAnnouncementBanner(),

          // Greeting
          _buildGreeting(profile),

          const SizedBox(height: AppSpacing.lg),

          // Completion Card
          _buildCompletionCard(profile),

          const SizedBox(height: AppSpacing.lg),

          // Quick Actions
          _buildQuickActions(),

          const SizedBox(height: AppSpacing.lg),

          // Recent Downloads Section
          _buildRecentDownloadsSection(),

          const SizedBox(height: AppSpacing.xxl), // Bottom padding
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
          style: AppTypography.h1,
        ),
        const SizedBox(height: 4),
        Text(
          dateStr,
          style: AppTypography.body.copyWith(
            color: AppColors.textSecondary,
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(
          color: AppColors.divider,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
                      backgroundColor: const Color(0xFFEAF2FF),
                      color: AppColors.primary,
                      strokeWidth: 4,
                    ),
                    Text(
                      '$pct%',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CV completion',
                      style: AppTypography.h3,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_filledSectionCount(profile)}'
                      ' of 7 sections filled',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (pct < 100 && tip.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () => context.go('/cv/form',
                  extra: {'initialStep': tipStep}),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  border: Border.all(
                    color: const Color(0xFFFFCC02),
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
                        style: AppTypography.caption.copyWith(
                          color: const Color(0xFFE65100),
                          height: 1.5,
                        ),
                      ),
                    ),
                    Text(
                      'Add now',
                      style: AppTypography.caption.copyWith(
                        color: const Color(0xFFE65100),
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
          style: AppTypography.h3.copyWith(color: const Color(0xFF0A0A0A)),
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
          color: AppColors.background,
          border: Border.all(
            color: AppColors.divider,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
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
        color: const Color(0xFFEAF2FF),
        border: Border.all(color: const Color(0xFFBBDEFB), width: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
            child: const Icon(
              LucideIcons.x,
              size: 16,
              color: Color(0xFF90CAF9),
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
              style: AppTypography.h3.copyWith(color: const Color(0xFF0A0A0A)),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                context.go('/cv/downloads');
              },
              child: Text(
                'View all',
                style: AppTypography.body.copyWith(
                  color: AppColors.primary,
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
                  style: AppTypography.h3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Divider
            Container(
              height: 1,
              color: AppColors.divider,
            ),

            const SizedBox(height: 8),

            // Sign out
            ListTile(
              leading: const Icon(
                LucideIcons.logOut,
                color: AppColors.error,
              ),
              title: Text(
                'Sign out',
                style: AppTypography.body.copyWith(
                  color: AppColors.error,
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
          color: AppColors.divider,
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
              style: AppTypography.body.copyWith(
                color: AppColors.primary,
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
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF0A0A0A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  TimeUtils.timeAgo(cv.generatedAt),
                  style: AppTypography.caption.copyWith(
                    color: const Color(0xFF6B7280),
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
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                LucideIcons.download,
                size: 14,
                color: Color(0xFF1565C0),
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
          color: AppColors.divider,
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
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 1),
          Container(
            height: 2,
            width: double.infinity * 0.8,
            color: AppColors.divider,
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
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download CV: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}