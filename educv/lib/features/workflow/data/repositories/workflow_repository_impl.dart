import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../domain/workflow_repository.dart';
import '../models/workflow_models.dart';

class WorkflowRepositoryImpl implements WorkflowRepository {
  final ApiClient _apiClient;

  WorkflowRepositoryImpl(this._apiClient);

  @override
  Future<WorkflowInstanceModel?> getCVWorkflow(String cvId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.workflowCV(cvId),
      );

      final apiResponse = ApiResponse.fromJson(response.data!, null);
      if (!apiResponse.success) {
        // Return null if no workflow found instead of throwing
        if (response.statusCode == 404) {
          return null;
        }
        throw AppException(
          message: apiResponse.message ?? 'Failed to get CV workflow',
        );
      }

      return WorkflowInstanceModel.fromJson(apiResponse.data ?? {});
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw AppException(message: 'Network error: ${e.message}');
    } catch (e) {
      throw AppException(
        message: 'Failed to get CV workflow: ${e.toString()}',
      );
    }
  }

  @override
  Future<WorkflowInstanceModel> getWorkflowInstance(String instanceId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.workflowInstances}$instanceId/',
      );

      final apiResponse = ApiResponse.fromJson(response.data!, null);
      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.message ?? 'Workflow instance not found',
        );
      }

      return WorkflowInstanceModel.fromJson(apiResponse.data ?? {});
    } on DioException catch (e) {
      throw AppException(message: 'Network error: ${e.message}');
    } catch (e) {
      throw AppException(
        message: 'Failed to get workflow instance: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<WorkflowInstanceModel>> getWorkflowInstances({
    int page = 1,
    int pageSize = 20,
    String? status,
    String? workflowConfigId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      
      if (status != null) queryParams['status'] = status;
      if (workflowConfigId != null) queryParams['workflow_config'] = workflowConfigId;

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.workflowInstances,
        queryParameters: queryParams,
      );

      final apiResponse = ApiResponse.fromJson(response.data!, null);
      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.message ?? 'Failed to get workflow instances',
        );
      }

      final List<dynamic> instancesData = apiResponse.data['results'] ?? [];
      return instancesData
          .map((item) => WorkflowInstanceModel.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
    } on DioException catch (e) {
      throw AppException(message: 'Network error: ${e.message}');
    } catch (e) {
      throw AppException(
        message: 'Failed to get workflow instances: ${e.toString()}',
      );
    }
  }

  @override
  Future<WorkflowInstanceModel> performTransition(
    String instanceId,
    WorkflowTransitionRequest request,
  ) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.workflowTransition(instanceId),
        data: request.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(response.data!, null);
      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.message ?? 'Failed to perform transition',
        );
      }

      return WorkflowInstanceModel.fromJson(apiResponse.data ?? {});
    } on DioException catch (e) {
      throw AppException(message: 'Network error: ${e.message}');
    } catch (e) {
      throw AppException(
        message: 'Failed to perform transition: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<WorkflowTransitionModel>> getAvailableTransitions(String instanceId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.workflowInstances}$instanceId/available-transitions/',
      );

      final apiResponse = ApiResponse.fromJson(response.data!, null);
      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.message ?? 'Failed to get available transitions',
        );
      }

      final List<dynamic> transitionsData = apiResponse.data['transitions'] ?? [];
      return transitionsData
          .map((item) => WorkflowTransitionModel.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
    } on DioException catch (e) {
      throw AppException(message: 'Network error: ${e.message}');
    } catch (e) {
      throw AppException(
        message: 'Failed to get available transitions: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<WorkflowTransitionLogModel>> getTransitionHistory(
    String instanceId, {
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.workflowInstances}$instanceId/history/',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
        },
      );

      final apiResponse = ApiResponse.fromJson(response.data!, null);
      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.message ?? 'Failed to get transition history',
        );
      }

      final List<dynamic> historyData = apiResponse.data['results'] ?? [];
      return historyData
          .map((item) => WorkflowTransitionLogModel.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
    } on DioException catch (e) {
      throw AppException(message: 'Network error: ${e.message}');
    } catch (e) {
      throw AppException(
        message: 'Failed to get transition history: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<WorkflowConfigurationModel>> getWorkflowConfigurations({
    String? entityType,
    bool? isActive,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (entityType != null) queryParams['entity_type'] = entityType;
      if (isActive != null) queryParams['is_active'] = isActive;

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.workflowConfigurations,
        queryParameters: queryParams,
      );

      final apiResponse = ApiResponse.fromJson(response.data!, null);
      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.message ?? 'Failed to get workflow configurations',
        );
      }

      final List<dynamic> configsData = apiResponse.data['results'] ?? [];
      return configsData
          .map((item) => WorkflowConfigurationModel.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
    } on DioException catch (e) {
      throw AppException(message: 'Network error: ${e.message}');
    } catch (e) {
      throw AppException(
        message: 'Failed to get workflow configurations: ${e.toString()}',
      );
    }
  }

  @override
  Future<WorkflowConfigurationModel> getWorkflowConfiguration(String configId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.workflowConfigurations}$configId/',
      );

      final apiResponse = ApiResponse.fromJson(response.data!, null);
      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.message ?? 'Workflow configuration not found',
        );
      }

      return WorkflowConfigurationModel.fromJson(apiResponse.data ?? {});
    } on DioException catch (e) {
      throw AppException(message: 'Network error: ${e.message}');
    } catch (e) {
      throw AppException(
        message: 'Failed to get workflow configuration: ${e.toString()}',
      );
    }
  }

  @override
  Future<WorkflowDashboardModel> getWorkflowDashboard({
    String? workflowConfigId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (workflowConfigId != null) queryParams['workflow_config'] = workflowConfigId;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConstants.workflowDashboard,
        queryParameters: queryParams,
      );

      final apiResponse = ApiResponse.fromJson(response.data!, null);
      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.message ?? 'Failed to get workflow dashboard',
        );
      }

      return WorkflowDashboardModel.fromJson(apiResponse.data ?? {});
    } on DioException catch (e) {
      throw AppException(message: 'Network error: ${e.message}');
    } catch (e) {
      throw AppException(
        message: 'Failed to get workflow dashboard: ${e.toString()}',
      );
    }
  }

  @override
  Future<WorkflowInstanceModel> createWorkflowInstance({
    required String workflowConfigId,
    required String contentType,
    required String objectId,
    Map<String, dynamic>? properties,
  }) async {
    try {
      final data = {
        'workflow_config': workflowConfigId,
        'content_type': contentType,
        'object_id': objectId,
        if (properties != null) 'properties': properties,
      };

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConstants.workflowInstances,
        data: data,
      );

      final apiResponse = ApiResponse.fromJson(response.data!, null);
      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.message ?? 'Failed to create workflow instance',
        );
      }

      return WorkflowInstanceModel.fromJson(apiResponse.data ?? {});
    } on DioException catch (e) {
      throw AppException(message: 'Network error: ${e.message}');
    } catch (e) {
      throw AppException(
        message: 'Failed to create workflow instance: ${e.toString()}',
      );
    }
  }

  @override
  Future<WorkflowInstanceModel> updateWorkflowInstance(
    String instanceId,
    Map<String, dynamic> properties,
  ) async {
    try {
      final response = await _apiClient.patch<Map<String, dynamic>>(
        '${ApiConstants.workflowInstances}$instanceId/',
        data: {'properties': properties},
      );

      final apiResponse = ApiResponse.fromJson(response.data!, null);
      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.message ?? 'Failed to update workflow instance',
        );
      }

      return WorkflowInstanceModel.fromJson(apiResponse.data ?? {});
    } on DioException catch (e) {
      throw AppException(message: 'Network error: ${e.message}');
    } catch (e) {
      throw AppException(
        message: 'Failed to update workflow instance: ${e.toString()}',
      );
    }
  }
}