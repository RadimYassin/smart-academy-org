import 'package:get/get.dart';
import '../enrollment_controller.dart';

class EnrollmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EnrollmentController());
  }
}

