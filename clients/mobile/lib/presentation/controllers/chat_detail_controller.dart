import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatDetailController extends GetxController {
  final messageController = TextEditingController();

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  void sendMessage() {
    if (messageController.text.isNotEmpty) {
      // TODO: Implement send message logic
      messageController.clear();
    }
  }
}

