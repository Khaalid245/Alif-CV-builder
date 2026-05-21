import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/cv_intelligence_models.dart';

class RecommendationCard extends StatelessWidget {
  final RecommendationModel recommendation;
  final VoidCallback? onImplemented;
  final VoidCallback? onAction;
  final bool showActions;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.onImplemented,
    this.onAction,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSpacing.sm),
            _buildContent(),
            if (showActions && !recommendation.isImplemented) ...[
              const SizedBox(height: AppSpacing.md),
              _buildActions(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildPriorityIndicator(),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recommendation.title,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  _buildCategoryChip(),
                  const SizedBox(width: AppSpacing.sm),
                  if (recommendation.isImplemented)
                    _buildImplementedBadge(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityIndicator() {
    final color = _getPriorityColor();
    final icon = _getPriorityIcon();
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: 20,
        color: color,
      ),
    );
  }

  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _formatCategory(recommendation.category),
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildImplementedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.check,
            size: 12,
            color: AppColors.success,
          ),
          const SizedBox(width: 4),
          Text(
            'Implemented',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Text(
      recommendation.description,
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondary,
        height: 1.5,
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        if (recommendation.actionUrl != null && onAction != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(LucideIcons.externalLink, size: 16),
              label: Text(recommendation.actionText),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        if (recommendation.actionUrl != null && onAction != null)
          const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onImplemented,
            icon: const Icon(LucideIcons.check, size: 16),
            label: const Text('Mark as Done'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Color _getPriorityColor() {
    switch (recommendation.priority.toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      case 'low':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getPriorityIcon() {
    switch (recommendation.priority.toLowerCase()) {
      case 'high':
        return LucideIcons.alertTriangle;
      case 'medium':
        return LucideIcons.alertCircle;
      case 'low':
        return LucideIcons.info;
      default:
        return LucideIcons.circle;
    }
  }

  String _formatCategory(String category) {
    return category.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
  }
}

class RecommendationsList extends StatelessWidget {
  final List<RecommendationModel> recommendations;
  final Function(String)? onRecommendationImplemented;
  final Function(RecommendationModel)? onRecommendationAction;
  final bool showFilters;
  final String? selectedCategory;
  final String? selectedPriority;
  final Function(String?)? onCategoryChanged;
  final Function(String?)? onPriorityChanged;

  const RecommendationsList({
    super.key,
    required this.recommendations,
    this.onRecommendationImplemented,
    this.onRecommendationAction,
    this.showFilters = false,
    this.selectedCategory,
    this.selectedPriority,
    this.onCategoryChanged,
    this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showFilters) ...[
          _buildFilters(),
          const SizedBox(height: AppSpacing.md),
        ],
        _buildRecommendationsList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Icon(
              LucideIcons.checkCircle,
              size: 64,
              color: AppColors.success,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'All Caught Up!',
              style: AppTypography.headingSmall.copyWith(
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'You\'ve implemented all recommendations. Great job!',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final categories = recommendations.map((r) => r.category).toSet().toList()..sort();
    final priorities = recommendations.map((r) => r.priority).toSet().toList()..sort();

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('All Categories'),
              ),
              ...categories.map((category) => DropdownMenuItem<String>(
                value: category,
                child: Text(_formatCategory(category)),
              )),
            ],
            onChanged: onCategoryChanged,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: selectedPriority,
            decoration: const InputDecoration(
              labelText: 'Priority',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('All Priorities'),
              ),
              ...priorities.map((priority) => DropdownMenuItem<String>(
                value: priority,
                child: Text(_formatCategory(priority)),
              )),
            ],
            onChanged: onPriorityChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recommendations.length,
      itemBuilder: (context, index) {
        final recommendation = recommendations[index];
        return RecommendationCard(
          recommendation: recommendation,
          onImplemented: onRecommendationImplemented != null
              ? () => onRecommendationImplemented!(recommendation.id)
              : null,
          onAction: onRecommendationAction != null
              ? () => onRecommendationAction!(recommendation)
              : null,
        );
      },
    );
  }

  String _formatCategory(String category) {
    return category.split('_').map((word) => 
      word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
  }
}