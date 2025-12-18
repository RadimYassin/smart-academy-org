import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../routes/app_routes.dart';
import '../../controllers/auth/signin_controller.dart';

class SignInScreen extends GetView<SignInController> {
  const SignInScreen({super.key});

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
              // Tab Bar
              _buildTabBar(context, isDarkMode),
              const SizedBox(height: 24),
              // Tab View Content
              Expanded(
                child: _buildTabView(context, isDarkMode),
              ),
              const SizedBox(height: 24),
              // Sign In Button
              _buildSignInButton(context, isDarkMode),
              const SizedBox(height: 24),
              // Divider
              _buildDivider(context, isDarkMode),
              const SizedBox(height: 16),
              // Social Login Buttons
              _buildSocialLogins(context, isDarkMode),
              const SizedBox(height: 24),
              // Sign Up Link
              _buildSignUpLink(context, isDarkMode),
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
          AppStrings.welcomeBack,
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
          AppStrings.welcomeBackSubtitle,
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

  Widget _buildTabBar(BuildContext context, bool isDarkMode) {
    return TabBar(
      controller: controller.tabController,
      tabs: controller.authTabs,
      labelColor: AppColors.onboardingContinue,
      unselectedLabelColor: isDarkMode ? AppColors.greyLight : AppColors.grey,
      indicatorColor: AppColors.onboardingContinue,
      indicatorWeight: 3,
      labelStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 500.ms)
        .slideY(begin: -0.1, end: 0, duration: 500.ms, delay: 500.ms);
  }

  Widget _buildTabView(BuildContext context, bool isDarkMode) {
    return TabBarView(
      controller: controller.tabController,
      children: [
        _buildEmailTab(context, isDarkMode),
        _buildPhoneTab(context, isDarkMode),
      ],
    );
  }

  Widget _buildEmailTab(BuildContext context, bool isDarkMode) {
    return Column(
      children: [
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
        const SizedBox(height: 16),
        // Forgot Password Link
        _buildForgotPasswordLink(context, isDarkMode),
      ],
    );
  }

  Widget _buildPhoneTab(BuildContext context, bool isDarkMode) {
    return Column(
      children: [
        // Phone Field
        TextField(
          controller: controller.phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: AppStrings.yourPhone,
            prefixIcon: Icon(
              Icons.phone_outlined,
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
          hintText: AppStrings.yourPassword,
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

  Widget _buildForgotPasswordLink(BuildContext context, bool isDarkMode) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: controller.openForgotPasswordSheet,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          AppStrings.forgotPassword,
          style: TextStyle(
            color: AppColors.onboardingContinue,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 1100.ms);
  }

  Widget _buildSignInButton(BuildContext context, bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.signIn,
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
          AppStrings.signIn,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 1300.ms)
        .slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 1300.ms)
        .scale(
          delay: 1300.ms,
          duration: 500.ms,
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.0, 1.0),
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildDivider(BuildContext context, bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: isDarkMode ? AppColors.primaryDark : AppColors.border,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppStrings.orWith,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                ),
          ),
        ),
        Expanded(
          child: Divider(
            color: isDarkMode ? AppColors.primaryDark : AppColors.border,
            thickness: 1,
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 1500.ms);
  }

  Widget _buildSocialLogins(BuildContext context, bool isDarkMode) {
    return Row(
      children: [
        // Apple Button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement Apple sign in
            },
            icon: Image.asset(
              'assets/images/apple_icon.png',
              width: 20,
              height: 20,
            ),
            label: const Text('Apple'),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDarkMode ? AppColors.white : AppColors.black,
              side: BorderSide(
                color: isDarkMode
                    ? AppColors.border.withValues(alpha: 0.2)
                    : AppColors.border,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 1700.ms)
            .scale(delay: 1700.ms),
        const SizedBox(width: 12),
        // Google Button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement Google sign in
            },
            icon: Image.asset(
              'assets/images/google_icon.png',
              width: 20,
              height: 20,
            ),
            label: const Text('Google'),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDarkMode ? AppColors.white : AppColors.black,
              side: BorderSide(
                color: isDarkMode
                    ? AppColors.border.withValues(alpha: 0.2)
                    : AppColors.border,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 1900.ms)
            .scale(delay: 1900.ms),
      ],
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
            Get.toNamed(AppRoutes.signup);
          },
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
        .fadeIn(duration: 500.ms, delay: 2100.ms);
  }
}

