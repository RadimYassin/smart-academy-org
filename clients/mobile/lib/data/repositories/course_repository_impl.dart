import '../../core/utils/logger.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/course_remote_datasource.dart';
import '../models/course/course.dart';
import '../models/course/module.dart';
import '../models/course/lesson.dart';
import '../models/course/lesson_content.dart';
import '../models/course/quiz.dart';
import '../models/course/question.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDataSource _remoteDataSource;

  CourseRepositoryImpl(this._remoteDataSource);

  // Course operations
  @override
  Future<List<Course>> getAllCourses() async {
    try {
      return await _remoteDataSource.getAllCourses();
    } catch (e) {
      Logger.logError('Repository get all courses error', error: e);
      rethrow;
    }
  }

  @override
  Future<List<Course>> getTeacherCourses(int teacherId) async {
    try {
      return await _remoteDataSource.getTeacherCourses(teacherId);
    } catch (e) {
      Logger.logError('Repository get teacher courses error', error: e);
      rethrow;
    }
  }

  @override
  Future<Course> getCourseById(String courseId) async {
    try {
      return await _remoteDataSource.getCourseById(courseId);
    } catch (e) {
      Logger.logError('Repository get course by ID error', error: e);
      rethrow;
    }
  }

  @override
  Future<Course> createCourse(CreateCourseRequest request) async {
    try {
      return await _remoteDataSource.createCourse(request);
    } catch (e) {
      Logger.logError('Repository create course error', error: e);
      rethrow;
    }
  }

  @override
  Future<Course> updateCourse(String courseId, Map<String, dynamic> courseData) async {
    try {
      return await _remoteDataSource.updateCourse(courseId, courseData);
    } catch (e) {
      Logger.logError('Repository update course error', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteCourse(String courseId) async {
    try {
      await _remoteDataSource.deleteCourse(courseId);
    } catch (e) {
      Logger.logError('Repository delete course error', error: e);
      rethrow;
    }
  }

  // Module operations
  @override
  Future<List<Module>> getModulesByCourse(String courseId) async {
    try {
      return await _remoteDataSource.getModulesByCourse(courseId);
    } catch (e) {
      Logger.logError('Repository get modules error', error: e);
      rethrow;
    }
  }

  @override
  Future<Module> createModule(String courseId, CreateModuleRequest request) async {
    try {
      return await _remoteDataSource.createModule(courseId, request);
    } catch (e) {
      Logger.logError('Repository create module error', error: e);
      rethrow;
    }
  }

  @override
  Future<Module> updateModule(String courseId, String moduleId, Map<String, dynamic> moduleData) async {
    try {
      return await _remoteDataSource.updateModule(courseId, moduleId, moduleData);
    } catch (e) {
      Logger.logError('Repository update module error', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteModule(String courseId, String moduleId) async {
    try {
      await _remoteDataSource.deleteModule(courseId, moduleId);
    } catch (e) {
      Logger.logError('Repository delete module error', error: e);
      rethrow;
    }
  }

  // Lesson operations
  @override
  Future<List<Lesson>> getLessonsByModule(String moduleId) async {
    try {
      return await _remoteDataSource.getLessonsByModule(moduleId);
    } catch (e) {
      Logger.logError('Repository get lessons error', error: e);
      rethrow;
    }
  }

  @override
  Future<Lesson> getLessonById(String lessonId) async {
    try {
      return await _remoteDataSource.getLessonById(lessonId);
    } catch (e) {
      Logger.logError('Repository get lesson by ID error', error: e);
      rethrow;
    }
  }

  @override
  Future<Lesson> createLesson(String moduleId, CreateLessonRequest request) async {
    try {
      return await _remoteDataSource.createLesson(moduleId, request);
    } catch (e) {
      Logger.logError('Repository create lesson error', error: e);
      rethrow;
    }
  }

  @override
  Future<Lesson> updateLesson(String moduleId, String lessonId, Map<String, dynamic> lessonData) async {
    try {
      return await _remoteDataSource.updateLesson(moduleId, lessonId, lessonData);
    } catch (e) {
      Logger.logError('Repository update lesson error', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteLesson(String moduleId, String lessonId) async {
    try {
      await _remoteDataSource.deleteLesson(moduleId, lessonId);
    } catch (e) {
      Logger.logError('Repository delete lesson error', error: e);
      rethrow;
    }
  }

  // Lesson Content operations
  @override
  Future<List<LessonContent>> getContentByLesson(String lessonId) async {
    try {
      return await _remoteDataSource.getContentByLesson(lessonId);
    } catch (e) {
      Logger.logError('Repository get content error', error: e);
      rethrow;
    }
  }

  @override
  Future<LessonContent> createContent(String lessonId, CreateLessonContentRequest request) async {
    try {
      return await _remoteDataSource.createContent(lessonId, request);
    } catch (e) {
      Logger.logError('Repository create content error', error: e);
      rethrow;
    }
  }

  @override
  Future<LessonContent> updateContent(String lessonId, String contentId, Map<String, dynamic> contentData) async {
    try {
      return await _remoteDataSource.updateContent(lessonId, contentId, contentData);
    } catch (e) {
      Logger.logError('Repository update content error', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteContent(String lessonId, String contentId) async {
    try {
      await _remoteDataSource.deleteContent(lessonId, contentId);
    } catch (e) {
      Logger.logError('Repository delete content error', error: e);
      rethrow;
    }
  }

  // Quiz operations
  @override
  Future<List<Quiz>> getQuizzesByCourse(String courseId) async {
    try {
      return await _remoteDataSource.getQuizzesByCourse(courseId);
    } catch (e) {
      Logger.logError('Repository get quizzes error', error: e);
      rethrow;
    }
  }

  @override
  Future<Quiz> getQuizById(String courseId, String quizId) async {
    try {
      return await _remoteDataSource.getQuizById(courseId, quizId);
    } catch (e) {
      Logger.logError('Repository get quiz by ID error', error: e);
      rethrow;
    }
  }

  @override
  Future<Quiz> createQuiz(String courseId, CreateQuizRequest request) async {
    try {
      return await _remoteDataSource.createQuiz(courseId, request);
    } catch (e) {
      Logger.logError('Repository create quiz error', error: e);
      rethrow;
    }
  }

  @override
  Future<Quiz> updateQuiz(String courseId, String quizId, Map<String, dynamic> quizData) async {
    try {
      return await _remoteDataSource.updateQuiz(courseId, quizId, quizData);
    } catch (e) {
      Logger.logError('Repository update quiz error', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteQuiz(String courseId, String quizId) async {
    try {
      await _remoteDataSource.deleteQuiz(courseId, quizId);
    } catch (e) {
      Logger.logError('Repository delete quiz error', error: e);
      rethrow;
    }
  }

  // Question operations
  @override
  Future<List<Question>> getQuestionsByQuiz(String quizId) async {
    try {
      return await _remoteDataSource.getQuestionsByQuiz(quizId);
    } catch (e) {
      Logger.logError('Repository get questions error', error: e);
      rethrow;
    }
  }

  @override
  Future<Question> createQuestion(String quizId, CreateQuestionRequest request) async {
    try {
      return await _remoteDataSource.createQuestion(quizId, request);
    } catch (e) {
      Logger.logError('Repository create question error', error: e);
      rethrow;
    }
  }

  @override
  Future<Question> updateQuestion(String quizId, String questionId, Map<String, dynamic> questionData) async {
    try {
      return await _remoteDataSource.updateQuestion(quizId, questionId, questionData);
    } catch (e) {
      Logger.logError('Repository update question error', error: e);
      rethrow;
    }
  }

  @override
  Future<void> deleteQuestion(String quizId, String questionId) async {
    try {
      await _remoteDataSource.deleteQuestion(quizId, questionId);
    } catch (e) {
      Logger.logError('Repository delete question error', error: e);
      rethrow;
    }
  }
}

