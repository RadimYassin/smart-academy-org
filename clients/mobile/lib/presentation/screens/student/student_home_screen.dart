import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../controllers/student_navigation_controller.dart';

class StudentHomeScreen extends GetView<StudentNavigationController> {
  const StudentHomeScreen({super.key});

  /// Get responsive label based on screen width
  String _getLabel(String fullLabel, String shortLabel, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < 360 ? shortLabel : fullLabel;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Body: Show the current screen based on the controller's tabIndex
      body: Obx(
        () => controller.screens[controller.tabIndex.value]
            .animate()
            .fadeIn(duration: 300.ms),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.primaryDark : AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom > 0 
                    ? 4 
                    : 8,
                top: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildNavItem(
                      context,
                      Icons.home,
                      Icons.home_outlined,
                      _getLabel('My Courses', 'Home', context),
                      0,
                      isDarkMode,
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      context,
                      Icons.explore,
                      Icons.explore_outlined,
                      'Explore',
                      1,
                      isDarkMode,
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      context,
                      Icons.chat_bubble,
                      Icons.chat_bubble_outline,
                      _getLabel('AI Chat', 'Chat', context),
                      2,
                      isDarkMode,
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      context,
                      Icons.person,
                      Icons.person_outline,
                      'Profile',
                      3,
                      isDarkMode,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
    int index,
    bool isDarkMode,
  ) {
    final theme = Theme.of(context);
    // Check if the current tab is selected
    final isSelected = controller.tabIndex.value == index;

    // Set color, icon, and font weight based on selection
    final color = isSelected
        ? AppColors.onboardingContinue
        : (isDarkMode ? AppColors.greyLight : AppColors.grey);
    final icon = isSelected ? activeIcon : inactiveIcon;
    final fontWeight = isSelected ? FontWeight.bold : FontWeight.normal;

    // Get screen width to adjust font size responsively
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 360 ? 9.0 : 10.0;
    final iconSize = screenWidth < 360 ? 20.0 : 22.0;

    return InkWell(
      onTap: () => controller.changeTabIndex(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: color,
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: fontWeight,
                  fontSize: fontSize,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

