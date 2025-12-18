import 'package:get/get.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/progress/progress.dart';
import '../../../domain/repositories/progress_repository.dart';

class ProgressController extends GetxController {
  // Repository
  late final ProgressRepository _progressRepository;

  // Progress data
  final courseProgress = <String, CourseProgressResponse>{}.obs;
  final lessonProgress = <String, List<LessonProgressResponse>>{}.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _progressRepository = Get.find<ProgressRepository>();
  }

  /// Mark lesson as complete
  Future<void> markLessonComplete(String lessonId) async {
    try {
      final response = await _progressRepository.markLessonComplete(lessonId);
      
      // Update lesson progress
      if (lessonProgress.containsKey(response.lessonId)) {
        final progressList = lessonProgress[response.lessonId]!;
        final index = progressList.indexWhere((p) => p.lessonId == lessonId);
        if (index != -1) {
          progressList[index] = response;
        } else {
          progressList.add(response);
        }
        lessonProgress[response.lessonId] = progressList;
      }

      Get.snackbar(
        'Success',
        'Lesson marked as complete!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      Logger.logError('Mark lesson complete error', error: e);
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  /// Get lesson progress
  Future<LessonProgressResponse?> getLessonProgress(String lessonId) async {
    try {
      return await _progressRepository.getLessonProgress(lessonId);
    } catch (e) {
      Logger.logError('Get lesson progress error', error: e);
      return null;
    }
  }

  /// Get course progress
  Future<void> loadCourseProgress(String courseId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final progress = await _progressRepository.getCourseProgress(courseId);
      courseProgress[courseId] = progress;

      Logger.logInfo('Loaded course progress: ${progress.completionRate}%');
    } catch (e) {
      Logger.logError('Load course progress error', error: e);
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get all lesson progress for a course
  Future<void> loadAllLessonProgressForCourse(String courseId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final progressList = await _progressRepository.getAllLessonProgressForCourse(courseId);
      lessonProgress[courseId] = progressList;

      Logger.logInfo('Loaded ${progressList.length} lesson progress records');
    } catch (e) {
      Logger.logError('Load all lesson progress error', error: e);
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if lesson is completed
  bool isLessonCompleted(String courseId, String lessonId) {
    final progressList = lessonProgress[courseId];
    if (progressList == null) return false;
    final progress = progressList.firstWhere(
      (p) => p.lessonId == lessonId,
      orElse: () => LessonProgressResponse(
        lessonId: lessonId,
        lessonTitle: '',
        completed: false,
      ),
    );
    return progress.completed;
  }

  /// Get completion rate for a course
  double getCourseCompletionRate(String courseId) {
    final progress = courseProgress[courseId];
    if (progress == null) return 0.0;
    return progress.completionRate;
  }
}

