import 'package:get/get.dart';
import '../recommendation_controller.dart';

class RecommendationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecommendationController>(() => RecommendationController());
  }
}

