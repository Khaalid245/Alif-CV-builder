import '../models/version_models.dart';

abstract class VersionHistoryRepository {
  Future<List<CVVersionModel>> getVersionHistory();
  Future<CVVersionModel> getVersion(String versionId);
  Future<VersionComparisonModel> compareVersions(int fromVersion, int toVersion);
  Future<CVVersionModel> restoreVersion(int versionNumber);
  Future<VersionStatsModel> getVersionStats();
}