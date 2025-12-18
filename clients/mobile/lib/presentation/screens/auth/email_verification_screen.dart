import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../controllers/auth/signup_controller.dart';

class EmailVerificationScreen extends GetView<SignUpController> {
  const EmailVerificationScreen({super.key});

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
            Icons.close,
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
              const SizedBox(height: 40),
              // OTP Input
              _buildOtpInput(context, isDarkMode),
              const SizedBox(height: 16),
              // Use different email link
              _buildUseDifferentEmailLink(context, isDarkMode),
              const Spacer(),
              // Verify Account Button
              _buildVerifyButton(context, isDarkMode),
              const SizedBox(height: 16),
              // Resend Code Button
              _buildResendButton(context, isDarkMode),
              const SizedBox(height: 32),
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
          AppStrings.authenticationCode,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.white : AppColors.black,
              ),
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 100.ms)
            .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 100.ms),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                  height: 1.5,
                ),
            children: [
              const TextSpan(text: AppStrings.enterCodeSentToEmail),
              TextSpan(
                text: ', ${controller.emailController.text}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 300.ms)
            .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 300.ms),
      ],
    );
  }

  Widget _buildOtpInput(BuildContext context, bool isDarkMode) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: isDarkMode ? AppColors.white : AppColors.black,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDarkMode ? AppColors.primaryDark : AppColors.border,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(
          color: AppColors.onboardingContinue,
          width: 2,
        ),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: isDarkMode
            ? AppColors.primaryDark
            : AppColors.border.withValues(alpha: 0.3),
        border: Border.all(
          color: AppColors.onboardingContinue,
          width: 2,
        ),
      ),
    );

    return Center(
      child: Pinput(
        controller: controller.otpController,
        length: 5,
        keyboardType: TextInputType.number,
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        submittedPinTheme: submittedPinTheme,
        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
        showCursor: true,
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 500.ms)
        .scale(
          delay: 500.ms,
          duration: 500.ms,
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildUseDifferentEmailLink(BuildContext context, bool isDarkMode) {
    return Center(
      child: TextButton(
        onPressed: controller.goToSignUpScreen,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          AppStrings.useDifferentEmail,
          style: TextStyle(
            color: AppColors.onboardingContinue,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 700.ms);
  }

  Widget _buildVerifyButton(BuildContext context, bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.verifyEmailCode,
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
          AppStrings.verifyAccount,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 900.ms)
        .slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 900.ms)
        .scale(
          delay: 900.ms,
          duration: 500.ms,
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.0, 1.0),
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildResendButton(BuildContext context, bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: controller.resendEmailCode,
        style: OutlinedButton.styleFrom(
          foregroundColor: isDarkMode ? AppColors.white : AppColors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(
            color: isDarkMode
                ? AppColors.border.withValues(alpha: 0.2)
                : AppColors.border,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          AppStrings.resendCode,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? AppColors.greyLight : AppColors.grey,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 1100.ms)
        .slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 1100.ms);
  }
}

