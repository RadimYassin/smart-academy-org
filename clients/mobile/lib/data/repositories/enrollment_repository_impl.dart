import '../../core/utils/logger.dart';
import '../../domain/repositories/enrollment_repository.dart';
import '../datasources/enrollment_remote_datasource.dart';
import '../models/enrollment/enrollment.dart';

class EnrollmentRepositoryImpl implements EnrollmentRepository {
  final EnrollmentRemoteDataSource _remoteDataSource;

  EnrollmentRepositoryImpl(this._remoteDataSource);

  @override
  Future<Enrollment> assignStudent(AssignStudentRequest request) async {
    try {
      return await _remoteDataSource.assignStudent(request);
    } catch (e) {
      Logger.logError('Repository assign student error', error: e);
      rethrow;
    }
  }

  @override
  Future<List<Enrollment>> assignClass(AssignClassRequest request) async {
    try {
      return await _remoteDataSource.assignClass(request);
    } catch (e) {
      Logger.logError('Repository assign class error', error: e);
      rethrow;
    }
  }

  @override
  Future<List<Enrollment>> getCourseEnrollments(String courseId) async {
    try {
      return await _remoteDataSource.getCourseEnrollments(courseId);
    } catch (e) {
      Logger.logError('Repository get course enrollments error', error: e);
      rethrow;
    }
  }

  @override
  Future<void> unenrollStudent(String courseId, int studentId) async {
    try {
      await _remoteDataSource.unenrollStudent(courseId, studentId);
    } catch (e) {
      Logger.logError('Repository unenroll student error', error: e);
      rethrow;
    }
  }

  @override
  Future<List<Enrollment>> getMyCourses() async {
    try {
      return await _remoteDataSource.getMyCourses();
    } catch (e) {
      Logger.logError('Repository get my courses error', error: e);
      rethrow;
    }
  }
}

