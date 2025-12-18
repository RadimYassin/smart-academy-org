import 'package:dio/dio.dart';
import '../../utils/logger.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Logger.logError(
      'API Error: ${err.message}',
      error: err,
      tag: 'ErrorInterceptor',
    );

    // Handle different error types
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        Logger.logWarning('Timeout error occurred');
        break;
      case DioExceptionType.badResponse:
        Logger.logWarning('Bad response: ${err.response?.statusCode}');
        break;
      case DioExceptionType.cancel:
        Logger.logWarning('Request cancelled');
        break;
      case DioExceptionType.unknown:
        Logger.logWarning('Unknown error occurred');
        break;
      default:
        Logger.logWarning('Unknown error type');
    }

    handler.next(err);
  }
}

