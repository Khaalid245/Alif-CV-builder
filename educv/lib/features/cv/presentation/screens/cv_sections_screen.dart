import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../providers/cv_provider.dart';

class CVSectionsScreen extends ConsumerStatefulWidget {
  const CVSectionsScreen({super.key});

  @override
  ConsumerState<CVSectionsScreen> createState() => _CVSectionsScreenState();
}

class _CVSectionsScreenState extends ConsumerState<CVSectionsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch CV data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cvProfileProvider.notifier).fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cvAsync = ref.watch(cvProfileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My CV',
          style: AppTypography.h2.copyWith(color: const Color(0xFF0A0A0A)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.divider,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: cvAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Text('Error loading CV data: $error'),
          ),
          data: (cvProfile) {
            if (cvProfile == null) {
              return const Center(
                child: Text('No CV data found'),
              );
            }

            final completedSections = _getCompletedSectionsCount(cvProfile);
            final completionPercentage = cvProfile.completionPercentage;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall Progress
                _buildProgressSection(completionPercentage, completedSections),

                const SizedBox(height: 20),

                // Section List
                _buildSectionsList(cvProfile),

                const SizedBox(height: 24),

                // Generate Button
                AppButton.primary(
                  label: 'Generate my 3 CVs',
                  icon: LucideIcons.fileDown,
                  onPressed: () => context.go('/pdf/result'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressSection(
      int completionPercentage, int completedSections) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Profile strength',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0A0A0A),
              ),
            ),
            const Spacer(),
            Text(
              '$completionPercentage%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1565C0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: completionPercentage / 100,
            color: const Color(0xFF1565C0),
            backgroundColor: const Color(0xFFEAF2FF),
            minHeight: 5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$completedSections of 7 sections complete',
          style: AppTypography.caption.copyWith(
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionsList(dynamic cvProfile) {
    final sections = _getSections(cvProfile);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.divider,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          for (int i = 0; i < sections.length; i++) ...[
            _buildSectionTile(sections[i]),
            if (i < sections.length - 1) const Divider(height: 1, indent: 54),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTile(CVSectionData section) {
    return InkWell(
      onTap: () =>
          context.go('/cv/form', extra: {'initialStep': section.stepIndex}),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Icon Box
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: section.hasData
                    ? const Color(0xFFEAF2FF)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                section.icon,
                size: 16,
                color: section.hasData
                    ? const Color(0xFF1565C0)
                    : const Color(0xFF9E9E9E),
              ),
            ),

            const SizedBox(width: 12),

            // Section Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                  Text(
                    section.hasData ? section.countLabel : 'Not added yet',
                    style: TextStyle(
                      fontSize: 11,
                      color: section.hasData
                          ? const Color(0xFF6B7280)
                          : const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),

            // Status Indicator
            if (section.hasData)
              const Icon(
                LucideIcons.checkCircle,
                size: 16,
                color: AppColors.success,
              )
            else
              const Text(
                'Add',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1565C0),
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _getCompletedSectionsCount(dynamic cvProfile) {
    final sections = _getSections(cvProfile);
    return sections.where((section) => section.hasData).length;
  }

  List<CVSectionData> _getSections(dynamic cvProfile) {
    return [
      CVSectionData(
        name: 'Personal Info',
        icon: LucideIcons.user,
        stepIndex: 0,
        hasData: (cvProfile.phone?.isNotEmpty == true) ||
            (cvProfile.summary?.isNotEmpty == true),
        countLabel: _getPersonalInfoLabel(cvProfile),
      ),
      CVSectionData(
        name: 'Education',
        icon: LucideIcons.graduationCap,
        stepIndex: 1,
        hasData: cvProfile.educations?.isNotEmpty == true,
        countLabel: '${cvProfile.educations?.length ?? 0} entries',
      ),
      CVSectionData(
        name: 'Experience',
        icon: LucideIcons.briefcase,
        stepIndex: 2,
        hasData: cvProfile.experiences?.isNotEmpty == true,
        countLabel: '${cvProfile.experiences?.length ?? 0} entries',
      ),
      CVSectionData(
        name: 'Skills',
        icon: LucideIcons.zap,
        stepIndex: 3,
        hasData: cvProfile.skills?.isNotEmpty == true,
        countLabel: '${cvProfile.skills?.length ?? 0} skills',
      ),
      CVSectionData(
        name: 'Languages',
        icon: LucideIcons.globe,
        stepIndex: 4,
        hasData: cvProfile.languages?.isNotEmpty == true,
        countLabel: '${cvProfile.languages?.length ?? 0} languages',
      ),
      CVSectionData(
        name: 'Projects',
        icon: LucideIcons.code2,
        stepIndex: 5,
        hasData: cvProfile.projects?.isNotEmpty == true,
        countLabel: '${cvProfile.projects?.length ?? 0} projects',
      ),
      CVSectionData(
        name: 'Certifications',
        icon: LucideIcons.award,
        stepIndex: 6,
        hasData: cvProfile.certifications?.isNotEmpty == true,
        countLabel: '${cvProfile.certifications?.length ?? 0} certs',
      ),
    ];
  }

  String _getPersonalInfoLabel(dynamic cvProfile) {
    final hasPhone = cvProfile.phone?.isNotEmpty == true;
    final hasSummary = cvProfile.summary?.isNotEmpty == true;

    if (hasPhone && hasSummary) {
      return 'Profile filled';
    } else if (hasPhone || hasSummary) {
      return 'Partially filled';
    } else {
      return 'Not added yet';
    }
  }
}

class CVSectionData {
  final String name;
  final IconData icon;
  final int stepIndex;
  final bool hasData;
  final String countLabel;

  CVSectionData({
    required this.name,
    required this.icon,
    required this.stepIndex,
    required this.hasData,
    required this.countLabel,
  });
}
