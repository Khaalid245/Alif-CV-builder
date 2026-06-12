import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../cv/presentation/providers/cv_provider.dart';
import '../../../data/models/template_model.dart';
import '../providers/template_engine_provider.dart';
import '../providers/template_engine_repository_provider.dart';

class TemplateCatalogScreen extends ConsumerStatefulWidget {
  const TemplateCatalogScreen({super.key});

  @override
  ConsumerState<TemplateCatalogScreen> createState() =>
      _TemplateCatalogScreenState();
}

class _TemplateCatalogScreenState extends ConsumerState<TemplateCatalogScreen> {
  // Tracks whether we already seeded the role filter from the user's profile.
  // We do it once so manual filter changes by the user are not overridden.
  bool _roleAutoApplied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(templateEngineProvider).initialize();
    });
  }

  // ── Role auto-filter ──────────────────────────────────────────────────────
  // Called once from build() when the CV profile has loaded and we haven't
  // applied the role filter yet. Uses addPostFrameCallback so we never mutate
  // state during a build pass.
  void _maybeApplyRoleFilter(String? roleSlug) {
    if (_roleAutoApplied || roleSlug == null) return;
    _roleAutoApplied = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(templateEngineProvider).setRole(roleSlug);
    });
  }

  @override
  Widget build(BuildContext context) {
    final templateState = ref.watch(templateEngineProvider);

    // Watch the user's CV profile to extract their target role
    final profileAsync = ref.watch(cvProfileProvider);
    final targetRole = profileAsync.whenOrNull(data: (p) => p?.targetRole);
    final roleSlug = targetRole?['slug'] as String?;
    final roleName = targetRole?['name'] as String?;

    // Auto-seed the role filter once (non-destructive — user can still clear it)
    _maybeApplyRoleFilter(roleSlug);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Template Catalog',
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(roleName),
            const SizedBox(height: AppSpacing.xxl),

            // ── Recommended for your role banner ───────────────────────────
            if (roleName != null && templateState.selectedRole != null)
              _buildRoleBanner(roleName, templateState, context),

            // ── Active filters row ─────────────────────────────────────────
            if (templateState.hasActiveFilters) ...[
              _buildActiveFilterRow(templateState, roleName),
              const SizedBox(height: AppSpacing.lg),
            ],

            // ── Templates grid ─────────────────────────────────────────────
            if (templateState.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xxl),
                  child: AppLoader(),
                ),
              )
            else if (templateState.error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Text(
                    templateState.error!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              )
            else if (templateState.templates.isEmpty)
              _buildEmptyState(templateState, roleName)
            else
              _buildTemplatesGrid(
                  templateState.templates, templateState, context),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(String? roleName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.sparkles,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'Enterprise Templates',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          roleName != null
              ? 'Templates for $roleName'
              : 'Choose your professional look',
          style: AppTypography.h1
              .copyWith(fontSize: 32, color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          roleName != null
              ? 'Showing templates optimised for $roleName roles. '
                  'Tap "Show all" to browse every template.'
              : 'Select from our meticulously designed CV templates. '
                  'Optimized for Applicant Tracking Systems (ATS).',
          style:
              AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // ── Role recommendation banner ─────────────────────────────────────────────

  Widget _buildRoleBanner(
    String roleName,
    dynamic templateState,
    BuildContext context,
  ) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.08),
                AppColors.primary.withOpacity(0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.target,
                    size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Role-matched templates',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Filtered for $roleName — these layouts are preferred by '
                      '$roleName recruiters.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () =>
                    ref.read(templateEngineProvider).clearFilters(),
                child: Text(
                  'Show all',
                  style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  // ── Active filter chips row ────────────────────────────────────────────────

  Widget _buildActiveFilterRow(dynamic templateState, String? roleName) {
    return Row(
      children: [
        const Icon(LucideIcons.filter,
            size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text('Filters: ',
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textSecondary)),
        if (templateState.selectedRole != null)
          _filterChip(
            roleName ?? templateState.selectedRole,
            onRemove: () => ref.read(templateEngineProvider).setRole(null),
          ),
        const Spacer(),
        TextButton(
          onPressed: () => ref.read(templateEngineProvider).clearFilters(),
          child: Text('Clear all',
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
        ),
      ],
    );
  }

  Widget _filterChip(String label, {required VoidCallback onRemove}) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: AppTypography.caption.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child:
                const Icon(LucideIcons.x, size: 12, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  // ── Empty state (when role filter returns no templates) ────────────────────

  Widget _buildEmptyState(dynamic templateState, String? roleName) {
    final hasRoleFilter = templateState.selectedRole != null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          children: [
            const Icon(LucideIcons.layoutTemplate,
                size: 48, color: AppColors.divider),
            const SizedBox(height: AppSpacing.md),
            Text(
              hasRoleFilter
                  ? 'No templates found for ${roleName ?? 'this role'} yet.'
                  : 'No templates found.',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (hasRoleFilter) ...[
              const SizedBox(height: AppSpacing.md),
              AppButton(
                text: 'Browse all templates',
                variant: AppButtonVariant.outline,
                onPressed: () =>
                    ref.read(templateEngineProvider).clearFilters(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Templates grid ─────────────────────────────────────────────────────────

  Widget _buildTemplatesGrid(List<TemplateModel> templates,
      TemplateEngineProvider templateState, BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.lg,
            children: templates.map((template) {
              return SizedBox(
                width: (constraints.maxWidth - (AppSpacing.lg * 2)) / 3,
                child: _buildTemplateCard(context, template, templateState),
              );
            }).toList(),
          );
        } else {
          return Column(
            children: templates.map((template) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: _buildTemplateCard(context, template, templateState),
              );
            }).toList(),
          );
        }
      },
    );
  }

  Widget _buildTemplateCard(BuildContext context, TemplateModel template,
      TemplateEngineProvider templateState) {
    // A card is "recommended" when it's the first result in a role-filtered list
    final isRoleMatch = templateState.selectedRole != null;
    final isFeatured = template.slug == 'modern' ||
        (isRoleMatch &&
            templateState.templates.firstOrNull?.slug == template.slug);
    final accentColor = _getAccentColor(template.slug);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFeatured ? AppColors.primary : AppColors.divider,
          width: isFeatured ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isFeatured ? AppColors.primary : Colors.black)
                .withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Template preview
          Container(
            height: 200,
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isFeatured
                  ? AppColors.primary.withOpacity(0.05)
                  : AppColors.background,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              border:
                  const Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: template.previewImageUrl != null
                ? Image.asset(
                    template.previewImageUrl!,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (_, __, ___) => const Icon(
                        LucideIcons.imageOff,
                        size: 40,
                        color: AppColors.divider),
                  )
                : const Center(
                    child: Icon(LucideIcons.image,
                        size: 40, color: AppColors.divider)),
          ),

          // Card details
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge row
                if (isFeatured)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isRoleMatch ? 'BEST MATCH' : 'RECOMMENDED',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                Text(template.name,
                    style: AppTypography.h3
                        .copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  template.description ??
                      'A professional template to help you stand out.',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Features
                ..._getFeatures(template.slug).map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(LucideIcons.checkCircle2,
                            size: 16, color: accentColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: AppTypography.bodySmall
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                AppButton(
                  text: 'Use ${template.name}',
                  variant: isFeatured
                      ? AppButtonVariant.primary
                      : AppButtonVariant.outline,
                  isFullWidth: true,
                  onPressed: () => context.go('/cv/form'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getAccentColor(String slug) {
    switch (slug) {
      case 'modern':
        return const Color(0xFF00ACC1);
      case 'classic':
        return const Color(0xFF1565C0);
      case 'academic':
        return const Color(0xFF5E35B1);
      default:
        return AppColors.primary;
    }
  }

  List<String> _getFeatures(String slug) {
    switch (slug) {
      case 'modern':
        return [
          'ATS-friendly parsing',
          'Prominent skills section',
          'Clean typography'
        ];
      case 'classic':
        return [
          'Conservative styling',
          'Maximum content density',
          'Chronological focus'
        ];
      case 'academic':
        return [
          'Extended publications section',
          'Grants and awards styling',
          'Detailed research history'
        ];
      default:
        return ['ATS-friendly', 'Professional layout'];
    }
  }
}
