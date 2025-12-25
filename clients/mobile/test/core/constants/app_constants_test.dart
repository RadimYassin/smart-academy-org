// Unit tests for AppConstants

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    test('has correct base URL', () {
      // Base URL may vary by environment, just verify it's not empty
      expect(AppConstants.baseUrl, isNotEmpty);
      expect(AppConstants.baseUrl, contains('http'));
    });

    test('has correct service paths', () {
      expect(AppConstants.userServicePath, equals('/user-management-service'));
      expect(AppConstants.courseServicePath, equals('/course-service'));
      expect(AppConstants.lmsConnectorPath, equals('/lmsconnector'));
      expect(AppConstants.chatbotServicePath, equals('/chatbot-edu-service'));
    });

    test('has correct timeout durations', () {
      expect(AppConstants.apiTimeout, equals(const Duration(seconds: 30)));
      expect(AppConstants.chatbotTimeout, equals(const Duration(seconds: 120)));
    });

    test('has correct auth endpoints', () {
      expect(
        AppConstants.loginEndpoint,
        equals('/user-management-service/api/v1/auth/login'),
      );
      expect(
        AppConstants.registerEndpoint,
        equals('/user-management-service/api/v1/auth/register'),
      );
      expect(
        AppConstants.refreshTokenEndpoint,
        equals('/user-management-service/api/v1/auth/refresh-token'),
      );
      expect(
        AppConstants.verifyEmailEndpoint,
        equals('/user-management-service/api/v1/verification/verify'),
      );
      expect(
        AppConstants.resendOtpEndpoint,
        equals('/user-management-service/api/v1/verification/resend'),
      );
    });

    test('has correct storage keys', () {
      expect(AppConstants.accessTokenKey, equals('access_token'));
      expect(AppConstants.refreshTokenKey, equals('refresh_token'));
      expect(AppConstants.isLoggedInKey, equals('is_logged_in'));
      expect(AppConstants.userDataKey, equals('user_data'));
      expect(AppConstants.userEmailKey, equals('user_email'));
      expect(AppConstants.userRoleKey, equals('user_role'));
    });

    test('has correct secure storage keys', () {
      expect(AppConstants.secureEmailKey, equals('secure_email'));
      expect(AppConstants.securePasswordKey, equals('secure_password'));
      expect(AppConstants.biometricEnabledKey, equals('biometric_enabled'));
    });

    test('has correct app info', () {
      expect(AppConstants.appName, equals('Smart Academy'));
      expect(AppConstants.appVersion, equals('1.0.0'));
    });

    test('has correct pagination defaults', () {
      expect(AppConstants.defaultPageSize, equals(20));
    });

    test('has correct date-time formats', () {
      expect(AppConstants.dateFormat, equals('yyyy-MM-dd'));
      expect(AppConstants.timeFormat, equals('HH:mm:ss'));
      expect(AppConstants.dateTimeFormat, equals('yyyy-MM-dd HH:mm:ss'));
    });
  });
}
