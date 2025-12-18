import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../controllers/courses_controller.dart';

class StudentExploreScreen extends GetView<CoursesController> {
  const StudentExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.primary : AppColors.background,
      appBar: AppBar(
        title: const Text('Explore Courses'),
        backgroundColor: isDarkMode ? AppColors.primaryDark : AppColors.primary,
        foregroundColor: AppColors.white,
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        if (controller.isLoadingCourses.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadCourses(),
          child: CustomScrollView(
            slivers: [
              // Search and Filters
              if (controller.courses.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildSearchAndFilters(context, isDarkMode),
                ),

              // Courses Grid
              if (controller.courses.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(context, isDarkMode),
                )
              else if (controller.filteredCourses.isEmpty)
                SliverFillRemaining(
                  child: _buildNoResults(context, isDarkMode),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final course = controller.filteredCourses[index];
                        return _buildCourseCard(context, course, isDarkMode)
                            .animate()
                            .fadeIn(delay: (index * 50).ms)
                            .slideY(begin: 0.1, end: 0);
                      },
                      childCount: controller.filteredCourses.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: isDarkMode ? AppColors.primary : AppColors.background,
      child: Column(
        children: [
          TextField(
            onChanged: (value) => controller.updateSearchQuery(value),
            decoration: InputDecoration(
              hintText: 'Search courses...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: isDarkMode ? AppColors.primaryDark : AppColors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: controller.selectedCategory.value,
                  isExpanded: true,
                  items: controller.getCategories().map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) controller.updateCategoryFilter(value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String>(
                  value: controller.selectedLevel.value,
                  isExpanded: true,
                  items: ['All', 'BEGINNER', 'INTERMEDIATE', 'ADVANCED']
                      .map((level) {
                    return DropdownMenuItem(value: level, child: Text(level));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) controller.updateLevelFilter(value);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore_outlined,
            size: 64,
            color: isDarkMode ? AppColors.greyLight : AppColors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No courses available',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isDarkMode ? AppColors.white : AppColors.black,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(BuildContext context, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: isDarkMode ? AppColors.greyLight : AppColors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No courses found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isDarkMode ? AppColors.white : AppColors.black,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, course, bool isDarkMode) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Get.toNamed('/student/courses/${course.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.onboardingContinue.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: course.thumbnailUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          course.thumbnailUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.book, size: 48);
                          },
                        ),
                      )
                    : const Icon(Icons.book, size: 48),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                            color: AppColors.onboardingContinue,
                          ),
                    ),
                    const Spacer(),
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
}

