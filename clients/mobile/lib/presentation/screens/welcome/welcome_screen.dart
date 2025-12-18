import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../routes/app_routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.primary : AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Main Illustration
              _buildIllustration(isDarkMode),
              const SizedBox(height: 40),
              // Main Heading
              _buildHeading(context, isDarkMode),
              const SizedBox(height: 16),
              // Subtitle
              _buildSubtitle(context, isDarkMode),
              const Spacer(),
              // Primary Button
              _buildGetStartedButton(context, isDarkMode),
              const SizedBox(height: 24),
              // Divider Text
              _buildSignInWith(context, isDarkMode),
              const SizedBox(height: 16),
              // Social Logins
              _buildSocialLogins(context),
              const SizedBox(height: 32),
              // Sign Up Link
              _buildSignUpLink(context, isDarkMode),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration(bool isDarkMode) {
    return Image.asset(
      'assets/images/app_logo_illustration.png',
      width: 200,
      height: 200,
      fit: BoxFit.contain,
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 100.ms)
        .scale(
          delay: 100.ms,
          duration: 600.ms,
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.0, 1.0),
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildHeading(BuildContext context, bool isDarkMode) {
    return Text(
      AppStrings.welcomeToOverskill,
      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColors.white : AppColors.black,
          ),
      textAlign: TextAlign.center,
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 400.ms)
        .slideY(begin: 0.3, end: 0, duration: 500.ms, delay: 400.ms);
  }

  Widget _buildSubtitle(BuildContext context, bool isDarkMode) {
    return Text(
      AppStrings.oneLessonAtATime,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: isDarkMode ? AppColors.greyLight : AppColors.grey,
          ),
      textAlign: TextAlign.center,
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 600.ms)
        .slideY(begin: 0.3, end: 0, duration: 500.ms, delay: 600.ms);
  }

  Widget _buildGetStartedButton(BuildContext context, bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Get.toNamed(AppRoutes.signup);
        },
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
          AppStrings.getStarted,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 800.ms)
        .slideY(begin: 0.3, end: 0, duration: 500.ms, delay: 800.ms)
        .scale(
          delay: 800.ms,
          duration: 500.ms,
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.0, 1.0),
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildSignInWith(BuildContext context, bool isDarkMode) {
    return Text(
      AppStrings.signInWith,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isDarkMode ? AppColors.greyLight : AppColors.grey,
          ),
      textAlign: TextAlign.center,
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 1000.ms);
  }

  Widget _buildSocialLogins(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          context,
          'assets/images/google_icon.png',
          () {
            // TODO: Implement Google sign in
          },
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 1200.ms)
            .scale(delay: 1200.ms),
        const SizedBox(width: 20),
        _buildSocialButton(
          context,
          'assets/images/apple_icon.png',
          () {
            // TODO: Implement Apple sign in
          },
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 1400.ms)
            .scale(delay: 1400.ms),
        const SizedBox(width: 20),
        _buildSocialButton(
          context,
          'assets/images/facebook_icon.png',
          () {
            // TODO: Implement Facebook sign in
          },
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 1600.ms)
            .scale(delay: 1600.ms),
      ],
    );
  }

  Widget _buildSocialButton(
    BuildContext context,
    String assetPath,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.primaryDark
              : AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.border.withValues(alpha: 0.2)
                : AppColors.border,
            width: 1,
          ),
        ),
        child: Center(
          child: Image.asset(
            assetPath,
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink(BuildContext context, bool isDarkMode) {
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
          onPressed: () {
            Get.toNamed(AppRoutes.signin);
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            AppStrings.signIn,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onboardingContinue,
                ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 1800.ms)
        .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 1800.ms);
  }
}

