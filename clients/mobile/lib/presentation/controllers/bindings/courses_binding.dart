import 'package:get/get.dart';
import '../courses_controller.dart';

class CoursesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CoursesController());
  }
}

