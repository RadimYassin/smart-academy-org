import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../controllers/profile_controller.dart';
import '../../routes/app_routes.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.primary : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Custom Header (Replaces AppBar) ---
              _buildHeader(context, theme, isDarkMode)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: -0.1, end: 0, duration: 400.ms, delay: 100.ms),

              // --- User Info Card ---
              _buildUserInfoCard(context, theme, isDarkMode)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .scale(delay: 200.ms),
              const SizedBox(height: 16),

              // --- Stats Cards ---
              _buildStatsCards(context, theme, isDarkMode)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 300.ms)
                  .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 300.ms),
              const SizedBox(height: 16),

              // --- Interests Card ---
              _buildInterestsCard(context, theme, isDarkMode)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 400.ms)
                  .scale(delay: 400.ms),
              const SizedBox(height: 16),

              // --- Activity/Goals Tabs ---
              _buildActivityTabs(context, theme, isDarkMode)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 500.ms)
                  .slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 500.ms),
              const SizedBox(height: 16),

              // --- Settings List ---
              _buildSettingsList(context, theme, isDarkMode)
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 600.ms)
                  .slideY(begin: 0.1, end: 0, duration: 600.ms, delay: 600.ms),

              const SizedBox(height: 48), // Bottom padding for nav bar
            ],
          ),
        ),
      ),
    );
  }

  // --- Header ---
  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppStrings.profile,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.white : AppColors.black,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: isDarkMode ? AppColors.white : AppColors.black,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // --- User Info ---
  Widget _buildUserInfoCard(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Card(
        color: isDarkMode ? AppColors.primaryDark : AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDarkMode
                ? AppColors.border.withValues(alpha: 0.2)
                : AppColors.border,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.onboardingContinue.withValues(alpha: 0.2),
                child: Icon(
                  Icons.person,
                  size: 32,
                  color: AppColors.onboardingContinue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.user.value == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final user = controller.user.value;
                  if (user == null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Loading...',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? AppColors.white : AppColors.black,
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? AppColors.white : AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.onboardingContinue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          user.role.toUpperCase(),
                          style: TextStyle(
                            color: AppColors.onboardingContinue,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: isDarkMode ? AppColors.white : AppColors.black,
                ),
                onPressed: () => _showEditProfileDialog(context, theme, isDarkMode),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Stats ---
  Widget _buildStatsCards(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  color: AppColors.success.withValues(alpha: 0.15),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDarkMode
                          ? AppColors.border.withValues(alpha: 0.2)
                          : AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Obx(() => Text(
                          '${controller.completedCoursesCount.value}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        )),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.courseCompleted,
                          style: TextStyle(
                            color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDarkMode
                          ? AppColors.border.withValues(alpha: 0.2)
                          : AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Obx(() => Text(
                          '${controller.enrolledCoursesCount.value}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        )),
                        const SizedBox(height: 4),
                        Text(
                          'Enrolled Courses',
                          style: TextStyle(
                            color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Credit Balance Card
          Obx(() {
            final credit = controller.creditBalance.value;
            final isLoading = controller.isLoadingCreditBalance.value;
            final error = controller.creditBalanceError.value;
            
            return Card(
              color: Colors.blue.withValues(alpha: 0.15),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDarkMode
                      ? AppColors.border.withValues(alpha: 0.2)
                      : AppColors.border,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            )
                          : Icon(
                              error.isNotEmpty
                                  ? Icons.error_outline
                                  : Icons.account_balance_wallet,
                              color: error.isNotEmpty ? Colors.red : Colors.blue,
                              size: 24,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Credits',
                            style: TextStyle(
                              color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (error.isNotEmpty)
                            Text(
                              error.length > 30 ? '${error.substring(0, 30)}...' : error,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          else
                            Text(
                              credit != null
                                  ? '${credit.balance.toStringAsFixed(2)}'
                                  : isLoading
                                      ? 'Loading...'
                                      : '0.00',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: credit != null ? Colors.blue : (isDarkMode ? AppColors.greyLight : AppColors.grey),
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      color: Colors.blue,
                      onPressed: isLoading ? null : () => controller.loadCreditBalance(),
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- Interests ---
  Widget _buildInterestsCard(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Card(
        color: isDarkMode ? AppColors.primaryDark : AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDarkMode
                ? AppColors.border.withValues(alpha: 0.2)
                : AppColors.border,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInterestChip(AppStrings.uxDesign, isDarkMode)
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 500.ms),
                  _buildInterestChip(AppStrings.finance, isDarkMode)
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 600.ms),
                  _buildInterestChip(AppStrings.design, isDarkMode)
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 700.ms),
                  _buildInterestChip(AppStrings.website, isDarkMode)
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 800.ms),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() => LinearProgressIndicator(
                value: controller.totalProgress.value / 100,
                backgroundColor: isDarkMode
                    ? AppColors.primaryLight
                    : AppColors.progressInactive,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.onboardingContinue),
                borderRadius: BorderRadius.circular(4),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInterestChip(String label, bool isDarkMode) {
    return Chip(
      label: Text(label),
      backgroundColor: isDarkMode
          ? AppColors.onboardingContinue.withValues(alpha: 0.2)
          : AppColors.background,
      labelStyle: TextStyle(
        color: isDarkMode ? AppColors.white : AppColors.black,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  // --- Activity Tabs ---
  Widget _buildActivityTabs(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Card(
        color: isDarkMode ? AppColors.primaryDark : AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDarkMode
                ? AppColors.border.withValues(alpha: 0.2)
                : AppColors.border,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            TabBar(
              controller: controller.tabController,
              tabs: controller.activityTabs,
              labelColor: AppColors.onboardingContinue,
              unselectedLabelColor: isDarkMode ? AppColors.greyLight : AppColors.grey,
              indicatorColor: AppColors.onboardingContinue,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            SizedBox(
              height: 200,
              child: TabBarView(
                controller: controller.tabController,
                children: [
                  // --- Recent Tab ---
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildRecentCourseItem(theme, isDarkMode)
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 900.ms),
                      const SizedBox(height: 8),
                      _buildRecentCourseItem(theme, isDarkMode)
                          .animate()
                          .fadeIn(duration: 300.ms, delay: 1000.ms),
                    ],
                  ),
                  // --- Goals Tab ---
                  Center(
                    child: Text(
                      AppStrings.goalsContent,
                      style: TextStyle(
                        color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                      ),
                    ),
                  ),
                  // --- Activity Tab ---
                  Center(
                    child: Text(
                      AppStrings.activityContent,
                      style: TextStyle(
                        color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCourseItem(ThemeData theme, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primary : AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.greyLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.laptop,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.design,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.masterDigitalProductDesignUx,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppColors.white : AppColors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: 0.75,
                        backgroundColor: isDarkMode
                            ? AppColors.primaryLight
                            : AppColors.progressInactive,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.onboardingContinue),
                        borderRadius: BorderRadius.circular(2),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '75% ${AppStrings.completed}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Settings List ---
  Widget _buildSettingsList(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Card(
        color: isDarkMode ? AppColors.primaryDark : AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDarkMode
                ? AppColors.border.withValues(alpha: 0.2)
                : AppColors.border,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            _buildSettingsTile(context, theme, isDarkMode, AppStrings.personalDetails, Icons.person_outline, () {}),
            _buildSettingsTile(context, theme, isDarkMode, AppStrings.preferenceVideo, Icons.video_settings_outlined, () {}),
            _buildSettingsTile(
              context,
              theme,
              isDarkMode,
              'Course Recommendations',
              Icons.recommend_outlined,
              () => Get.toNamed(AppRoutes.recommendations),
            ),
            _buildSettingsTile(context, theme, isDarkMode, AppStrings.yourDownload, Icons.download_outlined, () {}),
            Obx(() {
              return SwitchListTile(
                title: Text(
                  AppStrings.darkMode,
                  style: TextStyle(
                    color: isDarkMode ? AppColors.white : AppColors.black,
                  ),
                ),
                secondary: Icon(
                  Icons.dark_mode_outlined,
                  color: isDarkMode ? AppColors.white : AppColors.black,
                ),
                value: controller.isDarkMode.value,
                onChanged: controller.toggleDarkMode,
                activeThumbColor: AppColors.onboardingContinue,
              );
            }),
            // Biometric Authentication Toggle
            Obx(() {
              if (!controller.isBiometricAvailable.value) {
                return const SizedBox.shrink();
              }
              
              return SwitchListTile(
                title: Text(
                  'Biometric Authentication',
                  style: TextStyle(
                    color: isDarkMode ? AppColors.white : AppColors.black,
                  ),
                ),
                subtitle: Text(
                  'Use fingerprint or Face ID to sign in quickly',
                  style: TextStyle(
                    color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                    fontSize: 12,
                  ),
                ),
                secondary: Icon(
                  Icons.fingerprint,
                  color: isDarkMode ? AppColors.white : AppColors.black,
                ),
                value: controller.isBiometricEnabled.value,
                onChanged: (value) async {
                  // Update UI immediately for better UX
                  controller.isBiometricEnabled.value = value;
                  // Then perform the actual toggle
                  await controller.toggleBiometric(value);
                },
                activeThumbColor: AppColors.onboardingContinue,
              );
            }),
            Divider(
              color: isDarkMode
                  ? AppColors.border.withValues(alpha: 0.2)
                  : AppColors.border,
            ),
            _buildSettingsTile(context, theme, isDarkMode, AppStrings.referralCode, Icons.card_giftcard_outlined, () {}),
            _buildSettingsTile(context, theme, isDarkMode, AppStrings.learningReminder, Icons.schedule_outlined, () {}),
            _buildSettingsTile(context, theme, isDarkMode, AppStrings.voucherCode, Icons.airplane_ticket_outlined, () {}),
            Divider(
              color: isDarkMode
                  ? AppColors.border.withValues(alpha: 0.2)
                  : AppColors.border,
            ),
            _buildSettingsTile(context, theme, isDarkMode, AppStrings.investerAcademy, Icons.school_outlined, () {}),
            _buildSettingsTile(context, theme, isDarkMode, AppStrings.faqs, Icons.quiz_outlined, () {}),
            _buildSettingsTile(context, theme, isDarkMode, AppStrings.helpCenter, Icons.help_outline, () {}),
            Divider(
              color: isDarkMode
                  ? AppColors.border.withValues(alpha: 0.2)
                  : AppColors.border,
            ),
            _buildSettingsTile(context, theme, isDarkMode, AppStrings.language, Icons.language_outlined, () {}),
            _buildSettingsTile(context, theme, isDarkMode, AppStrings.privacy, Icons.privacy_tip_outlined, () {}),
            Divider(
              color: isDarkMode
                  ? AppColors.border.withValues(alpha: 0.2)
                  : AppColors.border,
            ),
            // Logout button
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => controller.logout(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    ThemeData theme,
    bool isDarkMode,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDarkMode ? AppColors.white : AppColors.black,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? AppColors.white : AppColors.black,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDarkMode ? AppColors.greyLight : AppColors.grey,
      ),
      onTap: onTap,
    );
  }

  // --- Edit Profile Dialog ---
  void _showEditProfileDialog(BuildContext context, ThemeData theme, bool isDarkMode) {
    final controller = Get.find<ProfileController>();
    final user = controller.user.value;
    
    if (user == null) return;

    final firstNameController = TextEditingController(text: user.firstName);
    final lastNameController = TextEditingController(text: user.lastName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.primaryDark : AppColors.white,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: isDarkMode ? AppColors.white : AppColors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                labelStyle: TextStyle(
                  color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDarkMode ? AppColors.border.withValues(alpha: 0.2) : AppColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.onboardingContinue),
                ),
              ),
              style: TextStyle(
                color: isDarkMode ? AppColors.white : AppColors.black,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                labelStyle: TextStyle(
                  color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDarkMode ? AppColors.border.withValues(alpha: 0.2) : AppColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.onboardingContinue),
                ),
              ),
              style: TextStyle(
                color: isDarkMode ? AppColors.white : AppColors.black,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDarkMode ? AppColors.greyLight : AppColors.grey,
              ),
            ),
          ),
          Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () async {
                    await controller.updateProfile(
                      firstNameController.text.trim(),
                      lastNameController.text.trim(),
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.onboardingContinue,
              foregroundColor: AppColors.white,
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  )
                : const Text('Save'),
          )),
        ],
      ),
    );
  }
}
