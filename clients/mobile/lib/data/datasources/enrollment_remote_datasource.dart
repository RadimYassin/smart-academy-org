import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../models/enrollment/enrollment.dart';

class EnrollmentRemoteDataSource {
  final ApiClient _apiClient;

  EnrollmentRemoteDataSource(this._apiClient);

  /// Assign a single student to a course
  Future<Enrollment> assignStudent(AssignStudentRequest request) async {
    try {
      Logger.logInfo('Assigning student ${request.studentId} to course ${request.courseId}');
      final response = await _apiClient.post(
        '${AppConstants.courseServicePath}/api/enrollments/student',
        data: request.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Logger.logInfo('Student assigned successfully');
        return Enrollment.fromJson(response.data);
      } else {
        throw Exception('Failed to assign student');
      }
    } on DioException catch (e) {
      Logger.logError('Assign student error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 
                       e.response!.data?['error'] ?? 
                       'Failed to assign student';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Assign an entire class to a course
  Future<List<Enrollment>> assignClass(AssignClassRequest request) async {
    try {
      Logger.logInfo('Assigning class ${request.classId} to course ${request.courseId}');
      final response = await _apiClient.post(
        '${AppConstants.courseServicePath}/api/enrollments/class',
        data: request.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data;
        Logger.logInfo('Class assigned successfully, ${data.length} enrollments created');
        return data.map((json) => Enrollment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to assign class');
      }
    } on DioException catch (e) {
      Logger.logError('Assign class error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 
                       e.response!.data?['error'] ?? 
                       'Failed to assign class';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Get all enrollments for a specific course
  Future<List<Enrollment>> getCourseEnrollments(String courseId) async {
    try {
      Logger.logInfo('Fetching enrollments for course: $courseId');
      final response = await _apiClient.get(
        '${AppConstants.courseServicePath}/api/enrollments/courses/$courseId',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        Logger.logInfo('Fetched ${data.length} enrollments');
        return data.map((json) => Enrollment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load enrollments');
      }
    } on DioException catch (e) {
      Logger.logError('Get course enrollments error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to load enrollments';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Unenroll a student from a course
  Future<void> unenrollStudent(String courseId, int studentId) async {
    try {
      Logger.logInfo('Unenrolling student $studentId from course $courseId');
      final response = await _apiClient.delete(
        '${AppConstants.courseServicePath}/api/enrollments/courses/$courseId/students/$studentId',
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to unenroll student');
      }
      Logger.logInfo('Student unenrolled successfully');
    } on DioException catch (e) {
      Logger.logError('Unenroll student error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to unenroll student';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Get current student's enrolled courses
  Future<List<Enrollment>> getMyCourses() async {
    try {
      Logger.logInfo('Fetching my enrolled courses');
      final response = await _apiClient.get(
        '${AppConstants.courseServicePath}/api/enrollments/my-courses',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        Logger.logInfo('Fetched ${data.length} enrolled courses');
        return data.map((json) => Enrollment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load enrolled courses');
      }
    } on DioException catch (e) {
      Logger.logError('Get my courses error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to load courses';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }
}

