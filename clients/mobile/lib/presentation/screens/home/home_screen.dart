import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../routes/app_routes.dart';
import '../../controllers/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.primary : AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Custom Header (Now it's sticky) ---
          _buildHeader(context, theme, isDarkMode),

          // --- Wrap the rest in Expanded and SingleChildScrollView ---
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  
                  // --- "Continue Learning" Section ---
                  _buildSectionHeader(AppStrings.continueLearning, isDarkMode: isDarkMode),
                  const SizedBox(height: 16),
                  _buildContinueLearningCard(context, theme, isDarkMode),
                  const SizedBox(height: 32),
                  
                  // --- "Recently Added" Section ---
                  _buildSectionHeader(AppStrings.recentlyAdded, showSeeMore: true, isDarkMode: isDarkMode),
                  const SizedBox(height: 16),
                  _buildRecentlyAddedList(context, theme, isDarkMode),
                  const SizedBox(height: 24),

                  // --- "Explore topics" Section ---
                  _buildSectionHeader(AppStrings.exploreTopics, showSeeMore: true, isDarkMode: isDarkMode),
                  const SizedBox(height: 16),
                  _buildExploreTopics(context, theme, isDarkMode),
                  const SizedBox(height: 24),

                  // --- "Popular courses" Section ---
                  _buildSectionHeader(AppStrings.popularCourses, showSeeMore: true, isDarkMode: isDarkMode),
                  const SizedBox(height: 16),
                  _buildPopularCoursesList(context, theme, isDarkMode),
                  const SizedBox(height: 24),

                  // --- "Suggestion for you" Section ---
                  _buildSectionHeader(AppStrings.suggestionForYou, showSeeMore: true, isDarkMode: isDarkMode),
                  const SizedBox(height: 16),
                  _buildSuggestionsList(context, theme, isDarkMode),
                  const SizedBox(height: 48), // Padding for nav bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Header Widget ---
  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.dashboardHeader,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => controller.isLoading.value
                          ? Text(
                              'Welcome...',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Text(
                              controller.getWelcomeMessage(),
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 100.ms)
                        .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: 100.ms),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.upgradeSkill,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.7),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 200.ms)
                        .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: 200.ms),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.search_rounded, color: AppColors.white),
                    onPressed: () {},
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 300.ms)
                      .scale(delay: 300.ms),
                  IconButton(
                    icon: const Icon(Icons.auto_awesome, color: AppColors.white),
                    onPressed: () {
                      Get.toNamed(AppRoutes.aiChat);
                    },
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 325.ms)
                      .scale(delay: 325.ms),
                  IconButton(
                    icon: const Icon(Icons.message_outlined, color: AppColors.white),
                    onPressed: () {
                      Get.toNamed(AppRoutes.messages);
                    },
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 350.ms)
                      .scale(delay: 350.ms),
                  IconButton(
                    icon: Stack(
                      children: [
                        const Icon(Icons.notifications_none_rounded, color: AppColors.white),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      Get.toNamed(AppRoutes.notifications);
                    },
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 400.ms)
                      .scale(delay: 400.ms),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // --- Search Bar ---
          TextField(
            decoration: InputDecoration(
              hintText: AppStrings.whatDoYouWantToLearn,
              prefixIcon: Icon(Icons.search, color: AppColors.grey),
              filled: true,
              fillColor: AppColors.primaryLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 500.ms)
              .slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 500.ms),
        ],
      ),
    );
  }

  // --- Section Header Helper ---
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
              .fadeIn(duration: 400.ms, delay: 600.ms)
              .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: 600.ms),
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
                .fadeIn(duration: 400.ms, delay: 700.ms),
        ],
      ),
    );
  }

  // --- "Continue Learning" Card ---
  Widget _buildContinueLearningCard(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Placeholder for course image
                  Container(
                    width: 80,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.greyLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.laptop,
                      size: 30,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.dashboardCategory.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            AppStrings.website,
                            style: TextStyle(
                              color: AppColors.dashboardCategory,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.fundamentalsHtmlCss,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? AppColors.white : AppColors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '23 of 33 ${AppStrings.lessonsProgress}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                    ),
                  ),
                  Text(
                    '75% ${AppStrings.completed}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.75,
                  backgroundColor: isDarkMode
                      ? AppColors.primaryLight
                      : AppColors.progressInactive,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.onboardingContinue),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 800.ms)
        .slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 800.ms);
  }

  // --- "Recently Added" Horizontal List ---
  Widget _buildRecentlyAddedList(BuildContext context, ThemeData theme, bool isDarkMode) {
    final courseList = [
      {
        'title': AppStrings.investmentBankingCourse,
        'category': AppStrings.finance,
        'price': '\$120.00',
      },
      {
        'title': AppStrings.backendGuide,
        'category': AppStrings.finance,
        'price': '\$96.00',
      },
      {
        'title': 'Advanced Flutter Development',
        'category': 'Development',
        'price': '\$149.00',
      },
    ];

    return SizedBox(
      height: 320, // Increased to accommodate content better
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: courseList.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final course = courseList[index];
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 24.0 : 16, right: index == courseList.length - 1 ? 24.0 : 0),
            child: _buildCourseCard(context, course, isDarkMode, index),
          );
        },
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Map<String, String> course, bool isDarkMode, int index, [Duration? customDelay]) {
    // Responsive width: ~70% of screen width, max 240, min 200
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
              child: Icon(
                Icons.image,
                size: 50,
                color: AppColors.grey,
              ),
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
        .fadeIn(duration: 500.ms, delay: customDelay ?? (900 + (index * 100)).ms)
        .slideX(begin: 0.2, end: 0, duration: 500.ms, delay: customDelay ?? (900 + (index * 100)).ms);
  }

  // --- "Explore topics" Grid ---
  Widget _buildExploreTopics(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5,
        children: [
          _buildTopicCard(context, theme, AppStrings.design, Icons.design_services_outlined, isDarkMode, 1200.ms),
          _buildTopicCard(context, theme, AppStrings.business, Icons.business_center_outlined, isDarkMode, 1300.ms),
          _buildTopicCard(context, theme, AppStrings.finance, Icons.analytics_outlined, isDarkMode, 1400.ms),
          _buildTopicCard(context, theme, AppStrings.marketing, Icons.campaign_outlined, isDarkMode, 1500.ms),
        ],
      ),
    );
  }

  Widget _buildTopicCard(
    BuildContext context,
    ThemeData theme,
    String title,
    IconData icon,
    bool isDarkMode,
    Duration delay,
  ) {
    return Card(
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
      color: isDarkMode ? AppColors.primaryDark : AppColors.white,
      child: InkWell(
        onTap: () {
          Get.toNamed(AppRoutes.category, arguments: title);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.onboardingContinue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.onboardingContinue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? AppColors.white : AppColors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: delay)
        .scale(delay: delay, duration: 400.ms, begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0));
  }

  // --- "Popular courses" Horizontal List ---
  Widget _buildPopularCoursesList(BuildContext context, ThemeData theme, bool isDarkMode) {
    final courseList = [
      {
        'title': AppStrings.masterDigitalProductDesign,
        'category': AppStrings.finance,
        'price': '\$70.00',
        'rating': '4.7 (1,882)',
      },
      {
        'title': AppStrings.adobeFamToolIllustrator,
        'category': AppStrings.finance,
        'price': '\$50.00',
        'rating': '4.8 (2,500)',
      },
      {
        'title': 'Advanced UI/UX Design Principles',
        'category': AppStrings.design,
        'price': '\$89.00',
        'rating': '4.9 (3,200)',
      },
    ];

    return SizedBox(
      height: 320, // Increased to accommodate content better
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
            child: _buildCourseCard(context, course, isDarkMode, index, 1600.ms),
          );
        },
      ),
    );
  }

  // --- "Suggestion for you" Horizontal List ---
  Widget _buildSuggestionsList(BuildContext context, ThemeData theme, bool isDarkMode) {
    final suggestionList = [
      {
        'title': 'React Native Development Masterclass',
        'category': AppStrings.business,
        'price': '\$99.00',
        'rating': '4.6 (4,100)',
      },
      {
        'title': 'Digital Marketing Strategies 2024',
        'category': AppStrings.marketing,
        'price': '\$75.00',
        'rating': '4.8 (5,000)',
      },
      {
        'title': 'Business Analytics and Data Science',
        'category': AppStrings.finance,
        'price': '\$129.00',
        'rating': '4.9 (6,300)',
      },
    ];

    return SizedBox(
      height: 320, // Increased to accommodate content better
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: suggestionList.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final course = suggestionList[index];
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 24.0 : 16,
              right: index == suggestionList.length - 1 ? 24.0 : 0,
            ),
            child: _buildCourseCard(context, course, isDarkMode, index, 1800.ms),
          );
        },
      ),
    );
  }
}
