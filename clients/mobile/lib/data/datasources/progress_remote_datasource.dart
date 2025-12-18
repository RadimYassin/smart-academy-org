import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../models/progress/progress.dart';

class ProgressRemoteDataSource {
  final ApiClient _apiClient;

  ProgressRemoteDataSource(this._apiClient);

  /// Mark a lesson as complete
  Future<LessonProgressResponse> markLessonComplete(String lessonId) async {
    try {
      Logger.logInfo('Marking lesson as complete: $lessonId');
      final response = await _apiClient.post(
        '${AppConstants.courseServicePath}/api/progress/lessons/$lessonId/complete',
        data: null,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Logger.logInfo('Lesson marked as complete');
        return LessonProgressResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to mark lesson as complete');
      }
    } on DioException catch (e) {
      Logger.logError('Mark lesson complete error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to mark lesson as complete';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Get lesson progress for current student
  Future<LessonProgressResponse> getLessonProgress(String lessonId) async {
    try {
      Logger.logInfo('Fetching lesson progress: $lessonId');
      final response = await _apiClient.get(
        '${AppConstants.courseServicePath}/api/progress/lessons/$lessonId',
      );
      if (response.statusCode == 200) {
        return LessonProgressResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load lesson progress');
      }
    } on DioException catch (e) {
      Logger.logError('Get lesson progress error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to load progress';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Get course progress for current student
  Future<CourseProgressResponse> getCourseProgress(String courseId) async {
    try {
      Logger.logInfo('Fetching course progress: $courseId');
      final response = await _apiClient.get(
        '${AppConstants.courseServicePath}/api/progress/courses/$courseId',
      );
      if (response.statusCode == 200) {
        return CourseProgressResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load course progress');
      }
    } on DioException catch (e) {
      Logger.logError('Get course progress error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to load progress';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Get all lesson progress for a course
  Future<List<LessonProgressResponse>> getAllLessonProgressForCourse(String courseId) async {
    try {
      Logger.logInfo('Fetching all lesson progress for course: $courseId');
      final response = await _apiClient.get(
        '${AppConstants.courseServicePath}/api/progress/courses/$courseId/lessons',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        Logger.logInfo('Fetched ${data.length} lesson progress records');
        return data.map((json) => LessonProgressResponse.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load lesson progress');
      }
    } on DioException catch (e) {
      Logger.logError('Get all lesson progress error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to load progress';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }
}

