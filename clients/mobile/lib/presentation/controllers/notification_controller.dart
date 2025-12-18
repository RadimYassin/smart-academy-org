import 'package:get/get.dart';

enum NotificationCategory { promotions, system, orders, others }

class NotificationController extends GetxController {
  // Observable for the selected category
  final selectedCategory = NotificationCategory.promotions.obs;

  void selectCategory(NotificationCategory category) {
    selectedCategory.value = category;
    // TODO: Add logic to filter the list of notifications
  }
}

