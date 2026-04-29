import '../data/models/admin_models.dart';

abstract class AdminRepository {
  // Platform statistics
  Future<PlatformStatsModel> getStats();
  Future<List<TemplateStatsModel>> getTemplateStats();
  Future<List<Map<String, dynamic>>> getGrowthData(String period);

  // Student management
  Future<PaginatedResponse<AdminStudentModel>> getStudents({
    int page = 1,
    String? search,
    String? status,
    String? ordering,
  });
  
  Future<AdminStudentDetailModel> getStudentDetail(String id);
  
  Future<void> updateStudentStatus(
    String id,
    String status,
    String? reason,
  );
  
  Future<void> processDeletion(String id);

  // CV management
  Future<PaginatedResponse<AdminCVModel>> getGeneratedCVs({
    int page = 1,
    String? template,
    String? ordering,
  });
  
  Future<Map<String, int>> getCVSectionFillRates();

  // Audit logs
  Future<PaginatedResponse<AuditLogModel>> getAuditLogs({
    int page = 1,
    String? action,
    String? fromDate,
    String? toDate,
    bool securityOnly = false,
  });
}