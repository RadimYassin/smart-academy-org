class AppConstants {
  // API Configuration - Smart Academy Backend
  // Change this IP address to match your backend server
  static const String baseUrl = 'http://localhost:8888'; // API Gateway URL
  static const String userServicePath = '/user-management-service';
  static const String courseServicePath = '/course-service';
  static const String lmsConnectorPath = '/lmsconnector';
  static const String chatbotServicePath = '/chatbot-edu-service';
  
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration chatbotTimeout = Duration(seconds: 120); // Longer timeout for AI chat requests
  
  // Auth Endpoints
  static const String loginEndpoint = '$userServicePath/api/v1/auth/login';
  static const String registerEndpoint = '$userServicePath/api/v1/auth/register';
  static const String refreshTokenEndpoint = '$userServicePath/api/v1/auth/refresh-token';
  static const String verifyEmailEndpoint = '$userServicePath/api/v1/verification/verify';
  static const String resendOtpEndpoint = '$userServicePath/api/v1/verification/resend';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String isLoggedInKey = 'is_logged_in';
  static const String userDataKey = 'user_data';
  static const String userEmailKey = 'user_email';
  static const String userRoleKey = 'user_role';
  
  // Secure Storage Keys for Biometric
  static const String secureEmailKey = 'secure_email';
  static const String securePasswordKey = 'secure_password';
  static const String biometricEnabledKey = 'biometric_enabled';
  
  // App Info
  static const String appName = 'Smart Academy';
  static const String appVersion = '1.0.0';
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // DateTime Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm:ss';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
}
