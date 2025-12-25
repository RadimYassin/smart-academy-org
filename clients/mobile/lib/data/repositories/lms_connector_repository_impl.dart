import '../../data/datasources/lms_connector_remote_datasource.dart';
import '../../data/models/lms/lms_models.dart';
import '../../domain/repositories/lms_connector_repository.dart';

class LMSConnectorRepositoryImpl implements LMSConnectorRepository {
  final LMSConnectorRemoteDataSource remoteDataSource;

  LMSConnectorRepositoryImpl(this.remoteDataSource);

  @override
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      return await remoteDataSource.healthCheck();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<LMSDataResponse> pullDataFromMoodle() async {
    try {
      return await remoteDataSource.pullDataFromMoodle();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SyncCourseResponse> syncCourseStudents(int courseId) async {
    try {
      return await remoteDataSource.syncCourseStudents(courseId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AIStudentData>> getAllAIData() async {
    try {
      return await remoteDataSource.getAllAIData();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AIStudentData> getStudentAIData(int studentId) async {
    try {
      return await remoteDataSource.getStudentAIData(studentId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> exportAIDataAsCSV() async {
    try {
      return await remoteDataSource.exportAIDataAsCSV();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<LMSStats> getStats() async {
    try {
      return await remoteDataSource.getStats();
    } catch (e) {
      rethrow;
    }
  }
}
