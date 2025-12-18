import 'package:get/get.dart';
import '../dashboard_controller.dart';
import '../explore_controller.dart';
import '../profile_controller.dart';
import '../home_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ExploreController>(() => ExploreController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}

