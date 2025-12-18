import 'package:get/get.dart';
import 'package:mobile/presentation/controllers/auth/signin_controller.dart';

class SignInBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignInController>(() => SignInController());
  }
}

