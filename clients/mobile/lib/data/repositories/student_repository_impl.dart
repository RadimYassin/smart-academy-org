import '../../core/utils/logger.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/student_remote_datasource.dart';
import '../models/student/student_dto.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentRemoteDataSource _remoteDataSource;

  StudentRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<StudentDto>> getAllStudents() async {
    try {
      return await _remoteDataSource.getAllStudents();
    } catch (e) {
      Logger.logError('Repository get all students error', error: e);
      rethrow;
    }
  }

  @override
  Future<StudentDto> getStudentById(int studentId) async {
    try {
      return await _remoteDataSource.getStudentById(studentId);
    } catch (e) {
      Logger.logError('Repository get student by ID error', error: e);
      rethrow;
    }
  }
}

