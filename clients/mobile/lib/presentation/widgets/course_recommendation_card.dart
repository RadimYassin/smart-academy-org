import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/course/course.dart';
import '../routes/app_routes.dart';

class CourseRecommendationCard extends StatelessWidget {
  final Course course;

  const CourseRecommendationCard({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.courseDetails,
          arguments: {'courseId': course.id},
        );
      },
      child: Card(
        color: isDarkMode ? AppColors.primaryDark : AppColors.white,
        elevation: 2,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: course.thumbnailUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: course.thumbnailUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 120,
                        color: AppColors.greyLight.withValues(alpha: 0.2),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 120,
                        color: AppColors.greyLight.withValues(alpha: 0.2),
                        child: Icon(
                          Icons.school,
                          size: 48,
                          color: AppColors.grey,
                        ),
                      ),
                    )
                  : Container(
                      height: 120,
                      color: AppColors.greyLight.withValues(alpha: 0.2),
                      child: Icon(
                        Icons.school,
                        size: 48,
                        color: AppColors.grey,
                      ),
                    ),
            ),

            // Course Info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(course.category).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      course.category,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getCategoryColor(course.category),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Course Title
                  Text(
                    course.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? AppColors.white : AppColors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Course Description
                  Text(
                    course.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? AppColors.greyLight : AppColors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Level Badge
                  Row(
                    children: [
                      Icon(
                        _getLevelIcon(course.level),
                        size: 16,
                        color: _getLevelColor(course.level),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatLevel(course.level),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getLevelColor(course.level),
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

  /// Get color based on category
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'design':
        return Colors.purple;
      case 'development':
        return Colors.blue;
      case 'business':
        return Colors.orange;
      case 'marketing':
        return Colors.pink;
      case 'finance':
        return Colors.green;
      default:
        return AppColors.onboardingContinue;
    }
  }

  /// Get color based on level
  Color _getLevelColor(String level) {
    switch (level.toUpperCase()) {
      case 'BEGINNER':
        return Colors.green;
      case 'INTERMEDIATE':
        return Colors.orange;
      case 'ADVANCED':
        return Colors.red;
      default:
        return AppColors.grey;
    }
  }

  /// Get icon based on level
  IconData _getLevelIcon(String level) {
    switch (level.toUpperCase()) {
      case 'BEGINNER':
        return Icons.emoji_events_outlined;
      case 'INTERMEDIATE':
        return Icons.trending_up;
      case 'ADVANCED':
        return Icons.workspace_premium;
      default:
        return Icons.info_outline;
    }
  }

  /// Format level text
  String _formatLevel(String level) {
    return level[0].toUpperCase() + level.substring(1).toLowerCase();
  }
}
