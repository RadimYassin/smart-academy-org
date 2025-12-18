import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../screens/student/student_dashboard_screen.dart';
import '../screens/student/student_explore_screen.dart';
import '../screens/ai_chat/ai_chat_screen.dart';
import '../screens/profile/profile_screen.dart';

class StudentNavigationController extends GetxController {
  final tabIndex = 0.obs;

  // List of screens for the tabs
  final List<Widget> screens = [
    const StudentDashboardScreen(),
    const StudentExploreScreen(),
    const AiChatScreen(),
    const ProfileScreen(),
  ];

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }
}

