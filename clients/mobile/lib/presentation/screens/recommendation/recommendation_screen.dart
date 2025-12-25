import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../controllers/recommendation_controller.dart';
import '../../widgets/course_recommendation_card.dart';

class RecommendationScreen extends GetView<RecommendationController> {
  const RecommendationScreen({super.key});

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
        title: Text(
          AppStrings.courseRecommendations,
          style: TextStyle(
            color: isDarkMode ? AppColors.white : AppColors.black,
          ),
        ),
        actions: [
          Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            return IconButton(
              icon: Icon(
                Icons.refresh,
                color: isDarkMode ? AppColors.white : AppColors.black,
              ),
              onPressed: controller.refresh,
            );
          }),
        ],
      ),
      body: Obx(() {
        // Loading State
        if (controller.isLoading.value && controller.recommendedCourses.isEmpty) {
          return _buildLoadingState(isDarkMode);
        }

        // Error State
        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorState(context, isDarkMode);
        }

        // Empty State
        if (controller.recommendedCourses.isEmpty) {
          return _buildEmptyState(isDarkMode);
        }

        // Success State - Show Recommendations
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: CustomScrollView(
            slivers: [
              // Header with count
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommended for You',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? AppColors.white : AppColors.black,
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
                      const SizedBox(height: 8),
                      Text(
                        '${controller.recommendedCourses.length} courses match your learning path',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                    ],
                  ),
                ),
              ),

              // Course Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final course = controller.recommendedCourses[index];
                      return CourseRecommendationCard(course: course)
                          .animate()
                          .fadeIn(
                            duration: 400.ms,
                            delay: (50 * (index % 6)).ms,
                          )
                          .scale(
                            delay: (50 * (index % 6)).ms,
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1, 1),
                          );
                    },
                    childCount: controller.recommendedCourses.length,
                  ),
                ),
              ),

              // Bottom spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Build loading state with shimmer effect
  Widget _buildLoadingState(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          Shimmer.fromColors(
            baseColor: isDarkMode
                ? AppColors.primaryLight.withValues(alpha: 0.3)
                : AppColors.greyLight.withValues(alpha: 0.3),
            highlightColor: isDarkMode
                ? AppColors.primaryLight.withValues(alpha: 0.5)
                : AppColors.greyLight.withValues(alpha: 0.5),
            child: Container(
              width: 200,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Shimmer.fromColors(
            baseColor: isDarkMode
                ? AppColors.primaryLight.withValues(alpha: 0.3)
                : AppColors.greyLight.withValues(alpha: 0.3),
            highlightColor: isDarkMode
                ? AppColors.primaryLight.withValues(alpha: 0.5)
                : AppColors.greyLight.withValues(alpha: 0.5),
            child: Container(
              width: 150,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Grid shimmer
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: isDarkMode
                      ? AppColors.primaryLight.withValues(alpha: 0.3)
                      : AppColors.greyLight.withValues(alpha: 0.3),
                  highlightColor: isDarkMode
                      ? AppColors.primaryLight.withValues(alpha: 0.5)
                      : AppColors.greyLight.withValues(alpha: 0.5),
                  child: Card(
                    color: isDarkMode ? AppColors.primaryDark : AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(BuildContext context, bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms)
                .scale(delay: 100.ms),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.white : AppColors.black,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? AppColors.greyLight : AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.onboardingContinue,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
          ],
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.success,
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .scale(delay: 100.ms),
          const SizedBox(height: 16),
          Text(
            'All Caught Up!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.white : AppColors.black,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Text(
              'You\'re enrolled in all available courses. Keep up the great work!',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? AppColors.greyLight : AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
          ),
        ],
      ),
    );
  }
}


