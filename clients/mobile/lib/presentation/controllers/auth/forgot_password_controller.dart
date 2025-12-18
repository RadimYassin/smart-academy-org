import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Enum to manage the different pages in the bottom sheet
enum ForgotPasswordPage { selectMethod, emailInput, phoneInput }

class ForgotPasswordController extends GetxController {
  // Text controllers
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // Observable for the current page
  final currentPage = ForgotPasswordPage.selectMethod.obs;

  @override
  void onClose() {
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  // --- Navigation Methods ---
  void goToEmailInput() {
    currentPage.value = ForgotPasswordPage.emailInput;
  }

  void goToPhoneInput() {
    currentPage.value = ForgotPasswordPage.phoneInput;
  }

  void goToMethodSelection() {
    currentPage.value = ForgotPasswordPage.selectMethod;
  }

  // --- API Call Method ---
  void sendPasswordResetLink() {
    if (currentPage.value == ForgotPasswordPage.emailInput) {
      // TODO: Implement API call for email reset
    } else if (currentPage.value == ForgotPasswordPage.phoneInput) {
      // TODO: Implement API call for phone reset
    }

    // Close the bottom sheet on success
    Get.back();
  }
}

