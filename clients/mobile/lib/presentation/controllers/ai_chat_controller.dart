import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  final messageController = TextEditingController();
  final messages = <Message>[].obs;
  final isTyping = false.obs;

  @override
  void onInit() {
    super.onInit();
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

    // Add user message
    messages.add(Message(
      text: messageController.text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    ));
    final userMessage = messageController.text.trim();
    messageController.clear();

    // Simulate AI thinking
    isTyping.value = true;
    await Future.delayed(const Duration(seconds: 1));

    // Generate AI response (mock for now)
    final aiResponse = _generateAiResponse(userMessage);
    messages.add(Message(
      text: aiResponse,
      isUser: false,
      timestamp: DateTime.now(),
    ));

    isTyping.value = false;
  }

  String _generateAiResponse(String userMessage) {
    // Mock AI responses
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('course') || lowerMessage.contains('learn')) {
      return 'Great question! Let me help you find the perfect course. What topic interests you most?';
    } else if (lowerMessage.contains('hi') || lowerMessage.contains('hello')) {
      return 'Hello! I\'m here to help you with your learning journey. What would you like to know?';
    } else if (lowerMessage.contains('help')) {
      return 'I can help you with:\n• Finding courses\n• Learning recommendations\n• Answering questions\n• Study tips\nWhat would you like to know?';
    } else {
      return 'That\'s interesting! I\'m here to help you learn and grow. Could you tell me more about what you\'re looking for?';
    }
  }
}

