import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/jwt_utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/course/course.dart';
import '../../../data/models/course/module.dart';
import '../../../data/models/course/lesson.dart';
import '../../../data/models/course/lesson_content.dart';
import '../../../data/models/course/lesson_content.dart';
import '../../../data/models/course/quiz.dart';
import '../../../data/models/course/question.dart';
import '../../../domain/repositories/course_repository.dart';
import '../../../domain/repositories/auth_repository.dart';

class CoursesController extends GetxController {
  // Repositories
  late final CourseRepository _courseRepository;
  late final AuthRepository _authRepository;

  // Courses
  final courses = <Course>[].obs;
  final isLoadingCourses = false.obs;
  final errorMessage = ''.obs;

  // Selected course
  final selectedCourse = Rxn<Course>();
  final courseModules = <Module>[].obs;
  final courseQuizzes = <Quiz>[].obs;
  final isLoadingCourseContent = false.obs;

  // UI State
  final searchQuery = ''.obs;
  final selectedCategory = 'All'.obs;
  final selectedLevel = 'All'.obs;
  final filteredCourses = <Course>[].obs;

  // Modals
  final showCreateCourseModal = false.obs;
  final showEditCourseModal = false.obs;
  final showDeleteCourseModal = false.obs;
  final courseToDelete = Rxn<Course>();
  final courseToEdit = Rxn<Course>();

  // Form states
  final newCourse = Rx<CreateCourseRequest>(CreateCourseRequest(
    title: '',
    description: '',
    category: '',
    level: 'BEGINNER',
  ));

  @override
  void onInit() {
    super.onInit();
    _courseRepository = Get.find<CourseRepository>();
    _authRepository = Get.find<AuthRepository>();
    loadCourses();
  }

  /// Load courses based on user role
  Future<void> loadCourses() async {
    try {
      isLoadingCourses.value = true;
      errorMessage.value = '';

      // Get user role from storage
      final storage = Get.find<GetStorage>();
      final userData = storage.read<Map<dynamic, dynamic>>('user_data');
      final role = userData?['role']?.toString().toUpperCase() ?? 'STUDENT';
      
      // Get userId from JWT token
      int? userId;
      final accessToken = storage.read<String>(AppConstants.accessTokenKey);
      if (accessToken != null && accessToken.isNotEmpty) {
        userId = JwtUtils.getUserIdFromToken();
        Logger.logInfo('Extracted userId from JWT: $userId');
      }
      
      // Fallback: try to get from userData if not in token
      if (userId == null) {
        final userIdFromData = userData?['userId'];
        if (userIdFromData != null) {
          userId = userIdFromData is int 
              ? userIdFromData 
              : int.tryParse(userIdFromData.toString());
        }
      }

      List<Course> data;
      if (role == 'TEACHER') {
        if (userId == null || userId == 0) {
          throw Exception('Unable to get teacher ID. Please log in again.');
        }
        Logger.logInfo('Loading courses for teacher ID: $userId');
        data = await _courseRepository.getTeacherCourses(userId);
      } else {
        Logger.logInfo('Loading all courses for student');
        data = await _courseRepository.getAllCourses();
      }

      courses.value = data;
      _applyFilters();

      Logger.logInfo('Loaded ${data.length} courses');
    } catch (e) {
      Logger.logError('Load courses error', error: e);
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoadingCourses.value = false;
    }
  }

  /// Apply filters to courses
  void _applyFilters() {
    var filtered = courses.toList();

    // Search filter
    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((course) {
        return course.title.toLowerCase().contains(query) ||
               course.description.toLowerCase().contains(query) ||
               course.category.toLowerCase().contains(query);
      }).toList();
    }

    // Category filter
    if (selectedCategory.value != 'All') {
      filtered = filtered.where((course) => course.category == selectedCategory.value).toList();
    }

    // Level filter
    if (selectedLevel.value != 'All') {
      filtered = filtered.where((course) => course.level == selectedLevel.value).toList();
    }

