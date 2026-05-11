import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/section_card.dart';
import 'section_padding.dart';
import 'section_header.dart';
import 'cv_template_info.dart';
import 'cv_previews/classic_cv_preview.dart';
import 'cv_previews/modern_cv_preview.dart';
import 'cv_previews/academic_cv_preview.dart';

class TemplatesSection extends StatefulWidget {
  const TemplatesSection({super.key});

  @override
  State<TemplatesSection> createState() => _TemplatesSectionState();
}

class _TemplatesSectionState extends State<TemplatesSection>
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
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );
    _previewController = AnimationController(
      duration: const Duration(milliseconds: 320),
      vsync: this,
    );

    _infoFadeAnim = CurvedAnimation(
      parent: _infoController,
      curve: Curves.easeOut,
    );
    _previewSlideAnim = Tween<Offset>(
      begin: const Offset(0.08, 0),
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
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFF),
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: SectionPadding(
        child: Column(
          children: [
            const SectionHeader(
              eyebrow: 'CV Templates',
              title: 'Three formats.\nEvery opportunity covered.',
              subtitle:
                  'Tap any template to explore a live sample and see which format fits your goals best.',
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildTemplateTabs(),
            const SizedBox(height: AppSpacing.xl),
            _buildMainContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateTabs() {
    return Row(
      children: CVTemplateInfo.templates.asMap().entries.map((entry) {
        final index = entry.key;
        final template = entry.value;
        return Padding(
          padding: EdgeInsets.only(right: index < 2 ? 8 : 0),
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
        )),
        const SizedBox(width: 32),
        Expanded(
          flex: 1,
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
        const SizedBox(height: 24),
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
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF1565C0) : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
          color: isSelected ? const Color(0xFFEAF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              template.icon,
              size: 16,
              color: isSelected
                  ? const Color(0xFF1565C0)
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              template.name,
              style: AppTypography.body.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF1565C0)
                    : AppColors.textSecondary,
              ),
            ),
            if (template.isPopular) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Popular',
                  style: AppTypography.caption.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
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
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.name,
                  style: AppTypography.h2.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0A0A0A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  template.description,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.65,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'BEST FOR',
                  style: AppTypography.caption.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.07,
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: template.bestFor
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF2FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              tag,
                              style: AppTypography.caption.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1565C0),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.divider, height: 1),
                const SizedBox(height: 12),
                Column(
                  children: template.features
                      .map((feature) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  LucideIcons.check,
                                  size: 16,
                                  color: Color(0xFF1565C0),
                                ),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: AppTypography.body.copyWith(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
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
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'Use this template',
              onPressed: () => context.go('/register'),
              icon: LucideIcons.fileDown,
            ),
          ),
        ],
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
        color: AppColors.surface,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(20),
      constraints: const BoxConstraints(minHeight: 460),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Text(
              'LIVE PREVIEW',
              style: AppTypography.caption.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textHint,
                letterSpacing: 0.07,
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
