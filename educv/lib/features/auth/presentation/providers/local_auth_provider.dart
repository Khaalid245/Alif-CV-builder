import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

class LocalAuthState {
  final bool isVerified;
  final bool isSupported;
  final bool isAuthenticating;
  final String? error;

  const LocalAuthState({
    this.isVerified = false,
    this.isSupported = false,
    this.isAuthenticating = false,
    this.error,
  });

  LocalAuthState copyWith({
    bool? isVerified,
    bool? isSupported,
    bool? isAuthenticating,
    String? error,
  }) {
    return LocalAuthState(
      isVerified: isVerified ?? this.isVerified,
      isSupported: isSupported ?? this.isSupported,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
      error: error,
    );
  }
}

class LocalAuthNotifier extends StateNotifier<LocalAuthState> {
  final LocalAuthentication _auth = LocalAuthentication();

  LocalAuthNotifier() : super(const LocalAuthState()) {
    _checkSupport();
  }

  Future<void> _checkSupport() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      state = state.copyWith(isSupported: isSupported || canCheckBiometrics);
      
      // If hardware isn't supported, just let them through
      if (!state.isSupported) {
        state = state.copyWith(isVerified: true);
      }
    } catch (e) {
      state = state.copyWith(isSupported: false, isVerified: true);
    }
  }

  Future<bool> authenticate() async {
    if (!state.isSupported) {
      state = state.copyWith(isVerified: true);
      return true;
    }

    state = state.copyWith(isAuthenticating: true, error: null);

    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please authenticate to access your CV data',
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Biometric Authentication Required',
            cancelButton: 'Cancel',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancel',
          ),
        ],
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: false, // Allows PIN fallback
        ),
      );

      state = state.copyWith(
        isVerified: didAuthenticate,
        isAuthenticating: false,
      );
      
      return didAuthenticate;
    } on PlatformException catch (e) {
      state = state.copyWith(
        isAuthenticating: false,
        error: e.message ?? 'Authentication error',
      );
      return false;
    }
  }
  
  void reset() {
    state = state.copyWith(isVerified: !state.isSupported);
  }
}

final localAuthProvider = StateNotifierProvider<LocalAuthNotifier, LocalAuthState>((ref) {
  return LocalAuthNotifier();
});