    filteredCourses.assignAll(filtered);
  }

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  /// Update category filter
  void updateCategoryFilter(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  /// Update level filter
  void updateLevelFilter(String level) {
    selectedLevel.value = level;
    _applyFilters();
  }

  /// Get unique categories
  List<String> getCategories() {
    final categories = courses.map((c) => c.category).toSet().toList();
    return ['All', ...categories];
  }

  /// Create a new course
  Future<void> createCourse() async {
    try {
      if (newCourse.value.title.trim().isEmpty) {
        Get.snackbar('Error', 'Course title is required');
        return;
      }
      if (newCourse.value.description.trim().isEmpty) {
        Get.snackbar('Error', 'Course description is required');
        return;
      }
      if (newCourse.value.category.trim().isEmpty) {
        Get.snackbar('Error', 'Course category is required');
        return;
      }

      final created = await _courseRepository.createCourse(newCourse.value);
      courses.add(created);
      _applyFilters();

      // Reset form
      newCourse.value = CreateCourseRequest(
        title: '',
        description: '',
        category: '',
        level: 'BEGINNER',
      );
      showCreateCourseModal.value = false;

      Get.snackbar(
        'Success',
        'Course created successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Logger.logError('Create course error', error: e);
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  /// Update course
  Future<void> updateCourse() async {
    try {
      if (courseToEdit.value == null) return;
      if (newCourse.value.title.trim().isEmpty) {
        Get.snackbar('Error', 'Course title is required');
        return;
      }

      final updated = await _courseRepository.updateCourse(
        courseToEdit.value!.id,
        newCourse.value.toJson(),
      );

      final index = courses.indexWhere((c) => c.id == updated.id);
      if (index != -1) {
        courses[index] = updated;
      }
      _applyFilters();

      showEditCourseModal.value = false;
      courseToEdit.value = null;

      Get.snackbar(
        'Success',
        'Course updated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Logger.logError('Update course error', error: e);
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  /// Delete course
  Future<void> deleteCourse() async {
    try {
      if (courseToDelete.value == null) return;

      await _courseRepository.deleteCourse(courseToDelete.value!.id);
      courses.removeWhere((c) => c.id == courseToDelete.value!.id);
      _applyFilters();

      showDeleteCourseModal.value = false;
      courseToDelete.value = null;

      Get.snackbar(
        'Success',
        'Course deleted successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Logger.logError('Delete course error', error: e);
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  /// Load course content (modules and quizzes)
  Future<void> loadCourseContent(String courseId) async {
    try {
      isLoadingCourseContent.value = true;

      final List<Module> modules = await _courseRepository.getModulesByCourse(courseId);
      final List<Quiz> quizzes = await _courseRepository.getQuizzesByCourse(courseId);

      // For each module, fetch its lessons
      final List<Module> modulesWithLessons = await Future.wait<Module>(
        modules.map<Future<Module>>((Module module) async {
          final List<Lesson> lessons = await _courseRepository.getLessonsByModule(module.id);
          // For each lesson, fetch its content
          final List<Lesson> lessonsWithContent = await Future.wait(
            lessons.map<Future<Lesson>>((Lesson lesson) async {
              final List<LessonContent> contents = await _courseRepository.getContentByLesson(lesson.id);
              return Lesson(
                id: lesson.id,
                moduleId: lesson.moduleId,
                title: lesson.title,
                summary: lesson.summary,
                orderIndex: lesson.orderIndex,
                contents: contents,
                createdAt: lesson.createdAt,
                updatedAt: lesson.updatedAt,
              );
            }),
          );
          return Module(
            id: module.id,
            courseId: module.courseId,
            title: module.title,
            description: module.description,
            orderIndex: module.orderIndex,
            lessons: lessonsWithContent,
            createdAt: module.createdAt,
            updatedAt: module.updatedAt,
          );
        }),
      );

      // For each quiz, fetch its questions
      final List<Quiz> quizzesWithQuestions = await Future.wait<Quiz>(
        quizzes.map<Future<Quiz>>((Quiz quiz) async {
          final List<Question> questions = await _courseRepository.getQuestionsByQuiz(quiz.id);
          return Quiz(
            id: quiz.id,
            courseId: quiz.courseId,
            title: quiz.title,
            description: quiz.description,
            difficulty: quiz.difficulty,
            passingScore: quiz.passingScore,
            mandatory: quiz.mandatory,
            questions: questions,
            createdAt: quiz.createdAt,
            updatedAt: quiz.updatedAt,
          );
        }),
      );

      courseModules.value = modulesWithLessons;
      courseQuizzes.value = quizzesWithQuestions;

      Logger.logInfo('Loaded ${modulesWithLessons.length} modules and ${quizzesWithQuestions.length} quizzes');
    } catch (e) {
      Logger.logError('Load course content error', error: e);
      Get.snackbar(
        'Error',
        'Failed to load course content',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoadingCourseContent.value = false;
    }
  }

  /// Open course detail
  void openCourseDetail(Course course) {
    selectedCourse.value = course;
    loadCourseContent(course.id);
  }

  /// Open edit course modal
  void openEditCourseModal(Course course) {
    courseToEdit.value = course;
    newCourse.value = CreateCourseRequest(
      title: course.title,
      description: course.description,
      category: course.category,
      level: course.level,
      thumbnailUrl: course.thumbnailUrl,
    );
    showEditCourseModal.value = true;
  }

  /// Open delete course modal
  void openDeleteCourseModal(Course course) {
    courseToDelete.value = course;
    showDeleteCourseModal.value = true;
  }
}

