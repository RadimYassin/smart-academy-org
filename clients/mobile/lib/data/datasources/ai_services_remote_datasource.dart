import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/logger.dart';
import '../models/ai/ai_models.dart';

class AIServicesRemoteDataSource {
  final ApiClient _apiClient;

  AIServicesRemoteDataSource(this._apiClient);

  // ============================================================================
  // Health & Info APIs
  // ============================================================================

  /// Get AI service health status
  Future<Map<String, dynamic>> getHealthStatus() async {
    try {
      Logger.logInfo('Checking AI service health');
      
      final response = await _apiClient.get('/ai/health');

      if (response.statusCode == 200 && response.data != null) {
        Logger.logInfo('AI service is UP');
        return response.data;
      } else {
        throw Exception('Failed to get AI service health');
      }
    } on DioException catch (e) {
      Logger.logError('AI health check error', error: e);
      
      if (e.response != null) {
        throw Exception('AI service unavailable');
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Get AI service information
  Future<Map<String, dynamic>> getServiceInfo() async {
    try {
      Logger.logInfo('Fetching AI service info');
      
      final response = await _apiClient.get('/ai/info');

      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      } else {
        throw Exception('Failed to get AI service info');
      }
    } on DioException catch (e) {
      Logger.logError('AI service info error', error: e);
      throw Exception('Failed to get service information');
    }
  }

  // ============================================================================
  // PrepaData APIs
  // ============================================================================

  /// Clean and prepare student data
  Future<PrepDataResponse> cleanData(File csvFile, {double threshold = 50.0}) async {
    try {
      Logger.logInfo('Uploading data for cleaning');
      
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(csvFile.path),
        'threshold': threshold,
      });

      final response = await _apiClient.post(
        '/ai/api/prepadata/clean',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 && response.data != null) {
        Logger.logInfo('Data cleaned successfully');
        return PrepDataResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to clean data');
      }
    } on DioException catch (e) {
      Logger.logError('Data cleaning error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to clean data';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Get PrepaData service status
  Future<AIServiceStatus> getPrepDataStatus() async {
    try {
      final response = await _apiClient.get('/ai/api/prepadata/status');

      if (response.statusCode == 200 && response.data != null) {
        return AIServiceStatus.fromJson(response.data);
      } else {
        throw Exception('Failed to get PrepaData status');
      }
    } on DioException catch (e) {
      Logger.logError('PrepaData status error', error: e);
      throw Exception('Failed to get service status');
    }
  }

  // ============================================================================
  // StudentProfiler APIs
  // ============================================================================

  /// Profile students and create clusters
  Future<ProfileResponse> profileStudents(ProfileRequest request) async {
    try {
      Logger.logInfo('Profiling students with ${request.nClusters} clusters');
      
      final response = await _apiClient.post(
        '/ai/api/profiler/profile',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        Logger.logInfo('Student profiling completed');
        return ProfileResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to profile students');
      }
    } on DioException catch (e) {
      Logger.logError('Student profiling error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to profile students';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Get StudentProfiler service status
  Future<AIServiceStatus> getProfilerStatus() async {
    try {
      final response = await _apiClient.get('/ai/api/profiler/status');

      if (response.statusCode == 200 && response.data != null) {
        return AIServiceStatus.fromJson(response.data);
      } else {
        throw Exception('Failed to get Profiler status');
      }
    } on DioException catch (e) {
      Logger.logError('Profiler status error', error: e);
      throw Exception('Failed to get service status');
    }
  }

  // ============================================================================
  // PathPredictor APIs
  // ============================================================================

  /// Train prediction model
  Future<TrainResponse> trainModel(TrainRequest request) async {
    try {
      Logger.logInfo('Training prediction model');
      
      final response = await _apiClient.post(
        '/ai/api/predictor/train',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        Logger.logInfo('Model trained successfully');
        return TrainResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to train model');
      }
    } on DioException catch (e) {
      Logger.logError('Model training error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to train model';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Predict student failure risk
  Future<PredictionResponse> predictStudentRisk(Map<String, dynamic> studentData) async {
    try {
      Logger.logInfo('Predicting student risk for ID: ${studentData['ID']}');
      
      final response = await _apiClient.post(
        '/ai/api/predictor/predict',
        data: PredictionRequest(studentData: studentData).toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        Logger.logInfo('Prediction completed');
        return PredictionResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to predict student risk');
      }
    } on DioException catch (e) {
      Logger.logError('Prediction error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to predict';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Get PathPredictor service status
  Future<AIServiceStatus> getPredictorStatus() async {
    try {
      final response = await _apiClient.get('/ai/api/predictor/status');

      if (response.statusCode == 200 && response.data != null) {
        return AIServiceStatus.fromJson(response.data);
      } else {
        throw Exception('Failed to get Predictor status');
      }
    } on DioException catch (e) {
      Logger.logError('Predictor status error', error: e);
      throw Exception('Failed to get service status');
    }
  }

  // ============================================================================
  // RecoBuilder APIs
  // ============================================================================

  /// Generate personalized recommendations for students
  Future<RecommendationResponse> generateRecommendations(RecommendationRequest request) async {
    try {
      Logger.logInfo('Generating recommendations for ${request.studentIds.length} students');
      
      final response = await _apiClient.post(
        '/ai/api/recommender/generate',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        Logger.logInfo('Recommendations generated successfully');
        return RecommendationResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to generate recommendations');
      }
    } on DioException catch (e) {
      Logger.logError('Recommendation generation error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to generate recommendations';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Get RecoBuilder service status
  Future<AIServiceStatus> getRecommenderStatus() async {
    try {
      final response = await _apiClient.get('/ai/api/recommender/status');

      if (response.statusCode == 200 && response.data != null) {
        return AIServiceStatus.fromJson(response.data);
      } else {
        throw Exception('Failed to get Recommender status');
      }
    } on DioException catch (e) {
      Logger.logError('Recommender status error', error: e);
      throw Exception('Failed to get service status');
    }
  }
}
