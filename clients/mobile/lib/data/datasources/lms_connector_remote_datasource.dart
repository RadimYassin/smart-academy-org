import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../models/lms/lms_models.dart';

class LMSConnectorRemoteDataSource {
  final ApiClient _apiClient;

  LMSConnectorRemoteDataSource(this._apiClient);

  // ============================================================================
  // Ingestion APIs
  // ============================================================================

  /// Health check for LMS connector service
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      Logger.logInfo('Checking LMS connector health');
      
      final response = await _apiClient.get(
        '${AppConstants.lmsConnectorPath}/ingestion/health',
      );

      if (response.statusCode == 200 && response.data != null) {
        Logger.logInfo('LMS connector is healthy');
        return response.data;
      } else {
        throw Exception('LMS connector health check failed');
      }
    } on DioException catch (e) {
      Logger.logError('LMS health check error', error: e);
      throw Exception('LMS connector unavailable');
    }
  }

  /// Pull all data from Moodle for AI models
  Future<LMSDataResponse> pullDataFromMoodle() async {
    try {
      Logger.logInfo('Pulling data from Moodle');
      
      final response = await _apiClient.post(
        '${AppConstants.lmsConnectorPath}/ingestion/pull',
      );

      if (response.statusCode == 200 && response.data != null) {
        Logger.logInfo('Moodle data pulled successfully');
        return LMSDataResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to pull Moodle data');
      }
    } on DioException catch (e) {
      Logger.logError('Pull Moodle data error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to pull data';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Sync course students from Moodle
  Future<SyncCourseResponse> syncCourseStudents(int courseId) async {
    try {
      Logger.logInfo('Syncing course students: $courseId');
      
      final response = await _apiClient.post(
        '${AppConstants.lmsConnectorPath}/ingestion/sync-course-students/$courseId',
      );

      if (response.statusCode == 200 && response.data != null) {
        Logger.logInfo('Course students synced successfully');
        return SyncCourseResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to sync course students');
      }
    } on DioException catch (e) {
      Logger.logError('Sync course students error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to sync students';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Get all AI-ready student data
  Future<List<AIStudentData>> getAllAIData() async {
    try {
      Logger.logInfo('Fetching all AI student data');
      
      final response = await _apiClient.get(
        '${AppConstants.lmsConnectorPath}/ingestion/ai-data',
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        Logger.logInfo('Fetched ${data.length} AI student records');
        return data.map((json) => AIStudentData.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch AI data');
      }
    } on DioException catch (e) {
      Logger.logError('Get AI data error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to fetch AI data';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Get AI data for a specific student
  Future<AIStudentData> getStudentAIData(int studentId) async {
    try {
      Logger.logInfo('Fetching AI data for student: $studentId');
      
      final response = await _apiClient.get(
        '${AppConstants.lmsConnectorPath}/ingestion/ai-data/student/$studentId',
      );

      if (response.statusCode == 200 && response.data != null) {
        Logger.logInfo('Student AI data fetched successfully');
        return AIStudentData.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch student AI data');
      }
    } on DioException catch (e) {
      Logger.logError('Get student AI data error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to fetch student data';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Export AI data as CSV
  Future<String> exportAIDataAsCSV() async {
    try {
      Logger.logInfo('Exporting AI data as CSV');
      
      final response = await _apiClient.get(
        '${AppConstants.lmsConnectorPath}/ingestion/export-csv',
      );

      if (response.statusCode == 200 && response.data != null) {
        Logger.logInfo('CSV export successful');
        return response.data['csv_data'] as String? ?? response.data.toString();
      } else {
        throw Exception('Failed to export CSV');
      }
    } on DioException catch (e) {
      Logger.logError('Export CSV error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to export CSV';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Get ingestion statistics
  Future<LMSStats> getStats() async {
    try {
      Logger.logInfo('Fetching ingestion statistics');
      
      final response = await _apiClient.get(
        '${AppConstants.lmsConnectorPath}/ingestion/stats',
      );

      if (response.statusCode == 200 && response.data != null) {
        Logger.logInfo('Statistics fetched successfully');
        return LMSStats.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch statistics');
      }
    } on DioException catch (e) {
      Logger.logError('Get stats error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to fetch stats';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }
}
