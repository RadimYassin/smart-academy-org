import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../routes/app_routes.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the topic name passed as an argument
    final String topicName = Get.arguments as String? ?? 'Category';
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.primary : AppColors.background,
      body: Column(
        children: [
          // --- Custom Header ---
          _buildCategoryHeader(context, theme, isDarkMode, topicName),

          // --- Scrollable Content ---
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // --- "Most popular" Section ---
                  _buildSectionHeader(AppStrings.mostPopular, showSeeMore: true, isDarkMode: isDarkMode),
                  const SizedBox(height: 16),
                  _buildPopularCoursesList(context, theme, isDarkMode),
                  const SizedBox(height: 24),

                  // --- "Explore topics" (sub-topics) ---
                  _buildSectionHeader(AppStrings.exploreTopics, showSeeMore: true, isDarkMode: isDarkMode),
                  const SizedBox(height: 16),
                  _buildSubTopicsList(context, theme, isDarkMode),
                  const SizedBox(height: 24),

                  // --- "Featured course" Section ---
                  _buildSectionHeader(AppStrings.featuredCourse, isDarkMode: isDarkMode),
                  const SizedBox(height: 16),
                  _buildFeaturedCourseCard(context, theme, isDarkMode),
                  const SizedBox(height: 48), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Header Widget ---
  Widget _buildCategoryHeader(
    BuildContext context,
    ThemeData theme,
    bool isDarkMode,
    String topicName,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 60, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.dashboardHeader,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.white),
                onPressed: () => Get.back(),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .scale(delay: 100.ms),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$topicName ${AppStrings.courses}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 200.ms)
                      .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 200.ms),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.letsExploreCourse,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.7),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 400.ms)
                      .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 400.ms),
                ],
              ),
            ],
          ),
          Icon(Icons.category_rounded, color: AppColors.white, size: 32)
              .animate()
              .fadeIn(duration: 500.ms, delay: 300.ms)
              .scale(delay: 300.ms),
        ],
      ),
    );
  }

  // --- Helper for Section Headers ---
  Widget _buildSectionHeader(String title, {bool showSeeMore = false, required bool isDarkMode}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? AppColors.white : AppColors.black,
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 600.ms)
              .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 600.ms),
          if (showSeeMore)
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                AppStrings.seeMore,
                style: const TextStyle(
                  color: AppColors.onboardingContinue,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 700.ms),
        ],
      ),
    );
  }

  // --- "Most popular" List ---
  Widget _buildPopularCoursesList(BuildContext context, ThemeData theme, bool isDarkMode) {
    final courseList = [
      {
        'title': AppStrings.photoshopBlendTool,
        'category': AppStrings.finance,
        'price': '\$30.00',
        'rating': '4.9 (40,312)',
      },
      {
        'title': AppStrings.completeCourse,
        'category': AppStrings.finance,
        'price': '\$150.00',
        'rating': '4.8 (25,000)',
      },
      {
        'title': 'Advanced Design Techniques',
        'category': AppStrings.design,
        'price': '\$89.00',
        'rating': '4.7 (18,500)',
      },
    ];

    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: courseList.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final course = courseList[index];
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 24.0 : 16,
              right: index == courseList.length - 1 ? 24.0 : 0,
            ),
            child: _buildCourseCard(context, course, isDarkMode, index),
          );
        },
      ),
    );
  }

  // Reuse the course card widget from HomeScreen
  Widget _buildCourseCard(BuildContext context, Map<String, String> course, bool isDarkMode, int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth * 0.7).clamp(200.0, 240.0);

    return SizedBox(
      width: cardWidth,
      child: InkWell(
        onTap: () {
          Get.toNamed(AppRoutes.courseDetails, arguments: course['title']);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.primaryDark : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Image Placeholder
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.greyLight.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Icon(Icons.image, size: 50, color: AppColors.grey),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      course['category']!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Course Title
                  Text(
                    course['title']!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? AppColors.white : AppColors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // Price
                  Text(
                    course['price']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onboardingContinue,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Rating
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 16, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          course['rating'] ?? '4.8 (1,881)',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
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
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: (800 + (index * 100)).ms)
        .slideX(begin: 0.2, end: 0, duration: 500.ms, delay: (800 + (index * 100)).ms);
  }

  // --- "Explore topics" (Sub-topics) ---
  Widget _buildSubTopicsList(BuildContext context, ThemeData theme, bool isDarkMode) {
    final topics = [
      {'name': AppStrings.branding, 'icon': Icons.brush},
      {'name': AppStrings.uxDesign, 'icon': Icons.design_services},
      {'name': AppStrings.illustration, 'icon': Icons.palette},
      {'name': AppStrings.figma, 'icon': Icons.crop_square},
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topic = topics[index];
          return Padding(
            padding: EdgeInsets.only(right: index == topics.length - 1 ? 0 : 24),
            child: _buildSubTopicIcon(
              context,
              theme,
              isDarkMode,
              topic['name'] as String,
              topic['icon'] as IconData,
              index,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubTopicIcon(
    BuildContext context,
    ThemeData theme,
    bool isDarkMode,
    String label,
    IconData icon,
    int index,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.onboardingContinue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.onboardingContinue, size: 28),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: (1000 + (index * 100)).ms)
            .scale(delay: (1000 + (index * 100)).ms),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? AppColors.greyLight : AppColors.grey,
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: (1100 + (index * 100)).ms),
      ],
    );
  }

  // --- "Featured course" Card ---
  Widget _buildFeaturedCourseCard(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.primaryDark : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background placeholder
              Container(
                color: AppColors.greyLight.withValues(alpha: 0.2),
                child: Icon(Icons.image, size: 60, color: AppColors.grey),
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      AppStrings.featuredCourse,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Discover the best courses from top instructors',
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 1400.ms)
        .slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 1400.ms);
  }
}

