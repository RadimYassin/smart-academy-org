import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../constants/app_constants.dart';
import '../../utils/logger.dart';
import '../../../shared/services/token_storage_service.dart';

class AuthInterceptor extends Interceptor {
  TokenStorageService? _tokenStorage;

  TokenStorageService get tokenStorage {
    _tokenStorage ??= Get.find<TokenStorageService>();
    return _tokenStorage!;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Get access token from storage (synchronous read)
    try {
      final storage = Get.find<GetStorage>();
      final accessToken = storage.read<String>(AppConstants.accessTokenKey);
      
      // Add Authorization header if token exists
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
        Logger.logInfo('Added auth token to request: ${options.path}');
      } else {
        Logger.logWarning('No access token available for request: ${options.path}');
      }
    } catch (e) {
      Logger.logError('Error getting access token in interceptor', error: e);
    }
    
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      Logger.logWarning('Unauthorized request - Token expired or invalid');
      
      // Try to refresh token
      final refreshToken = await tokenStorage.getRefreshToken();
      
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Attempt token refresh
          final dio = Dio();
          final response = await dio.post(
            '${AppConstants.baseUrl}${AppConstants.refreshTokenEndpoint}',
            data: {'refreshToken': refreshToken},
          );
          
          if (response.statusCode == 200) {
            // Extract new tokens (handle both snake_case and camelCase)
            final newAccessToken = response.data['access_token'] ?? 
                                   response.data['accessToken'] ?? '';
            final newRefreshToken = response.data['refresh_token'] ?? 
                                    response.data['refreshToken'] ?? '';
            
            if (newAccessToken.isNotEmpty && newRefreshToken.isNotEmpty) {
              // Save new tokens using token storage service
              final saved = await tokenStorage.saveTokens(
                newAccessToken,
                newRefreshToken,
              );
              
              if (saved) {
                Logger.logInfo('Token refreshed and saved successfully');
                
                // Retry the original request with new token
                err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                final retryResponse = await dio.fetch(err.requestOptions);
                return handler.resolve(retryResponse);
              } else {
                Logger.logError('Failed to save refreshed tokens');
                await _clearAuthData();
              }
            } else {
              Logger.logError('Invalid token response format');
              await _clearAuthData();
            }
          }
        } catch (e) {
          Logger.logError('Token refresh failed', error: e);
          // Clear auth data on refresh failure
          await _clearAuthData();
        }
      } else {
        // No refresh token available
        Logger.logWarning('No refresh token available');
        await _clearAuthData();
      }
    }
    
    handler.next(err);
  }

  Future<void> _clearAuthData() async {
    try {
      await tokenStorage.clearTokens();
      final storage = Get.find<GetStorage>();
      await storage.remove(AppConstants.userDataKey);
      await storage.write(AppConstants.isLoggedInKey, false);
      Logger.logInfo('Auth data cleared due to token expiration');
    } catch (e) {
      Logger.logError('Error clearing auth data', error: e);
    }
  }
}
