class AppConstants {
  // API Configuration - Smart Academy Backend
  // Change this IP address to match your backend server
  static const String baseUrl = 'http://192.168.11.131:8888'; // API Gateway URL
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
  
  // AI Services Endpoints (via Gateway)
  static const String aiServicesBasePath = '/ai';
  static const String aiHealthEndpoint = '$aiServicesBasePath/health';
  static const String aiInfoEndpoint = '$aiServicesBasePath/info';
  
  // PrepaData Module
  static const String prepaDataStatusEndpoint = '$aiServicesBasePath/api/prepadata/status';
  static const String prepaDataCleanEndpoint = '$aiServicesBasePath/api/prepadata/clean';
  
  // StudentProfiler Module
  static const String profilerStatusEndpoint = '$aiServicesBasePath/api/profiler/status';
  static const String profilerProfileEndpoint = '$aiServicesBasePath/api/profiler/profile';
  
  // PathPredictor Module
  static const String predictorStatusEndpoint = '$aiServicesBasePath/api/predictor/status';
  static const String predictorTrainEndpoint = '$aiServicesBasePath/api/predictor/train';
  static const String predictorPredictEndpoint = '$aiServicesBasePath/api/predictor/predict';
  
  // RecoBuilder Module
  static const String recommenderStatusEndpoint = '$aiServicesBasePath/api/recommender/status';
  static const String recommenderGenerateEndpoint = '$aiServicesBasePath/api/recommender/generate';
  
  // LMS Connector Endpoints
  static const String lmsConnectorBasePath = '/lmsconnector/ingestion';
  static const String lmsHealthEndpoint = '$lmsConnectorBasePath/health';
  static const String lmsPullDataEndpoint = '$lmsConnectorBasePath/pull';
  static const String lmsAiDataEndpoint = '$lmsConnectorBasePath/ai-data';
  static const String lmsStudentDataEndpoint = '$lmsConnectorBasePath/ai-data/student';
  static const String lmsExportCsvEndpoint = '$lmsConnectorBasePath/export-csv';
  static const String lmsStatsEndpoint = '$lmsConnectorBasePath/stats';
  static const String lmsSyncCourseStudentsEndpoint = '$lmsConnectorBasePath/sync-course-students';
  
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
