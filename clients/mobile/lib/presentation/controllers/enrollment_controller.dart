import 'package:get/get.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/enrollment/enrollment.dart';
import '../../../domain/repositories/enrollment_repository.dart';
import '../../../domain/repositories/course_repository.dart';

class EnrollmentController extends GetxController {
  // Repositories
  late final EnrollmentRepository _enrollmentRepository;
  late final CourseRepository _courseRepository;

  // Enrollments
  final enrollments = <Enrollment>[].obs;
  final myEnrollments = <Enrollment>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Modals
  final showAssignStudentModal = false.obs;
  final showAssignClassModal = false.obs;

  // Selected course for assignment
  final selectedCourseId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _enrollmentRepository = Get.find<EnrollmentRepository>();
    _courseRepository = Get.find<CourseRepository>();
  }

  /// Load enrollments for a course
  Future<void> loadCourseEnrollments(String courseId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = await _enrollmentRepository.getCourseEnrollments(courseId);
      enrollments.value = data;

      Logger.logInfo('Loaded ${data.length} enrollments');
    } catch (e) {
      Logger.logError('Load enrollments error', error: e);
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

  /// Load my enrolled courses (for students)
  Future<void> loadMyCourses() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final data = await _enrollmentRepository.getMyCourses();
      myEnrollments.value = data;

      Logger.logInfo('Loaded ${data.length} enrolled courses');
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

  /// Assign student to course
  Future<void> assignStudent(String courseId, int studentId) async {
    try {
      final enrollment = await _enrollmentRepository.assignStudent(
        AssignStudentRequest(courseId: courseId, studentId: studentId),
      );
      enrollments.add(enrollment);

      Get.snackbar(
        'Success',
        'Student assigned successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Logger.logError('Assign student error', error: e);
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  /// Assign class to course
  Future<void> assignClass(String courseId, String classId) async {
    try {
      final enrollmentsList = await _enrollmentRepository.assignClass(
        AssignClassRequest(courseId: courseId, classId: classId),
      );
      enrollments.addAll(enrollmentsList);

      Get.snackbar(
        'Success',
        'Class assigned successfully. ${enrollmentsList.length} students enrolled.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Logger.logError('Assign class error', error: e);
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  /// Unenroll student from course
  Future<void> unenrollStudent(String courseId, int studentId) async {
    try {
      await _enrollmentRepository.unenrollStudent(courseId, studentId);
      enrollments.removeWhere((e) => e.courseId == courseId && e.studentId == studentId);

      Get.snackbar(
        'Success',
        'Student unenrolled successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Logger.logError('Unenroll student error', error: e);
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }
}

