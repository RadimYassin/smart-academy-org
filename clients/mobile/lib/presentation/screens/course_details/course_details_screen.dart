import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../controllers/course_details_controller.dart';

class CourseDetailsScreen extends GetView<CourseDetailsController> {
  const CourseDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // TODO: Get real course data based on ID
    final String courseTitle = Get.arguments as String? ?? 'Course Title';

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
          courseTitle,
          style: TextStyle(
            color: isDarkMode ? AppColors.white : AppColors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share_outlined,
              color: isDarkMode ? AppColors.white : AppColors.black,
            ),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: controller.tabController,
          tabs: controller.courseTabs,
          labelColor: AppColors.onboardingContinue,
          unselectedLabelColor: isDarkMode ? AppColors.greyLight : AppColors.grey,
          indicatorColor: AppColors.onboardingContinue,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: [
          _buildAboutTab(context, theme, isDarkMode),
          _buildLessonsTab(context, theme, isDarkMode),
          _buildReviewsTab(context, theme, isDarkMode),
        ],
      ),
      // --- Sticky Bottom Bar ---
      bottomNavigationBar: _buildBottomBar(context, theme, isDarkMode),
    );
  }

  Widget _buildBottomBar(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24).copyWith(bottom: 32),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primary : AppColors.background,
        border: Border(
          top: BorderSide(
            color: isDarkMode ? AppColors.border.withValues(alpha: 0.2) : AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          OutlinedButton(
            onPressed: controller.toggleWishlist,
            style: OutlinedButton.styleFrom(
              foregroundColor: isDarkMode ? AppColors.white : AppColors.black,
              side: BorderSide(
                color: isDarkMode ? AppColors.border.withValues(alpha: 0.3) : AppColors.border,
              ),
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(16),
            ),
            child: const Icon(Icons.favorite_border),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: controller.buyCourse,
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
                '${AppStrings.buy} \$69.00',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 300.ms)
        .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 300.ms);
  }

  // --- Tab 1: About ---
  Widget _buildAboutTab(BuildContext context, ThemeData theme, bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.descriptions,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.white : AppColors.black,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: 100.ms),
          const SizedBox(height: 16),
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.isDescriptionExpanded.value
                      ? AppStrings.courseDescriptionExtended
                      : AppStrings.courseDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                    height: 1.5,
                  ),
                ),
                TextButton(
                  onPressed: controller.toggleDescription,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    controller.isDescriptionExpanded.value ? AppStrings.showLess : AppStrings.showMore,
                    style: TextStyle(
                      color: AppColors.onboardingContinue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 300.ms)
              .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: 300.ms),
          const SizedBox(height: 24),
          Text(
            AppStrings.keyPoints,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.white : AppColors.black,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 500.ms)
              .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: 500.ms),
          const SizedBox(height: 16),
          _buildKeyPointTile(theme, AppStrings.criticalThinking, 6)
              .animate()
              .fadeIn(duration: 400.ms, delay: 700.ms)
              .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: 700.ms),
          _buildKeyPointTile(theme, AppStrings.userExperienceResearch, 8)
              .animate()
              .fadeIn(duration: 400.ms, delay: 900.ms)
              .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: 900.ms),
          _buildKeyPointTile(theme, AppStrings.usabilityTesting, 10)
              .animate()
              .fadeIn(duration: 400.ms, delay: 1100.ms)
              .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: 1100.ms),
        ],
      ),
    );
  }

  Widget _buildKeyPointTile(ThemeData theme, String title, int delayIndex) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Tab 2: Lessons ---
  Widget _buildLessonsTab(BuildContext context, ThemeData theme, bool isDarkMode) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Text(
          AppStrings.classLabel,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColors.white : AppColors.black,
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: 100.ms),
        const SizedBox(height: 16),
        _buildLessonTile(theme, AppStrings.instructorIntroduction, '04:00', Icons.play_circle_fill, true, 3)
            .animate()
            .fadeIn(duration: 400.ms, delay: 300.ms)
            .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: 300.ms),
        _buildLessonTile(theme, AppStrings.designShortage, '03:49', Icons.play_circle_fill, true, 5)
            .animate()
            .fadeIn(duration: 400.ms, delay: 500.ms)
            .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: 500.ms),
        _buildLessonTile(theme, AppStrings.makeItPretty, '03:49', Icons.lock_outline, false, 7)
            .animate()
            .fadeIn(duration: 400.ms, delay: 700.ms)
            .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: 700.ms),
        const SizedBox(height: 24),
        Text(
          AppStrings.userExperienceResearch,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColors.white : AppColors.black,
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 900.ms)
            .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: 900.ms),
        const SizedBox(height: 16),
        _buildLessonTile(theme, AppStrings.researchProcess, '05:00', Icons.lock_outline, false, 11)
            .animate()
            .fadeIn(duration: 400.ms, delay: 1100.ms)
            .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: 1100.ms),
        _buildLessonTile(theme, AppStrings.doingResearch, '06:43', Icons.lock_outline, false, 13)
            .animate()
            .fadeIn(duration: 400.ms, delay: 1300.ms)
            .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: 1300.ms),
      ],
    );
  }

  Widget _buildLessonTile(ThemeData theme, String title, String duration, IconData icon, bool isUnlocked, int delayIndex) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: isUnlocked ? AppColors.success : AppColors.grey,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isUnlocked ? AppColors.black : AppColors.grey,
        ),
      ),
      trailing: Text(
        duration,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.grey,
        ),
      ),
      onTap: isUnlocked ? () {} : null,
    );
  }

  // --- Tab 3: Reviews ---
  Widget _buildReviewsTab(BuildContext context, ThemeData theme, bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.ratings,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.white : AppColors.black,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: 100.ms),
          const SizedBox(height: 16),
          _buildRatingsCard(context, theme, isDarkMode)
              .animate()
              .fadeIn(duration: 500.ms, delay: 300.ms)
              .scale(delay: 300.ms),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.userReviews,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppColors.white : AppColors.black,
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.onboardingContinue,
                ),
                icon: const Icon(Icons.sort, size: 18),
                label: Text(AppStrings.sort),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 800.ms)
              .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 800.ms),
          const SizedBox(height: 16),
          _buildUserReviewTile(context, theme, 'Merrill Kervin', '4.5', '3 ${AppStrings.weeksAgo}', 'Pulvinar nisl blandit cras lacus diam posuere. Varius sem vestibulum egestas ultricies. Gravida aliquam nibh ultricies risus augue a enim nulla.', 10)
              .animate()
              .fadeIn(duration: 400.ms, delay: 1000.ms)
              .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 1000.ms),
          _buildUserReviewTile(context, theme, 'John Doe', '5.0', '1 ${AppStrings.monthAgo}', 'Amazing course! Highly recommend to anyone interested in digital product design.', 12)
              .animate()
              .fadeIn(duration: 400.ms, delay: 1200.ms)
              .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 1200.ms),
        ],
      ),
    );
  }

  Widget _buildRatingsCard(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Card(
      color: isDarkMode ? AppColors.primaryDark : AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              AppStrings.customerReview,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.white : AppColors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '12K ${AppStrings.kRatings} - 1,765 ${AppStrings.kReviews}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDarkMode ? AppColors.greyLight : AppColors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '4.5',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppColors.white : AppColors.black,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.outOf5,
                  style: TextStyle(
                    color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => Icon(
                  Icons.star,
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildRatingBar(theme, '5 star', 0.60, isDarkMode),
            const SizedBox(height: 8),
            _buildRatingBar(theme, '4 star', 0.35, isDarkMode),
            const SizedBox(height: 8),
            _buildRatingBar(theme, '3 star', 0.05, isDarkMode),
            const SizedBox(height: 8),
            _buildRatingBar(theme, '2 star', 0.05, isDarkMode),
            const SizedBox(height: 8),
            _buildRatingBar(theme, '1 star', 0.05, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBar(ThemeData theme, String label, double percent, bool isDarkMode) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? AppColors.greyLight : AppColors.grey,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: isDarkMode
                  ? AppColors.border.withValues(alpha: 0.2)
                  : AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.warning),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 35,
          child: Text(
            '${(percent * 100).toInt()}%',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? AppColors.greyLight : AppColors.grey,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildUserReviewTile(BuildContext context, ThemeData theme, String name, String rating, String date, String review, int delayIndex) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      color: isDarkMode ? AppColors.primaryDark : AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.onboardingContinue,
                  radius: 24,
                  child: Text(
                    name[0],
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? AppColors.white : AppColors.black,
                        ),
                      ),
                      Text(
                        date,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(rating),
                  avatar: const Icon(
                    Icons.star,
                    color: AppColors.warning,
                    size: 16,
                  ),
                  backgroundColor: isDarkMode ? AppColors.primaryLight : AppColors.background,
                  labelStyle: TextStyle(
                    color: isDarkMode ? AppColors.white : AppColors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              review,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

