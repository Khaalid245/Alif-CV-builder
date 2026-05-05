import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/utils/file_saver.dart';
import '../../../../core/utils/date_formatter.dart';
import '../providers/pdf_provider.dart';
import '../../data/models/generated_cv_model.dart';

class PDFResultScreen extends ConsumerStatefulWidget {
  const PDFResultScreen({super.key});

  @override
  ConsumerState<PDFResultScreen> createState() => _PDFResultScreenState();
}

class _PDFResultScreenState extends ConsumerState<PDFResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only generate if no results exist in this session.
      // Prevents regenerating every time the screen is opened.
      final existing = ref.read(generateCVsProvider).valueOrNull;
      if (existing == null) {
        ref.read(generateCVsProvider.notifier).generate();
      }
      ref.read(pdfHistoryProvider.notifier).fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final generateState = ref.watch(generateCVsProvider);
    final historyState = ref.watch(pdfHistoryProvider);
    final downloadStates = ref.watch(downloadStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: () => context.go('/cv/dashboard'),
        ),
        title: Text(
          'My CVs',
          style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.clock, color: AppColors.textPrimary, size: 20),
            onPressed: () {
              // Scroll to history section or show history sheet
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.divider,
          ),
        ),
      ),
      body: generateState.when(
        data: (response) {
          if (response == null) {
            return _buildGeneratingState();
          }
          return _buildReadyState(response, historyState, downloadStates);
        },
        loading: () => _buildGeneratingState(),
        error: (error, _) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildGeneratingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated generating icon
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  LucideIcons.fileText,
                  color: AppColors.primary,
                  size: 36,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Generating your CVs',
            style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Creating 3 professional templates,\nthis takes a few seconds...',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Generation steps
          const _GenerationSteps(),
        ],
      ),
    );
  }

  Widget _buildReadyState(
    GenerateResponse response,
    AsyncValue<List<GeneratedCVModel>> historyState,
    Map<String, DownloadStatus> downloadStates,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FFF4),
              border: Border.all(color: const Color(0xFFA3D9B1)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.checkCircle, color: AppColors.success, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your CVs are ready!',
                      style: AppTypography.h3.copyWith(color: AppColors.success),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '3 professional formats generated',
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Choose Your Template',
            style: AppTypography.h2.copyWith(color: AppColors.textPrimary),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Tap a template to preview, then download as PDF',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Template cards
          ...response.cvs.map((cv) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _CVTemplateCard(
              cv: cv,
              downloadStatus: downloadStates[cv.template] ?? DownloadStatus.idle,
              onPreview: () => context.go('/pdf/preview/${cv.id}'),
              onDownload: () => _downloadPDF(cv),
            ),
          )).toList(),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Generation info
          Text(
            'Generated on',
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            DateFormatter.toDateTimeFormat(response.generatedAt),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Previous CVs section
          Text(
            'Previously Generated',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          historyState.when(
            data: (history) {
              if (history.isEmpty) {
                return Text(
                  'No previous CVs',
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                );
              }
              
              return Column(
                children: history.map((cv) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _HistoryTile(cv: cv, onDownload: () => _downloadPDF(cv)),
                )).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => TextButton.icon(
              onPressed: () => ref.read(pdfHistoryProvider.notifier).fetch(),
              icon: const Icon(LucideIcons.refreshCw, size: 14, color: AppColors.primary),
              label: Text(
                'Could not load history. Tap to retry.',
                style: AppTypography.caption.copyWith(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            EmptyState(
              icon: LucideIcons.alertCircle,
              title: 'Generation Failed',
              subtitle: error.contains('validation') || error.contains('education')
                  ? 'Could not generate your CVs. Please check your CV has at least one education entry and try again.'
                  : error,
            ),
            
            const SizedBox(height: 24),
            
            AppButton(
              text: 'Try Again',
              onPressed: () => ref.read(generateCVsProvider.notifier).generate(),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Need help?',
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            
            TextButton(
              onPressed: () {
                // Contact support action
              },
              child: Text(
                'Contact Support',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadPDF(GeneratedCVModel cv) async {
    final downloadNotifier = ref.read(downloadStateProvider.notifier);
    
    try {
      downloadNotifier.startDownload(cv.template);
      
      final repository = ref.read(pdfRepositoryProvider);
      final pdfBytes = await repository.downloadPDF(cv.id);
      
      final filePath = await FileSaver.savePDF(
        bytes: pdfBytes,
        templateName: cv.templateDisplay,
      );
      
      await FileSaver.openFile(filePath);
      
      downloadNotifier.downloadSuccess(cv.template);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${cv.templateDisplay} CV saved to your device'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (error) {
      downloadNotifier.downloadError(cv.template);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download CV: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _GenerationSteps extends ConsumerWidget {
  const _GenerationSteps();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generateState = ref.watch(generateCVsProvider);
    final isLoading = generateState.isLoading;
    final isDone = generateState.valueOrNull != null;

    final templates = [
      ('Classic Template', 'classic'),
      ('Modern Template', 'modern'),
      ('Academic Template', 'academic'),
    ];

    return Column(
      children: templates.map((entry) {
        final label = entry.$1;

        final GenerationStepStatus status;
        if (isDone) {
          status = GenerationStepStatus.done;
        } else if (isLoading) {
          // Show loading sequentially based on template order
          status = GenerationStepStatus.loading;
        } else {
          status = GenerationStepStatus.pending;
        }

        return _GenerationStepRow(
          icon: LucideIcons.fileText,
          label: label,
          status: status,
        );
      }).toList(),
    );
  }
}

enum GenerationStepStatus { pending, loading, done }

class _GenerationStepRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final GenerationStepStatus status;

  const _GenerationStepRow({
    required this.icon,
    required this.label,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: _buildStatusIndicator(),
          ),
          
          const SizedBox(width: AppSpacing.sm),
          
          Text(
            label,
            style: AppTypography.body.copyWith(color: AppColors.textPrimary),
          ),
          
          const Spacer(),
          
          if (status == GenerationStepStatus.done)
            Text(
              'Ready',
              style: AppTypography.caption.copyWith(color: AppColors.success),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    switch (status) {
      case GenerationStepStatus.pending:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.textSecondary),
          ),
        );
      case GenerationStepStatus.loading:
        return const CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        );
      case GenerationStepStatus.done:
        return const Icon(
          LucideIcons.checkCircle,
          color: AppColors.success,
          size: 24,
        );
    }
  }
}

class _CVTemplateCard extends StatelessWidget {
  final GeneratedCVModel cv;
  final DownloadStatus downloadStatus;
  final VoidCallback onPreview;
  final VoidCallback onDownload;

  const _CVTemplateCard({
    required this.cv,
    required this.downloadStatus,
    required this.onPreview,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      onTap: onPreview,
      child: Column(
        children: [
          Row(
            children: [
              // Template thumbnail
              Container(
                width: 48,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(height: 4, width: 30, color: AppColors.primary),
                    const SizedBox(height: 4),
                    Container(height: 2, width: 40, color: AppColors.divider),
                    const SizedBox(height: 2),
                    Container(height: 2, width: 35, color: AppColors.divider),
                    const SizedBox(height: 2),
                    Container(height: 2, width: 38, color: AppColors.divider),
                  ],
                ),
              ),
              
              const SizedBox(width: AppSpacing.sm),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          cv.templateDisplay,
                          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
                        ),
                        const Spacer(),
                        _TemplateBadge(template: cv.template),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      cv.templateDescription,
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                    
                    const SizedBox(height: AppSpacing.sm),
                    
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Preview',
                            onPressed: onPreview,
                            icon: LucideIcons.eye,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppButton(
                            text: downloadStatus == DownloadStatus.loading ? 'Saving...' : 'Download',
                            onPressed: onDownload,
                            isLoading: downloadStatus == DownloadStatus.loading,
                            icon: LucideIcons.download,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (downloadStatus == DownloadStatus.success) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(LucideIcons.checkCircle, color: AppColors.success, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Downloaded • ${DateFormatter.getRelativeTime(DateTime.now())}',
                  style: AppTypography.caption.copyWith(color: AppColors.success),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TemplateBadge extends StatelessWidget {
  final String template;

  const _TemplateBadge({required this.template});

  @override
  Widget build(BuildContext context) {
    final (text, color) = _getBadgeData();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTypography.uppercase.copyWith(
          color: AppColors.white,
        ),
      ),
    );
  }

  (String, Color) _getBadgeData() {
    switch (template) {
      case 'classic':
        return ('Professional', AppColors.textSecondary);
      case 'modern':
        return ('Popular', AppColors.primary);
      case 'academic':
        return ('Academic', AppColors.textPrimary);
      default:
        return ('', AppColors.textSecondary);
    }
  }
}

class _HistoryTile extends StatelessWidget {
  final GeneratedCVModel cv;
  final VoidCallback onDownload;

  const _HistoryTile({
    required this.cv,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Row(
        children: [
          // Template thumbnail (smaller)
          Container(
            width: 36,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(height: 3, width: 24, color: AppColors.primary),
                const SizedBox(height: 3),
                Container(height: 2, width: 28, color: AppColors.divider),
                const SizedBox(height: 2),
                Container(height: 2, width: 26, color: AppColors.divider),
              ],
            ),
          ),
          
          const SizedBox(width: AppSpacing.sm),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cv.templateDisplay,
                  style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.toDisplayFormat(cv.generatedAt),
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${cv.downloadCount} downloads',
                  style: AppTypography.caption.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
          
          IconButton(
            icon: const Icon(LucideIcons.download, color: AppColors.primary, size: 20),
            onPressed: onDownload,
          ),
        ],
      ),
    );
  }
}
