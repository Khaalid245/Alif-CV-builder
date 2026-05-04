class PlatformStatsModel {
  final int totalStudents;
  final int activeStudents;
  final int suspendedStudents;
  final int deactivatedStudents;
  final int newToday;
  final int newThisWeek;
  final int newThisMonth;
  final int totalGenerated;
  final int generatedToday;
  final int generatedThisWeek;
  final int totalDownloads;
  final String mostPopularTemplate;
  final int deletionRequestsPending;
  final int studentsWithCompleteCV;
  final double averageCompletionPercentage;

  const PlatformStatsModel({
    required this.totalStudents,
    required this.activeStudents,
    required this.suspendedStudents,
    required this.deactivatedStudents,
    required this.newToday,
    required this.newThisWeek,
    required this.newThisMonth,
    required this.totalGenerated,
    required this.generatedToday,
    required this.generatedThisWeek,
    required this.totalDownloads,
    required this.mostPopularTemplate,
    required this.deletionRequestsPending,
    required this.studentsWithCompleteCV,
    required this.averageCompletionPercentage,
  });

  factory PlatformStatsModel.fromJson(Map<String, dynamic> json) {
    // Backend returns nested: {students: {...}, cvs: {...}, platform: {...}}
    final students = json['students'] as Map<String, dynamic>? ?? {};
    final cvs = json['cvs'] as Map<String, dynamic>? ?? {};
    final platform = json['platform'] as Map<String, dynamic>? ?? {};

    return PlatformStatsModel(
      totalStudents: students['total'] ?? 0,
      activeStudents: students['active'] ?? 0,
      suspendedStudents: students['suspended'] ?? 0,
      deactivatedStudents: students['deactivated'] ?? 0,
      newToday: students['new_today'] ?? 0,
      newThisWeek: students['new_this_week'] ?? 0,
      newThisMonth: students['new_this_month'] ?? 0,
      totalGenerated: cvs['total_generated'] ?? 0,
      generatedToday: cvs['generated_today'] ?? 0,
      generatedThisWeek: cvs['generated_this_week'] ?? 0,
      totalDownloads: cvs['total_downloads'] ?? 0,
      mostPopularTemplate: cvs['most_popular_template']?.toString() ?? '',
      deletionRequestsPending: platform['deletion_requests_pending'] ?? 0,
      studentsWithCompleteCV: platform['students_with_complete_cv'] ?? 0,
      averageCompletionPercentage:
          (platform['average_completion_percentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_students': totalStudents,
      'active_students': activeStudents,
      'suspended_students': suspendedStudents,
      'deactivated_students': deactivatedStudents,
      'new_today': newToday,
      'new_this_week': newThisWeek,
      'new_this_month': newThisMonth,
      'total_generated': totalGenerated,
      'generated_today': generatedToday,
      'generated_this_week': generatedThisWeek,
      'total_downloads': totalDownloads,
      'most_popular_template': mostPopularTemplate,
      'deletion_requests_pending': deletionRequestsPending,
      'students_with_complete_cv': studentsWithCompleteCV,
      'average_completion_percentage': averageCompletionPercentage,
    };
  }
}

class TemplateStatsModel {
  final String template;
  final String templateDisplay;
  final int totalGenerated;
  final int totalDownloads;
  final double percentageOfTotal;

  const TemplateStatsModel({
    required this.template,
    required this.templateDisplay,
    required this.totalGenerated,
    required this.totalDownloads,
    required this.percentageOfTotal,
  });

  factory TemplateStatsModel.fromJson(Map<String, dynamic> json) {
    return TemplateStatsModel(
      template: json['template'] ?? '',
      templateDisplay: json['template_display'] ?? '',
      totalGenerated: json['total_generated'] ?? 0,
      totalDownloads: json['total_downloads'] ?? 0,
      percentageOfTotal: (json['percentage_of_total'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'template': template,
      'template_display': templateDisplay,
      'total_generated': totalGenerated,
      'total_downloads': totalDownloads,
      'percentage_of_total': percentageOfTotal,
    };
  }
}

class AdminStudentModel {
  final String id;
  final String email;
  final String fullName;
  final String studentId;
  final String role;
  final String status;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final double cvCompletionPercentage;
  final int totalCvsGenerated;
  final bool deletionRequested;
  final DateTime? deletionRequestedAt;
  final bool termsAccepted;
  final DateTime? termsAcceptedAt;
  final bool privacyPolicyAccepted;
  final DateTime? privacyPolicyAcceptedAt;
  final bool dataProcessingConsent;
  final DateTime? dataProcessingConsentAt;
  final String? photoUrl;

  const AdminStudentModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.studentId,
    required this.role,
    required this.status,
    required this.createdAt,
    this.lastLoginAt,
    required this.cvCompletionPercentage,
    required this.totalCvsGenerated,
    required this.deletionRequested,
    this.deletionRequestedAt,
    required this.termsAccepted,
    this.termsAcceptedAt,
    required this.privacyPolicyAccepted,
    this.privacyPolicyAcceptedAt,
    required this.dataProcessingConsent,
    this.dataProcessingConsentAt,
    this.photoUrl,
  });

  factory AdminStudentModel.fromJson(Map<String, dynamic> json) {
    return AdminStudentModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      studentId: json['student_id'] ?? '',
      role: json['role'] ?? 'student',
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(json['created_at']),
      lastLoginAt: json['last_login_at'] != null ? DateTime.parse(json['last_login_at']) : null,
      cvCompletionPercentage: (json['cv_completion_percentage'] ?? 0.0).toDouble(),
      totalCvsGenerated: json['total_cvs_generated'] ?? 0,
      deletionRequested: json['deletion_requested'] ?? false,
      deletionRequestedAt: json['deletion_requested_at'] != null ? DateTime.parse(json['deletion_requested_at']) : null,
      termsAccepted: json['terms_accepted'] ?? false,
      termsAcceptedAt: json['terms_accepted_at'] != null ? DateTime.parse(json['terms_accepted_at']) : null,
      privacyPolicyAccepted: json['privacy_policy_accepted'] ?? false,
      privacyPolicyAcceptedAt: json['privacy_policy_accepted_at'] != null ? DateTime.parse(json['privacy_policy_accepted_at']) : null,
      dataProcessingConsent: json['data_processing_consent'] ?? false,
      dataProcessingConsentAt: json['data_processing_consent_at'] != null ? DateTime.parse(json['data_processing_consent_at']) : null,
      photoUrl: json['photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'student_id': studentId,
      'role': role,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'cv_completion_percentage': cvCompletionPercentage,
      'total_cvs_generated': totalCvsGenerated,
      'deletion_requested': deletionRequested,
      'deletion_requested_at': deletionRequestedAt?.toIso8601String(),
      'terms_accepted': termsAccepted,
      'terms_accepted_at': termsAcceptedAt?.toIso8601String(),
      'privacy_policy_accepted': privacyPolicyAccepted,
      'privacy_policy_accepted_at': privacyPolicyAcceptedAt?.toIso8601String(),
      'data_processing_consent': dataProcessingConsent,
      'data_processing_consent_at': dataProcessingConsentAt?.toIso8601String(),
      'photo_url': photoUrl,
    };
  }

  String get lastActiveText {
    if (lastLoginAt == null) return 'Never';
    final now = DateTime.now();
    final difference = now.difference(lastLoginAt!);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Recently';
    }
  }
}

class AdminStudentDetailModel extends AdminStudentModel {
  final Map<String, dynamic>? cvProfile;
  final List<Map<String, dynamic>> generatedCvs;

  const AdminStudentDetailModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.studentId,
    required super.role,
    required super.status,
    required super.createdAt,
    super.lastLoginAt,
    required super.cvCompletionPercentage,
    required super.totalCvsGenerated,
    required super.deletionRequested,
    super.deletionRequestedAt,
    required super.termsAccepted,
    super.termsAcceptedAt,
    required super.privacyPolicyAccepted,
    super.privacyPolicyAcceptedAt,
    required super.dataProcessingConsent,
    super.dataProcessingConsentAt,
    super.photoUrl,
    this.cvProfile,
    required this.generatedCvs,
  });

  factory AdminStudentDetailModel.fromJson(Map<String, dynamic> json) {
    return AdminStudentDetailModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      studentId: json['student_id'] ?? '',
      role: json['role'] ?? 'student',
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(json['created_at']),
      lastLoginAt: json['last_login_at'] != null ? DateTime.parse(json['last_login_at']) : null,
      cvCompletionPercentage: (json['cv_completion_percentage'] ?? 0.0).toDouble(),
      totalCvsGenerated: json['total_cvs_generated'] ?? 0,
      deletionRequested: json['deletion_requested'] ?? false,
      deletionRequestedAt: json['deletion_requested_at'] != null ? DateTime.parse(json['deletion_requested_at']) : null,
      termsAccepted: json['terms_accepted'] ?? false,
      termsAcceptedAt: json['terms_accepted_at'] != null ? DateTime.parse(json['terms_accepted_at']) : null,
      privacyPolicyAccepted: json['privacy_policy_accepted'] ?? false,
      privacyPolicyAcceptedAt: json['privacy_policy_accepted_at'] != null ? DateTime.parse(json['privacy_policy_accepted_at']) : null,
      dataProcessingConsent: json['data_processing_consent'] ?? false,
      dataProcessingConsentAt: json['data_processing_consent_at'] != null ? DateTime.parse(json['data_processing_consent_at']) : null,
      photoUrl: json['photo_url'],
      cvProfile: json['cv_profile'],
      generatedCvs: List<Map<String, dynamic>>.from(json['generated_cvs'] ?? []),
    );
  }

  int get sectionsFilled {
    if (cvProfile == null) return 0;
    int count = 0;
    
    if (cvProfile!['education']?.isNotEmpty == true) count++;
    if (cvProfile!['experience']?.isNotEmpty == true) count++;
    if (cvProfile!['skills']?.isNotEmpty == true) count++;
    if (cvProfile!['languages']?.isNotEmpty == true) count++;
    if (cvProfile!['projects']?.isNotEmpty == true) count++;
    if (cvProfile!['certifications']?.isNotEmpty == true) count++;
    if (cvProfile!['summary']?.isNotEmpty == true) count++;
    
    return count;
  }
}

