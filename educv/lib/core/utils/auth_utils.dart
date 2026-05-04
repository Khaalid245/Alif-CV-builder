import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:educv/features/auth/presentation/providers/auth_provider.dart';
import '../storage/secure_storage.dart';

Future<void> logoutUser(WidgetRef ref, BuildContext context) async {
  try {
    final secureStorage = ref.read(secureStorageProvider);
    await secureStorage.clearTokens();

    // Clear current user from provider
    ref.read(currentUserProvider.notifier).state = null;

    if (context.mounted) {
      context.go('/login');
    }
  } catch (e) {
    debugPrint('Logout error: $e');
  }
}
