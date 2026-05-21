import 'package:dio/dio.dart';
import '../../exceptions/app_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppException appException;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        appException = NetworkException(
          message: 'Connection timeout. Please check your internet connection.',
          code: 'TIMEOUT',
          details: _extractErrorDetails(err),
        );
        break;
      
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final responseData = err.response?.data;
        
        String message = _extractErrorMessage(responseData) ?? 
                        'Server error (${statusCode ?? 'Unknown'})';
        
        appException = ServerException(
          message: message,
          code: statusCode?.toString(),
          details: responseData,
        );
        break;
      
      case DioExceptionType.cancel:
        appException = AppException(
          message: 'Request was cancelled',
          code: 'CANCELLED',
          details: _extractErrorDetails(err),
        );
        break;
      
      case DioExceptionType.connectionError:
        appException = NetworkException(
          message: 'Connection failed. Please check your network and server availability.',
          code: 'CONNECTION_ERROR',
          details: _extractErrorDetails(err),
        );
        break;
      
      default:
        String errorMessage = _extractErrorMessage(err.response?.data) ?? 
                             err.message ?? 
                             'An unexpected error occurred';
        
        // Prevent null error messages
        if (errorMessage.isEmpty || errorMessage == 'null') {
          errorMessage = 'Network request failed. Please check your connection and try again.';
        }
        
        appException = AppException(
          message: errorMessage,
          code: 'UNKNOWN',
          details: _extractErrorDetails(err),
        );
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: appException,
        type: err.type,
        response: err.response,
      ),
    );
  }

  String? _extractErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      // Try multiple possible error message fields
      final message = responseData['message'] ?? 
                     responseData['error']?['message'] ?? 
                     responseData['detail'] ??
                     responseData['non_field_errors']?.first;
      
      // Return non-empty message only
      if (message != null && message.toString().isNotEmpty && message.toString() != 'null') {
        return message.toString();
      }
    }
    if (responseData is String && responseData.isNotEmpty && responseData != 'null') {
      return responseData;
    }
    return null;
  }

  String _extractErrorDetails(DioException err) {
    final details = <String>[];
    
    if (err.message != null) {
      details.add('Message: ${err.message}');
    }
    
    if (err.response?.statusCode != null) {
      details.add('Status: ${err.response!.statusCode}');
    }
    
    if (err.requestOptions.uri.toString().isNotEmpty) {
      details.add('URL: ${err.requestOptions.uri}');
    }
    
    return details.join(', ');
  }
}