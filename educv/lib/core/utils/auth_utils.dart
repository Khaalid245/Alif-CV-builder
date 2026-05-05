import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:educv/features/auth/presentation/providers/auth_provider.dart';
import '../storage/secure_storage.dart';
import '../network/api_client.dart';
import '../constants/api_constants.dart';

Future<void> logoutUser(WidgetRef ref, BuildContext context) async {
  try {
    final secureStorage = ref.read(secureStorageProvider);
    final refreshToken = await secureStorage.getRefreshToken();

    // Blacklist the refresh token on the backend — fire and forget
    // If this fails (network down) we still clear local storage
    if (refreshToken != null) {
      try {
        final apiClient = ref.read(apiClientProvider);
        await apiClient.post(
          ApiConstants.logout,
          data: {'refresh': refreshToken},
        );
      } catch (_) {
        // Backend logout failed — proceed with local logout anyway
      }
    }

    // Clear all local auth data
    await secureStorage.clearAll();

    // Clear current user from provider
    ref.read(currentUserProvider.notifier).state = null;

    if (context.mounted) {
      context.go('/login');
    }
  } catch (e) {
    if (kDebugMode) debugPrint('Logout error: $e');
  }
}
