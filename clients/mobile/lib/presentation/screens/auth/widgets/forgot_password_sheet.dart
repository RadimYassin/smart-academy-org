import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../controllers/auth/forgot_password_controller.dart';

class ForgotPasswordSheet extends GetView<ForgotPasswordController> {
  const ForgotPasswordSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primary : AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Close Button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: isDarkMode ? AppColors.white : AppColors.black,
                ),
                onPressed: () => Get.back(),
              ),
            ),
            const SizedBox(height: 8),

            // Animated content based on the controller's state
            Obx(
              () => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildPage(theme, isDarkMode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to build the current page
  Widget _buildPage(ThemeData theme, bool isDarkMode) {
    switch (controller.currentPage.value) {
      case ForgotPasswordPage.selectMethod:
        return _buildMethodSelection(theme, isDarkMode);
      case ForgotPasswordPage.emailInput:
        return _buildEmailInput(theme, isDarkMode);
      case ForgotPasswordPage.phoneInput:
        return _buildPhoneInput(theme, isDarkMode);
    }
  }

  // Panel 1: Method Selection
  Widget _buildMethodSelection(ThemeData theme, bool isDarkMode) {
    return Column(
      key: const ValueKey('SelectMethod'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.forgotPasswordTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColors.white : AppColors.black,
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: 100.ms)
            .slideX(begin: -0.1, end: 0, duration: 300.ms, delay: 100.ms),
        const SizedBox(height: 8),
        Text(
          AppStrings.chooseMethodSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDarkMode ? AppColors.greyLight : AppColors.grey,
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: 200.ms),
        const SizedBox(height: 24),

        // Email Option
        _buildMethodTile(
          icon: Icons.email_outlined,
          title: AppStrings.yourEmailOption,
          subtitle: AppStrings.enterYourEmailOption,
          onTap: controller.goToEmailInput,
          isDarkMode: isDarkMode,
          delay: 300.ms,
        ),
        const SizedBox(height: 16),

        // Phone Option
        _buildMethodTile(
          icon: Icons.phone_outlined,
          title: AppStrings.phoneNumberOption,
          subtitle: AppStrings.enterPhoneNumberOption,
          onTap: controller.goToPhoneInput,
          isDarkMode: isDarkMode,
          delay: 400.ms,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMethodTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDarkMode,
    required Duration delay,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primaryDark : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? AppColors.border.withValues(alpha: 0.2)
              : AppColors.border,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.onboardingContinue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.onboardingContinue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? AppColors.white : AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: delay)
        .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: delay);
  }

  // Panel 2: Email Input
  Widget _buildEmailInput(ThemeData theme, bool isDarkMode) {
    return Column(
      key: const ValueKey('EmailInput'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.enterYourEmail,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColors.white : AppColors.black,
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: 100.ms)
            .slideX(begin: -0.1, end: 0, duration: 300.ms, delay: 100.ms),
        const SizedBox(height: 8),
        Text(
          AppStrings.enterEmailSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDarkMode ? AppColors.greyLight : AppColors.grey,
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: 200.ms),
        const SizedBox(height: 24),

        TextField(
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: AppStrings.yourEmail,
            prefixIcon: Icon(
              Icons.email_outlined,
              color: isDarkMode ? AppColors.greyLight : AppColors.grey,
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 300.ms)
            .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 300.ms),
        const SizedBox(height: 16),

        TextButton(
          onPressed: controller.goToMethodSelection,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            AppStrings.useAnotherMethod,
            style: TextStyle(
              color: AppColors.onboardingContinue,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 400.ms),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.sendPasswordResetLink,
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
              AppStrings.sendLink,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 500.ms)
            .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 500.ms),
        const SizedBox(height: 24),
      ],
    );
  }

  // Panel 3: Phone Input
  Widget _buildPhoneInput(ThemeData theme, bool isDarkMode) {
    return Column(
      key: const ValueKey('PhoneInput'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.enterYourPhoneNumber,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColors.white : AppColors.black,
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: 100.ms)
            .slideX(begin: -0.1, end: 0, duration: 300.ms, delay: 100.ms),
        const SizedBox(height: 8),
        Text(
          AppStrings.enterPhoneSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDarkMode ? AppColors.greyLight : AppColors.grey,
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: 200.ms),
        const SizedBox(height: 24),

        TextField(
          controller: controller.phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: AppStrings.yourPhone,
            prefixIcon: Icon(
              Icons.phone_outlined,
              color: isDarkMode ? AppColors.greyLight : AppColors.grey,
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 300.ms)
            .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 300.ms),
        const SizedBox(height: 16),

        TextButton(
          onPressed: controller.goToMethodSelection,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            AppStrings.useAnotherMethod,
            style: TextStyle(
              color: AppColors.onboardingContinue,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 400.ms),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.sendPasswordResetLink,
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
              AppStrings.sendLink,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 500.ms)
            .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 500.ms),
        const SizedBox(height: 24),
      ],
    );
  }
}

