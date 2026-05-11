import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/utils/time_utils.dart';
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
          
          return historyAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => _buildErrorState(error.toString()),
            data: (history) {
              if (history.isEmpty) {
                return _buildEmptyState();
              }
              
              return _buildDownloadsList(history);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                LucideIcons.download,
                size: 32,
                color: Color(0xFF1565C0),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'No CVs generated yet',
              style: AppTypography.h3.copyWith(
                color: const Color(0xFF0A0A0A),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Generate your professional CVs to start downloading them',
              style: AppTypography.body.copyWith(
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            AppButton.primary(
              label: 'Generate my CVs',
              icon: LucideIcons.fileDown,
              onPressed: () => context.go('/pdf/result'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
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

  Widget _buildDownloadsList(List<GeneratedCVModel> history) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Your generated CVs',
                style: AppTypography.h3.copyWith(
                  color: const Color(0xFF0A0A0A),
                ),
              ),
              const Spacer(),
              Text(
                '${history.length} CVs',
                style: AppTypography.caption.copyWith(
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Downloads List
          Column(
            children: history
                .map((cv) => _buildDownloadTile(cv))
                .toList(),
          ),
          
          const SizedBox(height: 24),
          
          // Generate More Button
          AppButton.secondary(
            label: 'Generate new CVs',
            icon: LucideIcons.plus,
            onPressed: () => context.go('/pdf/result'),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadTile(GeneratedCVModel cv) {
    return SectionCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // CV Thumbnail
          _buildCVThumbnail(cv.template),
          
          const SizedBox(width: 16),
          
          // CV Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      cv.templateDisplay,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0A0A0A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildTemplateBadge(cv.template),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  cv.templateDescription,
                  style: AppTypography.caption.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    const Icon(
                      LucideIcons.calendar,
                      size: 12,
                      color: Color(0xFF9E9E9E),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Generated ${TimeUtils.timeAgo(cv.generatedAt)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      LucideIcons.download,
                      size: 12,
                      color: Color(0xFF9E9E9E),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${cv.downloadCount} downloads',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Download Button
          Consumer(
            builder: (context, ref, child) {
              final downloadStates = ref.watch(downloadStateProvider);
              final isDownloading = downloadStates[cv.template] == DownloadStatus.loading;
              
              return GestureDetector(
                onTap: isDownloading ? null : () => _downloadCV(cv),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDownloading 
                        ? const Color(0xFFF5F5F5) 
                        : const Color(0xFFEAF2FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isDownloading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF1565C0),
                            ),
                          ),
                        )
                      : const Icon(
                          LucideIcons.download,
                          size: 18,
                          color: Color(0xFF1565C0),
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCVThumbnail(String template) {
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
      width: 40,
      height: 52,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.divider,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 3),
          Container(
            height: 2,
            width: double.infinity * 0.8,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            height: 2,
            width: double.infinity * 0.6,
            color: AppColors.divider,
          ),
          const SizedBox(height: 2),
          Container(
            height: 2,
            width: double.infinity * 0.9,
            color: AppColors.divider,
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateBadge(String template) {
    String label;
    Color color;
    
    switch (template) {
      case 'classic':
        label = 'Professional';
        color = const Color(0xFF1565C0);
        break;
      case 'modern':
        label = 'Popular';
        color = const Color(0xFF00ACC1);
        break;
      case 'academic':
        label = 'Academic';
        color = const Color(0xFF8E24AA);
        break;
      default:
        label = 'CV';
        color = const Color(0xFF1565C0);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void _downloadCV(GeneratedCVModel cv) async {
    try {
      ref.read(downloadStateProvider.notifier).startDownload(cv.template);
      
      final repository = ref.read(pdfRepositoryProvider);
      await repository.downloadPDF(cv.id);
      
      ref.read(downloadStateProvider.notifier).downloadSuccess(cv.template);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${cv.templateDisplay} CV downloaded successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      ref.read(downloadStateProvider.notifier).downloadError(cv.template);
      
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
}