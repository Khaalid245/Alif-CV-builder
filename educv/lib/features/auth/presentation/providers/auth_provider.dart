import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/auth_repository.dart';
import '../../data/models/auth_model.dart';
import '../../data/repositories/auth_repository_impl.dart';

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepositoryImpl(apiClient);
});

// Current user provider
final currentUserProvider = StateProvider<StudentModel?>((ref) => null);

// Auth status enum
enum AuthStatus { authenticated, unauthenticated, loading }

// Splash provider for auth check
final splashProvider = AsyncNotifierProvider<SplashNotifier, AuthStatus>(() {
  return SplashNotifier();
});

class SplashNotifier extends AsyncNotifier<AuthStatus> {
  @override
  Future<AuthStatus> build() async {
    return await checkAuthStatus();
  }

  Future<AuthStatus> checkAuthStatus() async {
    // Wait minimum 1.5 seconds for professional feel
    await Future.delayed(const Duration(milliseconds: 1500));

    final secureStorage = ref.read(secureStorageProvider);
    final accessToken = await secureStorage.getAccessToken();

    if (accessToken != null) {
      try {
        // Try to get user profile to verify token is valid
        final authRepository = ref.read(authRepositoryProvider);
        final student = await authRepository.getProfile();
        
        // Set current user in provider
        ref.read(currentUserProvider.notifier).state = student;
        
        return AuthStatus.authenticated;
      } catch (e) {
        // Token is invalid, clear all stored data
        await secureStorage.clearAll();
        return AuthStatus.unauthenticated;
      }
    }

    return AuthStatus.unauthenticated;
  }
}

// Login provider
final loginProvider = AsyncNotifierProvider<LoginNotifier, AuthResponse?>(() {
  return LoginNotifier();
});

class LoginNotifier extends AsyncNotifier<AuthResponse?> {
  @override
  Future<AuthResponse?> build() async {
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final authResponse = await authRepository.login(email, password);

      // Save tokens to secure storage
      final secureStorage = ref.read(secureStorageProvider);
      await secureStorage.saveTokens(
        accessToken: authResponse.tokens.accessToken,
        refreshToken: authResponse.tokens.refreshToken,
      );

      // Save user data to secure storage
      await secureStorage.saveUserData(
        userId: authResponse.student.id,
        email: authResponse.student.email,
        role: authResponse.student.role,
      );

      // Set current user in provider
      ref.read(currentUserProvider.notifier).state = authResponse.student;

      state = AsyncData(authResponse);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

// Register provider
final registerProvider = AsyncNotifierProvider<RegisterNotifier, AuthResponse?>(() {
  return RegisterNotifier();
});

class RegisterNotifier extends AsyncNotifier<AuthResponse?> {
  @override
  Future<AuthResponse?> build() async {
    return null;
  }

  Future<void> register({
    required String email,
    required String fullName,
    required String studentId,
    required String password,
    required String confirmPassword,
    required bool termsAccepted,
    required bool privacyPolicyAccepted,
    required bool dataProcessingConsent,
  }) async {
    state = const AsyncLoading();

    try {
      if (kDebugMode) {
        debugPrint('Starting registration for: $email');
      }
      
      final authRepository = ref.read(authRepositoryProvider);
      final authResponse = await authRepository.register(
        email: email,
        fullName: fullName,
        studentId: studentId,
        password: password,
        confirmPassword: confirmPassword,
        termsAccepted: termsAccepted,
        privacyPolicyAccepted: privacyPolicyAccepted,
        dataProcessingConsent: dataProcessingConsent,
      );

      if (kDebugMode) {
        debugPrint('Registration response received');
      }

      // Save tokens to secure storage
      final secureStorage = ref.read(secureStorageProvider);
      await secureStorage.saveTokens(
        accessToken: authResponse.tokens.accessToken,
        refreshToken: authResponse.tokens.refreshToken,
      );

      // Save user data to secure storage
      await secureStorage.saveUserData(
        userId: authResponse.student.id,
        email: authResponse.student.email,
        role: authResponse.student.role,
      );

      // Set current user in provider
      ref.read(currentUserProvider.notifier).state = authResponse.student;

      if (kDebugMode) {
        debugPrint('Registration completed successfully');
      }

      state = AsyncData(authResponse);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Registration error: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      state = AsyncError(e, stackTrace);
    }
  }
}