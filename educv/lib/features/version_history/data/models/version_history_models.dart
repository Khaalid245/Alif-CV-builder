/// Version History data models for EduCV
/// Production-quality models with comprehensive error handling and validation

class CVVersionModel {
  final String id;
  final int versionNumber;
  final String changeType;
  final String changeSummary;
  final Map<String, dynamic> cvData;
  final UserBasicModel changedBy;
  final DateTime changedAt;
  final String? ipAddress;
  final int dataSize;
  final double dataSizeMb;
  final List<String> fieldsChanged;
  final int? previousVersionNumber;

  const CVVersionModel({
    required this.id,
    required this.versionNumber,
    required this.changeType,
    required this.changeSummary,
    required this.cvData,
    required this.changedBy,
    required this.changedAt,
    this.ipAddress,
    required this.dataSize,
    required this.dataSizeMb,
    required this.fieldsChanged,
    this.previousVersionNumber,
  });

  factory CVVersionModel.fromJson(Map<String, dynamic> json) {
    try {
      return CVVersionModel(
        id: json['id']?.toString() ?? '',
        versionNumber: json['version_number'] ?? 0,
        changeType: json['change_type']?.toString() ?? 'update',
        changeSummary: json['change_summary']?.toString() ?? '',
        cvData: Map<String, dynamic>.from(json['cv_data'] ?? {}),
        changedBy: UserBasicModel.fromJson(
          Map<String, dynamic>.from(json['changed_by'] ?? {}),
        ),
        changedAt: _parseDateTime(json['changed_at']) ?? DateTime.now(),
        ipAddress: json['ip_address']?.toString(),
        dataSize: json['data_size'] ?? 0,
        dataSizeMb: _parseDouble(json['data_size_mb']) ?? 0.0,
        fieldsChanged: _parseStringList(json['fields_changed']),
        previousVersionNumber: json['previous_version_number'],
      );
    } catch (e) {
      throw FormatException('Failed to parse CVVersionModel: $e');
    }
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static List<String> _parseStringList(dynamic data) {
    if (data == null) return [];
    try {
      return List<String>.from(data);
    } catch (e) {
      return [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version_number': versionNumber,
      'change_type': changeType,
      'change_summary': changeSummary,
      'cv_data': cvData,
      'changed_by': changedBy.toJson(),
      'changed_at': changedAt.toIso8601String(),
      'ip_address': ipAddress,
      'data_size': dataSize,
      'data_size_mb': dataSizeMb,
      'fields_changed': fieldsChanged,
      'previous_version_number': previousVersionNumber,
    };
  }

  CVVersionModel copyWith({
    String? id,
    int? versionNumber,
    String? changeType,
    String? changeSummary,
    Map<String, dynamic>? cvData,
    UserBasicModel? changedBy,
    DateTime? changedAt,
    String? ipAddress,
    int? dataSize,
    double? dataSizeMb,
    List<String>? fieldsChanged,
    int? previousVersionNumber,
  }) {
    return CVVersionModel(
      id: id ?? this.id,
      versionNumber: versionNumber ?? this.versionNumber,
      changeType: changeType ?? this.changeType,
      changeSummary: changeSummary ?? this.changeSummary,
      cvData: cvData ?? this.cvData,
      changedBy: changedBy ?? this.changedBy,
      changedAt: changedAt ?? this.changedAt,
      ipAddress: ipAddress ?? this.ipAddress,
      dataSize: dataSize ?? this.dataSize,
      dataSizeMb: dataSizeMb ?? this.dataSizeMb,
      fieldsChanged: fieldsChanged ?? this.fieldsChanged,
      previousVersionNumber: previousVersionNumber ?? this.previousVersionNumber,
    );
  }

  // Business logic helpers
  bool get isCreate => changeType.toLowerCase() == 'create';
  bool get isUpdate => changeType.toLowerCase() == 'update';
  bool get isDelete => changeType.toLowerCase() == 'delete';
  bool get isRestore => changeType.toLowerCase() == 'restore';
  bool get isBulkUpdate => changeType.toLowerCase() == 'bulk_update';

  String get formattedSize {
    if (dataSizeMb >= 1.0) {
      return '${dataSizeMb.toStringAsFixed(2)} MB';
    } else {
      final kb = dataSize / 1024;
      return '${kb.toStringAsFixed(1)} KB';
    }
  }

  String get changeTypeDisplayName {
    switch (changeType.toLowerCase()) {
      case 'create':
        return 'Created';
      case 'update':
        return 'Updated';
      case 'delete':
        return 'Deleted';
      case 'restore':
        return 'Restored';
      case 'bulk_update':
        return 'Bulk Update';
      default:
        return changeType;
    }
  }
}

class UserBasicModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;

  const UserBasicModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  factory UserBasicModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserBasicModel(
        id: json['id']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        firstName: json['first_name']?.toString() ?? '',
        lastName: json['last_name']?.toString() ?? '',
      );
    } catch (e) {
      throw FormatException('Failed to parse UserBasicModel: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
    };
  }

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? email : name;
  }

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last'.isEmpty ? email.isNotEmpty ? email[0].toUpperCase() : '?' : '$first$last';
  }

  UserBasicModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
  }) {
    return UserBasicModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
    );
  }
}

