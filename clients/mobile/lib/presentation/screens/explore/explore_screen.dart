import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../routes/app_routes.dart';
import '../../controllers/explore_controller.dart';

class ExploreScreen extends GetView<ExploreController> {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.primary : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // --- Search Bar ---
            _buildSearchBar(context, theme, isDarkMode),

            // --- Content ---
            Expanded(
              child: Obx(
                () => controller.isSearching.value
                    ? _buildSearchView(context, theme, isDarkMode)
                    : _buildDefaultView(context, theme, isDarkMode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Search Bar (Shared) ---
  Widget _buildSearchBar(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Obx(
        () {
          final hasText = controller.searchQuery.isNotEmpty;

          return TextField(
            controller: controller.searchController,
            decoration: InputDecoration(
              hintText: AppStrings.searchForAnything,
              prefixIcon: Icon(
                Icons.search,
                color: isDarkMode ? AppColors.greyLight : AppColors.grey,
              ),
              suffixIcon: hasText
                  ? IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                      ),
                      onPressed: controller.clearSearch,
                    )
                  : Icon(
                      Icons.shopping_bag_outlined,
                      color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                    ),
              filled: true,
              fillColor: isDarkMode ? AppColors.primaryDark : AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          );
        },
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 100.ms)
        .slideY(begin: -0.2, end: 0, duration: 400.ms, delay: 100.ms);
  }

  // --- Default View (Panel 1) ---
  Widget _buildDefaultView(BuildContext context, ThemeData theme, bool isDarkMode) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // --- Promo Banner ---
          _buildPromoBanner(context, theme, isDarkMode),
          const SizedBox(height: 32),

          // --- Topics Section ---
          _buildSectionHeader(AppStrings.topics, showSeeMore: true, isDarkMode: isDarkMode),
          const SizedBox(height: 16),
          _buildExploreTopics(context, theme, isDarkMode),
          const SizedBox(height: 32),

          // --- Recently Added ---
          _buildSectionHeader(AppStrings.recentlyAdded, showSeeMore: true, isDarkMode: isDarkMode),
          const SizedBox(height: 16),
          _buildRecentlyAddedList(context, theme, isDarkMode),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // --- Search View (Panel 1, 2, 3) ---
  Widget _buildSearchView(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Column(
      children: [
        // --- Filter Bar ---
        _buildFilterBar(context, theme, isDarkMode),

        // --- Results Header ---
        _buildResultsHeader(context, theme, isDarkMode),

        // --- Results List/Grid ---
        Expanded(
          child: Obx(
            () => controller.isGridView.value
                ? _buildResultsGrid(context, theme, isDarkMode)
                : _buildResultsList(context, theme, isDarkMode),
          ),
        ),
      ],
    );
  }

  // --- Helper Widgets ---

  Widget _buildPromoBanner(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.onboardingContinue,
              AppColors.onboardingContinue.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.onboardingContinue.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.exploreOurBestLearningPaths,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 200.ms)
                        .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 200.ms),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.onboardingContinue,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        AppStrings.viewAll,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 400.ms)
                        .scale(delay: 400.ms),
                  ],
                ),
              ),
              // Placeholder for woman image
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: AppColors.white,
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 300.ms)
                  .scale(delay: 300.ms),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 300.ms)
        .slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 300.ms);
  }

  Widget _buildSectionHeader(String title, {bool showSeeMore = false, required bool isDarkMode}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
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
              child: const Text(
                AppStrings.seeMore,
                style: TextStyle(
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
          _buildTopicCard(context, theme, AppStrings.design, Icons.design_services_outlined, isDarkMode, 800.ms),
          _buildTopicCard(context, theme, AppStrings.business, Icons.business_center_outlined, isDarkMode, 900.ms),
          _buildTopicCard(context, theme, AppStrings.finance, Icons.analytics_outlined, isDarkMode, 1000.ms),
          _buildTopicCard(context, theme, AppStrings.marketing, Icons.campaign_outlined, isDarkMode, 1100.ms),
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

  Widget _buildRecentlyAddedList(BuildContext context, ThemeData theme, bool isDarkMode) {
    final courseList = [
      {
        'title': AppStrings.investmentBankingCourse,
        'category': AppStrings.finance,
        'price': '\$120.00',
        'rating': '4.8 (1,881)',
      },
      {
        'title': AppStrings.backendGuide,
        'category': AppStrings.finance,
        'price': '\$96.00',
        'rating': '4.9 (2,500)',
      },
      {
        'title': 'Advanced Flutter Development',
        'category': 'Development',
        'price': '\$149.00',
        'rating': '4.7 (3,200)',
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
            child: _buildCourseCard(context, course, isDarkMode, index, 1200.ms),
          );
        },
      ),
    );
  }

  Widget _buildCourseCard(
    BuildContext context,
    Map<String, String> course,
    bool isDarkMode,
    int index,
    Duration customDelay,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth * 0.7).clamp(200.0, 240.0);

    return SizedBox(
      width: cardWidth,
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
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: customDelay)
        .slideX(begin: 0.2, end: 0, duration: 500.ms, delay: customDelay);
  }

  // --- Filter Bar Widget ---
  Widget _buildFilterBar(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFilterChip(context, theme, AppStrings.filter, Icons.filter_list, isDarkMode),
          _buildFilterChip(context, theme, AppStrings.sortBy, null, isDarkMode),
          _buildFilterChip(context, theme, AppStrings.allLevels, null, isDarkMode),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 200.ms)
        .slideY(begin: -0.1, end: 0, duration: 400.ms, delay: 200.ms);
  }

  Widget _buildFilterChip(
    BuildContext context,
    ThemeData theme,
    String label,
    IconData? icon,
    bool isDarkMode,
  ) {
    final bool isFilterButton = label == AppStrings.filter;

    return OutlinedButton.icon(
      onPressed: isFilterButton ? controller.openFilterSheet : () {},
      icon: icon != null
          ? Icon(
              icon,
              size: 18,
              color: isDarkMode ? AppColors.greyLight : AppColors.grey,
            )
          : const SizedBox.shrink(),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? AppColors.white : AppColors.black,
            ),
          ),
          if (icon == null) // Show dropdown arrow if no leading icon
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: isDarkMode ? AppColors.greyLight : AppColors.grey,
            ),
        ],
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: isDarkMode ? AppColors.border.withValues(alpha: 0.3) : AppColors.border,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  // --- Results Header Widget ---
  Widget _buildResultsHeader(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '10,000 ${AppStrings.results}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? AppColors.white : AppColors.black,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 300.ms),
          Obx(
            () {
              final isGrid = controller.isGridView.value;
              return Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.grid_view_rounded,
                      color: isGrid ? AppColors.onboardingContinue : AppColors.grey,
                    ),
                    onPressed: controller.toggleViewMode,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.view_list_rounded,
                      color: !isGrid ? AppColors.onboardingContinue : AppColors.grey,
                    ),
                    onPressed: controller.toggleViewMode,
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms);
            },
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 300.ms)
        .slideY(begin: -0.1, end: 0, duration: 400.ms, delay: 300.ms);
  }

  // --- Results List (Panel 1) ---
  Widget _buildResultsList(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${controller.errorMessage.value}',
                  style: TextStyle(
                    color: isDarkMode ? AppColors.white : AppColors.black,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.loadAllCourses(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.filteredCourses.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'No courses found',
              style: TextStyle(
                color: isDarkMode ? AppColors.greyLight : AppColors.grey,
              ),
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
        itemCount: controller.filteredCourses.length,
        itemBuilder: (context, index) {
          final course = controller.filteredCourses[index];
          return _buildListCardFromCourse(context, course, isDarkMode, index);
        },
      );
    });
  }

  Widget _buildListCardFromCourse(BuildContext context, course, bool isDarkMode, int index) {
    return InkWell(
      onTap: () => Get.toNamed('/course-details', arguments: course.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.primaryDark : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course thumbnail
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.onboardingContinue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: course.thumbnailUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        course.thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.book, size: 32);
                        },
                      ),
                    )
                  : const Icon(Icons.book, size: 32),
            ),
            const SizedBox(width: 16),
            // Course info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? AppColors.white : AppColors.black,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.category,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getLevelColor(course.level).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          course.level,
                          style: TextStyle(
                            fontSize: 10,
                            color: _getLevelColor(course.level),
                            fontWeight: FontWeight.w600,
                          ),
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

  Color _getLevelColor(String level) {
    switch (level) {
      case 'BEGINNER':
        return Colors.green;
      case 'INTERMEDIATE':
        return Colors.orange;
      case 'ADVANCED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildListCard(BuildContext context, Map<String, String> course, bool isDarkMode, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.greyLight.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Icon(Icons.laptop, size: 40, color: AppColors.grey),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        course['category']!,
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Title
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
                    const SizedBox(height: 8),
                    // Price
                    Text(
                      course['price']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onboardingContinue,
                      ),
                    ),
                    // Rating
                    Row(
                      children: [
                        Icon(Icons.star, color: AppColors.warning, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          course['rating']!,
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
            ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (500 + (index * 100)).ms)
        .slideX(begin: 0.2, end: 0, duration: 400.ms, delay: (500 + (index * 100)).ms);
  }

  // --- Results Grid (Panel 2 & 3) ---
  Widget _buildResultsGrid(BuildContext context, ThemeData theme, bool isDarkMode) {
    final courseList = [
      {
        'title': AppStrings.masterDigitalProductDesign,
        'category': AppStrings.design,
        'price': '\$89.00',
        'rating': '4.8',
      },
      {
        'title': AppStrings.completeInvestmentBanking,
        'category': AppStrings.finance,
        'price': '\$150.00',
        'rating': '4.9',
      },
      {
        'title': AppStrings.photoshopBlendTool,
        'category': AppStrings.finance,
        'price': '\$30.00',
        'rating': '4.7',
      },
      {
        'title': AppStrings.completeWebDesign,
        'category': AppStrings.design,
        'price': '\$120.00',
        'rating': '4.8',
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: courseList.length,
      itemBuilder: (context, index) {
        final course = courseList[index];
        return _buildGridCard(context, course, isDarkMode, index);
      },
    );
  }

  Widget _buildGridCard(BuildContext context, Map<String, String> course, bool isDarkMode, int index) {
    return InkWell(
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
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.greyLight.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Icon(Icons.image, size: 50, color: AppColors.grey),
            ),
          ),
          // Content
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      course['category']!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Title
                  Text(
                    course['title']!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? AppColors.white : AppColors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // Price
                  Text(
                    course['price']!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onboardingContinue,
                    ),
                  ),
                  // Rating
                  Row(
                    children: [
                      Icon(Icons.star, color: AppColors.warning, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        course['rating']!,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (500 + (index * 100)).ms)
        .scale(delay: (500 + (index * 100)).ms, duration: 400.ms, begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0));
  }
}
