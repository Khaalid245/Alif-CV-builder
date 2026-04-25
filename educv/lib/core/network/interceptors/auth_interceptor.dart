import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final Ref _ref;

  AuthInterceptor(this._ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
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
      // Token expired, try to refresh
      final secureStorage = _ref.read(secureStorageProvider);
      final refreshToken = await secureStorage.getRefreshToken();

      if (refreshToken != null) {
        try {
          // TODO: Implement token refresh logic in Phase 8
          // For now, just clear tokens and let user re-login
          await secureStorage.clearTokens();
        } catch (e) {
          await secureStorage.clearTokens();
        }
      }
    }

    handler.next(err);
  }
}