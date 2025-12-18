import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import 'forgot_password_controller.dart';
import '../../screens/auth/widgets/forgot_password_sheet.dart';

class SignInController extends GetxController with GetSingleTickerProviderStateMixin {
  // Tab controller for Email/Phone
  late final TabController tabController;

  // Form text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  // Password visibility
  final isPasswordHidden = true.obs;

  final List<Tab> authTabs = <Tab>[
    const Tab(text: 'Email'),
    const Tab(text: 'Phone Number'),
  ];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(vsync: this, length: authTabs.length);
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

  void signIn() {
    // TODO: Implement Sign In logic using a UseCase
    // e.g., final result = await signInUseCase(
    //   email: emailController.text,
    //   password: passwordController.text
    // );
    // On successful login, navigate to dashboard
    Get.offAllNamed(AppRoutes.dashboard);
  }

  void openForgotPasswordSheet() {
    // Lazily put the controller, it will be alive only for the sheet
    Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController());

    Get.bottomSheet(
      const ForgotPasswordSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

