import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/jwt_utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/repositories/course_repository.dart';
import '../../../domain/repositories/enrollment_repository.dart';
import '../../../domain/repositories/class_repository.dart';

class TeacherDashboardController extends GetxController {
  // Repositories
  late final CourseRepository _courseRepository;
  late final EnrollmentRepository _enrollmentRepository;
  late final ClassRepository _classRepository;

  // Statistics
  final totalCourses = 0.obs;
  final totalStudents = 0.obs;
  final totalClasses = 0.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _courseRepository = Get.find<CourseRepository>();
    _enrollmentRepository = Get.find<EnrollmentRepository>();
    _classRepository = Get.find<ClassRepository>();
    loadStatistics();
  }

  /// Load dashboard statistics
  Future<void> loadStatistics() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get user ID from JWT token
      final storage = Get.find<GetStorage>();
      int? userId;
      final accessToken = storage.read<String>(AppConstants.accessTokenKey);
      if (accessToken != null && accessToken.isNotEmpty) {
        userId = JwtUtils.getUserIdFromToken();
        Logger.logInfo('Extracted userId from JWT: $userId');
      }
      
      // Fallback: try to get from userData if not in token
      if (userId == null) {
        final userData = storage.read<Map<dynamic, dynamic>>('user_data');
        final userIdFromData = userData?['userId'];
        if (userIdFromData != null) {
          userId = userIdFromData is int 
              ? userIdFromData 
              : int.tryParse(userIdFromData.toString());
        }
      }

      if (userId == null || userId == 0) {
        throw Exception('Unable to get teacher ID. Please log in again.');
      }

      // Load courses
      final courses = await _courseRepository.getTeacherCourses(userId);
      totalCourses.value = courses.length;

      // Load classes
      final classes = await _classRepository.getMyClasses();
      totalClasses.value = classes.length;

      // Calculate total students from classes
      int studentCount = 0;
      for (final classItem in classes) {
        studentCount += classItem.studentCount;
      }
      totalStudents.value = studentCount;

      Logger.logInfo('Dashboard statistics loaded');
    } catch (e) {
      Logger.logError('Load statistics error', error: e);
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}

