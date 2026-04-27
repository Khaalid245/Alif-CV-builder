import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../storage/secure_storage.dart';

class AuthUtils {
  static Future<void> logoutUser(WidgetRef ref, BuildContext context) async {
    try {
      final secureStorage = ref.read(secureStorageProvider);
      final refreshToken = await secureStorage.getRefreshToken();
      
      if (refreshToken != null) {
        // Try to call logout API
        try {
          final authRepository = ref.read(authRepositoryProvider);
          await authRepository.logout(refreshToken);
        } catch (e) {
          // Continue with logout even if API call fails
          debugPrint('Logout API call failed: $e');
        }
      }
      
      // Clear local storage
      await secureStorage.clearAll();
      
      // Clear provider state
      ref.invalidate(currentUserProvider);
      ref.invalidate(loginProvider);
      ref.invalidate(registerProvider);
      
      // Redirect to login
      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      debugPrint('Logout error: $e');
      // Even if logout fails, clear local data and redirect
      final secureStorage = ref.read(secureStorageProvider);
      await secureStorage.clearAll();
      ref.invalidate(currentUserProvider);
      
      if (context.mounted) {
        context.go('/login');
      }
    }
  }
}

// Convenience function for easier usage
Future<void> logoutUser(BuildContext context, WidgetRef ref) async {
  await AuthUtils.logoutUser(ref, context);
}