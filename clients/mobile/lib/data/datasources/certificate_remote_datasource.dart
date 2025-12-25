import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../models/certificate/certificate.dart';

class CertificateRemoteDataSource {
  final ApiClient _apiClient;

  CertificateRemoteDataSource(this._apiClient);

  /// Check certificate eligibility for a course
  Future<CertificateEligibility> checkEligibility(String courseId) async {
    try {
      Logger.logInfo('Checking certificate eligibility for course: $courseId');
      
      final response = await _apiClient.get(
        '${AppConstants.courseServicePath}/api/certificates/eligibility/$courseId',
      );

      if (response.statusCode == 200 && response.data != null) {
        Logger.logInfo('Certificate eligibility fetched successfully');
        return CertificateEligibility.fromJson(response.data);
      } else {
        throw Exception('Failed to check certificate eligibility');
      }
    } on DioException catch (e) {
      Logger.logError('Check eligibility error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to check eligibility';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Generate certificate for a course
  Future<Certificate> generateCertificate(String courseId) async {
    try {
      Logger.logInfo('Generating certificate for course: $courseId');
      
      final response = await _apiClient.post(
        '${AppConstants.courseServicePath}/api/certificates/generate/$courseId',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Logger.logInfo('Certificate generated successfully');
        return Certificate.fromJson(response.data);
      } else {
        throw Exception('Failed to generate certificate');
      }
    } on DioException catch (e) {
      Logger.logError('Generate certificate error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to generate certificate';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Get all student's certificates
  Future<List<Certificate>> getMyCertificates() async {
    try {
      Logger.logInfo('Fetching my certificates');
      
      final response = await _apiClient.get(
        '${AppConstants.courseServicePath}/api/certificates/my-certificates',
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        Logger.logInfo('Fetched ${data.length} certificates');
        return data.map((json) => Certificate.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch certificates');
      }
    } on DioException catch (e) {
      Logger.logError('Get certificates error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to fetch certificates';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Get certificate details by ID
  Future<Certificate> getCertificate(String certificateId) async {
    try {
      Logger.logInfo('Fetching certificate: $certificateId');
      
      final response = await _apiClient.get(
        '${AppConstants.courseServicePath}/api/certificates/$certificateId',
      );

      if (response.statusCode == 200 && response.data != null) {
        return Certificate.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch certificate');
      }
    } on DioException catch (e) {
      Logger.logError('Get certificate error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to fetch certificate';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Download certificate as PDF
  Future<List<int>> downloadCertificate(String certificateId) async {
    try {
      Logger.logInfo('Downloading certificate: $certificateId');
      
      final response = await _apiClient.dio.get(
        '${AppConstants.courseServicePath}/api/certificates/$certificateId/download',
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        Logger.logInfo('Certificate downloaded successfully');
        return response.data;
      } else {
        throw Exception('Failed to download certificate');
      }
    } on DioException catch (e) {
      Logger.logError('Download certificate error', error: e);
      
      if (e.response != null) {
        throw Exception('Failed to download certificate');
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Verify certificate with verification code (Public API)
  Future<CertificateVerification> verifyCertificate(String verificationCode) async {
    try {
      Logger.logInfo('Verifying certificate: $verificationCode');
      
      final response = await _apiClient.get(
        '${AppConstants.courseServicePath}/api/certificates/verify/$verificationCode',
      );

      if (response.statusCode == 200 && response.data != null) {
        Logger.logInfo('Certificate verified successfully');
        return CertificateVerification.fromJson(response.data);
      } else {
        throw Exception('Invalid certificate');
      }
    } on DioException catch (e) {
      Logger.logError('Verify certificate error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Certificate not found or invalid';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }
}
