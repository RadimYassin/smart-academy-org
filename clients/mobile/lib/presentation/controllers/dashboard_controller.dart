import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../screens/explore/explore_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/wishlist/wishlist_screen.dart';
import '../routes/app_routes.dart';

class DashboardController extends GetxController {
  final tabIndex = 0.obs;

  // List of screens for the tabs
  final List<Widget> screens = [
    const HomeScreen(),
    const ExploreScreen(),
    Container(), // Placeholder for the central button action
    const WishlistScreen(),
    const ProfileScreen(),
  ];

  void changeTabIndex(int index) {
    if (index == 2) {
      // Instead of printing, open the new recommendation page
      Get.toNamed(AppRoutes.recommendations);
      return; // Stop execution, do not change the tab index
    }
    tabIndex.value = index;
  }
}

