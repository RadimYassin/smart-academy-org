import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/logger.dart';
import '../../../domain/repositories/ai_chat_repository.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class AiChatController extends GetxController {
  late final AiChatRepository _aiChatRepository;
  
  final messageController = TextEditingController();
  final messages = <Message>[].obs;
  final isTyping = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _aiChatRepository = Get.find<AiChatRepository>();
    
    // Add welcome message
    messages.add(Message(
      text: 'Hello! I\'m your AI learning assistant. How can I help you today?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) return;

    final userMessage = messageController.text.trim();
    
    // Add user message
    messages.add(Message(
      text: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    messageController.clear();
    errorMessage.value = '';

    // Show typing indicator
    isTyping.value = true;

    try {
      // Call real AI API
      final aiResponse = await _aiChatRepository.askQuestion(userMessage);
      
      messages.add(Message(
        text: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      
      Logger.logInfo('AI response received successfully');
    } catch (e) {
      Logger.logError('AI chat error', error: e);
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      
      // Show error message to user
      messages.add(Message(
        text: 'I apologize, but I encountered an error: ${errorMessage.value}. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      isTyping.value = false;
    }
  }
}

