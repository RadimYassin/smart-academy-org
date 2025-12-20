import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/auth/login_request.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../routes/app_routes.dart';
import 'forgot_password_controller.dart';
import '../../screens/auth/widgets/forgot_password_sheet.dart';
import '../../../../shared/services/biometric_service.dart';
import '../../../../shared/services/secure_storage_service.dart';

class SignInController extends GetxController with GetSingleTickerProviderStateMixin {
  // Dependency injection - will be injected via binding
  late final AuthRepository _authRepository;
  late final BiometricService _biometricService;
  late final SecureStorageService _secureStorageService;

  // Tab controller for Email/Phone
  late final TabController tabController;

  // Form text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Password visibility
  final isPasswordHidden = true.obs;

  // Loading state
  final isLoading = false.obs;

  // Error message
  final errorMessage = ''.obs;

  // Biometric availability
  final isBiometricAvailable = false.obs;
  final biometricType = 'Biometric'.obs;

  final List<Tab> authTabs = <Tab>[
    const Tab(text: 'Email'),
    const Tab(text: 'Phone Number'),
  ];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(vsync: this, length: authTabs.length);
    
    // Get repository from GetX dependency injection
    _authRepository = Get.find<AuthRepository>();
    _biometricService = BiometricService();
    _secureStorageService = SecureStorageService();
    
    // Check biometric availability
    _checkBiometricAvailability();
    
