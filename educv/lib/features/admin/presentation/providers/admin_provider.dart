import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/models/admin_models.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../domain/admin_repository.dart';

// Repository provider
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AdminRepositoryImpl(apiClient);
});

// Platform stats provider
final platformStatsProvider = AsyncNotifierProvider<StatsNotifier, PlatformStatsModel?>(() {
  return StatsNotifier();
});

class StatsNotifier extends AsyncNotifier<PlatformStatsModel?> {
  @override
  Future<PlatformStatsModel?> build() async {
    return null;
  }

  Future<void> fetch() async {
    state = const AsyncLoading();
    
    try {
      final repository = ref.read(adminRepositoryProvider);
      final stats = await repository.getStats();
      state = AsyncData(stats);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await fetch();
  }
}

// Template stats provider
final templateStatsProvider = AsyncNotifierProvider<TemplateStatsNotifier, List<TemplateStatsModel>>(() {
  return TemplateStatsNotifier();
});

class TemplateStatsNotifier extends AsyncNotifier<List<TemplateStatsModel>> {
  @override
  Future<List<TemplateStatsModel>> build() async {
    return [];
  }

  Future<void> fetch() async {
    state = const AsyncLoading();
    
    try {
      final repository = ref.read(adminRepositoryProvider);
      final stats = await repository.getTemplateStats();
      state = AsyncData(stats);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

// Admin students provider
final adminStudentsProvider = AsyncNotifierProvider<StudentsNotifier, PaginatedResponse<AdminStudentModel>?>(() {
  return StudentsNotifier();
});

class StudentsNotifier extends AsyncNotifier<PaginatedResponse<AdminStudentModel>?> {
  String? _currentSearch;
  String? _currentStatus;
  String? _currentOrdering;

  @override
  Future<PaginatedResponse<AdminStudentModel>?> build() async {
    return null;
  }

  Future<void> fetch({
    String? search,
    String? status,
    String? ordering,
  }) async {
    _currentSearch = search;
    _currentStatus = status;
    _currentOrdering = ordering;
    
    state = const AsyncLoading();
    
    try {
      final repository = ref.read(adminRepositoryProvider);
      final response = await repository.getStudents(
        search: search,
        status: status,
        ordering: ordering,
      );
      state = AsyncData(response);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasMore) return;

    try {
      final repository = ref.read(adminRepositoryProvider);
      final nextPage = await repository.getStudents(
        page: currentState.currentPage + 1,
        search: _currentSearch,
        status: _currentStatus,
        ordering: _currentOrdering,
      );

      final updatedResults = [...currentState.results, ...nextPage.results];
      final updatedResponse = PaginatedResponse<AdminStudentModel>(
        count: nextPage.count,
        totalPages: nextPage.totalPages,
        currentPage: nextPage.currentPage,
        next: nextPage.next,
        previous: nextPage.previous,
        results: updatedResults,
      );

      state = AsyncData(updatedResponse);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await fetch(
      search: _currentSearch,
      status: _currentStatus,
      ordering: _currentOrdering,
    );
  }
}

// Student detail provider
final studentDetailProvider = AsyncNotifierProvider.family<StudentDetailNotifier, AdminStudentDetailModel?, String>(() {
  return StudentDetailNotifier();
});

class StudentDetailNotifier extends FamilyAsyncNotifier<AdminStudentDetailModel?, String> {
  @override
  Future<AdminStudentDetailModel?> build(String arg) async {
    return null;
  }

  Future<void> fetch(String id) async {
    state = const AsyncLoading();
    
    try {
      final repository = ref.read(adminRepositoryProvider);
      final student = await repository.getStudentDetail(id);
      state = AsyncData(student);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> updateStatus(String id, String status, String? reason) async {
    try {
      final repository = ref.read(adminRepositoryProvider);
      await repository.updateStudentStatus(id, status, reason);
      await fetch(id); // Refresh data
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> processDeletion(String id) async {
    try {
      final repository = ref.read(adminRepositoryProvider);
      await repository.processDeletion(id);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

// Admin CVs provider
final adminCVsProvider = AsyncNotifierProvider<AdminCVsNotifier, PaginatedResponse<AdminCVModel>?>(() {
  return AdminCVsNotifier();
});

class AdminCVsNotifier extends AsyncNotifier<PaginatedResponse<AdminCVModel>?> {
  String? _currentTemplate;
  String? _currentOrdering;

  @override
  Future<PaginatedResponse<AdminCVModel>?> build() async {
    return null;
  }

  Future<void> fetch({
    String? template,
    String? ordering,
  }) async {
    _currentTemplate = template;
    _currentOrdering = ordering;
    
    state = const AsyncLoading();
    
    try {
      final repository = ref.read(adminRepositoryProvider);
      final response = await repository.getGeneratedCVs(
        template: template,
        ordering: ordering,
      );
      state = AsyncData(response);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasMore) return;

    try {
      final repository = ref.read(adminRepositoryProvider);
      final nextPage = await repository.getGeneratedCVs(
        page: currentState.currentPage + 1,
        template: _currentTemplate,
        ordering: _currentOrdering,
      );

      final updatedResults = [...currentState.results, ...nextPage.results];
      final updatedResponse = PaginatedResponse<AdminCVModel>(
        count: nextPage.count,
        totalPages: nextPage.totalPages,
        currentPage: nextPage.currentPage,
        next: nextPage.next,
        previous: nextPage.previous,
        results: updatedResults,
      );

      state = AsyncData(updatedResponse);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

// CV section fill rates provider
final cvSectionFillRatesProvider = AsyncNotifierProvider<CVSectionFillRatesNotifier, Map<String, int>>(() {
  return CVSectionFillRatesNotifier();
});

class CVSectionFillRatesNotifier extends AsyncNotifier<Map<String, int>> {
  @override
  Future<Map<String, int>> build() async {
    return {};
  }

  Future<void> fetch() async {
    state = const AsyncLoading();
    
    try {
      final repository = ref.read(adminRepositoryProvider);
      final fillRates = await repository.getCVSectionFillRates();
      state = AsyncData(fillRates);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

// Audit logs provider
final auditLogsProvider = AsyncNotifierProvider<AuditLogsNotifier, PaginatedResponse<AuditLogModel>?>(() {
  return AuditLogsNotifier();
});

class AuditLogsNotifier extends AsyncNotifier<PaginatedResponse<AuditLogModel>?> {
  String? _currentAction;
  String? _currentFromDate;
  String? _currentToDate;
  bool _securityOnly = false;

  @override
  Future<PaginatedResponse<AuditLogModel>?> build() async {
    return null;
  }

  Future<void> fetch({
    String? action,
    String? fromDate,
    String? toDate,
    bool securityOnly = false,
  }) async {
    _currentAction = action;
    _currentFromDate = fromDate;
    _currentToDate = toDate;
    _securityOnly = securityOnly;
    
    state = const AsyncLoading();
    
    try {
      final repository = ref.read(adminRepositoryProvider);
      final response = await repository.getAuditLogs(
        action: action,
        fromDate: fromDate,
        toDate: toDate,
        securityOnly: securityOnly,
      );
      state = AsyncData(response);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasMore) return;

    try {
      final repository = ref.read(adminRepositoryProvider);
      final nextPage = await repository.getAuditLogs(
        page: currentState.currentPage + 1,
        action: _currentAction,
        fromDate: _currentFromDate,
        toDate: _currentToDate,
        securityOnly: _securityOnly,
      );

      final updatedResults = [...currentState.results, ...nextPage.results];
      final updatedResponse = PaginatedResponse<AuditLogModel>(
        count: nextPage.count,
        totalPages: nextPage.totalPages,
        currentPage: nextPage.currentPage,
        next: nextPage.next,
        previous: nextPage.previous,
        results: updatedResults,
      );

      state = AsyncData(updatedResponse);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  void resetFilters() {
    _currentAction = null;
    _currentFromDate = null;
    _currentToDate = null;
    _securityOnly = false;
  }
}

// Admin tab provider
final adminTabProvider = StateProvider<int>((ref) => 0);