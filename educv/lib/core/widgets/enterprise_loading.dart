import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'skeleton_loader.dart';
import 'enterprise_components.dart';

enum LoadingState { initial, loading, loaded, error, empty }

class EnterpriseLoadingManager extends StatelessWidget {
  final LoadingState state;
  final Widget child;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final String? loadingMessage;
  final String? errorMessage;
  final String? emptyMessage;
  final VoidCallback? onRetry;

  const EnterpriseLoadingManager({
    super.key,
    required this.state,
    required this.child,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.loadingMessage,
    this.errorMessage,
    this.emptyMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case LoadingState.initial:
      case LoadingState.loading:
        return loadingWidget ?? _buildDefaultLoading();
      case LoadingState.error:
        return errorWidget ?? _buildDefaultError();
      case LoadingState.empty:
        return emptyWidget ?? _buildDefaultEmpty();
      case LoadingState.loaded:
        return child;
    }
  }

  Widget _buildDefaultLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          if (loadingMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              loadingMessage!,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Something went wrong',
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Please try again or contact support if the problem persists.',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              emptyMessage ?? 'No data available',
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'There\'s nothing to show here yet.',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Specialized loading widgets for different scenarios
class CVDashboardSkeleton extends StatelessWidget {
  const CVDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero section skeleton
          const SkeletonLoader(width: 200, height: 32),
          const SizedBox(height: AppSpacing.sm),
          const SkeletonLoader(width: 300, height: 16),
          const SizedBox(height: AppSpacing.xl),

          // Stats grid skeleton
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.5,
            children: List.generate(4, (index) => const SkeletonStats()),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Action buttons skeleton
          Row(
            children: [
              Expanded(
                  child: SkeletonLoader(width: double.infinity, height: 48)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                  child: SkeletonLoader(width: double.infinity, height: 48)),
            ],
          ),
        ],
      ),
    );
  }
}

class CVSectionsSkeleton extends StatelessWidget {
  const CVSectionsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header skeleton
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              const SkeletonLoader(width: 24, height: 24),
              const SizedBox(width: AppSpacing.md),
              const SkeletonLoader(width: 150, height: 24),
            ],
          ),
        ),

        // List items skeleton
        Expanded(
          child: ListView.builder(
            itemCount: 6,
            itemBuilder: (context, index) => const SkeletonListItem(),
          ),
        ),
      ],
    );
  }
}

// Loading overlay for forms
class FormLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const FormLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: AppColors.textPrimary.withValues(alpha: 0.3),
            child: Center(
              child: EnterpriseCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                      if (message != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          message!,
                          style: AppTypography.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
