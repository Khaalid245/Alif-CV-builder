import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/admin_repository.dart';
import '../models/admin_models.dart';

class AdminRepositoryImpl implements AdminRepository {
  final ApiClient _apiClient;

  AdminRepositoryImpl(this._apiClient);

  @override
  Future<PlatformStatsModel> getStats() async {
    final response = await _apiClient.get('/admin/stats/');
    final apiResponse = ApiResponse.fromJson(response.data, null);
    
    if (!apiResponse.success) {
      throw Exception(apiResponse.error?.message ?? 'Failed to get platform stats');
    }
    
    return PlatformStatsModel.fromJson(apiResponse.data as Map<String, dynamic>);
  }

  @override
  Future<List<TemplateStatsModel>> getTemplateStats() async {
    final response = await _apiClient.get('/admin/template-stats/');
    final apiResponse = ApiResponse.fromJson(response.data, null);
    
    if (!apiResponse.success) {
      throw Exception(apiResponse.error?.message ?? 'Failed to get template stats');
    }
    
    final List<dynamic> templatesData = (apiResponse.data as Map<String, dynamic>)['templates'] ?? [];
    return templatesData
        .map((template) => TemplateStatsModel.fromJson(template as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getGrowthData(String period) async {
    final response = await _apiClient.get('/admin/growth-data/', queryParameters: {
      'period': period,
    });
    final apiResponse = ApiResponse.fromJson(response.data, null);
    
    if (!apiResponse.success) {
      throw Exception(apiResponse.error?.message ?? 'Failed to get growth data');
    }
    
    return List<Map<String, dynamic>>.from((apiResponse.data as Map<String, dynamic>)['data'] ?? []);
  }

  @override
  Future<PaginatedResponse<AdminStudentModel>> getStudents({
    int page = 1,
    String? search,
    String? status,
    String? ordering,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
    };
    
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (status != null && status != 'all') {
      queryParams['status'] = status;
    }
    if (ordering != null) {
      queryParams['ordering'] = ordering;
    }

    final response = await _apiClient.get('/admin/students/', queryParameters: queryParams);
    final apiResponse = ApiResponse.fromJson(response.data, null);
    
    if (!apiResponse.success) {
      throw Exception(apiResponse.error?.message ?? 'Failed to get students');
    }
    
    return PaginatedResponse.fromJson(
      apiResponse.data as Map<String, dynamic>,
      (json) => AdminStudentModel.fromJson(json),
    );
  }

  @override
  Future<AdminStudentDetailModel> getStudentDetail(String id) async {
    final response = await _apiClient.get('/admin/students/$id/');
    final apiResponse = ApiResponse.fromJson(response.data, null);
    
    if (!apiResponse.success) {
      throw Exception(apiResponse.error?.message ?? 'Failed to get student detail');
    }
    
    return AdminStudentDetailModel.fromJson(apiResponse.data as Map<String, dynamic>);
  }

  @override
  Future<void> updateStudentStatus(String id, String status, String? reason) async {
    final body = <String, dynamic>{
      'status': status,
    };
    
    if (reason != null && reason.isNotEmpty) {
      body['reason'] = reason;
    }

    final response = await _apiClient.patch('/admin/students/$id/status/', data: body);
    final apiResponse = ApiResponse.fromJson(response.data, null);
    
    if (!apiResponse.success) {
      throw Exception(apiResponse.error?.message ?? 'Failed to update student status');
    }
  }

  @override
  Future<void> processDeletion(String id) async {
    final response = await _apiClient.post('/admin/students/$id/process-deletion/');
    final apiResponse = ApiResponse.fromJson(response.data, null);
    
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
    final queryParams = <String, dynamic>{
      'page': page,
    };
    
    if (template != null && template != 'all') {
      queryParams['template'] = template;
    }
    if (ordering != null) {
      queryParams['ordering'] = ordering;
    }

    final response = await _apiClient.get('/admin/generated-cvs/', queryParameters: queryParams);
    final apiResponse = ApiResponse.fromJson(response.data, null);
    
    if (!apiResponse.success) {
      throw Exception(apiResponse.error?.message ?? 'Failed to get generated CVs');
    }
    
    return PaginatedResponse.fromJson(
      apiResponse.data as Map<String, dynamic>,
      (json) => AdminCVModel.fromJson(json),
    );
  }

  @override
  Future<Map<String, int>> getCVSectionFillRates() async {
    final response = await _apiClient.get('/admin/cv-section-fill-rates/');
    final apiResponse = ApiResponse.fromJson(response.data, null);
    
    if (!apiResponse.success) {
      throw Exception(apiResponse.error?.message ?? 'Failed to get section fill rates');
    }
    
    return Map<String, int>.from((apiResponse.data as Map<String, dynamic>)['fill_rates'] ?? {});
  }

  @override
  Future<PaginatedResponse<AuditLogModel>> getAuditLogs({
    int page = 1,
    String? action,
    String? fromDate,
    String? toDate,
    bool securityOnly = false,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
    };
    
    if (action != null && action != 'all') {
      queryParams['action'] = action;
    }
    if (fromDate != null) {
      queryParams['from_date'] = fromDate;
    }
    if (toDate != null) {
      queryParams['to_date'] = toDate;
    }
    if (securityOnly) {
      queryParams['security_only'] = true;
    }

    final response = await _apiClient.get('/admin/audit-logs/', queryParameters: queryParams);
    final apiResponse = ApiResponse.fromJson(response.data, null);
    
    if (!apiResponse.success) {
      throw Exception(apiResponse.error?.message ?? 'Failed to get audit logs');
    }
    
    return PaginatedResponse.fromJson(
      apiResponse.data as Map<String, dynamic>,
      (json) => AuditLogModel.fromJson(json),
    );
  }
}