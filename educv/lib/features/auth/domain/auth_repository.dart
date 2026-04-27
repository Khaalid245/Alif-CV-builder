import '../data/models/auth_model.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(String email, String password);
  
  Future<AuthResponse> register({
    required String email,
    required String fullName,
    required String studentId,
    required String password,
    required String confirmPassword,
    required bool termsAccepted,
    required bool privacyPolicyAccepted,
    required bool dataProcessingConsent,
  });
  
  Future<void> logout(String refreshToken);
  
  Future<StudentModel> getProfile();
}