import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageListController extends GetxController {
  final searchController = TextEditingController();

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // TODO: Add RxList of conversations
}

