import '../../core/utils/logger.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_remote_datasource.dart';
import '../models/progress/progress.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final ProgressRemoteDataSource _remoteDataSource;

  ProgressRepositoryImpl(this._remoteDataSource);

  @override
  Future<LessonProgressResponse> markLessonComplete(String lessonId) async {
    try {
      return await _remoteDataSource.markLessonComplete(lessonId);
    } catch (e) {
      Logger.logError('Repository mark lesson complete error', error: e);
      rethrow;
    }
  }

  @override
  Future<LessonProgressResponse> getLessonProgress(String lessonId) async {
    try {
      return await _remoteDataSource.getLessonProgress(lessonId);
    } catch (e) {
      Logger.logError('Repository get lesson progress error', error: e);
      rethrow;
    }
  }

  @override
  Future<CourseProgressResponse> getCourseProgress(String courseId) async {
    try {
      return await _remoteDataSource.getCourseProgress(courseId);
    } catch (e) {
      Logger.logError('Repository get course progress error', error: e);
      rethrow;
    }
  }

  @override
  Future<List<LessonProgressResponse>> getAllLessonProgressForCourse(String courseId) async {
    try {
      return await _remoteDataSource.getAllLessonProgressForCourse(courseId);
    } catch (e) {
      Logger.logError('Repository get all lesson progress error', error: e);
      rethrow;
    }
  }
}

