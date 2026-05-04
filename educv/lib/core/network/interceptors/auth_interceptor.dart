import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../storage/secure_storage.dart';
import '../../../app.dart' show navigatorKey;

class AuthInterceptor extends Interceptor {
  final Ref _ref;

  AuthInterceptor(this._ref);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final secureStorage = _ref.read(secureStorageProvider);
    final accessToken = await secureStorage.getAccessToken();

    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final secureStorage = _ref.read(secureStorageProvider);
      final refreshToken = await secureStorage.getRefreshToken();

      if (refreshToken != null) {
        try {
          // Attempt token refresh — placeholder until refresh endpoint is wired
          await secureStorage.clearTokens();
        } catch (_) {
          await secureStorage.clearTokens();
        }
      } else {
        await secureStorage.clearTokens();
      }

      // Show session expiry message before redirecting
      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your session has expired. Please sign in again.'),
            backgroundColor: Color(0xFFC62828),
            duration: Duration(milliseconds: 2500),
          ),
        );
      }

      await Future.delayed(const Duration(milliseconds: 800));

      final navContext = navigatorKey.currentContext;
      if (navContext != null && navContext.mounted) {
        navContext.go('/login');
      }
    }

    handler.next(err);
  }
}
