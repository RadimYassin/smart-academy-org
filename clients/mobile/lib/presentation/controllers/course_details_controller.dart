import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CourseDetailsController extends GetxController with GetSingleTickerProviderStateMixin {
  // Tab controller for About/Lessons/Reviews
  late final TabController tabController;

  final List<Tab> courseTabs = const <Tab>[
    Tab(text: 'About'),
    Tab(text: 'Lessons'),
    Tab(text: 'Reviews'),
  ];

  // Observable for "Show less/more"
  final isDescriptionExpanded = false.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(vsync: this, length: courseTabs.length);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void toggleDescription() {
    isDescriptionExpanded.value = !isDescriptionExpanded.value;
  }

  void buyCourse() {
    // TODO: Implement navigation to checkout
  }

  void toggleWishlist() {
    // TODO: Implement wishlist logic
  }
}

