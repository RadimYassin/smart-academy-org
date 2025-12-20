import 'package:get/get.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/progress/progress.dart';
import '../../../domain/repositories/progress_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import 'profile_controller.dart';

class ProgressController extends GetxController {
  // Repositories
  late final ProgressRepository _progressRepository;
  late final UserRepository _userRepository;

  // Progress data
  final courseProgress = <String, CourseProgressResponse>{}.obs;
  final lessonProgress = <String, List<LessonProgressResponse>>{}.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _progressRepository = Get.find<ProgressRepository>();
    _userRepository = Get.find<UserRepository>();
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

      // Reward student with 5 credits for completing the lesson
      try {
        final creditBalance = await _userRepository.rewardLessonComplete();
        
        // Update ProfileController if it exists to refresh the credit display
        try {
          final profileController = Get.find<ProfileController>();
          profileController.creditBalance.value = creditBalance;
          profileController.creditBalanceError.value = '';
        } catch (e) {
          // ProfileController might not be initialized, that's okay
          Logger.logWarning('ProfileController not found, skipping credit balance update');
        }
        
        Get.snackbar(
          'Success',
          'Lesson completed! +5 credits (Total: ${creditBalance.balance.toStringAsFixed(2)})',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.8),
          colorText: Get.theme.colorScheme.onPrimary,
          duration: const Duration(seconds: 3),
        );
        Logger.logInfo('Rewarded 5 credits for lesson completion. New balance: ${creditBalance.balance}');
      } catch (creditError) {
        // If credit reward fails, still show success for lesson completion
        Logger.logError('Failed to reward credits', error: creditError);
      Get.snackbar(
        'Success',
        'Lesson marked as complete!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onPrimary,
      );
      }
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

