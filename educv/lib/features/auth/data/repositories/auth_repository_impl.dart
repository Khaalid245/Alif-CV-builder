import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/auth_repository.dart';
import '../models/auth_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  @override
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Login failed',
          details: apiResponse.error?.details,
        );
      }

      return AuthResponse.fromJson(apiResponse.data);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<AuthResponse> register({
    required String email,
    required String fullName,
    required String studentId,
    required String password,
    required String confirmPassword,
    required bool termsAccepted,
    required bool privacyPolicyAccepted,
    required bool dataProcessingConsent,
  }) async {
    try {
      final requestData = {
        'email': email.trim(),
        'full_name': fullName.trim(),
        'student_id': studentId.trim(),
        'password': password,
        'confirm_password': confirmPassword,
        'terms_consent': termsAccepted,
        'marketing_consent': privacyPolicyAccepted,
        'data_processing_consent': dataProcessingConsent,
      };
      
      final response = await _apiClient.post(
        ApiConstants.register,
        data: requestData,
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Registration failed',
          details: apiResponse.error?.details,
        );
      }

      return AuthResponse.fromJson(apiResponse.data);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.logout,
        data: {
          'refresh': refreshToken,
        },
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Logout failed',
          details: apiResponse.error?.details,
        );
      }
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<StudentModel> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.profile);

      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data,
      );

      if (!apiResponse.success) {
        throw AppException(
          message: apiResponse.error?.message ?? 'Failed to get profile',
          details: apiResponse.error?.details,
        );
      }

      return StudentModel.fromJson(apiResponse.data);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }
}
