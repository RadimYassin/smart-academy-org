import '../../core/utils/logger.dart';
import '../../domain/repositories/class_repository.dart';
import '../datasources/class_remote_datasource.dart';
import '../models/student/student_class.dart';

class ClassRepositoryImpl implements ClassRepository {
  final ClassRemoteDataSource _remoteDataSource;

  ClassRepositoryImpl(this._remoteDataSource);

  @override
  Future<StudentClass> createClass(CreateClassRequest request) async {
    try {
      return await _remoteDataSource.createClass(request);
    } catch (e) {
      Logger.logError('Repository create class error', error: e);
      rethrow;
    }
  }

  @override
  Future<List<StudentClass>> getMyClasses() async {
    try {
      return await _remoteDataSource.getMyClasses();
    } catch (e) {
      Logger.logError('Repository get classes error', error: e);
      rethrow;
    }
  }

  @override
  Future<StudentClass> getClassById(String classId) async {
    try {
      return await _remoteDataSource.getClassById(classId);
    } catch (e) {
      Logger.logError('Repository get class by ID error', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteClass(String classId) async {
    try {
      await _remoteDataSource.deleteClass(classId);
    } catch (e) {
      Logger.logError('Repository delete class error', error: e);
      rethrow;
    }
  }

  @override
  Future<void> addStudentsToClass(String classId, AddStudentsRequest request) async {
    try {
      await _remoteDataSource.addStudentsToClass(classId, request);
    } catch (e) {
      Logger.logError('Repository add students error', error: e);
      rethrow;
    }
  }

  @override
  Future<List<ClassStudent>> getClassStudents(String classId) async {
    try {
      return await _remoteDataSource.getClassStudents(classId);
    } catch (e) {
      Logger.logError('Repository get class students error', error: e);
      rethrow;
    }
  }

  @override
  Future<void> removeStudentFromClass(String classId, int studentId) async {
    try {
      await _remoteDataSource.removeStudentFromClass(classId, studentId);
    } catch (e) {
      Logger.logError('Repository remove student error', error: e);
      rethrow;
    }
  }
}

