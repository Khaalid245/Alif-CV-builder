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

// Auth state model
class AuthState {
  final StudentModel? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    StudentModel? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final secureStorage = ref.read(secureStorageProvider);
      final accessToken = await secureStorage.getAccessToken();
      
      if (accessToken != null && accessToken.isNotEmpty) {
        final userId = await secureStorage.getUserId();
        final email = await secureStorage.getUserEmail();
        final role = await secureStorage.getUserRole();
        
        if (userId != null && email != null) {
          state = state.copyWith(
            user: StudentModel(
              id: userId,
              email: email,
              fullName: '', // Not stored in secure storage
              studentId: '', // Not stored in secure storage
              role: role ?? 'student',
              status: 'active',
              termsConsent: true,
              marketingConsent: false,
              dataProcessingConsent: true,
              createdAt: DateTime.now(),
            ),
            isAuthenticated: true,
          );
        }
      }
    } catch (e) {
      // Silent fail for auth check
    }
  }

  Future<void> logout() async {
    try {
      final secureStorage = ref.read(secureStorageProvider);
      await secureStorage.clearAll();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
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
      
      // Update auth state
      ref.read(authProvider.notifier).state = AuthState(
        user: authResponse.student,
        isAuthenticated: true,
      );

      state = AsyncData(authResponse);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

// Register provider
final registerProvider =
    AsyncNotifierProvider<RegisterNotifier, AuthResponse?>(() {
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
    required bool marketingConsent,
    required bool dataProcessingConsent,
  }) async {
    state = const AsyncLoading();

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final authResponse = await authRepository.register(
        email: email,
        fullName: fullName,
        studentId: studentId,
        password: password,
        confirmPassword: confirmPassword,
        termsAccepted: termsAccepted,
        marketingConsent: marketingConsent,
        dataProcessingConsent: dataProcessingConsent,
      );

      final secureStorage = ref.read(secureStorageProvider);
      await secureStorage.saveTokens(
        accessToken: authResponse.tokens.accessToken,
        refreshToken: authResponse.tokens.refreshToken,
      );
      await secureStorage.saveUserData(
        userId: authResponse.student.id,
        email: authResponse.student.email,
        role: authResponse.student.role,
      );
      ref.read(currentUserProvider.notifier).state = authResponse.student;
      
      // Update auth state
      ref.read(authProvider.notifier).state = AuthState(
        user: authResponse.student,
        isAuthenticated: true,
      );
      
      state = AsyncData(authResponse);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }
}
