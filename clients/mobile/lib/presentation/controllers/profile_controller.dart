import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/jwt_utils.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/user/user_dto.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/repositories/enrollment_repository.dart';
import '../../../domain/repositories/progress_repository.dart';

class ProfileController extends GetxController with GetSingleTickerProviderStateMixin {
  // Repositories
  late final UserRepository _userRepository;
  late final EnrollmentRepository _enrollmentRepository;
  late final ProgressRepository _progressRepository;

  // Tab controller for Recent/Goals/Activity
  late final TabController tabController;

  final List<Tab> activityTabs = const <Tab>[
    Tab(text: 'Recent'),
    Tab(text: 'Goals'),
    Tab(text: 'Activity'),
  ];

  // User data
  final user = Rxn<UserDto>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Stats
  final enrolledCoursesCount = 0.obs;
  final completedCoursesCount = 0.obs;
  final totalProgress = 0.0.obs;

  // Observable for dark mode toggle
  final isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(vsync: this, length: activityTabs.length);
    isDarkMode.value = Get.isDarkMode;
    
    _userRepository = Get.find<UserRepository>();
    _enrollmentRepository = Get.find<EnrollmentRepository>();
    _progressRepository = Get.find<ProgressRepository>();
    
    loadUserProfile();
    loadUserStats();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  /// Load user profile data
  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userId = JwtUtils.getUserIdFromToken();
      if (userId == null) {
        throw Exception('Unable to get user ID. Please log in again.');
      }

      final userData = await _userRepository.getUserById(userId);
      user.value = userData;

      Logger.logInfo('User profile loaded: ${userData.fullName}');
    } catch (e) {
      Logger.logError('Load user profile error', error: e);
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

  /// Load user statistics (courses, progress, etc.)
  Future<void> loadUserStats() async {
    try {
      // Get enrolled courses
      final enrollments = await _enrollmentRepository.getMyCourses();
      enrolledCoursesCount.value = enrollments.length;

      // Calculate completed courses and total progress
      int completed = 0;
      double totalProgressValue = 0.0;

      for (final enrollment in enrollments) {
        try {
          final progress = await _progressRepository.getCourseProgress(enrollment.courseId);
          totalProgressValue += progress.completionRate;
          if (progress.completionRate >= 100) {
            completed++;
          }
        } catch (e) {
          Logger.logWarning('Failed to fetch progress for course ${enrollment.courseId}: $e');
        }
      }

      completedCoursesCount.value = completed;
      totalProgress.value = enrolledCoursesCount.value > 0
          ? totalProgressValue / enrolledCoursesCount.value
          : 0.0;

      Logger.logInfo('User stats loaded: ${enrolledCoursesCount.value} courses, $completed completed');
    } catch (e) {
      Logger.logError('Load user stats error', error: e);
    }
  }

  /// Update user profile
  Future<void> updateProfile(String firstName, String lastName) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userId = JwtUtils.getUserIdFromToken();
      if (userId == null) {
        throw Exception('Unable to get user ID. Please log in again.');
      }

      final updatedUser = await _userRepository.updateUser(
        userId,
        UpdateUserRequest(firstName: firstName, lastName: lastName),
      );
      user.value = updatedUser;

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.8),
        colorText: Get.theme.colorScheme.onPrimary,
      );

      Logger.logInfo('Profile updated: ${updatedUser.fullName}');
    } catch (e) {
      Logger.logError('Update profile error', error: e);
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

  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    // TODO: Save theme choice to GetStorage
  }
}