    // Try automatic biometric login if enabled
    _tryAutoBiometricLogin();
  }

  /// Try automatic biometric login if enabled
  Future<void> _tryAutoBiometricLogin() async {
    try {
      // Wait a bit for the screen to be ready
      await Future.delayed(const Duration(milliseconds: 1000));
      
      Logger.logInfo('🔐 Starting auto biometric login check...');
      
      // Check if biometric is enabled and available
      final isEnabled = await _secureStorageService.isBiometricEnabled();
      Logger.logInfo('🔐 Biometric enabled: $isEnabled');
      
      final isAvailable = await _biometricService.isAvailable();
      Logger.logInfo('🔐 Biometric available: $isAvailable');
      
      if (!isEnabled || !isAvailable) {
        Logger.logInfo('ℹ️ Biometric auto-login not available (enabled: $isEnabled, available: $isAvailable)');
        return;
      }
      
      // Check if credentials are saved
      final hasCredentials = await _secureStorageService.hasSavedCredentials();
      Logger.logInfo('🔐 Has saved credentials: $hasCredentials');
      
      if (!hasCredentials) {
        Logger.logInfo('⚠️ Biometric enabled but no saved credentials found');
        return;
      }
      
      Logger.logInfo('🔐 All checks passed. Attempting automatic biometric login...');
      // Automatically trigger biometric login
      await signInWithBiometric(isAutoLogin: true);
    } catch (e, stackTrace) {
      Logger.logError('❌ Error in auto biometric login', error: e);
      Logger.logError('❌ Stack trace', error: stackTrace);
      // Don't show error to user, just log it - user can still login manually
    }
  }

  /// Check if biometric authentication is available
  Future<void> _checkBiometricAvailability() async {
    try {
      final available = await _biometricService.isAvailable();
      isBiometricAvailable.value = available;
      
      if (available) {
        final type = await _biometricService.getPrimaryBiometricType();
        biometricType.value = type;
      }
    } catch (e) {
      Logger.logError('Error checking biometric availability', error: e);
      isBiometricAvailable.value = false;
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  /// Validate email format
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    
    return null;
  }

  /// Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }

  /// Sign in with email and password
  Future<void> signIn() async {
    // Clear previous error
    errorMessage.value = '';

    // Validate form
    if (formKey.currentState?.validate() != true) {
      return;
    }

    // Show loading
    isLoading.value = true;

    try {
      Logger.logInfo('Attempting sign in for: ${emailController.text}');

      // Create login request
      final loginRequest = LoginRequest(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Call repository
      final response = await _authRepository.login(loginRequest);

      Logger.logInfo('Sign in successful for: ${response.email}');
      Logger.logInfo('User role: ${response.role}');

      // Save credentials securely if biometric is available
      if (isBiometricAvailable.value) {
        try {
          Logger.logInfo('💾 Saving credentials for biometric login...');
          await _secureStorageService.saveCredentials(
            emailController.text.trim(),
            passwordController.text,
          );
          Logger.logInfo('✅ Credentials saved successfully');
          
          // Check if biometric is enabled in profile settings
          final isBiometricEnabled = await _secureStorageService.isBiometricEnabled();
          if (!isBiometricEnabled) {
            Logger.logInfo('💾 Auto-enabling biometric (credentials saved)');
            await _secureStorageService.setBiometricEnabled(true);
          }
        } catch (e) {
          Logger.logError('Failed to save credentials for biometric', error: e);
        }
      }

      // Show success message
      Get.snackbar(
        'Welcome Back!',
        'Hello ${response.firstName} ${response.lastName}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Navigate based on user role
      if (response.role.toUpperCase() == 'TEACHER') {
        Logger.logInfo('Navigating to teacher dashboard');
        Get.offAllNamed(AppRoutes.teacherDashboard);
      } else if (response.role.toUpperCase() == 'STUDENT') {
        Logger.logInfo('Navigating to student home');
        Get.offAllNamed(AppRoutes.studentHome);
      } else {
        // Default to student home for unknown roles
        Logger.logWarning('Unknown role: ${response.role}, defaulting to student home');
        Get.offAllNamed(AppRoutes.studentHome);
      }
      
    } catch (e) {
      Logger.logError('Sign in error', error: e);
      
      // Extract error message
      String message = 'Login failed. Please try again.';
      if (e is Exception) {
        message = e.toString().replaceAll('Exception: ', '');
      }
      
      errorMessage.value = message;

      // Show error snackbar
      Get.snackbar(
        'Login Failed',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Open forgot password bottom sheet
  void openForgotPasswordSheet() {
    // Lazily put the controller, it will be alive only for the sheet
    Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController());

    Get.bottomSheet(
      const ForgotPasswordSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Navigate to sign up
  void navigateToSignUp() {
    Get.toNamed(AppRoutes.signup);
  }

  /// Sign in with Google (placeholder)
  Future<void> signInWithGoogle() async {
    Get.snackbar(
      'Coming Soon',
      'Google sign-in will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Sign in with Apple (placeholder)
  Future<void> signInWithApple() async {
    Get.snackbar(
      'Coming Soon',
      'Apple sign-in will be available soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Sign in with biometric authentication
  Future<void> signInWithBiometric({bool isAutoLogin = false}) async {
    Logger.logInfo('🔐 Starting biometric login (auto: $isAutoLogin)');
    
    // Check availability
    final isAvailable = await _biometricService.isAvailable();
    if (!isAvailable) {
      Logger.logWarning('❌ Biometric not available');
      if (!isAutoLogin) {
        Get.snackbar(
          'Biometric Not Available',
          'Biometric authentication is not available on this device',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
      return;
    }

    // Check if credentials are saved
    final hasCredentials = await _secureStorageService.hasSavedCredentials();
    if (!hasCredentials) {
      Logger.logWarning('❌ No saved credentials');
      if (!isAutoLogin) {
        Get.snackbar(
          'No Saved Credentials',
          'Please sign in with email and password first to enable biometric login',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Authenticate with biometric
      Logger.logInfo('🔐 Requesting biometric authentication...');
      final authenticated = await _biometricService.authenticate(
        reason: 'Authenticate to sign in to your account',
      );

      Logger.logInfo('🔐 Biometric authentication result: $authenticated');

      if (!authenticated) {
        isLoading.value = false;
        if (!isAutoLogin) {
          Get.snackbar(
            'Authentication Cancelled',
            'Biometric authentication was cancelled',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }
        return; // User cancelled or authentication failed
      }

      // Get saved credentials
      final savedEmail = await _secureStorageService.getSavedEmail();
      final savedPassword = await _secureStorageService.getSavedPassword();

      if (savedEmail == null || savedPassword == null) {
        throw Exception('Saved credentials not found');
      }

      // Create login request with saved credentials
      final loginRequest = LoginRequest(
        email: savedEmail,
        password: savedPassword,
      );

      // Call repository
      final response = await _authRepository.login(loginRequest);

      Logger.logInfo('Biometric sign in successful for: ${response.email}');

      // Show success message
      Get.snackbar(
        'Welcome Back!',
        'Hello ${response.firstName} ${response.lastName}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Navigate based on user role
      if (response.role.toUpperCase() == 'TEACHER') {
        Logger.logInfo('Navigating to teacher dashboard');
        Get.offAllNamed(AppRoutes.teacherDashboard);
      } else if (response.role.toUpperCase() == 'STUDENT') {
        Logger.logInfo('Navigating to student home');
        Get.offAllNamed(AppRoutes.studentHome);
      } else {
        Logger.logWarning('Unknown role: ${response.role}, defaulting to student home');
        Get.offAllNamed(AppRoutes.studentHome);
      }
    } catch (e) {
      Logger.logError('Biometric sign in error', error: e);
      
      String message = 'Biometric login failed. Please try again.';
      if (e is Exception) {
        message = e.toString().replaceAll('Exception: ', '');
      }
      
      errorMessage.value = message;

      Get.snackbar(
        'Biometric Login Failed',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
