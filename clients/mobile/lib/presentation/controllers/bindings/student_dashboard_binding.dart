import 'package:get/get.dart';
import '../student_dashboard_controller.dart';
import '../courses_controller.dart';
import '../enrollment_controller.dart';
import '../progress_controller.dart';

class StudentDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StudentDashboardController());
    Get.lazyPut(() => CoursesController());
    Get.lazyPut(() => EnrollmentController());
    Get.lazyPut(() => ProgressController());
  }
}

