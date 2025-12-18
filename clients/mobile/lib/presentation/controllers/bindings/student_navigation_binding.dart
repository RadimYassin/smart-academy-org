import 'package:get/get.dart';
import '../student_navigation_controller.dart';
import 'student_dashboard_binding.dart';
import 'courses_binding.dart';
import 'ai_chat_binding.dart';
import 'profile_binding.dart';

class StudentNavigationBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize navigation controller
    Get.lazyPut(() => StudentNavigationController());
    
    // Initialize child controllers that will be used in the tabs
    StudentDashboardBinding().dependencies();
    CoursesBinding().dependencies();
    AiChatBinding().dependencies();
    ProfileBinding().dependencies();
  }
}

