import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../models/course/course.dart';
import '../models/course/module.dart';
import '../models/course/lesson.dart';
import '../models/course/lesson_content.dart';
import '../models/course/quiz.dart';
import '../models/course/question.dart';
import '../models/course/quiz_attempt.dart';

class CourseRemoteDataSource {
  final ApiClient _apiClient;

  CourseRemoteDataSource(this._apiClient);

  // ============================================================================
  // Course API
  // ============================================================================

  /// Get all courses
  Future<List<Course>> getAllCourses() async {
    try {
      Logger.logInfo('Fetching all courses');
      final response = await _apiClient.get('${AppConstants.courseServicePath}/courses');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        Logger.logInfo('Fetched ${data.length} courses');
        return data.map((json) => Course.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load courses');
      }
    } on DioException catch (e) {
      Logger.logError('Get all courses error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to load courses';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Get courses by teacher ID
  Future<List<Course>> getTeacherCourses(int teacherId) async {
    try {
      Logger.logInfo('Fetching courses for teacher: $teacherId');
      final response = await _apiClient.get(
        '${AppConstants.courseServicePath}/courses/teacher/$teacherId',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        Logger.logInfo('Fetched ${data.length} courses for teacher');
        return data.map((json) => Course.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load teacher courses');
      }
    } on DioException catch (e) {
      Logger.logError('Get teacher courses error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to load courses';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Get course by ID
  Future<Course> getCourseById(String courseId) async {
    try {
      Logger.logInfo('Fetching course: $courseId');
      final response = await _apiClient.get(
        '${AppConstants.courseServicePath}/courses/$courseId',
      );
      if (response.statusCode == 200) {
        return Course.fromJson(response.data);
      } else {
        throw Exception('Failed to load course');
      }
    } on DioException catch (e) {
      Logger.logError('Get course by ID error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to load course';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Create new course
  Future<Course> createCourse(CreateCourseRequest request) async {
    try {
      Logger.logInfo('Creating course: ${request.title}');
      final response = await _apiClient.post(
        '${AppConstants.courseServicePath}/courses',
        data: request.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Logger.logInfo('Course created successfully');
        return Course.fromJson(response.data);
      } else {
        throw Exception('Failed to create course');
      }
    } on DioException catch (e) {
      Logger.logError('Create course error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to create course';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Update course
  Future<Course> updateCourse(String courseId, Map<String, dynamic> courseData) async {
    try {
      Logger.logInfo('Updating course: $courseId');
      final response = await _apiClient.put(
        '${AppConstants.courseServicePath}/courses/$courseId',
        data: courseData,
      );
      if (response.statusCode == 200) {
        Logger.logInfo('Course updated successfully');
        return Course.fromJson(response.data);
      } else {
        throw Exception('Failed to update course');
      }
    } on DioException catch (e) {
      Logger.logError('Update course error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to update course';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Delete course
  Future<void> deleteCourse(String courseId) async {
    try {
      Logger.logInfo('Deleting course: $courseId');
      final response = await _apiClient.delete(
        '${AppConstants.courseServicePath}/courses/$courseId',
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete course');
      }
      Logger.logInfo('Course deleted successfully');
    } on DioException catch (e) {
      Logger.logError('Delete course error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to delete course';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  // ============================================================================
  // Module API
  // ============================================================================

  /// Get modules for a course
  Future<List<Module>> getModulesByCourse(String courseId) async {
    try {
      Logger.logInfo('Fetching modules for course: $courseId');
      final response = await _apiClient.get(
        '${AppConstants.courseServicePath}/courses/$courseId/modules',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Module.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load modules');
      }
    } on DioException catch (e) {
      Logger.logError('Get modules error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to load modules';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Create module
  Future<Module> createModule(String courseId, CreateModuleRequest request) async {
    try {
      Logger.logInfo('Creating module: ${request.title}');
      final response = await _apiClient.post(
        '${AppConstants.courseServicePath}/courses/$courseId/modules',
        data: request.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Module.fromJson(response.data);
      } else {
        throw Exception('Failed to create module');
      }
    } on DioException catch (e) {
      Logger.logError('Create module error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to create module';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Update module
  Future<Module> updateModule(String courseId, String moduleId, Map<String, dynamic> moduleData) async {
    try {
      Logger.logInfo('Updating module: $moduleId');
      final response = await _apiClient.put(
        '${AppConstants.courseServicePath}/courses/$courseId/modules/$moduleId',
        data: moduleData,
      );
      if (response.statusCode == 200) {
        return Module.fromJson(response.data);
      } else {
        throw Exception('Failed to update module');
      }
    } on DioException catch (e) {
      Logger.logError('Update module error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to update module';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Delete module
  Future<void> deleteModule(String courseId, String moduleId) async {
    try {
      Logger.logInfo('Deleting module: $moduleId');
      final response = await _apiClient.delete(
        '${AppConstants.courseServicePath}/courses/$courseId/modules/$moduleId',
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete module');
      }
    } on DioException catch (e) {
      Logger.logError('Delete module error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to delete module';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  // ============================================================================
  // Lesson API
  // ============================================================================

  /// Get lessons for a module
  Future<List<Lesson>> getLessonsByModule(String moduleId) async {
    try {
      Logger.logInfo('Fetching lessons for module: $moduleId');
      final response = await _apiClient.get(
        '${AppConstants.courseServicePath}/modules/$moduleId/lessons',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Lesson.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load lessons');
      }
    } on DioException catch (e) {
      Logger.logError('Get lessons error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to load lessons';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Get lesson by ID
  Future<Lesson> getLessonById(String lessonId) async {
    try {
      Logger.logInfo('Fetching lesson: $lessonId');
      final response = await _apiClient.get(
        '${AppConstants.courseServicePath}/lessons/$lessonId',
      );
      if (response.statusCode == 200) {
        return Lesson.fromJson(response.data);
      } else {
        throw Exception('Failed to load lesson');
      }
    } on DioException catch (e) {
      Logger.logError('Get lesson by ID error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to load lesson';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Create lesson
  Future<Lesson> createLesson(String moduleId, CreateLessonRequest request) async {
    try {
      Logger.logInfo('Creating lesson: ${request.title}');
      final response = await _apiClient.post(
        '${AppConstants.courseServicePath}/modules/$moduleId/lessons',
        data: request.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Lesson.fromJson(response.data);
      } else {
        throw Exception('Failed to create lesson');
      }
    } on DioException catch (e) {
      Logger.logError('Create lesson error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to create lesson';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Update lesson
  Future<Lesson> updateLesson(String moduleId, String lessonId, Map<String, dynamic> lessonData) async {
    try {
      Logger.logInfo('Updating lesson: $lessonId');
      final response = await _apiClient.put(
        '${AppConstants.courseServicePath}/modules/$moduleId/lessons/$lessonId',
        data: lessonData,
      );
      if (response.statusCode == 200) {
        return Lesson.fromJson(response.data);
      } else {
        throw Exception('Failed to update lesson');
      }
    } on DioException catch (e) {
      Logger.logError('Update lesson error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to update lesson';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Delete lesson
  Future<void> deleteLesson(String moduleId, String lessonId) async {
    try {
      Logger.logInfo('Deleting lesson: $lessonId');
      final response = await _apiClient.delete(
        '${AppConstants.courseServicePath}/modules/$moduleId/lessons/$lessonId',
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete lesson');
      }
    } on DioException catch (e) {
      Logger.logError('Delete lesson error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to delete lesson';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  // ============================================================================
  // Lesson Content API
  // ============================================================================

  /// Get content for a lesson
  Future<List<LessonContent>> getContentByLesson(String lessonId) async {
    try {
      Logger.logInfo('Fetching content for lesson: $lessonId');
      final response = await _apiClient.get(
        '${AppConstants.courseServicePath}/lessons/$lessonId/content',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => LessonContent.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load lesson content');
      }
    } on DioException catch (e) {
      Logger.logError('Get lesson content error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to load content';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Create lesson content
  Future<LessonContent> createContent(String lessonId, CreateLessonContentRequest request) async {
    try {
      Logger.logInfo('Creating content for lesson: $lessonId');
      final response = await _apiClient.post(
        '${AppConstants.courseServicePath}/lessons/$lessonId/content',
        data: request.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return LessonContent.fromJson(response.data);
      } else {
        throw Exception('Failed to create content');
      }
    } on DioException catch (e) {
      Logger.logError('Create content error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to create content';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Update lesson content
  Future<LessonContent> updateContent(String lessonId, String contentId, Map<String, dynamic> contentData) async {
    try {
      Logger.logInfo('Updating content: $contentId');
      final response = await _apiClient.put(
        '${AppConstants.courseServicePath}/lessons/$lessonId/content/$contentId',
        data: contentData,
      );
      if (response.statusCode == 200) {
        return LessonContent.fromJson(response.data);
      } else {
        throw Exception('Failed to update content');
      }
    } on DioException catch (e) {
      Logger.logError('Update content error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to update content';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Delete lesson content
  Future<void> deleteContent(String lessonId, String contentId) async {
    try {
      Logger.logInfo('Deleting content: $contentId');
      final response = await _apiClient.delete(
        '${AppConstants.courseServicePath}/lessons/$lessonId/content/$contentId',
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete content');
      }
    } on DioException catch (e) {
      Logger.logError('Delete content error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to delete content';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  // ============================================================================
  // Quiz API
  // ============================================================================

  /// Get quizzes for a course
  Future<List<Quiz>> getQuizzesByCourse(String courseId) async {
    try {
      Logger.logInfo('Fetching quizzes for course: $courseId');
      final response = await _apiClient.get(
        '${AppConstants.courseServicePath}/courses/$courseId/quizzes',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Quiz.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load quizzes');
      }
    } on DioException catch (e) {
      Logger.logError('Get quizzes error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to load quizzes';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Get quiz by ID
  Future<Quiz> getQuizById(String courseId, String quizId) async {
    try {
      Logger.logInfo('Fetching quiz: $quizId');
      final response = await _apiClient.get(
        '${AppConstants.courseServicePath}/courses/$courseId/quizzes/$quizId',
      );
      if (response.statusCode == 200) {
        return Quiz.fromJson(response.data);
      } else {
        throw Exception('Failed to load quiz');
      }
    } on DioException catch (e) {
      Logger.logError('Get quiz by ID error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to load quiz';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Create quiz
  Future<Quiz> createQuiz(String courseId, CreateQuizRequest request) async {
    try {
      Logger.logInfo('Creating quiz: ${request.title}');
      final response = await _apiClient.post(
        '${AppConstants.courseServicePath}/courses/$courseId/quizzes',
        data: request.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Quiz.fromJson(response.data);
      } else {
        throw Exception('Failed to create quiz');
      }
    } on DioException catch (e) {
      Logger.logError('Create quiz error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to create quiz';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Update quiz
  Future<Quiz> updateQuiz(String courseId, String quizId, Map<String, dynamic> quizData) async {
    try {
      Logger.logInfo('Updating quiz: $quizId');
      final response = await _apiClient.put(
        '${AppConstants.courseServicePath}/courses/$courseId/quizzes/$quizId',
        data: quizData,
      );
      if (response.statusCode == 200) {
        return Quiz.fromJson(response.data);
      } else {
        throw Exception('Failed to update quiz');
      }
    } on DioException catch (e) {
      Logger.logError('Update quiz error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to update quiz';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Delete quiz
  Future<void> deleteQuiz(String courseId, String quizId) async {
    try {
      Logger.logInfo('Deleting quiz: $quizId');
      final response = await _apiClient.delete(
        '${AppConstants.courseServicePath}/courses/$courseId/quizzes/$quizId',
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete quiz');
      }
    } on DioException catch (e) {
      Logger.logError('Delete quiz error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to delete quiz';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  // ============================================================================
  // Question API
  // ============================================================================

  /// Get questions for a quiz
  Future<List<Question>> getQuestionsByQuiz(String quizId) async {
    try {
      Logger.logInfo('Fetching questions for quiz: $quizId');
      final response = await _apiClient.get(
        '${AppConstants.courseServicePath}/quizzes/$quizId/questions',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Question.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load questions');
      }
    } on DioException catch (e) {
      Logger.logError('Get questions error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to load questions';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Create question
  Future<Question> createQuestion(String quizId, CreateQuestionRequest request) async {
    try {
      Logger.logInfo('Creating question for quiz: $quizId');
      final response = await _apiClient.post(
        '${AppConstants.courseServicePath}/quizzes/$quizId/questions',
        data: request.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Question.fromJson(response.data);
      } else {
        throw Exception('Failed to create question');
      }
    } on DioException catch (e) {
      Logger.logError('Create question error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to create question';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Update question
  Future<Question> updateQuestion(String quizId, String questionId, Map<String, dynamic> questionData) async {
    try {
      Logger.logInfo('Updating question: $questionId');
      final response = await _apiClient.put(
        '${AppConstants.courseServicePath}/quizzes/$quizId/questions/$questionId',
        data: questionData,
      );
      if (response.statusCode == 200) {
        return Question.fromJson(response.data);
      } else {
        throw Exception('Failed to update question');
      }
    } on DioException catch (e) {
      Logger.logError('Update question error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to update question';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Delete question
  Future<void> deleteQuestion(String quizId, String questionId) async {
    try {
      Logger.logInfo('Deleting question: $questionId');
      final response = await _apiClient.delete(
        '${AppConstants.courseServicePath}/quizzes/$quizId/questions/$questionId',
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete question');
      }
    } on DioException catch (e) {
      Logger.logError('Delete question error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to delete question';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  // ============================================================================
  // Quiz Attempt API
  // ============================================================================

  /// Start a new quiz attempt
  Future<QuizAttempt> startQuizAttempt(String quizId) async {
    try {
      Logger.logInfo('Starting quiz attempt for quiz: $quizId');
      final response = await _apiClient.post(
        '${AppConstants.courseServicePath}/api/quiz-attempts/start/$quizId',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Logger.logInfo('Quiz attempt started successfully');
        return QuizAttempt.fromJson(response.data);
      } else {
        throw Exception('Failed to start quiz attempt');
      }
    } on DioException catch (e) {
      Logger.logError('Start quiz attempt error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to start quiz attempt';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Submit quiz attempt
  Future<QuizAttempt> submitQuizAttempt(String attemptId, SubmitQuizAttemptRequest request) async {
    try {
      Logger.logInfo('Submitting quiz attempt: $attemptId');
      final response = await _apiClient.post(
        '${AppConstants.courseServicePath}/api/quiz-attempts/$attemptId/submit',
        data: request.toJson(),
      );
      if (response.statusCode == 200) {
        Logger.logInfo('Quiz attempt submitted successfully');
        return QuizAttempt.fromJson(response.data);
      } else {
        throw Exception('Failed to submit quiz attempt');
      }
    } on DioException catch (e) {
      Logger.logError('Submit quiz attempt error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to submit quiz attempt';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Get student's all quiz attempts
  Future<List<QuizAttempt>> getStudentAttempts(int studentId) async {
    try {
      Logger.logInfo('Fetching quiz attempts for student: $studentId');
      final response = await _apiClient.get(
        '${AppConstants.courseServicePath}/api/quiz-attempts/student/$studentId',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        Logger.logInfo('Fetched ${data.length} quiz attempts');
        return data.map((json) => QuizAttempt.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load quiz attempts');
      }
    } on DioException catch (e) {
      Logger.logError('Get student attempts error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to load quiz attempts';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Get student's attempts for a specific quiz
  Future<List<QuizAttempt>> getStudentQuizAttempts(int studentId, String quizId) async {
    try {
      Logger.logInfo('Fetching quiz attempts for student $studentId and quiz $quizId');
      final response = await _apiClient.get(
        '${AppConstants.courseServicePath}/api/quiz-attempts/student/$studentId/quiz/$quizId',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        Logger.logInfo('Fetched ${data.length} quiz attempts');
        return data.map((json) => QuizAttempt.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load quiz attempts');
      }
    } on DioException catch (e) {
      Logger.logError('Get student quiz attempts error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to load quiz attempts';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }

  /// Get attempt details
  Future<QuizAttempt> getAttemptDetails(String attemptId) async {
    try {
      Logger.logInfo('Fetching quiz attempt details: $attemptId');
      final response = await _apiClient.get(
        '${AppConstants.courseServicePath}/api/quiz-attempts/$attemptId',
      );
      if (response.statusCode == 200) {
        return QuizAttempt.fromJson(response.data);
      } else {
        throw Exception('Failed to load attempt details');
      }
    } on DioException catch (e) {
      Logger.logError('Get attempt details error', error: e);
      if (e.response != null) {
        final message = e.response!.data?['message'] ?? 'Failed to load attempt details';
        throw Exception(message);
      } else {
        throw Exception('Network error. Please check your connection.');
      }
    }
  }
}

