import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Downloads',
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
          IconButton(
            onPressed: () => _showShareBottomSheet(context),
            icon: const Icon(
              LucideIcons.share2,
              size: 20,
              color: Color(0xFF0A0A0A),
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
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading downloads',
              style: AppTypography.h3.copyWith(
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTypography.body.copyWith(
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton.secondary(
              label: 'Retry',
              icon: LucideIcons.refreshCw,
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
              border: Border.all(
                color: AppColors.divider,
                width: 0.5,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.refreshCw,
                  size: 16,
                  color: Color(0xFF9E9E9E),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Regenerate all 3 CVs',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(generateCVsProvider.notifier).reset();
                    context.go('/pdf/result');
                  },
                  child: Text(
                    'Generate',
                    style: AppTypography.body.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: isFeatured ? const Color(0xFF1565C0) : AppColors.divider,
          width: isFeatured ? 1.0 : 0.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // CV Thumbnail
          _buildCVThumbnail(cv.template, isFeatured),

          const SizedBox(width: 14),

          // CV Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cv.templateDisplay,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A0A0A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${cv.downloadCount} downloads',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  TimeUtils.timeAgo(cv.generatedAt),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Column(
            children: [
              // Download PDF Button
              _buildActionButton(
                icon: LucideIcons.download,
                label: 'PDF',
                isFeatured: isFeatured,
                onTap: () => _downloadCV(cv),
              ),

              const SizedBox(height: 8),

              // Share Button
              _buildActionButton(
                icon: LucideIcons.share2,
                label: 'Share',
                isFeatured: false,
                onTap: () => _shareCV(cv),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isFeatured,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isFeatured ? const Color(0xFF1565C0) : AppColors.surface,
          border: isFeatured
              ? null
              : Border.all(
                  color: AppColors.divider,
                  width: 0.5,
                ),
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isFeatured ? Colors.white : const Color(0xFF4A4A4A),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isFeatured ? Colors.white : const Color(0xFF4A4A4A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCVThumbnail(String template, bool isFeatured) {
    Color primaryColor;
    switch (template) {
      case 'classic':
        primaryColor = const Color(0xFF1565C0);
        break;
      case 'modern':
        primaryColor = const Color(0xFF00ACC1);
        break;
      case 'academic':
        primaryColor = const Color(0xFF8E24AA);
        break;
      default:
        primaryColor = const Color(0xFF1565C0);
    }

    return Container(
      width: 36,
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.divider,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(4),
        color: isFeatured ? const Color(0xFFEAF2FF) : AppColors.surface,
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          Container(
            height: 3,
            width: double.infinity * 0.8,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            height: 2,
            width: double.infinity * 0.6,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            height: 2,
            width: double.infinity * 0.9,
            color: AppColors.divider,
          ),
          const SizedBox(height: 2),
          Container(
            height: 2,
            width: double.infinity * 0.7,
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

  void _shareCV(GeneratedCVModel cv) async {
    try {
      // Download bytes first
      final repository = ref.read(pdfRepositoryProvider);
      final bytes = await repository.downloadPDF(cv.id);

      // Save PDF to temporary location
      final path = await FileSaver.savePDF(
        bytes: bytes,
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
              backgroundColor: AppColors.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share CV: ${e.toString()}'),
            backgroundColor: AppColors.error,
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
              style: AppTypography.h3,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how to share your CV with recruiters',
              style: AppTypography.body.copyWith(
                color: const Color(0xFF6B7280),
              ),
            ),

            const SizedBox(height: 24),

            // Share PDF file option
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.share2,
                  size: 20,
                  color: Color(0xFF1565C0),
                ),
              ),
              title: const Text(
                'Share PDF file',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text(
                'Share your CV as a PDF file',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
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
                      backgroundColor: AppColors.error,
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
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.link,
                    size: 20,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
                title: const Text(
                  'Share link · Coming soon',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: const Text(
                  'Share a link to your online CV',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
