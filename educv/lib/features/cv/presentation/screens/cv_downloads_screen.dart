import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/theme/enterprise_theme.dart';
import '../../../../core/widgets/enterprise_ui_components.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../core/utils/file_saver.dart';
import '../../../pdf/presentation/providers/pdf_provider.dart';
import '../../../pdf/data/models/generated_cv_model.dart';

class CVDownloadsScreen extends ConsumerStatefulWidget {
  const CVDownloadsScreen({super.key});

  @override
  ConsumerState<CVDownloadsScreen> createState() => _CVDownloadsScreenState();
}

class _CVDownloadsScreenState extends ConsumerState<CVDownloadsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch PDF history when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pdfHistoryProvider.notifier).fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EnterpriseTheme.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: EnterpriseTheme.backgroundSecondary,
        elevation: 0,
        title: Text(
          'Downloads',
          style: EnterpriseTheme.h2,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: EnterpriseTheme.cardBorder,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showShareBottomSheet(context),
            icon: const Icon(
              LucideIcons.share2,
              size: 20,
              color: EnterpriseTheme.textPrimary,
            ),
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final historyAsync = ref.watch(pdfHistoryProvider);
          final generateAsync = ref.watch(generateCVsProvider);

          return historyAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => _buildErrorState(error.toString()),
            data: (history) {
              if (history.isEmpty) {
                return _buildEmptyState();
              }

              return _buildDownloadsList(history, generateAsync);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: EmptyState(
        icon: LucideIcons.fileDown,
        title: 'No CVs generated yet',
        subtitle:
            'Complete your profile and generate\nyour 3 professional CV templates.',
        actionLabel: 'Generate my CVs',
        onAction: () => context.go('/pdf/result'),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.alertCircle,
              size: 48,
              color: EnterpriseTheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading downloads',
              style: EnterpriseTheme.h3.copyWith(
                color: EnterpriseTheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: EnterpriseTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            EnterpriseButton(
              text: 'Retry',
              icon: LucideIcons.refreshCw,
              type: ButtonType.secondary,
              onPressed: () {
                ref.read(pdfHistoryProvider.notifier).fetch();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadsList(List<GeneratedCVModel> history,
      AsyncValue<GenerateResponse?> generateAsync) {
    // Get the latest batch (assuming all CVs from same generation have same timestamp)
    final latestBatch = history.isNotEmpty ? history.first : null;

    // Group by template and get the latest of each
    final templateMap = <String, GeneratedCVModel>{};
    for (final cv in history) {
      if (!templateMap.containsKey(cv.template) ||
          cv.generatedAt.isAfter(templateMap[cv.template]!.generatedAt)) {
        templateMap[cv.template] = cv;
      }
    }

    // Order templates: Modern (featured), Classic, Academic
    final orderedTemplates = ['modern', 'classic', 'academic'];
    final templateCVs = orderedTemplates
        .where((template) => templateMap.containsKey(template))
        .map((template) => templateMap[template]!)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Latest Batch Header
          if (latestBatch != null) ...[
            Text(
              'Generated ${TimeUtils.timeAgo(latestBatch.generatedAt)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0A0A0A),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '3 templates ready',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Template Download Cards
          Column(
            children: templateCVs
                .map((cv) =>
                    _buildDownloadTemplateCard(cv, cv.template == 'modern'))
                .toList(),
          ),

          const SizedBox(height: 16),

          // Regenerate Row
          Container(
            decoration: BoxDecoration(
              color: EnterpriseTheme.cardBackground,
              border: Border.all(
                color: EnterpriseTheme.cardBorder,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(EnterpriseTheme.radiusLg),
              boxShadow: EnterpriseTheme.shadowSm,
            ),
            padding: const EdgeInsets.all(EnterpriseTheme.spacing16),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.refreshCw,
                  size: 16,
                  color: EnterpriseTheme.textTertiary,
                ),
                const SizedBox(width: EnterpriseTheme.spacing12),
                Expanded(
                  child: Text(
                    'Regenerate all 3 CVs',
                    style: EnterpriseTheme.labelLarge,
                  ),
                ),
                EnterpriseButton(
                  text: 'Generate',
                  size: ButtonSize.small,
                  onPressed: () {
                    ref.read(generateCVsProvider.notifier).reset();
                    context.go('/pdf/result');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadTemplateCard(GeneratedCVModel cv, bool isFeatured) {
    return Container(
      margin: const EdgeInsets.only(bottom: EnterpriseTheme.spacing16),
      decoration: BoxDecoration(
        color: EnterpriseTheme.cardBackground,
        border: Border.all(
          color: isFeatured ? EnterpriseTheme.primaryPurple : EnterpriseTheme.cardBorder,
          width: isFeatured ? 1.0 : 0.5,
        ),
        borderRadius: BorderRadius.circular(EnterpriseTheme.radiusLg),
        boxShadow: EnterpriseTheme.shadowSm,
      ),
      padding: const EdgeInsets.all(EnterpriseTheme.spacing16),
      child: Row(
        children: [
          // CV Thumbnail
          _buildCVThumbnail(cv.template, isFeatured),

          const SizedBox(width: EnterpriseTheme.spacing16),

          // CV Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cv.templateDisplay,
                  style: EnterpriseTheme.h4,
                ),
                const SizedBox(height: EnterpriseTheme.spacing4),
                Text(
                  '${cv.downloadCount} downloads',
                  style: EnterpriseTheme.bodySmall,
                ),
                const SizedBox(height: EnterpriseTheme.spacing4),
                Text(
                  TimeUtils.timeAgo(cv.generatedAt),
                  style: EnterpriseTheme.labelSmall,
                ),
              ],
            ),
          ),

          // Action Buttons
          Column(
            children: [
              EnterpriseButton(
                icon: LucideIcons.download,
                text: 'PDF',
                type: isFeatured ? ButtonType.primary : ButtonType.secondary,
                size: ButtonSize.small,
                onPressed: () => _downloadCV(cv),
              ),
              const SizedBox(height: EnterpriseTheme.spacing8),
              EnterpriseButton(
                icon: LucideIcons.share2,
                text: 'Share',
                type: ButtonType.outline,
                size: ButtonSize.small,
                onPressed: () => _shareCV(cv),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCVThumbnail(String template, bool isFeatured) {
    Color primaryColor;
    switch (template) {
      case 'classic':
        primaryColor = EnterpriseTheme.primaryPurple;
        break;
      case 'modern':
        primaryColor = EnterpriseTheme.accentBlue;
        break;
      case 'academic':
        primaryColor = EnterpriseTheme.accentTeal;
        break;
      default:
        primaryColor = EnterpriseTheme.primaryPurple;
    }

    return Container(
      width: 48,
      height: 64,
      decoration: BoxDecoration(
        border: Border.all(
          color: EnterpriseTheme.cardBorder,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(EnterpriseTheme.radiusSm),
        color:
            isFeatured ? primaryColor.withOpacity(0.05) : EnterpriseTheme.backgroundTertiary,
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            height: 4,
            width: double.infinity * 0.8,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 3,
            width: double.infinity * 0.6,
            decoration: BoxDecoration(
              color: EnterpriseTheme.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: double.infinity * 0.9,
            color: EnterpriseTheme.cardBorder,
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: double.infinity * 0.7,
            color: EnterpriseTheme.cardBorder,
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
            backgroundColor: EnterpriseTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download CV: ${e.toString()}'),
            backgroundColor: EnterpriseTheme.error,
          ),
        );
      }
    }
  }

  void _shareCV(GeneratedCVModel cv) async {
    try {
      // Download bytes first
      final repository = ref.read(pdfRepositoryProvider);
      final bytes = await repository.downloadPDF(cv.id);

      // Save PDF to temporary location
      final path = await FileSaver.savePDF(
        bytes: bytes,
        fileName: '${cv.templateDisplay}_CV.pdf',
        templateName: cv.templateDisplay,
      );

      // Share the file (not available on web)
      if (!kIsWeb) {
        await Share.shareXFiles(
          [XFile(path)],
          text: 'My professional ${cv.templateDisplay} CV',
        );
      } else {
        // On web, just show a message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'File sharing not available on web. Use download instead.'),
              backgroundColor: EnterpriseTheme.primaryPurple,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share CV: ${e.toString()}'),
            backgroundColor: EnterpriseTheme.error,
          ),
        );
      }
    }
  }

  void _showShareBottomSheet(BuildContext context) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share your CV',
              style: EnterpriseTheme.h3,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how to share your CV with recruiters',
              style: EnterpriseTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            // Share PDF file option
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: EnterpriseTheme.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(EnterpriseTheme.radiusSm),
                ),
                child: const Icon(
                  LucideIcons.share2,
                  size: 20,
                  color: EnterpriseTheme.primaryPurple,
                ),
              ),
              title: Text(
                'Share PDF file',
                style: EnterpriseTheme.labelLarge,
              ),
              subtitle: Text(
                'Share your CV as a PDF file',
                style: EnterpriseTheme.bodySmall,
              ),
              onTap: () async {
                Navigator.pop(context);
                // Get the latest CVs for sharing
                final historyAsync = ref.read(pdfHistoryProvider);
                final history = historyAsync.valueOrNull ?? [];
                if (history.isNotEmpty) {
                  // Share the first (latest) CV
                  _shareCV(history.first);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No CVs available to share'),
                      backgroundColor: EnterpriseTheme.error,
                    ),
                  );
                }
              },
            ),

            // Share link option (disabled)
            Opacity(
              opacity: 0.4,
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: EnterpriseTheme.backgroundTertiary,
                    borderRadius: BorderRadius.circular(EnterpriseTheme.radiusSm),
                  ),
                  child: const Icon(
                    LucideIcons.link,
                    size: 20,
                    color: EnterpriseTheme.textTertiary,
                  ),
                ),
                title: Text(
                  'Share link · Coming soon',
                  style: EnterpriseTheme.labelLarge,
                ),
                subtitle: Text(
                  'Share a link to your online CV',
                  style: EnterpriseTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
