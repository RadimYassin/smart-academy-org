import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/auth/login_request.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../routes/app_routes.dart';
import 'forgot_password_controller.dart';
import '../../screens/auth/widgets/forgot_password_sheet.dart';

class SignInController extends GetxController with GetSingleTickerProviderStateMixin {
  // Dependency injection - will be injected via binding
  late final AuthRepository _authRepository;

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
}