class AdminCVModel {
  final String id;
  final String studentName;
  final String studentId;
  final String template;
  final String templateDisplay;
  final DateTime generatedAt;
  final int downloadCount;
  final String fileSize;

  const AdminCVModel({
    required this.id,
    required this.studentName,
    required this.studentId,
    required this.template,
    required this.templateDisplay,
    required this.generatedAt,
    required this.downloadCount,
    required this.fileSize,
  });

  factory AdminCVModel.fromJson(Map<String, dynamic> json) {
    return AdminCVModel(
      id: json['id'] ?? '',
      studentName: json['student_name'] ?? '',
      studentId: json['student_id'] ?? '',
      template: json['template'] ?? '',
      templateDisplay: json['template_display'] ?? '',
      generatedAt: DateTime.parse(json['generated_at']),
      downloadCount: json['download_count'] ?? 0,
      fileSize: json['file_size'] ?? '0 KB',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_name': studentName,
      'student_id': studentId,
      'template': template,
      'template_display': templateDisplay,
      'generated_at': generatedAt.toIso8601String(),
      'download_count': downloadCount,
      'file_size': fileSize,
    };
  }
}

class AuditLogModel {
  final String id;
  final String studentName;
  final String studentId;
  final String action;
  final String actionDisplay;
  final String ipAddress;
  final DateTime timestamp;
  final Map<String, dynamic> extraData;

