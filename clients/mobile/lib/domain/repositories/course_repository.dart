import '../../data/models/course/course.dart';
import '../../data/models/course/module.dart';
import '../../data/models/course/lesson.dart';
import '../../data/models/course/lesson_content.dart';
import '../../data/models/course/quiz.dart';
import '../../data/models/course/question.dart';

abstract class CourseRepository {
  // Course operations
  Future<List<Course>> getAllCourses();
  Future<List<Course>> getTeacherCourses(int teacherId);
  Future<Course> getCourseById(String courseId);
  Future<Course> createCourse(CreateCourseRequest request);
  Future<Course> updateCourse(String courseId, Map<String, dynamic> courseData);
  Future<void> deleteCourse(String courseId);

  // Module operations
  Future<List<Module>> getModulesByCourse(String courseId);
  Future<Module> createModule(String courseId, CreateModuleRequest request);
  Future<Module> updateModule(String courseId, String moduleId, Map<String, dynamic> moduleData);
  Future<void> deleteModule(String courseId, String moduleId);

  // Lesson operations
  Future<List<Lesson>> getLessonsByModule(String moduleId);
  Future<Lesson> getLessonById(String lessonId);
  Future<Lesson> createLesson(String moduleId, CreateLessonRequest request);
  Future<Lesson> updateLesson(String moduleId, String lessonId, Map<String, dynamic> lessonData);
  Future<void> deleteLesson(String moduleId, String lessonId);

  // Lesson Content operations
  Future<List<LessonContent>> getContentByLesson(String lessonId);
  Future<LessonContent> createContent(String lessonId, CreateLessonContentRequest request);
  Future<LessonContent> updateContent(String lessonId, String contentId, Map<String, dynamic> contentData);
  Future<void> deleteContent(String lessonId, String contentId);

  // Quiz operations
  Future<List<Quiz>> getQuizzesByCourse(String courseId);
  Future<Quiz> getQuizById(String courseId, String quizId);
  Future<Quiz> createQuiz(String courseId, CreateQuizRequest request);
  Future<Quiz> updateQuiz(String courseId, String quizId, Map<String, dynamic> quizData);
  Future<void> deleteQuiz(String courseId, String quizId);

  // Question operations
  Future<List<Question>> getQuestionsByQuiz(String quizId);
  Future<Question> createQuestion(String quizId, CreateQuestionRequest request);
  Future<Question> updateQuestion(String quizId, String questionId, Map<String, dynamic> questionData);
  Future<void> deleteQuestion(String quizId, String questionId);
}

