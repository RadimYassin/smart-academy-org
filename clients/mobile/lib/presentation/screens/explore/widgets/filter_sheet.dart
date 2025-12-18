import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../controllers/explore_controller.dart';

class FilterSheet extends GetView<ExploreController> {
  const FilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primary : AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // --- Header ---
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.filter,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppColors.white : AppColors.black,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 100.ms)
                    .slideX(begin: -0.1, end: 0, duration: 300.ms, delay: 100.ms),
                TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    AppStrings.cancel,
                    style: TextStyle(
                      color: AppColors.onboardingContinue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 200.ms)
                    .scale(delay: 200.ms),
              ],
            ),
          ),

          // --- Filter Options ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildRatingsSection(context, theme, isDarkMode),
                  const SizedBox(height: 8),
                  Divider(
                    color: isDarkMode
                        ? AppColors.border.withValues(alpha: 0.2)
                        : AppColors.border,
                  ),
                  const SizedBox(height: 8),
                  _buildTopicsSection(context, theme, isDarkMode),
                  const SizedBox(height: 8),
                  Divider(
                    color: isDarkMode
                        ? AppColors.border.withValues(alpha: 0.2)
                        : AppColors.border,
                  ),
                  const SizedBox(height: 8),
                  _buildLevelSection(context, theme, isDarkMode),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // --- Apply Button ---
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.applyFilters,
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
                  AppStrings.applyFilter,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 1200.ms)
              .slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 1200.ms),
        ],
      ),
    );
  }

  // --- Section Widgets ---

  Widget _buildRatingsSection(BuildContext context, ThemeData theme, bool isDarkMode) {
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 8),
        title: Text(
          AppStrings.ratings,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? AppColors.white : AppColors.black,
          ),
        ),
        initiallyExpanded: false,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                5,
                (index) {
                  final rating = index + 1;
                  return Obx(
                    () => IconButton(
                      icon: Icon(
                        rating <= controller.selectedRating.value
                            ? Icons.star
                            : Icons.star_outline,
                        color: AppColors.warning,
                        size: 32,
                      ),
                      onPressed: () {
                        controller.setRating(rating);
                      },
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms, delay: (400 + (index * 50)).ms)
                      .scale(delay: (400 + (index * 50)).ms);
                },
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 300.ms)
        .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 300.ms);
  }

  Widget _buildTopicsSection(BuildContext context, ThemeData theme, bool isDarkMode) {
    final topics = [
      AppStrings.design,
      AppStrings.finance,
      AppStrings.development,
    ];

    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 8),
        title: Text(
          AppStrings.topics,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? AppColors.white : AppColors.black,
          ),
        ),
        initiallyExpanded: true,
        children: List.generate(
          topics.length,
          (index) => _buildCheckbox(context, theme, topics[index], false, index + 4),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 500.ms)
        .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 500.ms);
  }

  Widget _buildLevelSection(BuildContext context, ThemeData theme, bool isDarkMode) {
    final levels = [
      AppStrings.beginner,
      AppStrings.intermediate,
      AppStrings.expert,
      AppStrings.professionals,
    ];

    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 8),
        title: Text(
          AppStrings.level,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? AppColors.white : AppColors.black,
          ),
        ),
        initiallyExpanded: false,
        children: List.generate(
          levels.length,
          (index) => _buildCheckbox(context, theme, levels[index], true, index + 7),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 700.ms)
        .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 700.ms);
  }

  // Helper for Checkboxes
  Widget _buildCheckbox(BuildContext context, ThemeData theme, String title, bool isLevel, int delayIndex) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Obx(
      () {
        final isSelected = isLevel
            ? controller.selectedLevels.contains(title)
            : controller.selectedTopics.contains(title);

        return CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? AppColors.white : AppColors.black,
            ),
          ),
          value: isSelected,
          onChanged: (bool? value) {
            if (isLevel) {
              controller.toggleLevel(title);
            } else {
              controller.toggleTopic(title);
            }
          },
          controlAffinity: ListTileControlAffinity.trailing,
          activeColor: AppColors.onboardingContinue,
        );
      },
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (delayIndex * 100).ms)
        .slideX(begin: -0.1, end: 0, duration: 400.ms, delay: (delayIndex * 100).ms);
  }
}

