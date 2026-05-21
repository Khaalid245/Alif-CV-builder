import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/utils/file_saver.dart';
import '../providers/pdf_provider.dart';


class PDFPreviewScreen extends ConsumerStatefulWidget {
  final String generatedCvId;

  const PDFPreviewScreen({
    super.key,
    required this.generatedCvId,
  });

  @override
  ConsumerState<PDFPreviewScreen> createState() => _PDFPreviewScreenState();
}

class _PDFPreviewScreenState extends ConsumerState<PDFPreviewScreen> {
  int currentPage = 0;
  int totalPages = 0;
  bool isReady = false;
  bool isDownloading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPDF();
  }

  Future<void> _loadPDF() async {
    try {
      await ref.read(pdfPreviewProvider.notifier).loadPDF(widget.generatedCvId);
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pdfBytes = ref.watch(pdfPreviewProvider);

    // Get template name from history or generate state
    final historyState = ref.watch(pdfHistoryProvider);
    final generateState = ref.watch(generateCVsProvider);

    String templateName = 'CV';

    historyState.whenData((history) {
      final cv = history.firstWhere(
        (cv) => cv.id == widget.generatedCvId,
        orElse: () => history.first,
      );
      templateName = cv.templateDisplay;
    });

    generateState.whenData((response) {
      if (response != null) {
        final cv = response.cvs.firstWhere(
          (cv) => cv.id == widget.generatedCvId,
          orElse: () => response.cvs.first,
        );
        templateName = cv.templateDisplay;
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: AppColors.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/pdf/result');
            }
          },
        ),
        title: Text(
          '$templateName CV',
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: AppButton(
              text: 'Download',
              onPressed: _downloadPDF,
              isLoading: isDownloading,
            ),
          ),
        ],
      ),
      body: _buildBody(pdfBytes, templateName),
    );
  }

  Widget _buildBody(Uint8List? pdfBytes, String templateName) {
    if (errorMessage != null) {
      return _buildErrorState(templateName);
    }

    if (pdfBytes == null) {
      return _buildLoadingState();
    }

    return _buildPDFView(pdfBytes);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Loading preview...',
            style:
                AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String templateName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Preview unavailable',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            text: 'Download Instead',
            onPressed: _downloadPDF,
          ),
        ],
      ),
    );
  }

  Widget _buildPDFView(Uint8List pdfBytes) {
    if (kIsWeb) {
      // Web-specific PDF viewer using blob URL
      return Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _WebPDFViewer(pdfBytes: pdfBytes),
              ),
            ),
          ),
          // Bottom bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.divider),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'PDF Preview',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
                const Spacer(),
                AppButton(
                  text: 'Download PDF',
                  onPressed: _downloadPDF,
                  isLoading: isDownloading,
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Mobile fallback - show download option
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.fileText,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'PDF Preview',
              style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Preview is not available on this platform.\nDownload to view your CV.',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              text: 'Download PDF',
              onPressed: _downloadPDF,
              isLoading: isDownloading,
            ),
          ],
        ),
      );
    }
  }

  Future<void> _downloadPDF() async {
    setState(() {
      isDownloading = true;
    });

    try {
      final repository = ref.read(pdfRepositoryProvider);
      final pdfBytes = await repository.downloadPDF(widget.generatedCvId);

      // Get template name for file naming
      String templateName = 'CV';
      final historyState = ref.read(pdfHistoryProvider);
      final generateState = ref.read(generateCVsProvider);

      historyState.whenData((history) {
        final cv = history.firstWhere(
          (cv) => cv.id == widget.generatedCvId,
          orElse: () => history.first,
        );
        templateName = cv.templateDisplay;
      });

      generateState.whenData((response) {
        if (response != null) {
          final cv = response.cvs.firstWhere(
            (cv) => cv.id == widget.generatedCvId,
            orElse: () => response.cvs.first,
          );
          templateName = cv.templateDisplay;
        }
      });

      final filePath = await FileSaver.savePDF(
        bytes: pdfBytes,
        fileName: '${templateName}_CV.pdf',
        templateName: templateName,
      );

      await FileSaver.openFile(filePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$templateName CV saved to your device'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download CV: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }
}

class _WebPDFViewer extends StatelessWidget {
  final Uint8List pdfBytes;

  const _WebPDFViewer({required this.pdfBytes});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // For web, show a message and download button instead of trying to embed PDF
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.fileText,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'PDF Ready for Download',
              style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your CV has been generated successfully.\nClick download to save it to your device.',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }
    
    return Container(
      child: Center(
        child: Text(
          'PDF preview not available',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
