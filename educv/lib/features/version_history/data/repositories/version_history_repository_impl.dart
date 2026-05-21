import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/version_history_repository.dart';
import '../models/version_models.dart';

class VersionHistoryRepositoryImpl implements VersionHistoryRepository {
  final ApiClient _apiClient;

  VersionHistoryRepositoryImpl(this._apiClient);

  @override
  Future<List<CVVersionModel>> getVersionHistory() async {
    final response = await _apiClient.get('/api/v1/version-history/versions/');
    
    if (response.success && response.data != null) {
      final List<dynamic> results = response.data['results'] ?? [];
      return results.map((json) => CVVersionModel.fromJson(json)).toList();
    }
    
    throw Exception(response.error?.message ?? 'Failed to fetch version history');
  }

  @override
  Future<CVVersionModel> getVersion(String versionId) async {
    final response = await _apiClient.get('/api/v1/version-history/versions/$versionId/');
    
    if (response.success && response.data != null) {
      return CVVersionModel.fromJson(response.data);
    }
    
    throw Exception(response.error?.message ?? 'Failed to fetch version');
  }

  @override
  Future<VersionComparisonModel> compareVersions(int fromVersion, int toVersion) async {
    final response = await _apiClient.post(
      '/api/v1/version-history/versions/compare/',
      data: {
        'from_version': fromVersion,
        'to_version': toVersion,
      },
    );
    
    if (response.success && response.data != null) {
      return VersionComparisonModel.fromJson(response.data);
    }
    
    throw Exception(response.error?.message ?? 'Failed to compare versions');
  }

  @override
  Future<CVVersionModel> restoreVersion(int versionNumber) async {
    final response = await _apiClient.post(
      '/api/v1/version-history/versions/$versionNumber/restore/',
      data: {},
    );
    
    if (response.success && response.data != null) {
      return CVVersionModel.fromJson(response.data);
    }
    
    throw Exception(response.error?.message ?? 'Failed to restore version');
  }

  @override
  Future<VersionStatsModel> getVersionStats() async {
    final response = await _apiClient.get('/api/v1/version-history/versions/stats/');
    
    if (response.success && response.data != null) {
      return VersionStatsModel.fromJson(response.data);
    }
    
    throw Exception(response.error?.message ?? 'Failed to fetch version statistics');
  }
}