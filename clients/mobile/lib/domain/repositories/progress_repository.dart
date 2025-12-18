import '../../data/models/progress/progress.dart';

abstract class ProgressRepository {
  Future<LessonProgressResponse> markLessonComplete(String lessonId);
  Future<LessonProgressResponse> getLessonProgress(String lessonId);
  Future<CourseProgressResponse> getCourseProgress(String courseId);
  Future<List<LessonProgressResponse>> getAllLessonProgressForCourse(String courseId);
}