  const AuditLogModel({
    required this.id,
    required this.studentName,
    required this.studentId,
    required this.action,
    required this.actionDisplay,
    required this.ipAddress,
    required this.timestamp,
    required this.extraData,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'] ?? '',
      studentName: json['student_name'] ?? '',
      studentId: json['student_id'] ?? '',
      action: json['action'] ?? '',
      actionDisplay: json['action_display'] ?? '',
      ipAddress: json['ip_address'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      extraData: Map<String, dynamic>.from(json['extra_data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_name': studentName,
      'student_id': studentId,
      'action': action,
      'action_display': actionDisplay,
      'ip_address': ipAddress,
      'timestamp': timestamp.toIso8601String(),
      'extra_data': extraData,
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String get extraDataSummary {
    if (extraData.isEmpty) return '';
    
    if (extraData.containsKey('reason')) {
      return 'Reason: ${extraData['reason']}';
    }
    
    if (extraData.containsKey('template')) {
      return 'Template: ${extraData['template']}';
    }
    
    return '';
  }
}

class PaginatedResponse<T> {
  final int count;
  final int totalPages;
  final int currentPage;
  final String? next;
  final String? previous;
  final List<T> results;

  const PaginatedResponse({
    required this.count,
    required this.totalPages,
    required this.currentPage,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      count: json['count'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
      currentPage: json['current_page'] ?? 1,
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List? ?? [])
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'count': count,
      'total_pages': totalPages,
      'current_page': currentPage,
      'next': next,
      'previous': previous,
      'results': results.map(toJsonT).toList(),
    };
  }

  bool get hasMore => next != null;
}