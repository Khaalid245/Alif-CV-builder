import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/premium_dark_colors.dart';
import '../../../../core/theme/premium_dark_typography.dart';
import 'cv_template_info.dart';
import 'cv_previews/classic_cv_preview.dart';
import 'cv_previews/modern_cv_preview.dart';
import 'cv_previews/academic_cv_preview.dart';

class PremiumDarkTemplatesSection extends StatefulWidget {
  const PremiumDarkTemplatesSection({super.key});

  @override
  State<PremiumDarkTemplatesSection> createState() => _PremiumDarkTemplatesSectionState();
}

class _PremiumDarkTemplatesSectionState extends State<PremiumDarkTemplatesSection>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _infoController;
  late AnimationController _previewController;
  late Animation<double> _infoFadeAnim;
  late Animation<Offset> _previewSlideAnim;
  late Animation<double> _previewFadeAnim;

  @override
  void initState() {
    super.initState();

    _infoController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _previewController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _infoFadeAnim = CurvedAnimation(
      parent: _infoController,
      curve: Curves.easeOut,
    );
    _previewSlideAnim = Tween<Offset>(
      begin: const Offset(0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _previewController,
      curve: Curves.easeOutCubic,
    ));
    _previewFadeAnim = CurvedAnimation(
      parent: _previewController,
      curve: Curves.easeOut,
    );

    _infoController.forward();
    _previewController.forward();
  }

  void _selectTemplate(int index) {
    if (index == _selectedIndex) return;

    _infoController.reset();
    _previewController.reset();

    setState(() => _selectedIndex = index);

    _infoController.forward();
    _previewController.forward();
  }

  @override
  void dispose() {
    _infoController.dispose();
    _previewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
      decoration: const BoxDecoration(
        color: PremiumDarkColors.background,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            _buildSectionHeader()
                .animate()
                .fadeIn(duration: 800.ms)
                .slideY(begin: 0.3, end: 0),
            const SizedBox(height: 60),
            _buildTemplateTabs()
                .animate(delay: 200.ms)
                .fadeIn(duration: 800.ms)
                .slideY(begin: 0.3, end: 0),
            const SizedBox(height: 60),
            _buildMainContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Column(
      children: [
        Text(
          'CV TEMPLATES',
          style: PremiumDarkTypography.eyebrow.copyWith(
            color: PremiumDarkColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Three formats.\nEvery opportunity covered.',
          style: PremiumDarkTypography.sectionTitle.copyWith(
            color: PremiumDarkColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          'Tap any template to explore a live sample and see which format fits your goals best.',
          style: PremiumDarkTypography.bodyLarge.copyWith(
            color: PremiumDarkColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTemplateTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: CVTemplateInfo.templates.asMap().entries.map((entry) {
        final index = entry.key;
        final template = entry.value;
        return Padding(
          padding: EdgeInsets.only(right: index < 2 ? 12 : 0),
          child: _TemplateTab(
            template: template,
            isSelected: index == _selectedIndex,
            onTap: () => _selectTemplate(index),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMainContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = constraints.maxWidth >= 800;
        return isWeb ? _buildWebLayout() : _buildMobileLayout();
      },
    );
  }

  Widget _buildWebLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _InfoPanel(
            template: CVTemplateInfo.templates[_selectedIndex],
            animation: _infoFadeAnim,
          ),
        ),
        const SizedBox(width: 60),
        Expanded(
          child: _PreviewPanel(
            selectedIndex: _selectedIndex,
            slideAnimation: _previewSlideAnim,
            fadeAnimation: _previewFadeAnim,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _InfoPanel(
          template: CVTemplateInfo.templates[_selectedIndex],
          animation: _infoFadeAnim,
        ),
        const SizedBox(height: 40),
        _PreviewPanel(
          selectedIndex: _selectedIndex,
          slideAnimation: _previewSlideAnim,
          fadeAnimation: _previewFadeAnim,
        ),
      ],
    );
  }
}

class _TemplateTab extends StatelessWidget {
  final CVTemplateInfo template;
  final bool isSelected;
  final VoidCallback onTap;

  const _TemplateTab({
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? PremiumDarkColors.glassBackground 
              : Colors.transparent,
          border: Border.all(
            color: isSelected 
                ? PremiumDarkColors.primary 
                : PremiumDarkColors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [
            BoxShadow(
              color: PremiumDarkColors.glow,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  template.icon,
                  size: 18,
                  color: isSelected
                      ? PremiumDarkColors.primary
                      : PremiumDarkColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Text(
                  template.name,
                  style: PremiumDarkTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? PremiumDarkColors.textPrimary
                        : PremiumDarkColors.textSecondary,
                  ),
                ),
                if (template.isPopular) ...[ 
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          PremiumDarkColors.gradientStart,
                          PremiumDarkColors.gradientEnd,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Popular',
                      style: PremiumDarkTypography.captionBold.copyWith(
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final CVTemplateInfo template;
  final Animation<double> animation;

  const _InfoPanel({
    required this.template,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: PremiumDarkColors.glassBackground,
              border: Border.all(color: PremiumDarkColors.glassBorder),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: PremiumDarkTypography.cardTitle.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: PremiumDarkColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      template.description,
                      style: PremiumDarkTypography.body.copyWith(
                        color: PremiumDarkColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'BEST FOR',
                      style: PremiumDarkTypography.eyebrow.copyWith(
                        fontSize: 10,
                        color: PremiumDarkColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: template.bestFor
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: PremiumDarkColors.primary.withValues(alpha: 0.1),
                                  border: Border.all(
                                    color: PremiumDarkColors.primary.withValues(alpha: 0.2),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tag,
                                  style: PremiumDarkTypography.captionBold.copyWith(
                                    color: PremiumDarkColors.primary,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            PremiumDarkColors.glassBorder,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: template.features
                          .map((feature) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: PremiumDarkColors.accent.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        LucideIcons.check,
                                        size: 12,
                                        color: PremiumDarkColors.accent,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        feature,
                                        style: PremiumDarkTypography.bodyMedium.copyWith(
                                          color: PremiumDarkColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildUseTemplateButton(context),
        ],
      ),
    );
  }

  Widget _buildUseTemplateButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            PremiumDarkColors.gradientStart,
            PremiumDarkColors.gradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: PremiumDarkColors.glow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/register'),
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.fileDown,
                  size: 20,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  'Use this template',
                  style: PremiumDarkTypography.buttonPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  final int selectedIndex;
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;

  const _PreviewPanel({
    required this.selectedIndex,
    required this.slideAnimation,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PremiumDarkColors.glassBackground,
        border: Border.all(color: PremiumDarkColors.glassBorder),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(minHeight: 500),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: Text(
                  'LIVE PREVIEW',
                  style: PremiumDarkTypography.eyebrow.copyWith(
                    fontSize: 10,
                    color: PremiumDarkColors.primary,
                  ),
                ),
              ),
              Center(
                child: SlideTransition(
                  position: slideAnimation,
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: _buildPreviewWidget(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewWidget() {
    switch (selectedIndex) {
      case 0:
        return const ClassicCVPreview();
      case 1:
        return const ModernCVPreview();
      case 2:
        return const AcademicCVPreview();
      default:
        return const ClassicCVPreview();
    }
  }
}