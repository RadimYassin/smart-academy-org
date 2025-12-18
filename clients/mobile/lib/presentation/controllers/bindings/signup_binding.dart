import 'package:get/get.dart';
import 'package:mobile/presentation/controllers/auth/signup_controller.dart';

class SignUpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignUpController>(() => SignUpController());
  }
}

