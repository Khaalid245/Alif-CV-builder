class StudentModel {
  final String id;
  final String email;
  final String fullName;
  final String studentId;
  final String role;
  final String status;
  final DateTime createdAt;

  const StudentModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.studentId,
    required this.role,
    required this.status,
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
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
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
    };
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