class VersionDiffModel {
  final String id;
  final String diffType;
  final String fieldPath;
  final dynamic oldValue;
  final dynamic newValue;
  final int fromVersionNumber;
  final int toVersionNumber;
  final DateTime createdAt;

  const VersionDiffModel({
    required this.id,
    required this.diffType,
    required this.fieldPath,
    this.oldValue,
    this.newValue,
    required this.fromVersionNumber,
    required this.toVersionNumber,
    required this.createdAt,
  });

  factory VersionDiffModel.fromJson(Map<String, dynamic> json) {
    try {
      return VersionDiffModel(
        id: json['id']?.toString() ?? '',
        diffType: json['diff_type']?.toString() ?? 'field_change',
        fieldPath: json['field_path']?.toString() ?? '',
        oldValue: json['old_value'],
        newValue: json['new_value'],
        fromVersionNumber: json['from_version_number'] ?? 0,
        toVersionNumber: json['to_version_number'] ?? 0,
        createdAt: CVVersionModel._parseDateTime(json['created_at']) ?? DateTime.now(),
      );
    } catch (e) {
      throw FormatException('Failed to parse VersionDiffModel: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'diff_type': diffType,
      'field_path': fieldPath,
      'old_value': oldValue,
      'new_value': newValue,
      'from_version_number': fromVersionNumber,
      'to_version_number': toVersionNumber,
      'created_at': createdAt.toIso8601String(),
    };
  }

  VersionDiffModel copyWith({
    String? id,
    String? diffType,
    String? fieldPath,
    dynamic oldValue,
    dynamic newValue,
    int? fromVersionNumber,
    int? toVersionNumber,
    DateTime? createdAt,
  }) {
    return VersionDiffModel(
      id: id ?? this.id,
      diffType: diffType ?? this.diffType,
      fieldPath: fieldPath ?? this.fieldPath,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
      fromVersionNumber: fromVersionNumber ?? this.fromVersionNumber,
      toVersionNumber: toVersionNumber ?? this.toVersionNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Business logic helpers
  bool get isFieldChange => diffType.toLowerCase() == 'field_change';
  bool get isSectionAdd => diffType.toLowerCase() == 'section_add';
  bool get isSectionRemove => diffType.toLowerCase() == 'section_remove';
  bool get isSectionModify => diffType.toLowerCase() == 'section_modify';

  String get displayFieldName {
    // Convert field path to human-readable name
    final parts = fieldPath.split('.');
    if (parts.isEmpty) return fieldPath;
    
    final fieldName = parts.last;
    return fieldName
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String get oldValueDisplay {
    if (oldValue == null) return 'None';
    if (oldValue is String) return oldValue.isEmpty ? 'Empty' : oldValue;
    if (oldValue is List) return '${oldValue.length} items';
    if (oldValue is Map) return 'Object';
    return oldValue.toString();
  }

  String get newValueDisplay {
    if (newValue == null) return 'None';
    if (newValue is String) return newValue.isEmpty ? 'Empty' : newValue;
    if (newValue is List) return '${newValue.length} items';
    if (newValue is Map) return 'Object';
    return newValue.toString();
  }
}

class VersionComparisonModel {
  final CVVersionModel fromVersion;
  final CVVersionModel toVersion;
  final List<VersionDiffModel> differences;
  final int totalChanges;

  const VersionComparisonModel({
    required this.fromVersion,
    required this.toVersion,
    required this.differences,
    required this.totalChanges,
  });

  factory VersionComparisonModel.fromJson(Map<String, dynamic> json) {
    try {
      return VersionComparisonModel(
        fromVersion: CVVersionModel.fromJson(
          Map<String, dynamic>.from(json['from_version'] ?? {}),
        ),
        toVersion: CVVersionModel.fromJson(
          Map<String, dynamic>.from(json['to_version'] ?? {}),
        ),
        differences: _parseDifferences(json['differences']),
        totalChanges: json['total_changes'] ?? 0,
      );
    } catch (e) {
      throw FormatException('Failed to parse VersionComparisonModel: $e');
    }
  }

  static List<VersionDiffModel> _parseDifferences(dynamic data) {
    if (data == null) return [];
    try {
      final List<dynamic> diffsList = List<dynamic>.from(data);
      return diffsList
          .map((item) => VersionDiffModel.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'from_version': fromVersion.toJson(),
      'to_version': toVersion.toJson(),
      'differences': differences.map((d) => d.toJson()).toList(),
      'total_changes': totalChanges,
    };
  }

  VersionComparisonModel copyWith({
    CVVersionModel? fromVersion,
    CVVersionModel? toVersion,
    List<VersionDiffModel>? differences,
    int? totalChanges,
  }) {
    return VersionComparisonModel(
      fromVersion: fromVersion ?? this.fromVersion,
      toVersion: toVersion ?? this.toVersion,
      differences: differences ?? this.differences,
      totalChanges: totalChanges ?? this.totalChanges,
    );
  }

  // Business logic helpers
  bool get hasChanges => totalChanges > 0;
  
  List<VersionDiffModel> get fieldChanges => 
      differences.where((d) => d.isFieldChange).toList();
  
  List<VersionDiffModel> get sectionChanges => 
      differences.where((d) => d.isSectionAdd || d.isSectionRemove || d.isSectionModify).toList();

  Map<String, List<VersionDiffModel>> get changesBySection {
    final Map<String, List<VersionDiffModel>> grouped = {};
    
    for (final diff in differences) {
      final section = diff.fieldPath.split('.').first;
      grouped.putIfAbsent(section, () => []).add(diff);
    }
    
    return grouped;
  }
}

class VersionActionModel {
  final String id;
  final String actionType;
  final UserBasicModel user;
  final int? versionNumber;
  final String? ipAddress;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const VersionActionModel({
    required this.id,
    required this.actionType,
    required this.user,
    this.versionNumber,
    this.ipAddress,
    required this.metadata,
    required this.createdAt,
  });

  factory VersionActionModel.fromJson(Map<String, dynamic> json) {
    try {
      return VersionActionModel(
        id: json['id']?.toString() ?? '',
        actionType: json['action_type']?.toString() ?? '',
        user: UserBasicModel.fromJson(
          Map<String, dynamic>.from(json['user'] ?? {}),
        ),
        versionNumber: json['version_number'],
        ipAddress: json['ip_address']?.toString(),
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
        createdAt: CVVersionModel._parseDateTime(json['created_at']) ?? DateTime.now(),
      );
    } catch (e) {
      throw FormatException('Failed to parse VersionActionModel: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action_type': actionType,
      'user': user.toJson(),
      'version_number': versionNumber,
      'ip_address': ipAddress,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  VersionActionModel copyWith({
    String? id,
    String? actionType,
    UserBasicModel? user,
    int? versionNumber,
    String? ipAddress,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return VersionActionModel(
      id: id ?? this.id,
      actionType: actionType ?? this.actionType,
      user: user ?? this.user,
      versionNumber: versionNumber ?? this.versionNumber,
      ipAddress: ipAddress ?? this.ipAddress,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Business logic helpers
  String get actionDisplayName {
    switch (actionType.toLowerCase()) {
      case 'view_version':
        return 'Viewed Version';
      case 'view_history':
        return 'Viewed History';
      case 'restore_version':
        return 'Restored Version';
      case 'compare_versions':
        return 'Compared Versions';
      case 'delete_version':
        return 'Deleted Version';
      default:
        return actionType;
    }
  }
}

class VersionHistoryStatsModel {
  final int totalVersions;
  final int oldestVersion;
  final int newestVersion;
  final double totalSizeMb;
  final Map<String, int> changeTypes;
  final List<VersionActionModel> recentActivity;

  const VersionHistoryStatsModel({
    required this.totalVersions,
    required this.oldestVersion,
    required this.newestVersion,
    required this.totalSizeMb,
    required this.changeTypes,
    required this.recentActivity,
  });

  factory VersionHistoryStatsModel.fromJson(Map<String, dynamic> json) {
    try {
      return VersionHistoryStatsModel(
        totalVersions: json['total_versions'] ?? 0,
        oldestVersion: json['oldest_version'] ?? 0,
        newestVersion: json['newest_version'] ?? 0,
        totalSizeMb: CVVersionModel._parseDouble(json['total_size_mb']) ?? 0.0,
        changeTypes: Map<String, int>.from(json['change_types'] ?? {}),
        recentActivity: _parseRecentActivity(json['recent_activity']),
      );
    } catch (e) {
      throw FormatException('Failed to parse VersionHistoryStatsModel: $e');
    }
  }

  static List<VersionActionModel> _parseRecentActivity(dynamic data) {
    if (data == null) return [];
    try {
      final List<dynamic> activityList = List<dynamic>.from(data);
      return activityList
          .map((item) => VersionActionModel.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'total_versions': totalVersions,
      'oldest_version': oldestVersion,
      'newest_version': newestVersion,
      'total_size_mb': totalSizeMb,
      'change_types': changeTypes,
      'recent_activity': recentActivity.map((a) => a.toJson()).toList(),
    };
  }

  VersionHistoryStatsModel copyWith({
    int? totalVersions,
    int? oldestVersion,
    int? newestVersion,
    double? totalSizeMb,
    Map<String, int>? changeTypes,
    List<VersionActionModel>? recentActivity,
  }) {
    return VersionHistoryStatsModel(
      totalVersions: totalVersions ?? this.totalVersions,
      oldestVersion: oldestVersion ?? this.oldestVersion,
      newestVersion: newestVersion ?? this.newestVersion,
      totalSizeMb: totalSizeMb ?? this.totalSizeMb,
      changeTypes: changeTypes ?? this.changeTypes,
      recentActivity: recentActivity ?? this.recentActivity,
    );
  }

  // Business logic helpers
  String get formattedTotalSize {
    if (totalSizeMb >= 1.0) {
      return '${totalSizeMb.toStringAsFixed(2)} MB';
    } else {
      final kb = totalSizeMb * 1024;
      return '${kb.toStringAsFixed(1)} KB';
    }
  }

  int get versionRange => newestVersion - oldestVersion + 1;
}

class RestoreVersionRequest {
  final int versionNumber;
  final bool confirm;

  const RestoreVersionRequest({
    required this.versionNumber,
    required this.confirm,
  });

  Map<String, dynamic> toJson() {
    return {
      'version_number': versionNumber,
      'confirm': confirm,
    };
  }
}

class CompareVersionsRequest {
  final int fromVersion;
  final int toVersion;

  const CompareVersionsRequest({
    required this.fromVersion,
    required this.toVersion,
  });

  Map<String, dynamic> toJson() {
    return {
      'from_version': fromVersion,
      'to_version': toVersion,
    };
  }
}

class VersionHistoryListModel {
  final List<CVVersionModel> versions;
  final int totalCount;
  final bool hasNext;
  final bool hasPrevious;
  final int currentPage;
  final int totalPages;

  const VersionHistoryListModel({
    required this.versions,
    required this.totalCount,
    required this.hasNext,
    required this.hasPrevious,
    required this.currentPage,
    required this.totalPages,
  });

  factory VersionHistoryListModel.fromJson(Map<String, dynamic> json) {
    try {
      return VersionHistoryListModel(
        versions: _parseVersions(json['results']),
        totalCount: json['count'] ?? 0,
        hasNext: json['next'] != null,
        hasPrevious: json['previous'] != null,
        currentPage: json['current_page'] ?? 1,
        totalPages: json['total_pages'] ?? 1,
      );
    } catch (e) {
      throw FormatException('Failed to parse VersionHistoryListModel: $e');
    }
  }

  static List<CVVersionModel> _parseVersions(dynamic data) {
    if (data == null) return [];
    try {
      final List<dynamic> versionsList = List<dynamic>.from(data);
      return versionsList
          .map((item) => CVVersionModel.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'results': versions.map((v) => v.toJson()).toList(),
      'count': totalCount,
      'has_next': hasNext,
      'has_previous': hasPrevious,
      'current_page': currentPage,
      'total_pages': totalPages,
    };
  }

  VersionHistoryListModel copyWith({
    List<CVVersionModel>? versions,
    int? totalCount,
    bool? hasNext,
    bool? hasPrevious,
    int? currentPage,
    int? totalPages,
  }) {
    return VersionHistoryListModel(
      versions: versions ?? this.versions,
      totalCount: totalCount ?? this.totalCount,
      hasNext: hasNext ?? this.hasNext,
      hasPrevious: hasPrevious ?? this.hasPrevious,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}