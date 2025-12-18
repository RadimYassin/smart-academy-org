import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../models/student/student_dto.dart';

class StudentRemoteDataSource {
  final ApiClient _apiClient;

  StudentRemoteDataSource(this._apiClient);

  /// Get all students (Admin and Teachers only)
  Future<List<StudentDto>> getAllStudents() async {
    try {
      Logger.logInfo('Fetching all students');
      
      final response = await _apiClient.get(
        '${AppConstants.userServicePath}/api/v1/users/students',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        Logger.logInfo('Fetched ${data.length} students');
        return data.map((json) => StudentDto.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load students');
      }
    } on DioException catch (e) {
      Logger.logError('Get all students error', error: e);
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? 'Failed to load students';
        
        switch (statusCode) {
          case 403:
            throw Exception('You do not have permission to view students');
          case 404:
            throw Exception('Students endpoint not found');
          default:
            throw Exception(message);
        }
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      Logger.logError('Unexpected get students error', error: e);
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  /// Get student by ID
  Future<StudentDto> getStudentById(int studentId) async {
    try {
      Logger.logInfo('Fetching student: $studentId');
      
      final response = await _apiClient.get(
        '${AppConstants.userServicePath}/api/v1/users/$studentId',
      );

      if (response.statusCode == 200) {
        return StudentDto.fromJson(response.data);
      } else {
        throw Exception('Failed to load student');
      }
    } on DioException catch (e) {
      Logger.logError('Get student by ID error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to load student';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }
}

