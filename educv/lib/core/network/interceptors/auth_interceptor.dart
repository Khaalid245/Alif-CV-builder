import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final Ref _ref;
  late final SecureStorageService _storage;

  AuthInterceptor(this._ref) {
    _storage = _ref.read(secureStorageProvider);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getAccessToken();
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _storage.getRefreshToken();
      
      if (refreshToken != null) {
        try {
          final dio = Dio();
          final response = await dio.post(
            '${err.requestOptions.baseUrl}/auth/token/refresh/',
            data: {'refresh': refreshToken},
          );
          
          if (response.statusCode == 200) {
            final newToken = response.data['access'];
            await _storage.saveTokens(
              accessToken: newToken,
              refreshToken: refreshToken,
            );
            
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newToken';
            
            final cloneReq = await dio.fetch(opts);
            handler.resolve(cloneReq);
            return;
          }
        } catch (e) {
          await _storage.clearTokens();
        }
      }
    }
    
    handler.next(err);
  }
}