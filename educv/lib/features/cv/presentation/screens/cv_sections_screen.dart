import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/premium_portfolio_colors.dart';
import '../../../../core/widgets/enterprise_loading.dart';
import '../../../../core/widgets/enterprise_components.dart';
import '../../../../core/accessibility/accessibility_foundation.dart';
import '../../../../core/accessibility/accessible_navigation.dart';
import '../../../../core/performance/performance_foundation.dart';
import '../../../../core/performance/optimized_components.dart';
import '../providers/cv_provider.dart';
import '../../data/models/cv_models.dart';

class CVSectionsScreen extends ConsumerStatefulWidget {
  const CVSectionsScreen({super.key});

  @override
  ConsumerState<CVSectionsScreen> createState() => _CVSectionsScreenState();
}

class _CVSectionsScreenState extends ConsumerState<CVSectionsScreen>
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
    
    // Fetch CV data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cvProfileProvider.notifier).fetch();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cvAsync = ref.watch(cvProfileProvider);

    return Scaffold(
      backgroundColor: PremiumPortfolioColors.background,
      appBar: AccessibleAppBar(
        title: 'My CV',
        onBackPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            context.go('/cv/dashboard');
          }
        },
      ),
      body: Stack(
        children: [
          // Grid background
          _buildGridBackground(),
          // Main content with enterprise loading
          EnterpriseLoadingManager(
            state: cvAsync.when(
              loading: () => LoadingState.loading,
              error: (_, __) => LoadingState.error,
              data: (profile) => profile == null ? LoadingState.empty : LoadingState.loaded,
            ),
            loadingWidget: const CVSectionsSkeleton(),
            errorMessage: cvAsync.hasError ? cvAsync.error.toString() : null,
            emptyMessage: 'No CV data found',
            onRetry: () => ref.read(cvProfileProvider.notifier).fetch(),
            child: cvAsync.hasValue && cvAsync.value != null
                ? FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildCVContent(cvAsync.value!),
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
        painter: CVGridPainter(),
      ),
    );
  }

  Widget _buildCVContent(CVProfileModel cvProfile) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100), // Bottom padding for nav bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simple Header
            SizedBox(
              width: double.infinity,
              child: _buildSimpleHeader(cvProfile),
            ),
            
            const SizedBox(height: 16),
            
            // Clean Sections List
            SizedBox(
              width: double.infinity,
              child: _buildCleanSectionsList(cvProfile),
            ),
            
            const SizedBox(height: 20),
            
            // Simple Generate Button
            SizedBox(
              width: double.infinity,
              child: _buildSimpleGenerateButton(),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleHeader(CVProfileModel cvProfile) {
    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.all(16), // Reduced padding
        decoration: BoxDecoration(
          color: PremiumPortfolioColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PremiumPortfolioColors.borderLight),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Build Your CV',
                      style: TextStyle(
                        fontSize: 20, // Further reduced font size
                        fontWeight: FontWeight.w700,
                        color: PremiumPortfolioColors.primaryText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Complete the sections below to create your professional CV',
                    style: TextStyle(
                      fontSize: 12, // Further reduced font size
                      color: PremiumPortfolioColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            // Simple Progress Indicator
            Semantics(
              label: AccessibilityLabels.cvProgress,
              value: '${cvProfile.completionPercentage} percent complete',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // Further reduced padding
                decoration: BoxDecoration(
                  color: cvProfile.completionPercentage >= 80
                      ? PremiumPortfolioColors.success.withValues(alpha: 0.1)
                      : PremiumPortfolioColors.accentPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12), // Further reduced radius
                  border: Border.all(
                    color: cvProfile.completionPercentage >= 80
                        ? PremiumPortfolioColors.success
                        : PremiumPortfolioColors.accentPurple,
                  ),
                ),
                child: Text(
                  '${cvProfile.completionPercentage}% Complete',
                  style: TextStyle(
                    fontSize: 10, // Further reduced font size
                    fontWeight: FontWeight.w600,
                    color: cvProfile.completionPercentage >= 80
                        ? PremiumPortfolioColors.success
                        : PremiumPortfolioColors.accentPurple,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanSectionsList(CVProfileModel cvProfile) {
    final sections = _getSections(cvProfile);
    
    return OptimizedEnterpriseCard(
      child: Column(
        children: [
          // Header
          OptimizedSectionHeader(
            title: 'CV Sections',
            subtitle: '${_getCompletedSectionsCount(cvProfile)} of ${sections.length} completed',
          ),
          
          // Sections List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final section = sections[index];
              return PerformantAnimatedWidget(
                fadeIn: true,
                slideIn: true,
                duration: Duration(milliseconds: 300 + (index * 100)),
                child: OptimizedListItem(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: section.hasData
                          ? PremiumPortfolioColors.success.withValues(alpha: 0.1)
                          : PremiumPortfolioColors.accentPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      section.icon,
                      size: 20,
                      color: section.hasData
                          ? PremiumPortfolioColors.success
                          : PremiumPortfolioColors.accentPurple,
                    ),
                  ),
                  title: section.name,
                  subtitle: section.hasData ? section.countLabel : 'Not added yet',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (section.hasData)
                        EnterpriseStatusBadge.success('Complete')
                      else
                        EnterpriseStatusBadge.info('Add'),
                      const SizedBox(width: 8),
                      Icon(
                        LucideIcons.chevronRight,
                        size: 16,
                        color: PremiumPortfolioColors.secondaryText,
                      ),
                    ],
                  ),
                  onTap: () => context.go('/cv/form', extra: {'initialStep': section.stepIndex}),
                  showDivider: index < sections.length - 1,
                ),
              );
            },
          ),
        ],
      ),
    );
  }



  Widget _buildSimpleGenerateButton() {
    return ResponsiveBuilder(
      builder: (context, constraints) {
        return MicroInteractionButton(
          onPressed: () => context.go('/pdf/result'),
          child: Container(
            width: double.infinity,
            height: constraints.isMobile ? 48 : 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PremiumPortfolioColors.accentPurple,
                  PremiumPortfolioColors.accentBlue,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.download,
                    size: constraints.isMobile ? 18 : 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Generate My CVs',
                    style: TextStyle(
                      fontSize: constraints.isMobile ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _buildSectionSemanticLabel(CVSectionData section) {
    final status = section.hasData 
        ? AccessibilityLabels.cvSectionComplete 
        : AccessibilityLabels.cvSectionIncomplete;
    return '${section.name} section, $status, ${section.countLabel}';
  }



  int _getCompletedSectionsCount(CVProfileModel cvProfile) {
    final sections = _getSections(cvProfile);
    return sections.where((section) => section.hasData).length;
  }

  List<CVSectionData> _getSections(CVProfileModel cvProfile) {
    return [
      CVSectionData(
        name: 'Personal Info',
        icon: LucideIcons.user,
        stepIndex: 0,
        hasData: (cvProfile.phone.isNotEmpty) || (cvProfile.summary.isNotEmpty),
        countLabel: _getPersonalInfoLabel(cvProfile),
      ),
      CVSectionData(
        name: 'Education',
        icon: LucideIcons.graduationCap,
        stepIndex: 1,
        hasData: cvProfile.education.isNotEmpty,
        countLabel: '${cvProfile.education.length} ${cvProfile.education.length == 1 ? 'entry' : 'entries'}',
      ),
      CVSectionData(
        name: 'Experience',
        icon: LucideIcons.briefcase,
        stepIndex: 2,
        hasData: cvProfile.experiences.isNotEmpty,
        countLabel: '${cvProfile.experiences.length} ${cvProfile.experiences.length == 1 ? 'position' : 'positions'}',
      ),
      CVSectionData(
        name: 'Skills',
        icon: LucideIcons.zap,
        stepIndex: 3,
        hasData: cvProfile.skills.isNotEmpty,
        countLabel: '${cvProfile.skills.length} ${cvProfile.skills.length == 1 ? 'skill' : 'skills'}',
      ),
      CVSectionData(
        name: 'Languages',
        icon: LucideIcons.globe,
        stepIndex: 4,
        hasData: cvProfile.languages.isNotEmpty,
        countLabel: '${cvProfile.languages.length} ${cvProfile.languages.length == 1 ? 'language' : 'languages'}',
      ),
      CVSectionData(
        name: 'Projects',
        icon: LucideIcons.code2,
        stepIndex: 5,
        hasData: cvProfile.projects.isNotEmpty,
        countLabel: '${cvProfile.projects.length} ${cvProfile.projects.length == 1 ? 'project' : 'projects'}',
      ),
      CVSectionData(
        name: 'Certifications',
        icon: LucideIcons.award,
        stepIndex: 6,
        hasData: cvProfile.certifications.isNotEmpty,
        countLabel: '${cvProfile.certifications.length} ${cvProfile.certifications.length == 1 ? 'certificate' : 'certificates'}',
      ),
    ];
  }

  String _getPersonalInfoLabel(CVProfileModel cvProfile) {
    final hasPhone = cvProfile.phone.isNotEmpty;
    final hasSummary = cvProfile.summary.isNotEmpty;

    if (hasPhone && hasSummary) {
      return 'Profile completed';
    } else if (hasPhone || hasSummary) {
      return 'Partially completed';
    } else {
      return 'Not started';
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

class CVGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PremiumPortfolioColors.gridOverlay
      ..strokeWidth = 0.5;

    const gridSize = 60.0;

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
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