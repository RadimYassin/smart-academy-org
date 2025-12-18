import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../controllers/notification_controller.dart';

class NotificationScreen extends GetView<NotificationController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        title: Text(
          AppStrings.notifications,
          style: TextStyle(
            color: isDarkMode ? AppColors.white : AppColors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: isDarkMode ? AppColors.white : AppColors.black,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Category Filter ---
          _buildCategoryFilter(context, theme, isDarkMode),

          // --- Notification List ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                _buildNotificationCard(
                  context: context,
                  theme: theme,
                  isDarkMode: isDarkMode,
                  icon: Icons.store,
                  iconBgColor: AppColors.onboardingContinue,
                  title: AppStrings.congratsOrderSuccessful,
                  category: AppStrings.orders,
                  date: 'Jan 28, 2023 04:00 PM',
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 100.ms)
                    .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: 100.ms),
                _buildNotificationCard(
                  context: context,
                  theme: theme,
                  isDarkMode: isDarkMode,
                  icon: Icons.discount,
                  iconBgColor: AppColors.warning,
                  title: AppStrings.changesInServiceTime,
                  category: AppStrings.promotions,
                  date: 'Jan 28, 2023 04:00 PM',
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 300.ms)
                    .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: 300.ms),
                _buildNotificationCard(
                  context: context,
                  theme: theme,
                  isDarkMode: isDarkMode,
                  icon: Icons.apps,
                  iconBgColor: AppColors.info,
                  title: AppStrings.changesInServiceTime,
                  category: AppStrings.others,
                  date: 'Jan 05, 2023 11:00 AM',
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 500.ms)
                    .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: 500.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Category Filter Widget ---
  Widget _buildCategoryFilter(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCategoryIcon(
              theme,
              isDarkMode,
              AppStrings.promotions,
              Icons.discount_outlined,
              NotificationCategory.promotions,
              controller.selectedCategory.value,
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 100.ms)
                .scale(delay: 100.ms),
            _buildCategoryIcon(
              theme,
              isDarkMode,
              AppStrings.system,
              Icons.settings_system_daydream_outlined,
              NotificationCategory.system,
              controller.selectedCategory.value,
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 200.ms)
                .scale(delay: 200.ms),
            _buildCategoryIcon(
              theme,
              isDarkMode,
              AppStrings.orders,
              Icons.store_outlined,
              NotificationCategory.orders,
              controller.selectedCategory.value,
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 300.ms)
                .scale(delay: 300.ms),
            _buildCategoryIcon(
              theme,
              isDarkMode,
              AppStrings.others,
              Icons.apps_outlined,
              NotificationCategory.others,
              controller.selectedCategory.value,
            )
                .animate()
                .fadeIn(duration: 300.ms, delay: 400.ms)
                .scale(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(
    ThemeData theme,
    bool isDarkMode,
    String label,
    IconData icon,
    NotificationCategory category,
    NotificationCategory selectedCategory,
  ) {
    final bool isSelected = category == selectedCategory;

    return InkWell(
      onTap: () => controller.selectCategory(category),
      borderRadius: BorderRadius.circular(50),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: isSelected
                ? AppColors.onboardingContinue
                : (isDarkMode ? AppColors.primaryDark : AppColors.white),
            child: Icon(
              icon,
              color: isSelected
                  ? AppColors.white
                  : (isDarkMode ? AppColors.greyLight : AppColors.grey),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? AppColors.greyLight : AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // --- Notification Card Widget ---
  Widget _buildNotificationCard({
    required BuildContext context,
    required ThemeData theme,
    required bool isDarkMode,
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String category,
    required String date,
  }) {
    return Card(
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
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: iconBgColor.withValues(alpha: 0.2),
              child: Icon(
                icon,
                color: iconBgColor,
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
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? AppColors.white : AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.notificationPlaceholder,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        category,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.onboardingContinue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? AppColors.greyDark
                              : AppColors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        date,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDarkMode
                              ? AppColors.greyLight
                              : AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

