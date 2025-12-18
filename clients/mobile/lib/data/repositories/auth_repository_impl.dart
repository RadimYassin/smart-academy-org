import 'package:get_storage/get_storage.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth/login_request.dart';
import '../models/auth/register_request.dart';
import '../models/auth/refresh_token_request.dart';
import '../models/auth/auth_response.dart';
import '../../../shared/services/token_storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final GetStorage _storage;
  final TokenStorageService _tokenStorage;

  AuthRepositoryImpl(this._remoteDataSource, this._storage)
      : _tokenStorage = TokenStorageService(_storage);

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _remoteDataSource.login(request);
      
      // Save tokens and user data
      await _saveAuthData(response);
      
      return response;
    } catch (e) {
      Logger.logError('Repository login error', error: e);
      rethrow;
    }
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _remoteDataSource.register(request);
      
      // Save tokens and user data
      await _saveAuthData(response);
      
      return response;
    } catch (e) {
      Logger.logError('Repository register error', error: e);
      rethrow;
    }
  }

  @override
  Future<AuthResponse> refreshToken(RefreshTokenRequest request) async {
    try {
      final response = await _remoteDataSource.refreshToken(request);
      
      // Update tokens using token storage service
      final saved = await _tokenStorage.saveTokens(
        response.accessToken,
        response.refreshToken,
      );
      
      if (!saved) {
        Logger.logWarning('Token save verification failed after refresh');
      }
      
      return response;
    } catch (e) {
      Logger.logError('Repository refresh token error', error: e);
      // If refresh fails, clear auth data
      await logout();
      rethrow;
    }
  }

  @override
  Future<void> verifyEmail(String email, String code) async {
    try {
      await _remoteDataSource.verifyEmail(email, code);
    } catch (e) {
      Logger.logError('Repository verify email error', error: e);
      rethrow;
    }
  }

  @override
  Future<void> resendOtp(String email) async {
    try {
      await _remoteDataSource.resendOtp(email);
    } catch (e) {
      Logger.logError('Repository resend OTP error', error: e);
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Clear tokens using token storage service
      await _tokenStorage.clearTokens();
      
      // Clear other user data
      await _storage.remove(AppConstants.userDataKey);
      await _storage.remove(AppConstants.userEmailKey);
      await _storage.remove(AppConstants.userRoleKey);
      await _storage.write(AppConstants.isLoggedInKey, false);
      
      Logger.logInfo('User logged out successfully - all tokens cleared');
    } catch (e) {
      Logger.logError('Logout error', error: e);
      rethrow;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final isLoggedIn = _storage.read<bool>(AppConstants.isLoggedInKey) ?? false;
      final accessToken = _storage.read<String>(AppConstants.accessTokenKey);
      
      return isLoggedIn && accessToken != null && accessToken.isNotEmpty;
    } catch (e) {
      Logger.logError('Check login status error', error: e);
      return false;
    }
  }

  @override
  Future<String?> getAccessToken() async {
    return await _tokenStorage.getAccessToken();
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _tokenStorage.getRefreshToken();
  }

  /// Private helper to save auth data
  Future<void> _saveAuthData(AuthResponse response) async {
    try {
      Logger.logInfo('Saving auth data...');
      
      // Save tokens using token storage service (with verification)
      final tokensSaved = await _tokenStorage.saveTokens(
        response.accessToken,
        response.refreshToken,
      );
      
      if (!tokensSaved) {
        Logger.logWarning('Token storage verification failed, but continuing...');
      }
      
      // Save user data
      await _storage.write(AppConstants.userEmailKey, response.email);
      await _storage.write(AppConstants.userRoleKey, response.role);
      await _storage.write(AppConstants.userDataKey, response.toJson());
      await _storage.write(AppConstants.isLoggedInKey, true);
      
      // Verify token storage
      final verified = await _tokenStorage.verifyTokenStorage();
      
      if (verified) {
        Logger.logInfo('✓ Auth data saved and verified successfully');
      } else {
        Logger.logWarning('⚠ Auth data saved but verification failed');
      }
    } catch (e) {
      Logger.logError('Error saving auth data', error: e);
      rethrow;
    }
  }
}

