import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController with GetSingleTickerProviderStateMixin {
  // Tab controller for Recent/Goals/Activity
  late final TabController tabController;

  final List<Tab> activityTabs = const <Tab>[
    Tab(text: 'Recent'),
    Tab(text: 'Goals'),
    Tab(text: 'Activity'),
  ];

  // Observable for dark mode toggle
  final isDarkMode = false.obs; // TODO: Link this to theme service

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(vsync: this, length: activityTabs.length);
    // TODO: Init isDarkMode from storage
    isDarkMode.value = Get.isDarkMode;
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    // TODO: Save theme choice to GetStorage
  }
}

