import '../models/lms/lms_models.dart';

abstract class LMSConnectorRepository {
  /// Health check
  Future<Map<String, dynamic>> healthCheck();

  /// Pull all data from Moodle
  Future<LMSDataResponse> pullDataFromMoodle();

  /// Sync course students
  Future<SyncCourseResponse> syncCourseStudents(int courseId);

  /// Get all AI-ready student data
  Future<List<AIStudentData>> getAllAIData();

  /// Get AI data for specific student
  Future<AIStudentData> getStudentAIData(int studentId);

  /// Export AI data as CSV
  Future<String> exportAIDataAsCSV();

  /// Get ingestion statistics
  Future<LMSStats> getStats();
}
