import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
import '../../routes/app_routes.dart';

class SignUpController extends GetxController {
  // Form text controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  // Form keys for validation
  final step1FormKey = GlobalKey<FormState>();
  final step2FormKey = GlobalKey<FormState>();

  // Password visibility
  final isPasswordHidden = true.obs;

  // Selected country
  final selectedCountry = Country.parse('US').obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void selectCountry(Country country) {
    selectedCountry.value = country;
  }

  // --- Navigation Methods ---

  // Called from Step 1 (SignUpScreen)
  void submitEmailForVerification() {
    // if (step1FormKey.currentState!.validate()) {
    //   TODO: Implement API call to send verification email
    // }
    Get.toNamed(AppRoutes.emailVerification);
  }

  // Called from EmailVerificationScreen
  void verifyEmailCode() {
    // TODO: Implement API call to verify code
    // On success, navigate to the phone number screen
    Get.toNamed(AppRoutes.phoneNumber);
  }

  void resendEmailCode() {
    // TODO: Implement API call to resend email
  }

  void goToSignUpScreen() {
    // Go back to the first step
    Get.back();
  }

  // Called from Step 2 (PhoneNumberScreen)
  void sendVerificationCode() {
    // if (step2FormKey.currentState!.validate()) {
    // TODO: Implement API call to send code
    // }
    // On successful verification, navigate to dashboard
    Get.offAllNamed(AppRoutes.dashboard);
  }

  // Called from "Sign in" link
  void navigateToSignIn() {
    Get.toNamed(AppRoutes.signin);
  }
}

