import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class RecommendationScreen extends StatelessWidget {
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
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.recommend,
              size: 64,
              color: isDarkMode ? AppColors.greyLight : AppColors.grey,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms)
                .scale(delay: 100.ms),
            const SizedBox(height: 16),
            Text(
              AppStrings.recommendedCoursesListedHere,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? AppColors.greyLight : AppColors.grey,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 300.ms),
          ],
        ),
      ),
    );
  }
}

