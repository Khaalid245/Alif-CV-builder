class CVVersionModel {
  final String id;
  final int versionNumber;
  final String changeType;
  final String changeSummary;
  final Map<String, dynamic> cvData;
  final String? changedBy;
  final DateTime changedAt;
  final String? ipAddress;
  final int dataSize;
  final List<String> fieldsChanged;
  final String? previousVersionId;

  const CVVersionModel({
    required this.id,
    required this.versionNumber,
    required this.changeType,
    required this.changeSummary,
    required this.cvData,
    this.changedBy,
    required this.changedAt,
    this.ipAddress,
    required this.dataSize,
    required this.fieldsChanged,
    this.previousVersionId,
  });

  factory CVVersionModel.fromJson(Map<String, dynamic> json) {
    return CVVersionModel(
      id: json['id'] ?? '',
      versionNumber: json['version_number'] ?? 0,
      changeType: json['change_type'] ?? '',
      changeSummary: json['change_summary'] ?? '',
      cvData: json['cv_data'] ?? {},
      changedBy: json['changed_by']?['full_name'],
      changedAt: DateTime.parse(json['changed_at'] ?? DateTime.now().toIso8601String()),
      ipAddress: json['ip_address'],
      dataSize: json['data_size'] ?? 0,
      fieldsChanged: List<String>.from(json['fields_changed'] ?? []),
      previousVersionId: json['previous_version']?['id'],
    );
  }
}

class VersionDiffModel {
  final String id;
  final String diffType;
  final String fieldPath;
  final dynamic oldValue;
  final dynamic newValue;
  final DateTime createdAt;

  const VersionDiffModel({
    required this.id,
    required this.diffType,
    required this.fieldPath,
    this.oldValue,
    this.newValue,
    required this.createdAt,
  });

  factory VersionDiffModel.fromJson(Map<String, dynamic> json) {
    return VersionDiffModel(
      id: json['id'] ?? '',
      diffType: json['diff_type'] ?? '',
      fieldPath: json['field_path'] ?? '',
      oldValue: json['old_value'],
      newValue: json['new_value'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class VersionComparisonModel {
  final CVVersionModel fromVersion;
  final CVVersionModel toVersion;
  final List<VersionDiffModel> differences;
  final Map<String, dynamic> summary;

  const VersionComparisonModel({
    required this.fromVersion,
    required this.toVersion,
    required this.differences,
    required this.summary,
  });

  factory VersionComparisonModel.fromJson(Map<String, dynamic> json) {
    return VersionComparisonModel(
      fromVersion: CVVersionModel.fromJson(json['from_version'] ?? {}),
      toVersion: CVVersionModel.fromJson(json['to_version'] ?? {}),
      differences: (json['differences'] as List<dynamic>?)
          ?.map((d) => VersionDiffModel.fromJson(d))
          .toList() ?? [],
      summary: json['summary'] ?? {},
    );
  }
}

class VersionStatsModel {
  final int totalVersions;
  final int oldestVersion;
  final int newestVersion;
  final double totalSizeMb;
  final Map<String, int> changeTypes;
  final List<CVVersionModel> recentActivity;

  const VersionStatsModel({
    required this.totalVersions,
    required this.oldestVersion,
    required this.newestVersion,
    required this.totalSizeMb,
    required this.changeTypes,
    required this.recentActivity,
  });

  factory VersionStatsModel.fromJson(Map<String, dynamic> json) {
    return VersionStatsModel(
      totalVersions: json['total_versions'] ?? 0,
      oldestVersion: json['oldest_version'] ?? 0,
      newestVersion: json['newest_version'] ?? 0,
      totalSizeMb: (json['total_size_mb'] ?? 0.0).toDouble(),
      changeTypes: Map<String, int>.from(json['change_types'] ?? {}),
      recentActivity: (json['recent_activity'] as List<dynamic>?)
          ?.map((v) => CVVersionModel.fromJson(v))
          .toList() ?? [],
    );
  }
}