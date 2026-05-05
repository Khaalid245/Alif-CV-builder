import 'dart:async';
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
  // Each pending request holds a Completer so it can be resolved or rejected.
  final List<Completer<String>> _tokenCompleters = [];

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

    // If a refresh is already running, queue this request and wait for the
    // new token via a Completer instead of hanging forever.
    if (_isRefreshing) {
      final completer = Completer<String>();
      _tokenCompleters.add(completer);
      try {
        final newToken = await completer.future;
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final retryDio = Dio();
        final retryResponse = await retryDio.fetch(err.requestOptions);
        handler.resolve(retryResponse);
      } catch (_) {
        handler.next(err);
      }
      return;
    }

    _isRefreshing = true;

    try {
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

      // Resolve all queued requests with the new token
      for (final completer in _tokenCompleters) {
        completer.complete(newAccessToken);
      }
      _tokenCompleters.clear();
      _isRefreshing = false;

      // Retry the original failed request
      err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      final retryDio = Dio();
      final retryResponse = await retryDio.fetch(err.requestOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      // Reject all queued requests
      for (final completer in _tokenCompleters) {
        completer.completeError('Token refresh failed');
      }
      _tokenCompleters.clear();
      _isRefreshing = false;
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
