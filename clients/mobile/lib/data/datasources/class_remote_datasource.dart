import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../models/student/student_class.dart';

class ClassRemoteDataSource {
  final ApiClient _apiClient;

  ClassRemoteDataSource(this._apiClient);

  /// Create a new student class
  Future<StudentClass> createClass(CreateClassRequest request) async {
    try {
      Logger.logInfo('Creating class: ${request.name}');
      
      final response = await _apiClient.post(
        '${AppConstants.courseServicePath}/api/classes',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Logger.logInfo('Class created successfully');
        return StudentClass.fromJson(response.data);
      } else {
        throw Exception('Failed to create class');
      }
    } on DioException catch (e) {
      Logger.logError('Create class error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to create class';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      Logger.logError('Unexpected create class error', error: e);
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  /// Get all classes for the authenticated teacher
  Future<List<StudentClass>> getMyClasses() async {
    try {
      Logger.logInfo('Fetching my classes');
      
      final response = await _apiClient.get(
        '${AppConstants.courseServicePath}/api/classes',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        Logger.logInfo('Fetched ${data.length} classes');
        return data.map((json) => StudentClass.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load classes');
      }
    } on DioException catch (e) {
      Logger.logError('Get classes error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to load classes';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    } catch (e) {
      Logger.logError('Unexpected get classes error', error: e);
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  /// Get class by ID
  Future<StudentClass> getClassById(String classId) async {
    try {
      Logger.logInfo('Fetching class: $classId');
      
      final response = await _apiClient.get(
        '${AppConstants.courseServicePath}/api/classes/$classId',
      );

      if (response.statusCode == 200) {
        return StudentClass.fromJson(response.data);
      } else {
        throw Exception('Failed to load class');
      }
    } on DioException catch (e) {
      Logger.logError('Get class by ID error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to load class';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Delete a class
  Future<void> deleteClass(String classId) async {
    try {
      Logger.logInfo('Deleting class: $classId');
      
      final response = await _apiClient.delete(
        '${AppConstants.courseServicePath}/api/classes/$classId',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete class');
      }
      
      Logger.logInfo('Class deleted successfully');
    } on DioException catch (e) {
      Logger.logError('Delete class error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to delete class';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Add students to a class
  Future<void> addStudentsToClass(String classId, AddStudentsRequest request) async {
    try {
      Logger.logInfo('Adding ${request.studentIds.length} students to class: $classId');
      
      final response = await _apiClient.post(
        '${AppConstants.courseServicePath}/api/classes/$classId/students',
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add students to class');
      }
      
      Logger.logInfo('Students added successfully');
    } on DioException catch (e) {
      Logger.logError('Add students to class error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to add students';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Get all students in a class
  Future<List<ClassStudent>> getClassStudents(String classId) async {
    try {
      Logger.logInfo('Fetching students for class: $classId');
      
      final response = await _apiClient.get(
        '${AppConstants.courseServicePath}/api/classes/$classId/students',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        Logger.logInfo('Fetched ${data.length} students');
        return data.map((json) => ClassStudent.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load class students');
      }
    } on DioException catch (e) {
      Logger.logError('Get class students error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to load students';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Remove a student from a class
  Future<void> removeStudentFromClass(String classId, int studentId) async {
    try {
      Logger.logInfo('Removing student $studentId from class: $classId');
      
      final response = await _apiClient.delete(
        '${AppConstants.courseServicePath}/api/classes/$classId/students/$studentId',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to remove student from class');
      }
      
      Logger.logInfo('Student removed successfully');
    } on DioException catch (e) {
      Logger.logError('Remove student from class error', error: e);
      
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to remove student';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }
}

