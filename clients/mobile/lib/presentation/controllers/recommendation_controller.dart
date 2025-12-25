import 'package:get/get.dart';
import '../../data/models/course/course.dart';
import '../../domain/repositories/course_repository.dart';
import '../../domain/repositories/enrollment_repository.dart';
import '../../core/utils/logger.dart';

class RecommendationController extends GetxController {
  late final CourseRepository _courseRepository;
  late final EnrollmentRepository _enrollmentRepository;

  // Observable state
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final recommendedCourses = <Course>[].obs;
  final enrolledCourseIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _courseRepository = Get.find<CourseRepository>();
    _enrollmentRepository = Get.find<EnrollmentRepository>();
    loadRecommendations();
  }

  /// Load course recommendations
  Future<void> loadRecommendations() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Fetch enrolled courses to filter them out
      await _loadEnrolledCourses();

      // Fetch all available courses
      final allCourses = await _courseRepository.getAllCourses();

      // Filter out already enrolled courses
      final filteredCourses = allCourses.where((course) {
        return !enrolledCourseIds.contains(course.id);
      }).toList();

      // Sort by level for better recommendations (Beginner first)
      filteredCourses.sort((a, b) {
        const levelOrder = {'BEGINNER': 0, 'INTERMEDIATE': 1, 'ADVANCED': 2};
        final aOrder = levelOrder[a.level.toUpperCase()] ?? 3;
        final bOrder = levelOrder[b.level.toUpperCase()] ?? 3;
        return aOrder.compareTo(bOrder);
      });

      recommendedCourses.value = filteredCourses;
      Logger.logInfo('Loaded ${filteredCourses.length} recommendations');
    } catch (e) {
      errorMessage.value = e.toString();
      Logger.logError('Failed to load recommendations: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load enrolled courses to filter them out from recommendations
  Future<void> _loadEnrolledCourses() async {
    try {
      final enrollments = await _enrollmentRepository.getMyCourses();
      enrolledCourseIds.value = enrollments.map((e) => e.courseId).toList();
      Logger.logInfo('Loaded ${enrolledCourseIds.length} enrolled courses');
    } catch (e) {
      Logger.logError('Failed to load enrolled courses: $e');
      // Continue even if this fails - we'll just show all courses
      enrolledCourseIds.value = [];
    }
  }

  /// Refresh recommendations
  @override
  Future<void> refresh() async {
    await loadRecommendations();
  }
}

