import '../../data/models/auth/login_request.dart';
import '../../data/models/auth/register_request.dart';
import '../../data/models/auth/refresh_token_request.dart';
import '../../data/models/auth/auth_response.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> register(RegisterRequest request);
  Future<AuthResponse> refreshToken(RefreshTokenRequest request);
  Future<void> verifyEmail(String email, String code);
  Future<void> resendOtp(String email);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
}

