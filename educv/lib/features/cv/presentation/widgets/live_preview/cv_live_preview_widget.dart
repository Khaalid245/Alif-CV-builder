import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/theme/premium_saas_theme.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../providers/live_cv_provider.dart';
import 'templates/modern_template.dart';
import 'templates/classic_template.dart';
import 'templates/academic_template.dart';

class CVLivePreviewWidget extends ConsumerWidget {
  const CVLivePreviewWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(liveCvProfileProvider);
    final template = ref.watch(liveCvTemplateProvider);

    return Container(
      color: const Color(0xFFF3F4F6),
      child: Column(
        children: [
          _buildToolbar(ref, template),
          Expanded(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: AspectRatio(
                    aspectRatio: 1 / 1.414, // A4 ratio
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Stack(
                        children: [
                          if (profile != null)
                            Positioned.fill(
                              child: SingleChildScrollView(
                                child: _buildTemplate(template, profile),
                              ),
                            )
                          else
                            const Center(
                              child: Text('Loading preview...'),
                            ),
                            
                          // Watermark
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Center(
                                child: Transform.rotate(
                                  angle: -0.5,
                                  child: Text(
                                    'PREVIEW',
                                    style: TextStyle(
                                      fontSize: 120,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.grey.withOpacity(0.08),
                                      letterSpacing: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplate(String template, dynamic profile) {
    switch (template) {
      case 'classic':
        return ClassicTemplate(profile: profile);
      case 'academic':
        return AcademicTemplate(profile: profile);
      case 'modern':
      default:
        return ModernTemplate(profile: profile);
    }
  }

  Widget _buildToolbar(WidgetRef ref, String currentTemplate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.layout, size: 20, color: PremiumSaaSTheme.primaryPurple),
              const SizedBox(width: 8),
              Text('Live Preview', style: AppTypography.h4.copyWith(color: PremiumSaaSTheme.textPrimary)),
            ],
          ),
          Row(
            children: [
              _buildTemplateButton(ref, 'modern', 'Modern', currentTemplate),
              const SizedBox(width: 8),
              _buildTemplateButton(ref, 'classic', 'Classic', currentTemplate),
              const SizedBox(width: 8),
              _buildTemplateButton(ref, 'academic', 'Academic', currentTemplate),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTemplateButton(WidgetRef ref, String id, String name, String currentTemplate) {
    final isSelected = id == currentTemplate;
    return InkWell(
      onTap: () => ref.read(liveCvTemplateProvider.notifier).state = id,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? PremiumSaaSTheme.primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? PremiumSaaSTheme.primaryPurple : PremiumSaaSTheme.lightBorder,
          ),
        ),
        child: Text(
          name,
          style: AppTypography.caption.copyWith(
            color: isSelected ? Colors.white : PremiumSaaSTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
