import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../controllers/auth/signup_controller.dart';

class SignUpScreen extends GetView<SignUpController> {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.primary : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? AppColors.white : AppColors.black,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header
              _buildHeader(context, isDarkMode),
              const SizedBox(height: 32),
              // Form Fields
              _buildFormFields(context, isDarkMode),
              const Spacer(),
              // Sign Up Button
              _buildSignUpButton(context, isDarkMode),
              const SizedBox(height: 16),
              // Terms and Privacy
              _buildTermsText(context, isDarkMode),
              const SizedBox(height: 24),
              // Sign In Link
              _buildSignInLink(context, isDarkMode),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.signUpToOverskill,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.white : AppColors.black,
              ),
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 100.ms)
            .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 100.ms),
        const SizedBox(height: 8),
        Text(
          AppStrings.signUpSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                height: 1.5,
              ),
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 300.ms)
            .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 300.ms),
      ],
    );
  }

  Widget _buildFormFields(BuildContext context, bool isDarkMode) {
    return Column(
      children: [
        // Name Field
        TextField(
          controller: controller.nameController,
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            hintText: AppStrings.yourName,
            prefixIcon: Icon(
              Icons.person_outline,
              color: isDarkMode ? AppColors.greyLight : AppColors.grey,
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 500.ms)
            .slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 500.ms),
        const SizedBox(height: 16),
        // Email Field
        TextField(
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: AppStrings.yourEmail,
            prefixIcon: Icon(
              Icons.email_outlined,
              color: isDarkMode ? AppColors.greyLight : AppColors.grey,
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 700.ms)
            .slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 700.ms),
        const SizedBox(height: 16),
        // Password Field
        _buildPasswordField(context, isDarkMode),
      ],
    );
  }

  Widget _buildPasswordField(BuildContext context, bool isDarkMode) {
    return Obx(
      () => TextField(
        controller: controller.passwordController,
        obscureText: controller.isPasswordHidden.value,
        decoration: InputDecoration(
          hintText: AppStrings.minCharacters,
          prefixIcon: Icon(
            Icons.lock_outline,
            color: isDarkMode ? AppColors.greyLight : AppColors.grey,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              controller.isPasswordHidden.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: isDarkMode ? AppColors.greyLight : AppColors.grey,
            ),
            onPressed: controller.togglePasswordVisibility,
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 500.ms, delay: 900.ms)
          .slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 900.ms),
    );
  }

  Widget _buildSignUpButton(BuildContext context, bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.submitEmailForVerification,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.onboardingContinue,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: Text(
          AppStrings.signUp,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 1100.ms)
        .slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 1100.ms)
        .scale(
          delay: 1100.ms,
          duration: 500.ms,
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.0, 1.0),
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildTermsText(BuildContext context, bool isDarkMode) {
    return Text(
      AppStrings.termsAndPrivacy,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isDarkMode ? AppColors.greyLight : AppColors.grey,
            height: 1.5,
          ),
      textAlign: TextAlign.center,
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 1300.ms);
  }

  Widget _buildSignInLink(BuildContext context, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.alreadyHaveAccount,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? AppColors.greyLight : AppColors.grey,
              ),
        ),
        TextButton(
          onPressed: controller.navigateToSignIn,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            AppStrings.signIn,
            style: TextStyle(
              color: AppColors.onboardingContinue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 1500.ms)
        .slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 1500.ms);
  }
}
