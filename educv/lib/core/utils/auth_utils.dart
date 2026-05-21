import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/api_client_provider.dart';
import '../exceptions/app_exception.dart';
import '../network/api_response.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class AuthUtils {
  static Future<bool> isTokenValid(WidgetRef ref) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get('/auth/profile/');
      return response.success;
    } catch (e) {
      return false;
    }
  }

  static Future<void> logout(WidgetRef ref) async {
    try {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.post('/auth/logout/');
      apiClient.removeAuthToken();
    } catch (e) {
      throw AppException(
        message: 'Failed to logout: ${e.toString()}',
        details: e,
      );
    }
  }

  static void setAuthToken(WidgetRef ref, String token) {
    final apiClient = ref.read(apiClientProvider);
    apiClient.setAuthToken(token);
  }

  static void clearAuthToken(WidgetRef ref) {
    final apiClient = ref.read(apiClientProvider);
    apiClient.removeAuthToken();
  }
}

// Helper function for logout
Future<void> logoutUser(WidgetRef ref, BuildContext context) async {
  try {
    final apiClient = ref.read(apiClientProvider);
    await apiClient.post('/auth/logout/');
    apiClient.removeAuthToken();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: ${e.toString()}')),
      );
    }
  }
}