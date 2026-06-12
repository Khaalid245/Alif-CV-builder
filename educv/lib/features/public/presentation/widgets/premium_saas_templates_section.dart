import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/widgets/premium_saas_grid_background.dart';
import 'cv_template_info.dart';
import 'cv_previews/classic_cv_preview.dart';
import 'cv_previews/modern_cv_preview.dart';
import 'cv_previews/academic_cv_preview.dart';

class PremiumSaaSTemplatesSection extends StatefulWidget {
  const PremiumSaaSTemplatesSection({super.key});

  @override
  State<PremiumSaaSTemplatesSection> createState() =>
      _PremiumSaaSTemplatesSectionState();
}

class _PremiumSaaSTemplatesSectionState
    extends State<PremiumSaaSTemplatesSection> with TickerProviderStateMixin {
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
    return PremiumSaaSGridBackground(
      opacity: 0.02,
      showRadialGradient: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 24),
        child: Center(
          child: ConstrainedBox(
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
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
            border: Border.all(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'CV TEMPLATES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4F46E5),
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Three formats.\\nEvery opportunity covered.',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          'Tap any template to explore a live sample and see which format fits your goals best.',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.7),
            height: 1.6,
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
          padding: EdgeInsets.only(right: index < 2 ? 16 : 0),
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
        final isDesktop = constraints.maxWidth >= 900;
        return isDesktop ? _buildDesktopLayout() : _buildMobileLayout();
      },
    );
  }

  Widget _buildDesktopLayout() {
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

class _TemplateTab extends StatefulWidget {
  final CVTemplateInfo template;
  final bool isSelected;
  final VoidCallback onTap;

  const _TemplateTab({
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_TemplateTab> createState() => _TemplateTabState();
}

class _TemplateTabState extends State<_TemplateTab> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? Colors.white.withValues(alpha: 0.05)
                : _isHovered
                    ? Colors.white.withValues(alpha: 0.02)
                    : Colors.transparent,
            border: Border.all(
              color: widget.isSelected
                  ? const Color(0xFF4F46E5)
                  : Colors.white.withValues(alpha: 0.1),
              width: widget.isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.template.icon,
                    size: 20,
                    color: widget.isSelected
                        ? const Color(0xFF4F46E5)
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.template.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: widget.isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  if (widget.template.isPopular) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Popular',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
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
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      template.description,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'BEST FOR',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4F46E5),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: template.bestFor
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4F46E5)
                                      .withValues(alpha: 0.1),
                                  border: Border.all(
                                    color: const Color(0xFF4F46E5)
                                        .withValues(alpha: 0.2),
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4F46E5),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Column(
                      children: template.features
                          .map((feature) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981)
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        LucideIcons.check,
                                        size: 14,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        feature,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white
                                              .withValues(alpha: 0.8),
                                          height: 1.5,
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
          const SizedBox(height: 32),
          _buildUseTemplateButton(context),
        ],
      ),
    );
  }

  Widget _buildUseTemplateButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/register'),
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.fileDown,
                  size: 20,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Use this template',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .shimmer(
          duration: 3000.ms,
          color: Colors.white.withValues(alpha: 0.1),
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
        color: Colors.white.withValues(alpha: 0.02),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      constraints: const BoxConstraints(minHeight: 600),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'LIVE PREVIEW',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4F46E5),
                      letterSpacing: 0.5,
                    ),
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
