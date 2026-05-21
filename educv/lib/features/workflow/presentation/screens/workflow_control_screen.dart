import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../cv/presentation/providers/cv_provider.dart';
import '../providers/workflow_provider.dart';
import '../widgets/workflow_state_widget.dart';
import '../widgets/workflow_transition_widget.dart';

class WorkflowControlScreen extends HookConsumerWidget {
  const WorkflowControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 3);
    final cvProfile = ref.watch(cvProfileProvider);
    
    // Get CV ID from profile
    final cvId = cvProfile.when(
      data: (profile) => profile?.id,
      loading: () => null,
      error: (_, __) => null,
    );

    if (cvId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Workflow Control'),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        body: const Center(
          child: Text('CV profile not found'),
        ),
      );
    }

    final workflowState = ref.watch(cvWorkflowProvider(cvId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workflow Control'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              labelStyle: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'Current State'),
                Tab(text: 'Actions'),
                Tab(text: 'History'),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _refreshWorkflow(ref, cvId),
            icon: const Icon(LucideIcons.refreshCw),
            tooltip: 'Refresh Workflow',
          ),
        ],
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _buildCurrentStateTab(context, ref, workflowState),
          _buildActionsTab(context, ref, workflowState, cvId),
          _buildHistoryTab(context, ref, workflowState),
        ],
      ),
    );
  }

  Widget _buildCurrentStateTab(
    BuildContext context,
    WidgetRef ref,
    CVWorkflowState state,
  ) {
    if (state.isLoading) {
      return const Center(child: AppLoader());
    }

    if (state.error != null) {
      return AppErrorState(
        message: state.error!,
        onRetry: () => ref.read(cvWorkflowProvider(ref.read(cvProfileProvider).value?.id ?? '').notifier).refreshWorkflow(),
      );
    }

    if (!state.hasWorkflow) {
      return _buildNoWorkflowState(context, ref);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WorkflowStateWidget(
            workflow: state.workflow!,
            showDetails: true,
          ),
          const SizedBox(height: AppSpacing.lg),
          WorkflowProgressWidget(
            workflow: state.workflow!,
            showLabels: true,
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildWorkflowInfo(state.workflow!),
        ],
      ),
    );
  }

  Widget _buildActionsTab(
    BuildContext context,
    WidgetRef ref,
    CVWorkflowState state,
    String cvId,
  ) {
    if (state.isLoading) {
      return const Center(child: AppLoader());
    }

    if (state.error != null) {
      return AppErrorState(
        message: state.error!,
        onRetry: () => ref.read(cvWorkflowProvider(cvId).notifier).refreshWorkflow(),
      );
    }

    if (!state.hasWorkflow) {
      return _buildNoWorkflowState(context, ref);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WorkflowStateWidget(
            workflow: state.workflow!,
            showDetails: false,
          ),
          const SizedBox(height: AppSpacing.lg),
          WorkflowTransitionActionsWidget(
            transitions: state.availableTransitions,
            onTransition: (transitionId, comment, metadata) => 
                _performTransition(context, ref, cvId, transitionId, comment, metadata),
            isLoading: state.isTransitioning,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(
    BuildContext context,
    WidgetRef ref,
    CVWorkflowState state,
  ) {
    if (state.isLoading) {
      return const Center(child: AppLoader());
    }

    if (state.error != null) {
      return AppErrorState(
        message: state.error!,
        onRetry: () => ref.read(cvWorkflowProvider(ref.read(cvProfileProvider).value?.id ?? '').notifier).refreshWorkflow(),
      );
    }

    if (!state.hasWorkflow) {
      return _buildNoWorkflowState(context, ref);
    }

    return Consumer(
      builder: (context, ref, child) {
        final historyState = ref.watch(transitionHistoryProvider(state.workflow!.id));
        
        return historyState.isLoading
            ? const Center(child: AppLoader())
            : historyState.error != null
                ? AppErrorState(
                    message: historyState.error!,
                    onRetry: () => ref.read(transitionHistoryProvider(state.workflow!.id).notifier).loadHistory(refresh: true),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: TransitionHistoryWidget(
                      history: historyState.history,
                      isLoading: historyState.isLoadingMore,
                      hasMore: historyState.hasMore,
                      onLoadMore: () => ref.read(transitionHistoryProvider(state.workflow!.id).notifier).loadMoreHistory(),
                    ),
                  );
      },
    );
  }

  Widget _buildNoWorkflowState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.workflow,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No Workflow Active',
              style: AppTypography.headingMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your CV is not currently part of any workflow process.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => _showCreateWorkflowDialog(context, ref),
              icon: const Icon(LucideIcons.plus),
              label: const Text('Start Workflow'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowInfo(workflow) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workflow Information',
              style: AppTypography.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildInfoRow('Name', workflow.workflowConfig.name),
            _buildInfoRow('Description', workflow.workflowConfig.description),
            _buildInfoRow('Entity Type', workflow.workflowConfig.entityType),
            _buildInfoRow('Started By', workflow.startedBy),
            _buildInfoRow('Started At', _formatDateTime(workflow.startedAt)),
            _buildInfoRow('Last Updated', _formatDateTime(workflow.updatedAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performTransition(
    BuildContext context,
    WidgetRef ref,
    String cvId,
    String transitionId,
    String? comment,
    Map<String, dynamic>? metadata,
  ) async {
    try {
      await ref.read(cvWorkflowProvider(cvId).notifier).performTransition(
        transitionId,
        comment: comment,
        metadata: metadata,
      );
      
      if (context.mounted) {
        SnackbarHelper.showSuccess(
          context,
          'Workflow transition completed successfully!',
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarHelper.showError(
          context,
          'Failed to perform transition: ${e.toString()}',
        );
      }
    }
  }

  void _refreshWorkflow(WidgetRef ref, String cvId) {
    ref.read(cvWorkflowProvider(cvId).notifier).refreshWorkflow();
  }

  void _showCreateWorkflowDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Workflow'),
        content: const Text(
          'Would you like to start a workflow process for your CV? '
          'This will enable state tracking and transition management.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _createWorkflow(context, ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  Future<void> _createWorkflow(BuildContext context, WidgetRef ref) async {
    try {
      // This would need to be implemented based on your workflow creation logic
      // For now, we'll show a placeholder message
      SnackbarHelper.showInfo(
        context,
        'Workflow creation feature coming soon!',
      );
    } catch (e) {
      if (context.mounted) {
        SnackbarHelper.showError(
          context,
          'Failed to create workflow: ${e.toString()}',
        );
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class WorkflowDashboardScreen extends HookConsumerWidget {
  const WorkflowDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(workflowDashboardProvider(null));
    final instancesState = ref.watch(workflowInstancesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workflow Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _refreshDashboard(ref),
            icon: const Icon(LucideIcons.refreshCw),
            tooltip: 'Refresh Dashboard',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshDashboard(ref),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              dashboardAsync.when(
                data: (dashboard) => _buildDashboardStats(dashboard),
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Center(child: AppLoader()),
                  ),
                ),
                error: (error, stack) => AppErrorState(
                  message: error.toString(),
                  onRetry: () => ref.refresh(workflowDashboardProvider(null)),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildInstancesList(context, ref, instancesState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardStats(dashboard) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workflow Statistics',
              style: AppTypography.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Instances',
                    dashboard.totalInstances.toString(),
                    LucideIcons.workflow,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildStatCard(
                    'Active',
                    dashboard.activeInstances.toString(),
                    LucideIcons.play,
                    AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Completed',
                    dashboard.completedInstances.toString(),
                    LucideIcons.checkCircle,
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildStatCard(
                    'Success Rate',
                    '${((dashboard.completedInstances / (dashboard.totalInstances > 0 ? dashboard.totalInstances : 1)) * 100).toStringAsFixed(1)}%',
                    LucideIcons.trendingUp,
                    AppColors.info,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const Spacer(),
              Text(
                value,
                style: AppTypography.headingSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstancesList(
    BuildContext context,
    WidgetRef ref,
    WorkflowInstancesState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Recent Workflow Instances',
                style: AppTypography.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => ref.read(workflowInstancesProvider.notifier).loadInstances(refresh: true),
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Refresh'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (state.isLoading)
          const Center(child: AppLoader())
        else if (state.error != null)
          AppErrorState(
            message: state.error!,
            onRetry: () => ref.read(workflowInstancesProvider.notifier).loadInstances(refresh: true),
          )
        else if (state.instances.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Text('No workflow instances found'),
            ),
          )
        else
          ...state.instances.take(5).map((instance) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: WorkflowStateWidget(
              workflow: instance,
              showDetails: false,
            ),
          )),
      ],
    );
  }

  Future<void> _refreshDashboard(WidgetRef ref) async {
    ref.refresh(workflowDashboardProvider(null));
    ref.read(workflowInstancesProvider.notifier).loadInstances(refresh: true);
  }
}