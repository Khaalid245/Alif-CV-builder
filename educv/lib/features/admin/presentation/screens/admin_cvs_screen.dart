import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../providers/admin_provider.dart';
import '../widgets/filter_chip_row.dart';
import '../widgets/admin_cv_tile.dart';
import '../widgets/fill_rate_bar.dart';
import '../widgets/pagination_loader.dart';
import '../../data/models/admin_models.dart';

class AdminCVsScreen extends ConsumerStatefulWidget {
  const AdminCVsScreen({super.key});

  @override
  ConsumerState<AdminCVsScreen> createState() => _AdminCVsScreenState();
}

class _AdminCVsScreenState extends ConsumerState<AdminCVsScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedTemplate = 'all';
  String _selectedSort = 'newest';
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminCVsProvider.notifier).fetch();
      ref.read(cvSectionFillRatesProvider.notifier).fetch();
    });
    
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    
    final cvsState = ref.read(adminCVsProvider);
    if (cvsState.value?.hasMore != true) return;

    setState(() => _isLoadingMore = true);
    await ref.read(adminCVsProvider.notifier).loadMore();
    setState(() => _isLoadingMore = false);
  }

  void _onTemplateChanged(String template) {
    setState(() => _selectedTemplate = template);
    ref.read(adminCVsProvider.notifier).fetch(
      template: template == 'all' ? null : template,
      ordering: _getSortOrdering(_selectedSort),
    );
  }

  void _onSortChanged(String sort) {
    setState(() => _selectedSort = sort);
    ref.read(adminCVsProvider.notifier).fetch(
      template: _selectedTemplate == 'all' ? null : _selectedTemplate,
      ordering: _getSortOrdering(sort),
    );
  }

  String _getSortOrdering(String sort) {
    switch (sort) {
      case 'newest':
        return '-generated_at';
      case 'oldest':
        return 'generated_at';
      case 'downloads':
        return '-download_count';
      default:
        return '-generated_at';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cvsState = ref.watch(adminCVsProvider);
    final fillRatesState = ref.watch(cvSectionFillRatesProvider);

    return Column(
      children: [
        // Filter row
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: FilterChipRow(
            options: const ['All Templates', 'Classic', 'Modern', 'Academic'],
            selected: _selectedTemplate,
            onChanged: (value) => _onTemplateChanged(value.toLowerCase().replaceAll(' templates', '')),
          ),
        ),
        
        // Sort row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Text(
                'Sort by:',
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _selectedSort,
                  underline: const SizedBox.shrink(),
                  isDense: true,
                  style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
                  onChanged: (value) => value != null ? _onSortChanged(value) : null,
                  items: const [
                    DropdownMenuItem(value: 'newest', child: Text('Newest First')),
                    DropdownMenuItem(value: 'oldest', child: Text('Oldest First')),
                    DropdownMenuItem(value: 'downloads', child: Text('Most Downloaded')),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // Stats summary
        cvsState.when(
          data: (response) => response != null ? _buildStatsSummary(response) : const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // CVs list
        Expanded(
          child: cvsState.when(
            data: (response) => response != null 
                ? _buildCVsList(response)
                : const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                'Error loading CVs: $error',
                style: AppTypography.body.copyWith(color: AppColors.error),
              ),
            ),
          ),
        ),
        
        // Section fill rates
        fillRatesState.when(
          data: (fillRates) => fillRates.isNotEmpty ? _buildSectionFillRates(fillRates) : const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildStatsSummary(PaginatedResponse<AdminCVModel> response) {
    final totalDownloads = response.results.fold<int>(0, (sum, cv) => sum + cv.downloadCount);
    final popularTemplate = _getMostPopularTemplate(response.results);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(child: _buildStatBox('Total', response.count.toString())),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: _buildStatBox('Downloads', totalDownloads.toString())),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: _buildStatBox('Popular', popularTemplate)),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.h3.copyWith(color: AppColors.primary),
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  String _getMostPopularTemplate(List<AdminCVModel> cvs) {
    if (cvs.isEmpty) return 'None';
    
    final templateCounts = <String, int>{};
    for (final cv in cvs) {
      templateCounts[cv.templateDisplay] = (templateCounts[cv.templateDisplay] ?? 0) + 1;
    }
    
    var mostPopular = templateCounts.entries.first;
    for (final entry in templateCounts.entries) {
      if (entry.value > mostPopular.value) {
        mostPopular = entry;
      }
    }
    
    return mostPopular.key;
  }

  Widget _buildCVsList(PaginatedResponse<AdminCVModel> response) {
    if (response.results.isEmpty) {
      return const EmptyState(
        icon: LucideIcons.fileText,
        title: 'No CVs found',
        subtitle: 'CVs will appear here when students generate them',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(adminCVsProvider.notifier).fetch(
        template: _selectedTemplate == 'all' ? null : _selectedTemplate,
        ordering: _getSortOrdering(_selectedSort),
      ),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: response.results.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == response.results.length) {
            return const PaginationLoader();
          }
          
          final cv = response.results[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AdminCVTile(cv: cv),
          );
        },
      ),
    );
  }

  Widget _buildSectionFillRates(Map<String, int> fillRates) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Section Fill Rates',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          SectionCard(
            child: Column(
              children: [
                FillRateBar(sectionName: 'Education', percentage: fillRates['education'] ?? 0),
                FillRateBar(sectionName: 'Experience', percentage: fillRates['experience'] ?? 0),
                FillRateBar(sectionName: 'Skills', percentage: fillRates['skills'] ?? 0),
                FillRateBar(sectionName: 'Languages', percentage: fillRates['languages'] ?? 0),
                FillRateBar(sectionName: 'Projects', percentage: fillRates['projects'] ?? 0),
                FillRateBar(sectionName: 'Certifications', percentage: fillRates['certifications'] ?? 0),
                FillRateBar(sectionName: 'Summary', percentage: fillRates['summary'] ?? 0),
                FillRateBar(sectionName: 'Photo', percentage: fillRates['photo'] ?? 0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}