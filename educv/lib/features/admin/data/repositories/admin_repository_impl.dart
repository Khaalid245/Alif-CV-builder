import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/admin_repository.dart';
import '../models/admin_models.dart';

class AdminRepositoryImpl implements AdminRepository {
  final ApiClient _apiClient;

  AdminRepositoryImpl(this._apiClient);

  @override
  Future<PlatformStatsModel> getStats() async {
    final response = await _apiClient.get(ApiConstants.adminStatsOverview);
    final apiResponse = ApiResponse<PlatformStatsModel>.fromJson(
      response.data,
      (data) => PlatformStatsModel.fromJson(data as Map<String, dynamic>),
    );
    if (!apiResponse.success) {
      throw Exception(apiResponse.error?.message ?? 'Failed to get platform stats');
    }
    return apiResponse.data!;
  }

  @override
  Future<List<TemplateStatsModel>> getTemplateStats() async {
    final response = await _apiClient.get(ApiConstants.adminStatsTemplates);
    final apiResponse = ApiResponse<List<TemplateStatsModel>>.fromJson(
      response.data,
      (data) => (data as List)
          .map((e) => TemplateStatsModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    if (!apiResponse.success) {
      throw Exception(apiResponse.error?.message ?? 'Failed to get template stats');
    }
    return apiResponse.data ?? [];
  }

  @override
  Future<List<Map<String, dynamic>>> getGrowthData(String period) async {
    final response = await _apiClient.get(
      ApiConstants.adminStatsGrowth,
      queryParameters: {'period': period},
    );
    final apiResponse = ApiResponse<List<Map<String, dynamic>>>.fromJson(
      response.data,
      (data) => List<Map<String, dynamic>>.from(data as List),
    );
    if (!apiResponse.success) {
      throw Exception(apiResponse.error?.message ?? 'Failed to get growth data');
    }
    return apiResponse.data ?? [];
  }

  @override
  Future<PaginatedResponse<AdminStudentModel>> getStudents({
    int page = 1,
    String? search,
    String? status,
    String? ordering,
  }) async {
    final queryParams = <String, dynamic>{'page': page};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (status != null && status != 'all') queryParams['status'] = status;
    if (ordering != null) queryParams['ordering'] = ordering;

    final response = await _apiClient.get(
      ApiConstants.adminStudents,
      queryParameters: queryParams,
    );
    final apiResponse = ApiResponse<PaginatedResponse<AdminStudentModel>>.fromJson(
      response.data,
      (data) => PaginatedResponse.fromJson(
        data as Map<String, dynamic>,
        (item) => AdminStudentModel.fromJson(item as Map<String, dynamic>),
      ),
    );
    if (!apiResponse.success) {
      throw Exception(apiResponse.error?.message ?? 'Failed to get students');
    }
    return apiResponse.data!;
  }

  @override
  Future<AdminStudentDetailModel> getStudentDetail(String id) async {
    final response = await _apiClient.get('${ApiConstants.adminStudents}$id/');
    final apiResponse = ApiResponse<AdminStudentDetailModel>.fromJson(
      response.data,
      (data) => AdminStudentDetailModel.fromJson(data as Map<String, dynamic>),
    );
    if (!apiResponse.success) {
      throw Exception(apiResponse.error?.message ?? 'Failed to get student detail');
    }
    return apiResponse.data!;
  }

  @override
  Future<void> updateStudentStatus(String id, String status, String? reason) async {
    final body = <String, dynamic>{'status': status};
    if (reason != null && reason.isNotEmpty) body['reason'] = reason;

    final response = await _apiClient.patch(
      '${ApiConstants.adminStudents}$id/status/',
      data: body,
    );
    final apiResponse = ApiResponse<void>.fromJson(response.data, (_) {});
    if (!apiResponse.success) {
      throw Exception(apiResponse.error?.message ?? 'Failed to update student status');
    }
  }

  @override
  Future<void> processDeletion(String id) async {
    final response = await _apiClient.post(
      '${ApiConstants.adminStudents}$id/process-deletion/',
    );
    final apiResponse = ApiResponse<void>.fromJson(response.data, (_) {});
    if (!apiResponse.success) {
      throw Exception(apiResponse.error?.message ?? 'Failed to process deletion');
    }
  }

  @override
  Future<PaginatedResponse<AdminCVModel>> getGeneratedCVs({
    int page = 1,
    String? template,
    String? ordering,
  }) async {
    final queryParams = <String, dynamic>{'page': page};
    if (template != null && template != 'all') queryParams['template'] = template;
    if (ordering != null) queryParams['ordering'] = ordering;

    final response = await _apiClient.get(
      ApiConstants.adminGeneratedCVs,
      queryParameters: queryParams,
    );
    final apiResponse = ApiResponse<PaginatedResponse<AdminCVModel>>.fromJson(
      response.data,
      (data) => PaginatedResponse.fromJson(
        data as Map<String, dynamic>,
        (item) => AdminCVModel.fromJson(item as Map<String, dynamic>),
      ),
    );
    if (!apiResponse.success) {
      throw Exception(apiResponse.error?.message ?? 'Failed to get generated CVs');
    }
    return apiResponse.data!;
  }

  @override
  Future<Map<String, int>> getCVSectionFillRates() async {
    final response = await _apiClient.get(ApiConstants.adminCVSectionFillRates);
    final apiResponse = ApiResponse<Map<String, int>>.fromJson(
      response.data,
      (data) => Map<String, int>.from(data as Map),
    );
    if (!apiResponse.success) {
      throw Exception(apiResponse.error?.message ?? 'Failed to get section fill rates');
    }
    return apiResponse.data ?? {};
  }

  @override
  Future<PaginatedResponse<AuditLogModel>> getAuditLogs({
    int page = 1,
    String? action,
    String? fromDate,
    String? toDate,
    bool securityOnly = false,
  }) async {
    final queryParams = <String, dynamic>{'page': page};
    if (action != null && action != 'all') queryParams['action'] = action;
    if (fromDate != null) queryParams['from_date'] = fromDate;
    if (toDate != null) queryParams['to_date'] = toDate;

    final endpoint = securityOnly
        ? ApiConstants.adminAuditLogsSecurity
        : ApiConstants.adminAuditLogs;

    final response = await _apiClient.get(endpoint, queryParameters: queryParams);
    final apiResponse = ApiResponse<PaginatedResponse<AuditLogModel>>.fromJson(
      response.data,
      (data) => PaginatedResponse.fromJson(
        data as Map<String, dynamic>,
        (item) => AuditLogModel.fromJson(item as Map<String, dynamic>),
      ),
    );
    if (!apiResponse.success) {
      throw Exception(apiResponse.error?.message ?? 'Failed to get audit logs');
    }
    return apiResponse.data!;
  }
}
