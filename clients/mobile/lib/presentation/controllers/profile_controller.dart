import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/jwt_utils.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/user/user_dto.dart';
import '../../../data/models/user/credit_balance.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/repositories/enrollment_repository.dart';
import '../../../domain/repositories/progress_repository.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../routes/app_routes.dart';
import '../../../../shared/services/biometric_service.dart';
import '../../../../shared/services/secure_storage_service.dart';

class ProfileController extends GetxController with GetSingleTickerProviderStateMixin {
  // Repositories
  late final UserRepository _userRepository;
  late final EnrollmentRepository _enrollmentRepository;
  late final ProgressRepository _progressRepository;
  late final AuthRepository _authRepository;
  
  // Services
  late final BiometricService _biometricService;
  late final SecureStorageService _secureStorageService;

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
  final creditBalance = Rxn<CreditBalance>();
  final creditBalanceError = ''.obs;
  final isLoadingCreditBalance = false.obs;

  // Observable for dark mode toggle
  final isDarkMode = false.obs;
  
  // Biometric settings
  final isBiometricAvailable = false.obs;
  final isBiometricEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(vsync: this, length: activityTabs.length);
    isDarkMode.value = Get.isDarkMode;
    
    _userRepository = Get.find<UserRepository>();
    _enrollmentRepository = Get.find<EnrollmentRepository>();
    _progressRepository = Get.find<ProgressRepository>();
    _authRepository = Get.find<AuthRepository>();
    _biometricService = BiometricService();
    _secureStorageService = SecureStorageService();
    
    loadUserProfile();
    loadUserStats();
    loadCreditBalance();
    checkBiometricAvailability();
    loadBiometricPreference();
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

  /// Load credit balance
  Future<void> loadCreditBalance() async {
    try {
      isLoadingCreditBalance.value = true;
      creditBalanceError.value = '';
      Logger.logInfo('Loading credit balance...');
      
      final balance = await _userRepository.getCreditBalance();
      creditBalance.value = balance;
      creditBalanceError.value = '';
      Logger.logInfo('Credit balance loaded successfully: ${balance.balance}');
    } catch (e, stackTrace) {
      Logger.logError('Load credit balance error', error: e);
      Logger.logError('Stack trace', error: stackTrace);
      
      // Set to null to show error state
      creditBalance.value = null;
      creditBalanceError.value = e.toString().replaceAll('Exception: ', '');
      
      // Log detailed error for debugging
      debugPrint('🔴 Credit balance error: $e');
      debugPrint('🔴 Stack trace: $stackTrace');
    } finally {
      isLoadingCreditBalance.value = false;
    }
  }

  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    // TODO: Save theme choice to GetStorage
  }

  /// Check if biometric authentication is available
  Future<void> checkBiometricAvailability() async {
    try {
      final available = await _biometricService.isAvailable();
      isBiometricAvailable.value = available;
    } catch (e) {
      Logger.logError('Error checking biometric availability', error: e);
      isBiometricAvailable.value = false;
    }
  }

  /// Load biometric preference
  Future<void> loadBiometricPreference() async {
    try {
      final enabled = await _secureStorageService.isBiometricEnabled();
      isBiometricEnabled.value = enabled;
    } catch (e) {
      Logger.logError('Error loading biometric preference', error: e);
      isBiometricEnabled.value = false;
    }
  }

  /// Toggle biometric authentication
  Future<void> toggleBiometric(bool value) async {
    Logger.logInfo('🔄 Toggling biometric to: $value');
    Logger.logInfo('🔄 Current state: ${isBiometricEnabled.value}');
    
    // Store the previous value in case we need to revert
    final previousValue = isBiometricEnabled.value;
    
    try {
      if (value) {
        // Enable biometric - verify it works first
        Logger.logInfo('🔐 Requesting biometric authentication...');
        
        // Check availability again before authenticating
        final isAvailable = await _biometricService.isAvailable();
        if (!isAvailable) {
          Logger.logWarning('❌ Biometric not available');
          isBiometricEnabled.value = false;
          Get.snackbar(
            'Biometric Not Available',
            'Biometric authentication is not available on this device',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          return;
        }
        
        final authenticated = await _biometricService.authenticate(
          reason: 'Enable biometric authentication for quick login',
        );
        
        Logger.logInfo('🔐 Biometric authentication result: $authenticated');
        
        if (!authenticated) {
          // User cancelled or authentication failed - revert to previous state
          Logger.logWarning('❌ Biometric authentication failed or cancelled');
          isBiometricEnabled.value = previousValue;
          Get.snackbar(
            'Biometric Not Enabled',
            'Biometric authentication was cancelled or failed',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          return;
        }
        
        Logger.logInfo('✅ Biometric authentication successful');
      }
      
      // Save preference
      Logger.logInfo('💾 Saving biometric preference: $value');
      await _secureStorageService.setBiometricEnabled(value);
      
      // Update the observable after successful save
      isBiometricEnabled.value = value;
      
      Logger.logInfo('✅ Biometric preference saved successfully. New state: ${isBiometricEnabled.value}');
      
      if (value) {
        Get.snackbar(
          'Biometric Enabled',
          'You can now use biometric authentication to sign in',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Biometric Disabled',
          'Biometric authentication has been disabled',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e, stackTrace) {
      Logger.logError('❌ Error toggling biometric', error: e);
      Logger.logError('❌ Stack trace', error: stackTrace);
      
      // Revert to previous state on error
      isBiometricEnabled.value = previousValue;
      
      Get.snackbar(
        'Error',
        'Failed to ${value ? "enable" : "disable"} biometric authentication: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Logout user and navigate to sign in screen
  Future<void> logout() async {
    try {
      Logger.logInfo('Logging out user...');
      
      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(Get.context!).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(Get.context!).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      );

      if (confirmed != true) {
        return;
      }

      // Call logout from repository
      await _authRepository.logout();
      
      Logger.logInfo('User logged out successfully');
      
      // Navigate to sign in screen and clear all routes
      Get.offAllNamed(AppRoutes.signin);
      
      // Show success message
      Get.snackbar(
        'Logged Out',
        'You have been logged out successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Logger.logError('Logout error', error: e);
      Get.snackbar(
        'Error',
        'Failed to logout: ${e.toString().replaceAll('Exception: ', '')}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}

