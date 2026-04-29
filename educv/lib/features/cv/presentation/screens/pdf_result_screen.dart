import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/pdf_file_saver.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../data/models/cv_models.dart';
import '../providers/cv_provider.dart';

class PDFResultScreen extends ConsumerWidget {
  const PDFResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generatedAsync = ref.watch(generatedCVsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Generate CVs', style: AppTypography.h2),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/cv/dashboard'),
        ),
      ),
      body: generatedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => ErrorState(
          title: 'Could not load CVs',
          message: error.toString(),
          onRetry: () => ref.invalidate(generatedCVsProvider),
        ),
        data: (generatedCVs) {
          if (generatedCVs.isEmpty) {
            return EmptyState(
              icon: Icons.picture_as_pdf,
              title: 'No CVs generated yet',
              subtitle: 'Generate your classic, modern, and academic CV templates.',
              actionLabel: 'Generate CVs',
              onAction: () => ref.read(generatedCVsProvider.notifier).generate(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your CVs are ready', style: AppTypography.h1),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Download any of the generated templates below.',
                  style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  text: 'Regenerate CVs',
                  icon: Icons.refresh,
                  onPressed: () => ref.read(generatedCVsProvider.notifier).generate(),
                ),
                const SizedBox(height: AppSpacing.lg),
                ...generatedCVs.map(
                  (cv) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _GeneratedCVCard(cv: cv),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GeneratedCVCard extends ConsumerStatefulWidget {
  final GeneratedCVModel cv;

  const _GeneratedCVCard({required this.cv});

  @override
  ConsumerState<_GeneratedCVCard> createState() => _GeneratedCVCardState();
}

class _GeneratedCVCardState extends ConsumerState<_GeneratedCVCard> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    final cv = widget.cv;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(AppSpacing.radiusBtn),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusBtn),
            ),
            child: const Icon(Icons.description, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cv.templateDisplay, style: AppTypography.h3),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _fileSizeLabel(cv.fileSize),
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          AppButton(
            text: 'Download',
            icon: Icons.download,
            width: 160,
            isLoading: _isDownloading,
            onPressed: () => _download(context),
          ),
        ],
      ),
    );
  }

  Future<void> _download(BuildContext context) async {
    setState(() => _isDownloading = true);

    try {
      final repository = ref.read(cvRepositoryProvider);
      final bytes = await repository.downloadGeneratedCV(widget.cv.id);

      await savePdfFile(
        bytes: bytes,
        fileName: _fileName(widget.cv),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.cv.templateDisplay} CV downloaded')),
        );
      }
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not download CV: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  String _fileName(GeneratedCVModel cv) {
    final template = cv.templateDisplay.isNotEmpty
        ? cv.templateDisplay
        : cv.template;
    final normalizedTemplate = template
        .trim()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '');

    return 'EduCV_${normalizedTemplate.isEmpty ? 'CV' : normalizedTemplate}.pdf';
  }

  String _fileSizeLabel(int bytes) {
    if (bytes <= 0) {
      return 'PDF file';
    }
    final kb = bytes / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(1)} KB';
    }
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }
}
