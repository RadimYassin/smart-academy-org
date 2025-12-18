import 'package:get/get.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/course/course.dart';
import '../../../data/models/enrollment/enrollment.dart';
import '../../../data/models/progress/progress.dart';
import '../../../domain/repositories/enrollment_repository.dart';
import '../../../domain/repositories/course_repository.dart';
import '../../../domain/repositories/progress_repository.dart';

class StudentDashboardController extends GetxController {
  // Repositories
  late final EnrollmentRepository _enrollmentRepository;
  late final CourseRepository _courseRepository;
  late final ProgressRepository _progressRepository;

  // Enrolled courses
  final enrollments = <Enrollment>[].obs;
  final courses = <Course>[].obs;
  final courseProgressMap = <String, CourseProgressResponse>{}.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _enrollmentRepository = Get.find<EnrollmentRepository>();
    _courseRepository = Get.find<CourseRepository>();
    _progressRepository = Get.find<ProgressRepository>();
    loadMyCourses();
  }

  /// Load student's enrolled courses with progress
  Future<void> loadMyCourses() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get enrollments
      final enrollmentsList = await _enrollmentRepository.getMyCourses();
      enrollments.value = enrollmentsList;

      // Get course details
      final courseIds = enrollmentsList.map((e) => e.courseId).toList();
      final coursesList = await Future.wait(
        courseIds.map<Future<Course?>>((id) async {
          try {
            return await _courseRepository.getCourseById(id);
          } catch (e) {
            Logger.logWarning('Failed to fetch course $id: $e');
            return null;
          }
        }),
      );
      courses.value = coursesList.whereType<Course>().toList();

      // Get progress for each course
      final progressMap = <String, CourseProgressResponse>{};
      for (final courseId in courseIds) {
        try {
          final progress = await _progressRepository.getCourseProgress(courseId);
          progressMap[courseId] = progress;
        } catch (e) {
          Logger.logWarning('Failed to fetch progress for course $courseId: $e');
        }
      }
      courseProgressMap.value = progressMap;

      Logger.logInfo('Loaded ${courses.length} enrolled courses');
    } catch (e) {
      Logger.logError('Load my courses error', error: e);
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get progress for a course
  CourseProgressResponse? getCourseProgress(String courseId) {
    return courseProgressMap[courseId];
  }

  /// Get completion rate for a course
  double getCompletionRate(String courseId) {
    final progress = courseProgressMap[courseId];
    if (progress == null) return 0.0;
    return progress.completionRate;
  }
}

