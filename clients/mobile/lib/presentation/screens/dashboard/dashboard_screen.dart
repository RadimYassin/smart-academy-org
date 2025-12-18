import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../controllers/dashboard_controller.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

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

      // Floating Action Button: The central "Courses" button
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.changeTabIndex(2),
        backgroundColor: AppColors.onboardingContinue,
        child: const Icon(Icons.menu_book_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom Navigation Bar
      bottomNavigationBar: Obx(
        () => BottomAppBar(
          color: isDarkMode ? AppColors.primary : AppColors.background,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home, Icons.home_outlined, AppStrings.home, 0),
              _buildNavItem(context, Icons.search, Icons.search_outlined, AppStrings.explore, 1),
              const SizedBox(width: 48), // Spacer for the FAB
              _buildNavItem(context, Icons.favorite, Icons.favorite_border, AppStrings.wishlist, 3),
              _buildNavItem(context, Icons.person, Icons.person_outline, AppStrings.profile, 4),
            ],
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
  ) {
    final theme = Theme.of(context);
    // Check if the current tab is selected
    final isSelected = controller.tabIndex.value == index;

    // Set color, icon, and font weight based on selection
    final color = isSelected ? theme.primaryColor : theme.hintColor;
    final icon = isSelected ? activeIcon : inactiveIcon;
    final fontWeight = isSelected ? FontWeight.bold : FontWeight.normal;

    return InkWell(
      onTap: () => controller.changeTabIndex(index),
      borderRadius: BorderRadius.circular(20), // for ripple effect
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // IMPORTANT for BottomAppBar
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 2), // Space between icon and text
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: fontWeight,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

