import 'package:get/get.dart';
import '../teacher_dashboard_controller.dart';
import '../courses_controller.dart';
import '../enrollment_controller.dart';
import '../progress_controller.dart';

class TeacherDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TeacherDashboardController());
    Get.lazyPut(() => CoursesController());
    Get.lazyPut(() => EnrollmentController());
    Get.lazyPut(() => ProgressController());
  }
}

