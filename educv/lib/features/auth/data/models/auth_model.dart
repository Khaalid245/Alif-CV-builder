class StudentModel {
  final String id;
  final String email;
  final String fullName;
  final String studentId;
  final String role;
  final String status;
  final bool termsConsent;
  final DateTime? termsConsentDate;
  final bool marketingConsent;
  final DateTime? marketingConsentDate;
  final bool dataProcessingConsent;
  final DateTime? dataProcessingConsentDate;
  final DateTime createdAt;

  const StudentModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.studentId,
    required this.role,
    required this.status,
    required this.termsConsent,
    this.termsConsentDate,
    required this.marketingConsent,
    this.marketingConsentDate,
    required this.dataProcessingConsent,
    this.dataProcessingConsentDate,
    required this.createdAt,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      studentId: json['student_id'] ?? '',
      role: json['role'] ?? 'student',
      status: json['status'] ?? 'active',
      termsConsent: json['terms_consent'] ?? false,
      termsConsentDate: _parseDate(json['terms_consent_date']),
      marketingConsent: json['marketing_consent'] ?? false,
      marketingConsentDate: _parseDate(json['marketing_consent_date']),
      dataProcessingConsent: json['data_processing_consent'] ?? false,
      dataProcessingConsentDate:
          _parseDate(json['data_processing_consent_date']),
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
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
      'terms_consent': termsConsent,
      'terms_consent_date': termsConsentDate?.toIso8601String(),
      'marketing_consent': marketingConsent,
      'marketing_consent_date': marketingConsentDate?.toIso8601String(),
      'data_processing_consent': dataProcessingConsent,
      'data_processing_consent_date':
          dataProcessingConsentDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    return DateTime.tryParse(value.toString());
  }
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access'] ?? '',
      refreshToken: json['refresh'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access': accessToken,
      'refresh': refreshToken,
    };
  }
}

class AuthResponse {
  final StudentModel student;
  final AuthTokens tokens;

  const AuthResponse({
    required this.student,
    required this.tokens,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      student: StudentModel.fromJson(json['user'] ?? {}),
      tokens: AuthTokens.fromJson(json['tokens'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': student.toJson(),
      'tokens': tokens.toJson(),
    };
  }
}
