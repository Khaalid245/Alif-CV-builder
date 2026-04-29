import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../storage/secure_storage.dart';

Future<void> logoutUser(WidgetRef ref, BuildContext context) async {
  try {
    // Clear tokens from secure storage
    final secureStorage = ref.read(secureStorageProvider);
    await secureStorage.clearTokens();
    
    // Navigate to login screen
    if (context.mounted) {
      context.go('/login');
    }
  } catch (e) {
    // Handle logout error silently or show a message
    debugPrint('Logout error: $e');
  }
}