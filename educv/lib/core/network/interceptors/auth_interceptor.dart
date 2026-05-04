import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../storage/secure_storage.dart';
import '../../constants/api_constants.dart';
import '../../../app.dart' show navigatorKey;

class AuthInterceptor extends Interceptor {
  final Ref _ref;

  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];

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
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final secureStorage = _ref.read(secureStorageProvider);
    final refreshToken = await secureStorage.getRefreshToken();

    if (refreshToken == null) {
      await _handleSessionExpired(handler, err);
      return;
    }

    // Queue this request if a refresh is already in progress
    if (_isRefreshing) {
      final completer = _PendingRequest(err.requestOptions);
      _pendingRequests.add(completer);
      return;
    }

    _isRefreshing = true;

    try {
      // Use a fresh Dio instance to avoid interceptor loops
      final refreshDio = Dio();
      final refreshResponse = await refreshDio.post(
        '${ApiConstants.baseUrl}${ApiConstants.tokenRefresh}',
        data: {'refresh': refreshToken},
      );

      final responseData = refreshResponse.data as Map<String, dynamic>;
      final data = responseData['data'] as Map<String, dynamic>?;

      final newAccessToken = data?['access'] as String? ??
          responseData['access'] as String?;
      final newRefreshToken = data?['refresh'] as String? ??
          responseData['refresh'] as String?;

      if (newAccessToken == null) {
        throw Exception('No access token in refresh response');
      }

      await secureStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken ?? refreshToken,
      );

      _isRefreshing = false;

      // Retry all queued requests with the new token
      for (final pending in _pendingRequests) {
        pending.options.headers['Authorization'] = 'Bearer $newAccessToken';
        try {
          final retryDio = Dio();
          final retryResponse = await retryDio.fetch(pending.options);
          pending.completer?.call(retryResponse);
        } catch (_) {
          // Individual retry failure — don't block others
        }
      }
      _pendingRequests.clear();

      // Retry the original failed request
      err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      final retryDio = Dio();
      final retryResponse = await retryDio.fetch(err.requestOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      _isRefreshing = false;
      _pendingRequests.clear();
      await _handleSessionExpired(handler, err);
    }
  }

  Future<void> _handleSessionExpired(
    ErrorInterceptorHandler handler,
    DioException err,
  ) async {
    final secureStorage = _ref.read(secureStorageProvider);
    await secureStorage.clearAll();

    final context = navigatorKey.currentContext;
    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your session has expired. Please sign in again.'),
          backgroundColor: Color(0xFFC62828),
          duration: Duration(milliseconds: 2500),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 800));
    }

    final navContext = navigatorKey.currentContext;
    if (navContext != null && navContext.mounted) {
      navContext.go('/login');
    }

    handler.reject(err);
  }
}

class _PendingRequest {
  final RequestOptions options;
  final void Function(Response)? completer;

  _PendingRequest(this.options, {this.completer});
}
