import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../domain/workflow_repository.dart';
import '../../data/repositories/workflow_repository_impl.dart';
import '../../data/models/workflow_models.dart';

// Repository provider
final workflowRepositoryProvider = Provider<WorkflowRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WorkflowRepositoryImpl(apiClient);
});

// CV Workflow state
class CVWorkflowState {
  final WorkflowInstanceModel? workflow;
  final List<WorkflowTransitionModel> availableTransitions;
  final bool isLoading;
  final bool isTransitioning;
  final String? error;
  final DateTime? lastUpdated;

  const CVWorkflowState({
    this.workflow,
    this.availableTransitions = const [],
    this.isLoading = false,
    this.isTransitioning = false,
    this.error,
    this.lastUpdated,
  });

  CVWorkflowState copyWith({
    WorkflowInstanceModel? workflow,
    List<WorkflowTransitionModel>? availableTransitions,
    bool? isLoading,
    bool? isTransitioning,
    String? error,
    DateTime? lastUpdated,
  }) {
    return CVWorkflowState(
      workflow: workflow ?? this.workflow,
      availableTransitions: availableTransitions ?? this.availableTransitions,
      isLoading: isLoading ?? this.isLoading,
      isTransitioning: isTransitioning ?? this.isTransitioning,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool get hasWorkflow => workflow != null;
  bool get canTransition => availableTransitions.isNotEmpty && !isTransitioning;
}

// CV Workflow provider
class CVWorkflowNotifier extends StateNotifier<CVWorkflowState> {
  final WorkflowRepository _repository;
  final String _cvId;

  CVWorkflowNotifier(this._repository, this._cvId) : super(const CVWorkflowState()) {
    _loadWorkflow();
  }

  Future<void> _loadWorkflow() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final workflow = await _repository.getCVWorkflow(_cvId);
      
      if (workflow != null) {
        final transitions = await _repository.getAvailableTransitions(workflow.id);
        state = state.copyWith(
          workflow: workflow,
          availableTransitions: transitions,
          isLoading: false,
          lastUpdated: DateTime.now(),
        );
      } else {
        state = state.copyWith(
          workflow: null,
          availableTransitions: [],
          isLoading: false,
          lastUpdated: DateTime.now(),
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
    }
  }

  Future<void> performTransition(
    String transitionId, {
    String? comment,
    Map<String, dynamic>? metadata,
  }) async {
    if (state.workflow == null) return;

    try {
      state = state.copyWith(isTransitioning: true, error: null);
      
      final request = WorkflowTransitionRequest(
        transitionId: transitionId,
        comment: comment,
        metadata: metadata,
      );
      
      final updatedWorkflow = await _repository.performTransition(
        state.workflow!.id,
        request,
      );
      
      final transitions = await _repository.getAvailableTransitions(updatedWorkflow.id);
      
      state = state.copyWith(
        workflow: updatedWorkflow,
        availableTransitions: transitions,
        isTransitioning: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isTransitioning: false,
        error: e is AppException ? e.message : e.toString(),
      );
      rethrow;
    }
  }

  Future<void> refreshWorkflow() async {
    await _loadWorkflow();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final cvWorkflowProvider = StateNotifierProvider.family<CVWorkflowNotifier, CVWorkflowState, String>((ref, cvId) {
  final repository = ref.watch(workflowRepositoryProvider);
  return CVWorkflowNotifier(repository, cvId);
});

// Workflow instances state
class WorkflowInstancesState {
  final List<WorkflowInstanceModel> instances;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final String? statusFilter;
  final String? configFilter;

  const WorkflowInstancesState({
    this.instances = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
    this.statusFilter,
    this.configFilter,
  });

  WorkflowInstancesState copyWith({
    List<WorkflowInstanceModel>? instances,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMore,
    String? statusFilter,
    String? configFilter,
  }) {
    return WorkflowInstancesState(
      instances: instances ?? this.instances,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      statusFilter: statusFilter ?? this.statusFilter,
      configFilter: configFilter ?? this.configFilter,
    );
  }
}

// Workflow instances provider
class WorkflowInstancesNotifier extends StateNotifier<WorkflowInstancesState> {
  final WorkflowRepository _repository;

  WorkflowInstancesNotifier(this._repository) : super(const WorkflowInstancesState()) {
    loadInstances();
  }

  Future<void> loadInstances({bool refresh = false}) async {
    try {
      if (refresh) {
        state = state.copyWith(
          isLoading: true,
          error: null,
          currentPage: 1,
          instances: [],
        );
      } else if (state.instances.isEmpty) {
        state = state.copyWith(isLoading: true, error: null);
      }

      final instances = await _repository.getWorkflowInstances(
        page: refresh ? 1 : state.currentPage,
        status: state.statusFilter,
        workflowConfigId: state.configFilter,
      );

      state = state.copyWith(
        instances: refresh ? instances : [...state.instances, ...instances],
        isLoading: false,
        hasMore: instances.length >= 20, // Assuming page size is 20
        currentPage: refresh ? 1 : state.currentPage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
    }
  }

  Future<void> loadMoreInstances() async {
    if (state.isLoadingMore || !state.hasMore) return;

    try {
      state = state.copyWith(isLoadingMore: true, error: null);
      
      final nextPage = state.currentPage + 1;
      final instances = await _repository.getWorkflowInstances(
        page: nextPage,
        status: state.statusFilter,
        workflowConfigId: state.configFilter,
      );
      
      state = state.copyWith(
        instances: [...state.instances, ...instances],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: instances.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e is AppException ? e.message : e.toString(),
      );
    }
  }

  void setFilters({String? status, String? config}) {
    state = state.copyWith(
      statusFilter: status,
      configFilter: config,
      instances: [],
      currentPage: 1,
      hasMore: true,
    );
    loadInstances();
  }

  void clearFilters() {
    state = state.copyWith(
      statusFilter: null,
      configFilter: null,
      instances: [],
      currentPage: 1,
      hasMore: true,
    );
    loadInstances();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final workflowInstancesProvider = StateNotifierProvider<WorkflowInstancesNotifier, WorkflowInstancesState>((ref) {
  final repository = ref.watch(workflowRepositoryProvider);
  return WorkflowInstancesNotifier(repository);
});

// Transition history state
class TransitionHistoryState {
  final List<WorkflowTransitionLogModel> history;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMore;

  const TransitionHistoryState({
    this.history = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
  });

  TransitionHistoryState copyWith({
    List<WorkflowTransitionLogModel>? history,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMore,
  }) {
    return TransitionHistoryState(
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// Transition history provider
class TransitionHistoryNotifier extends StateNotifier<TransitionHistoryState> {
  final WorkflowRepository _repository;
  final String _instanceId;

  TransitionHistoryNotifier(this._repository, this._instanceId) 
      : super(const TransitionHistoryState()) {
    loadHistory();
  }

  Future<void> loadHistory({bool refresh = false}) async {
    try {
      if (refresh) {
        state = state.copyWith(
          isLoading: true,
          error: null,
          currentPage: 1,
          history: [],
        );
      } else if (state.history.isEmpty) {
        state = state.copyWith(isLoading: true, error: null);
      }

      final history = await _repository.getTransitionHistory(
        _instanceId,
        page: refresh ? 1 : state.currentPage,
      );

      state = state.copyWith(
        history: refresh ? history : [...state.history, ...history],
        isLoading: false,
        hasMore: history.length >= 50, // Assuming page size is 50
        currentPage: refresh ? 1 : state.currentPage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e is AppException ? e.message : e.toString(),
      );
    }
  }

  Future<void> loadMoreHistory() async {
    if (state.isLoadingMore || !state.hasMore) return;

    try {
      state = state.copyWith(isLoadingMore: true, error: null);
      
      final nextPage = state.currentPage + 1;
      final history = await _repository.getTransitionHistory(
        _instanceId,
        page: nextPage,
      );
      
      state = state.copyWith(
        history: [...state.history, ...history],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: history.length >= 50,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e is AppException ? e.message : e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final transitionHistoryProvider = StateNotifierProvider.family<TransitionHistoryNotifier, TransitionHistoryState, String>((ref, instanceId) {
  final repository = ref.watch(workflowRepositoryProvider);
  return TransitionHistoryNotifier(repository, instanceId);
});

// Workflow configurations provider
final workflowConfigurationsProvider = FutureProvider.family<List<WorkflowConfigurationModel>, String?>((ref, entityType) async {
  final repository = ref.watch(workflowRepositoryProvider);
  return repository.getWorkflowConfigurations(
    entityType: entityType,
    isActive: true,
  );
});

// Specific workflow instance provider
final workflowInstanceProvider = FutureProvider.family<WorkflowInstanceModel, String>((ref, instanceId) async {
  final repository = ref.watch(workflowRepositoryProvider);
  return repository.getWorkflowInstance(instanceId);
});

// Workflow dashboard provider
final workflowDashboardProvider = FutureProvider.family<WorkflowDashboardModel, Map<String, dynamic>?>((ref, params) async {
  final repository = ref.watch(workflowRepositoryProvider);
  return repository.getWorkflowDashboard(
    workflowConfigId: params?['workflowConfigId'],
    startDate: params?['startDate'],
    endDate: params?['endDate'],
  );
});

// Available transitions provider
final availableTransitionsProvider = FutureProvider.family<List<WorkflowTransitionModel>, String>((ref, instanceId) async {
  final repository = ref.watch(workflowRepositoryProvider);
  return repository.getAvailableTransitions(instanceId);
});