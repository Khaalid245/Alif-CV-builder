import '../data/models/workflow_models.dart';

/// Repository interface for Workflow Control System operations
/// Defines all operations for workflow management, state transitions, and history
abstract class WorkflowRepository {
  /// Get workflow instance for a specific CV
  Future<WorkflowInstanceModel?> getCVWorkflow(String cvId);

  /// Get workflow instance by ID
  Future<WorkflowInstanceModel> getWorkflowInstance(String instanceId);

  /// Get all workflow instances with pagination
  Future<List<WorkflowInstanceModel>> getWorkflowInstances({
    int page = 1,
    int pageSize = 20,
    String? status,
    String? workflowConfigId,
  });

  /// Perform a workflow transition
  Future<WorkflowInstanceModel> performTransition(
    String instanceId,
    WorkflowTransitionRequest request,
  );

  /// Get available transitions for a workflow instance
  Future<List<WorkflowTransitionModel>> getAvailableTransitions(String instanceId);

  /// Get transition history for a workflow instance
  Future<List<WorkflowTransitionLogModel>> getTransitionHistory(
    String instanceId, {
    int page = 1,
    int pageSize = 50,
  });

  /// Get workflow configurations
  Future<List<WorkflowConfigurationModel>> getWorkflowConfigurations({
    String? entityType,
    bool? isActive,
  });

  /// Get workflow configuration by ID
  Future<WorkflowConfigurationModel> getWorkflowConfiguration(String configId);

  /// Get workflow dashboard data
  Future<WorkflowDashboardModel> getWorkflowDashboard({
    String? workflowConfigId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Create a new workflow instance
  Future<WorkflowInstanceModel> createWorkflowInstance({
    required String workflowConfigId,
    required String contentType,
    required String objectId,
    Map<String, dynamic>? properties,
  });

  /// Update workflow instance properties
  Future<WorkflowInstanceModel> updateWorkflowInstance(
    String instanceId,
    Map<String, dynamic> properties,
  );
}