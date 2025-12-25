import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../models/auth/login_request.dart';
import '../models/auth/register_request.dart';
import '../models/auth/refresh_token_request.dart';
import '../models/auth/auth_response.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

  /// Login with email and password
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      Logger.logInfo('Attempting login for: ${request.email}');
      
      final response = await _apiClient.post(
        AppConstants.loginEndpoint,
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        Logger.logInfo('Login successful');
        return AuthResponse.fromJson(response.data);
      } else {
        throw Exception('Login failed: Invalid response');
      }
    } on DioException catch (e) {
      Logger.logError('Login error', error: e);
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? 'Login failed';
        
        switch (statusCode) {
          case 401:
            throw Exception('Invalid email or password');
          case 403:
            throw Exception('Account not verified or disabled');
          case 404:
            throw Exception('User not found');
          default:
            throw Exception(message);
        }
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      Logger.logError('Unexpected login error', error: e);
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  /// Register new user
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      Logger.logInfo('Attempting registration for: ${request.email}');
      
      final response = await _apiClient.post(
        AppConstants.registerEndpoint,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Logger.logInfo('Registration successful');
        return AuthResponse.fromJson(response.data);
      } else {
        throw Exception('Registration failed: Invalid response');
      }
    } on DioException catch (e) {
      Logger.logError('Registration error', error: e);
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? 'Registration failed';
        
        switch (statusCode) {
          case 400:
            throw Exception(message); // Validation errors
          case 409:
            throw Exception('Email already registered');
          default:
            throw Exception(message);
        }
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      Logger.logError('Unexpected registration error', error: e);
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  /// Refresh access token
  Future<AuthResponse> refreshToken(RefreshTokenRequest request) async {
    try {
      Logger.logInfo('Refreshing access token');
      
      final response = await _apiClient.post(
        AppConstants.refreshTokenEndpoint,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        Logger.logInfo('Token refresh successful');
        return AuthResponse.fromJson(response.data);
      } else {
        throw Exception('Token refresh failed');
      }
    } on DioException catch (e) {
      Logger.logError('Token refresh error', error: e);
      throw Exception('Session expired. Please login again.');
    }
  }

  /// Verify email with OTP
  Future<void> verifyEmail(String email, String code) async {
    try {
      Logger.logInfo('Verifying email: $email');
      
      final response = await _apiClient.post(
        AppConstants.verifyEmailEndpoint,
        data: {
          'email': email,
          'code': code,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Email verification failed');
      }
      
      Logger.logInfo('Email verified successfully');
    } on DioException catch (e) {
      Logger.logError('Email verification error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Verification failed';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Resend OTP
  Future<void> resendOtp(String email) async {
    try {
      Logger.logInfo('Resending OTP to: $email');
      
      final response = await _apiClient.post(
        AppConstants.resendOtpEndpoint,
        data: {'email': email},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to resend OTP');
      }
      
      Logger.logInfo('OTP sent successfully');
    } on DioException catch (e) {
      Logger.logError('Resend OTP error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to resend OTP';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Request password reset code
  Future<void> forgotPassword(String email) async {
    try {
      Logger.logInfo('Requesting password reset for: $email');
      
      final response = await _apiClient.post(
        '${AppConstants.userServicePath}/api/v1/auth/forgot-password',
        data: {'email': email},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to request password reset');
      }
      
      Logger.logInfo('Password reset code sent successfully');
    } on DioException catch (e) {
      Logger.logError('Forgot password error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to request password reset';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Reset password with OTP code
  Future<void> resetPassword(String email, String code, String newPassword) async {
    try {
      Logger.logInfo('Resetting password for: $email');
      
      final response = await _apiClient.post(
        '${AppConstants.userServicePath}/api/v1/auth/reset-password',
        data: {
          'email': email,
          'code': code,
          'newPassword': newPassword,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to reset password');
      }
      
      Logger.logInfo('Password reset successfully');
    } on DioException catch (e) {
      Logger.logError('Reset password error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to reset password';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }
}

